#!/usr/bin/env bash
set -e

THEME_DIR="$HOME/.config/hypr/themes"
PALETTE_DIR="$THEME_DIR/palette-files"
ACTIVE_DIR="$THEME_DIR/active"

mkdir -p "$ACTIVE_DIR"

# 1. Select Theme via Rofi
selected_theme=$(find "$PALETTE_DIR" -maxdepth 1 -name "*.theme" -exec basename {} .theme \; | rofi -dmenu -i -p "Select Theme:")
[[ -z "$selected_theme" ]] && exit 0

theme_file="$PALETTE_DIR/${selected_theme}.theme"
[[ ! -f "$theme_file" ]] && exit 1
source "$theme_file"

# ==========================================
# HYPRLAND BORDER CONTRAST LOGIC
# ==========================================
if [[ "$selected_theme" == *"-light"* ]] || [[ "$selected_theme" == "moss" ]]; then
    # Light Themes: Active = DARK, Inactive = LIGHT
    hyprctl keyword general:col.active_border "rgba(${color_fg}ff)"
    hyprctl keyword general:col.inactive_border "rgba(${color_bg}ff)"
else
    # Dark Themes: Active = BRIGHT/ACCENT, Inactive = MUTED DARK
    hyprctl keyword general:col.active_border "rgba(${color_accent}ff)"
    hyprctl keyword general:col.inactive_border "rgba(32302fff)"
fi

# ==========================================
# 2. WRITE FOOT CONFIG
# ==========================================

if [[ "$selected_theme" == *"-light"* ]] || [[ "$selected_theme" == "moss" ]]; then
    foot_section="colors-light"
else
    foot_section="colors-dark"
fi

cat <<EOF > "$ACTIVE_DIR/foot-colors.ini"
# Generated for $theme_name
[$foot_section]
background=$color_bg
foreground=$color_fg
regular0=$color0
regular1=$color1
regular2=$color2
regular3=$color3
regular4=$color4
regular5=$color5
regular6=$color6
regular7=$color7
bright0=$color8
bright1=$color9
bright2=$color10
bright3=$color11
bright4=$color12
bright5=$color13
bright6=$color14
bright7=$color15
EOF

# ==========================================
# 3. BROADCAST TO RUNNING TERMINALS
# ==========================================

for pt in /dev/pts/[0-9]*; do
    printf "\033]10;#%s\033\\" "$color_fg" > "$pt" 2>/dev/null || true
    printf "\033]11;#%s\033\\" "$color_bg" > "$pt" 2>/dev/null || true
    printf "\033]4;0;#%s\033\\" "$color0" > "$pt" 2>/dev/null || true
    printf "\033]4;1;#%s\033\\" "$color1" > "$pt" 2>/dev/null || true
    printf "\033]4;2;#%s\033\\" "$color2" > "$pt" 2>/dev/null || true
    printf "\033]4;3;#%s\033\\" "$color3" > "$pt" 2>/dev/null || true
    printf "\033]4;4;#%s\033\\" "$color4" > "$pt" 2>/dev/null || true
    printf "\033]4;5;#%s\033\\" "$color5" > "$pt" 2>/dev/null || true
    printf "\033]4;6;#%s\033\\" "$color6" > "$pt" 2>/dev/null || true
    printf "\033]4;7;#%s\033\\" "$color7" > "$pt" 2>/dev/null || true
done

notify-send "Terminal Theme" "Switched to $theme_name"

