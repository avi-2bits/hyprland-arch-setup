#!/usr/bin/env bash

# Dependencies check
for cmd in yt-dlp fzf mpv; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed." >&2
    exit 1
  fi
done

# 1. Get search query (from arguments or interactive prompt)
query="$*"
if [[ -z "$query" ]]; then
  read -r -p "Enter YouTube Search: " query
fi

[[ -z "$query" ]] && { echo "No search query provided. Exiting."; exit 1; }

echo "Searching YouTube for: '$query'..."

# 2. Fetch top 25 results using yt-dlp
results=$(yt-dlp "ytsearch25:$query" \
  --flat-playlist \
  --ignore-errors \
  --no-warnings \
  --print "%(title)s [%(duration_string)s] :: https://youtu.be/%(id)s")

if [[ -z "$results" ]]; then
  echo "No results found."
  exit 1
fi

# 3. Select video via fzf
selected_video=$(echo "$results" | fzf \
  --prompt="Select Video > " \
  --header="Use Tab/Arrow keys to navigate, Enter to select" \
  --reverse \
  --delimiter=" :: " \
  --with-nth=1)

[[ -z "$selected_video" ]] && exit 0

# Extract URL from selection
video_url="${selected_video##* :: }"

# 4. Select Video Quality (720p prioritized at top)
quality_choice=$(cat <<'EOF' | fzf --prompt="Select Quality > " --reverse --no-sort --header="Enter to select resolution"
720p
1080p
480p
360p
Best Available
Audio Only
EOF
)

[[ -z "$quality_choice" ]] && exit 0

# Map choice to yt-dlp format strings for mpv
case "$quality_choice" in
  "720p")
    ytdl_format="bestvideo[height<=720]+bestaudio/best[height<=720]"
    ;;
  "1080p")
    ytdl_format="bestvideo[height<=1080]+bestaudio/best[height<=1080]"
    ;;
  "480p")
    ytdl_format="bestvideo[height<=480]+bestaudio/best[height<=480]"
    ;;
  "360p")
    ytdl_format="bestvideo[height<=360]+bestaudio/best[height<=360]"
    ;;
  "Best Available")
    ytdl_format="bestvideo+bestaudio/best"
    ;;
  "Audio Only")
    ytdl_format="bestaudio/best"
    ;;
esac

# 5. Play with mpv (terminal input disabled to prevent key leakage)
echo "Launching mpv ($quality_choice)..."

# Common MPV flags to suppress terminal warnings and input capturing
MPV_OPTS=(
  --no-terminal                # Disables terminal control and disables standard input
  --osc                        # Keeps On-Screen Controller working inside the player GUI
  --ytdl-format="$ytdl_format"
)

if [[ "$quality_choice" == "Audio Only" ]]; then
  # For audio-only, keep the terminal but run cleanly without input hooks
  mpv --ytdl-format="$ytdl_format" "$video_url" < /dev/null
else
  # Redirect stdin to /dev/null so no keystrokes are grabbed by the terminal
  mpv "${MPV_OPTS[@]}" "$video_url" < /dev/null
fi

