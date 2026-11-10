local home = os.getenv("HOME")

local ok, c = pcall(dofile, home .. "/.config/hypr/colors.lua")
if not ok or type(c) ~= "table" then
    c = {
        primary = "cdd6f4",
        secondary = "b4befe",
        tertiary = "f5c2e7",
        outline = "595959",
        shadow = "000000",
    }
end

hl.monitor({ output = "eDP-1",    mode = "1366x768@60",    position = "0x0",    scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@9.95", position = "1366x0", scale = 1 })

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "rofi -show drun"
local mainMod     = "SUPER"

hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("/usr/bin/lxqt-policykit-agent")
    hl.exec_cmd("xwayland-sni-proxy")
    hl.exec_cmd("swayidle -w timeout 0 '' before-sleep 'hyprlock --config " .. home .. "/.config/hypr/hyprlock.conf'")
    hl.exec_cmd("hyprswitch init --show-title --size-factor 6 --workspaces-per-row 5")
    hl.exec_cmd("[workspace special:term silent] kitty --class scratchpad")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

hl.config({
    general = {
        resize_on_border = true,
        extend_border_grab_area = 15,
        hover_icon_on_border = true,
        allow_tearing = false,
    },

    dwindle = {
        preserve_split = true,
        force_split = 2,
        smart_resizing = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        focus_on_activate = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
    },

    debug = {
        vfr = true,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

local themes = home .. "/.config/hypr/themes/"
local ok, theme = pcall(dofile, themes .. "current.lua")
if not ok or type(theme) ~= "function" then
    theme = dofile(themes .. "zzz.lua")
end
theme(c)

hl.layer_rule({
    name = "no-anim-quickshell",
    match = { namespace = "quickshell" },
    no_anim = true,
})

hl.window_rule({
    name = "float-utilities",
    match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager|org.gnome.Calculator|polkit-gnome-authentication-agent-1|lxqt-policykit-agent)$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "float-dialogs",
    match = { title = "^(Open File|Save File|Save As|Choose Files|File Upload)$" },
    float = true,
    center = true,
    size = "700 500",
})

hl.window_rule({
    name = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    size = "400 225",
    move = "100%-410 100%-235",
})

hl.window_rule({
    name = "scratchpad-terminal",
    match = { class = "^(scratchpad)$" },
    workspace = "special:term",
    float = true,
    size = "900 450",
    center = true,
})

hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wallpaper-picker.sh"))
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("hyprswitch gui --mod-key super --key TAB"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("wlogout"))

hl.bind(mainMod .. " + V", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ exact = { 600, 700 } }))
end)

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + semicolon", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40,  y = 0,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + bracketleft",  hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + grave",     hl.dsp.workspace.toggle_special("term"))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m region --freeze"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m output --freeze"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.2 @DEFAULT_AUDIO_SINK@ 2%+ && echo vol > /tmp/qs_osd"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- && echo vol > /tmp/qs_osd"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && echo vol > /tmp/qs_osd"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 2%+ && echo bri > /tmp/qs_osd"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 2%- && echo bri > /tmp/qs_osd"), { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })