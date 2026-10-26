#!/usr/bin/env python3

import os
import re
import sys
import tempfile
import subprocess
from pathlib import Path
from datetime import date
from shutil import copyfileobj

# ---------------------------------------------------------------------------
# PATH DEFINITIONS (Scoped entirely inside ~/.config/scripts/todo)
# ---------------------------------------------------------------------------
TODO_DIR = Path.home() / ".config" / "scripts" / "todo"
TODO_DIR.mkdir(parents=True, exist_ok=True)

TODO = TODO_DIR / "todo.md"
SCHEDULE = TODO_DIR / "Schedule.md"
ARCHIVE = TODO_DIR / "archive"

DAILY_RE = re.compile(r"^(\d{4}-\d{2}-\d{2})-todo\.md$")
WEEKDAYS = (
    "Monday", "Tuesday", "Wednesday", "Thursday",
    "Friday", "Saturday", "Sunday",
)

class TodoError(Exception):
    pass

def atomic_write(path, content, replace=True):
    """Write a complete file before installing it at its final path."""
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent
    )
    temp = Path(temp_name)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as f:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())
        if replace:
            os.replace(temp, path)
        else:
            os.link(temp, path)
            temp.unlink()
        try:
            dir_fd = os.open(path.parent, os.O_RDONLY)
            try:
                os.fsync(dir_fd)
            finally:
                os.close(dir_fd)
        except OSError:
            pass
    finally:
        temp.unlink(missing_ok=True)

def read_file(path):
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise TodoError(f"{path} does not exist.")
    except (OSError, UnicodeError) as e:
        raise TodoError(f"Cannot read {path}: {e}")

def headings(text):
    """Find top-level Markdown headings, ignoring fenced code blocks."""
    result = []
    in_fence = False
    fence_char = ""
    fence_length = 0
    for i, line in enumerate(text.splitlines()):
        match = re.match(r"^\s*(`{3,}|~{3,})", line)
        if match:
            marker = match.group(1)
            if not in_fence:
                in_fence = True
                fence_char = marker[0]
                fence_length = len(marker)
            elif marker[0] == fence_char and len(marker) >= fence_length:
                in_fence = False
            continue
        if not in_fence and re.match(r"^# ", line):
            result.append((i, line.rstrip()))
    return result

def split_daily(text, filename):
    lines = text.splitlines()
    found = headings(text)
    work = [i for i, h in found if h == "# Work"]
    plan = [i for i, h in found if h == "# Plan"]

    # Defensive guard: if user modified headers, fall back safely
    if len(work) != 1 or len(plan) != 1 or work[0] >= plan[0]:
        print(f"⚠️  Note: {filename} headers missing or modified. Preserving content.", file=sys.stderr)
        return text.strip("\n")

    work_text = "\n".join(lines[work[0] + 1:plan[0]]).strip("\n")
    return work_text

def save_work(daily):
    """Save only today's Work content to todo.md."""
    content = split_daily(read_file(daily), daily.name)
    if content:
        content += "\n"
    atomic_write(TODO, content)
    print(f"Saved Work to {TODO}")

def ensure_todo():
    if not TODO.exists():
        default_content = (
            "# Work\n\n"
            "- [ ] Review [[LAC]]\n"
            "- [ ] Review [[IWT]]\n"
            "- [ ] Review [[FCS]]\n"
            "- [ ] Review [[SPC]]\n"
        )
        atomic_write(TODO, default_content, replace=False)
        print(f"Created default {TODO}")
    elif not TODO.is_file():
        raise TodoError(f"{TODO} exists but is not a regular file.")

def ensure_schedule():
    if not SCHEDULE.exists():
        default_schedule = "\n\n".join([f"# {day}\n- [ ] Focus block" for day in WEEKDAYS]) + "\n"
        atomic_write(SCHEDULE, default_schedule, replace=False)
        print(f"Created default {SCHEDULE}")

def get_schedule(day):
    ensure_schedule()
    text = read_file(SCHEDULE)
    target = f"# {day.strftime('%A')}"
    found = headings(text)
    matches = [i for i, heading in found if heading == target]
    if len(matches) != 1:
        raise TodoError(f"{SCHEDULE} must contain exactly one '{target}' heading.")
    lines = text.splitlines()
    start = matches[0] + 1
    end = len(lines)
    for index, heading in found:
        if index > matches[0]:
            end = index
            break
    return "\n".join(lines[start:end]).strip("\n")

def daily_path(day):
    return TODO_DIR / f"{day.isoformat()}-todo.md"

def archive_daily(source):
    """Archive a daily file, verify the copy, then remove the original."""
    ARCHIVE.mkdir(parents=True, exist_ok=True)
    destination = ARCHIVE / source.name
    original = source.read_bytes()
    if destination.exists():
        if destination.read_bytes() != original:
            raise TodoError(
                f"Archive conflict: {destination} differs from original. Both kept."
            )
    else:
        try:
            with source.open("rb") as src, destination.open("xb") as dst:
                copyfileobj(src, dst)
                dst.flush()
                os.sync()
        except FileExistsError:
            pass
        if not destination.exists() or destination.read_bytes() != original:
            raise TodoError(f"Archive verification failed for {source.name}.")
    source.unlink()
    print(f"Archived {source.name} to {ARCHIVE}")

def create_daily(day):
    path = daily_path(day)
    if path.exists():
        return path
    ensure_todo()
    work = read_file(TODO).strip("\n")
    plan = get_schedule(day)
    parts = ["# Work", ""]
    if work:
        parts.extend([work, ""])
    parts.extend(["# Plan", ""])
    if plan:
        parts.extend([plan, ""])
    content = "\n".join(parts).rstrip("\n") + "\n"
    try:
        atomic_write(path, content, replace=False)
    except FileExistsError:
        if not path.exists():
            raise
    except OSError as e:
        if not path.exists():
            raise TodoError(f"Could not create today's file: {e}")
    print(f"Created {path.name}")
    return path

def previous_daily(day):
    """Find the most recent earlier daily file inside the todo directory."""
    candidates = []
    for path in TODO_DIR.iterdir():
        match = DAILY_RE.fullmatch(path.name)
        if not match or not path.is_file():
            continue
        try:
            file_day = date.fromisoformat(match.group(1))
        except ValueError:
            continue
        if file_day < day:
            candidates.append((file_day, path))
    candidates.sort(reverse=True)
    return candidates[0][1] if candidates else None

def open_editor(path):
    editor = os.environ.get("EDITOR") or os.environ.get("VISUAL") or "nvim"
    try:
        result = subprocess.run([*editor.split(), str(path)], cwd=str(TODO_DIR), check=False)
    except FileNotFoundError:
        raise TodoError(f"Editor '{editor}' not found. Install Neovim or set $EDITOR.")
    if result.returncode != 0:
        raise TodoError(f"Editor exited with status {result.returncode}.")

def main():
    args = sys.argv[1:]
    if len(args) > 1 or (args and args[0] not in ("list", "time", "save")):
        print("Usage: todo [list|time|save]", file=sys.stderr)
        return 2
    try:
        command = args[0] if args else ""
        if command == "list":
            ensure_todo()
            open_editor(TODO)
            return 0
        if command == "time":
            ensure_schedule()
            open_editor(SCHEDULE)
            return 0
        if command == "save":
            today_file = daily_path(date.today())
            if not today_file.is_file():
                raise TodoError(f"Today's file ({today_file.name}) does not exist.")
            save_work(today_file)
            return 0

        today = date.today()
        today_file = daily_path(today)
        if not today_file.exists():
            old_file = previous_daily(today)
            if old_file:
                save_work(old_file)
                archive_daily(old_file)
            create_daily(today)
        open_editor(today_file)
        return 0
    except (TodoError, OSError, UnicodeError) as e:
        print(f"todo: {e}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("\ntodo: interrupted.", file=sys.stderr)
        return 130

if __name__ == "__main__":
    raise SystemExit(main())

