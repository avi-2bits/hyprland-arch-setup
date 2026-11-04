export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# COLORS & PROMPT (Matugen)
# ==============================================================================

setopt PROMPT_SUBST

reload_prompt_colors() {
    local colors="$HOME/.cache/matugen/colors-zsh.zsh"
    local mode_file="$HOME/.cache/matugen/mode"
    local mode="dark"

    [[ -f "$mode_file" ]] && mode=$(<"$mode_file")
    [[ "$mode" != "light" ]] && mode="dark"

    [[ -f "$colors" ]] && source "$colors"

    local -a palette
    local foreground background cursor selection_bg selection_fg

    if [[ "$mode" == "light" ]]; then
        palette=(
            "$MATUGEN_LIGHT_COLOR0"  "$MATUGEN_LIGHT_COLOR1"
            "$MATUGEN_LIGHT_COLOR2"  "$MATUGEN_LIGHT_COLOR3"
            "$MATUGEN_LIGHT_COLOR4"  "$MATUGEN_LIGHT_COLOR5"
            "$MATUGEN_LIGHT_COLOR6"  "$MATUGEN_LIGHT_COLOR7"
            "$MATUGEN_LIGHT_COLOR8"  "$MATUGEN_LIGHT_COLOR9"
            "$MATUGEN_LIGHT_COLOR10" "$MATUGEN_LIGHT_COLOR11"
            "$MATUGEN_LIGHT_COLOR12" "$MATUGEN_LIGHT_COLOR13"
            "$MATUGEN_LIGHT_COLOR14" "$MATUGEN_LIGHT_COLOR15"
        )

        foreground="$MATUGEN_LIGHT_FOREGROUND"
        background="$MATUGEN_LIGHT_BACKGROUND"
        cursor="$MATUGEN_LIGHT_CURSOR"
        selection_bg="$MATUGEN_LIGHT_SELECTION_BG"
        selection_fg="$MATUGEN_LIGHT_SELECTION_FG"

        color2="$MATUGEN_LIGHT_PRIMARY"
        on_primary="$MATUGEN_LIGHT_BACKGROUND"
    else
        palette=(
            "$MATUGEN_DARK_COLOR0"  "$MATUGEN_DARK_COLOR1"
            "$MATUGEN_DARK_COLOR2"  "$MATUGEN_DARK_COLOR3"
            "$MATUGEN_DARK_COLOR4"  "$MATUGEN_DARK_COLOR5"
            "$MATUGEN_DARK_COLOR6"  "$MATUGEN_DARK_COLOR7"
            "$MATUGEN_DARK_COLOR8"  "$MATUGEN_DARK_COLOR9"
            "$MATUGEN_DARK_COLOR10" "$MATUGEN_DARK_COLOR11"
            "$MATUGEN_DARK_COLOR12" "$MATUGEN_DARK_COLOR13"
            "$MATUGEN_DARK_COLOR14" "$MATUGEN_DARK_COLOR15"
        )

        foreground="$MATUGEN_DARK_FOREGROUND"
        background="$MATUGEN_DARK_BACKGROUND"
        cursor="$MATUGEN_DARK_CURSOR"
        selection_bg="$MATUGEN_DARK_SELECTION_BG"
        selection_fg="$MATUGEN_DARK_SELECTION_FG"

        color2="$MATUGEN_DARK_PRIMARY"
        on_primary="$MATUGEN_DARK_BACKGROUND"
    fi

    # Update the current Foot terminal palette.
    if [[ -t 1 && -w /dev/tty ]]; then
        local i
        for i in {1..16}; do
            printf '\e]4;%d;#%s\e\\' \
                "$((i - 1))" "${palette[$i]#\#}" > /dev/tty
        done

        printf '\e]10;#%s\e\\' "${foreground#\#}" > /dev/tty
        printf '\e]11;#%s\e\\' "${background#\#}" > /dev/tty
        printf '\e]12;#%s\e\\' "${cursor#\#}" > /dev/tty
        printf '\e]17;#%s\e\\' "${selection_bg#\#}" > /dev/tty
        printf '\e]19;#%s\e\\' "${selection_fg#\#}" > /dev/tty
    fi

    PROMPT=$'\n%K{${color2:-#828C6A}}%F{${on_primary:-#1e211b}} %~ %k%f %F{${color2:-#828C6A}}❯%f '
}

reload_prompt_colors

TRAPUSR1() {
    reload_prompt_colors
    zle && zle reset-prompt
}

# ==============================================================================
# 2. NAVIGATION & HISTORY
# ==============================================================================
# Instant directory jumping (type folder name directly without 'cd')
setopt AUTO_CD

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS       # Ignore duplicate consecutive commands
setopt HIST_IGNORE_SPACE      # Commands starting with space are not saved
setopt SHARE_HISTORY          # Share history across all open terminals
setopt HIST_VERIFY            # Show expanded history commands before executing

# ==============================================================================
# 3. COMPLETIONS (Fast & Case-Insensitive)
# ==============================================================================
autoload -Uz compinit
zstyle ':completion:*' menu select                      # Navigate completions with arrow keys
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colored completions matching ls
compinit -d ~/.zcompdump

# ==============================================================================
# 4. KEYBINDINGS (Prefix History Search)
# ==============================================================================
# Type a few letters and press Up/Down arrow to search matching commands
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search     # Up Arrow
bindkey '^[[B' down-line-or-beginning-search   # Down Arrow

# ==============================================================================
# 5. ALIASES
# ==============================================================================
alias ..="cd .."
alias c="clear"

# Always show human-readable sizes and colors
alias ls="ls --color=auto -F"
alias ll="ls -lah"
alias la="ls -A"

# Safer file operations (prompt before overwriting)
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -Iv"

alias swaybg.sh="$HOME/.config/hypr/swaybg.sh"
alias kew="TERM=foot-direct kew"
alias yt-cli="~/.config/scripts/yt-cli.sh"

# ==============================================================================
# 6. FUZZY FINDER & UTILITIES (FZF, MPV, CHAFA)
# ==============================================================================
# Load fzf fuzzy completion & keybindings (Ctrl+R, Ctrl+T, Alt+C)
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# MPV Media Player wrapper
mpvplay() {
    local url="$1"
    local quality="${2:-480}"
    if [ -z "$url" ]; then
        echo "Usage: mpvplay <URL> [quality_height (default: 480)]"
        return 1
    fi
    mpv \
        --msg-level=all=warn,ytdl_hook=error \
        --term-playing-msg="▶ Playing: \${media-title}" \
        --ytdl-raw-options=format-sort="res:${quality}" \
        "$url"
}

export CHAFA_DEFAULT_FORMAT=sixels
export CHAFA_DEVICE_CLASS=sixel

export PATH="$HOME/.npm-global/bin:$PATH"
