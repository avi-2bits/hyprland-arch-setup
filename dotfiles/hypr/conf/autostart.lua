-- ~/.config/hypr/conf/autostart.lua

local home = os.getenv("HOME")

local function run_daemon(proc_name, exec_str)
    local cmd = exec_str or proc_name
    hl.exec_cmd(string.format("pgrep -x %s >/dev/null || %s", proc_name, cmd))
end

hl.on("hyprland.start", function()
    -- 1. Sync Wayland Display Environment to D-Bus and Systemd
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- 2. Core User Services (Idempotent: won't duplicate on reload)
    run_daemon("waybar")
    run_daemon("mako")
    run_daemon("wl-clip-persist", "wl-clip-persist --clipboard regular")
    run_daemon("polkit-kde-authentication-agent-1", "/usr/lib/polkit-kde-authentication-agent-1")

    -- 3. Security: Idle Daemon
    run_daemon("swayidle", "swayidle -w")

    -- 4. Dynamic Theming & Wallpaper (Absolute path resolution)
    -- Disable the fade-in animation for swaybg instantly on startup
    hl.exec_cmd("hyprctl keyword layerrule 'noanim, swaybg'")

    -- Restore the last-set wallpaper without hardcoding any paths
    hl.exec_cmd(home .. "/.config/hypr/swaybg.sh")

    hl.exec_cmd(home .. "/.config/themes/apply.py")
end)

