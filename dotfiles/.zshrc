export PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# 1. COLORS & PROMPT (Moss Green Box)
# ==============================================================================
autoload -U colors && colors
setopt PROMPT_SUBST

# Source dynamic prompt theme (with fallback if missing)
if [[ -f ~/.config/themes/output/prompt.zsh ]]; then
    source ~/.config/themes/output/prompt.zsh
else
    PROMPT=$'\n%K{65}%F{235} %~ %k%f %F{65}❯%f '
fi

# Reload prompt dynamically if the theme file changes
precmd() {
    [[ -f ~/.config/themes/output/prompt.zsh ]] && source ~/.config/themes/output/prompt.zsh
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
#=================
#==============================================================
# Load fzf fuzzy completion & keybindings (Ctrl+R, Ctrl+T, Alt+C)
#===============================================================================
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# mpv stuff
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

