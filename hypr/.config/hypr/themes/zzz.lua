return function(c)
    hl.config({
        general = {
            -- aligned to the quickshell bar: 5px margin (Strip margins), +4px depth slab on bottom/right; left gap = slab→face spacing between windows
            gaps_in = 4,
            gaps_out = { top = 5, right = 9, bottom = 9, left = 4 },
            border_size = 2,
            -- black stroke on every window like quickshell's Plate; focus shows via the slab colour
            col = {
                active_border = "rgba(" .. c.shadow .. "ff)",
                inactive_border = "rgba(" .. c.shadow .. "ff)",
            },
        },

        decoration = {
            rounding = 0,
            rounding_power = 2,
            active_opacity = 1.0,
            inactive_opacity = 1.0,
            dim_inactive = false,

            -- hard offset slab = quickshell Plate's 3D layer: range 2 + offset 2 → 0px top-left, 4px (UI.depth) bottom-right
            shadow = {
                enabled = true,
                sharp = true,
                range = 2,
                offset = "2 2",
                color = "rgba(" .. c.primary .. "ff)",
                color_inactive = "rgba(" .. c.outline .. "ff)",
            },

            blur = {
                enabled = false,
            },
        },
    })

    hl.config({ animations = { enabled = true } })

    hl.curve("ease",     { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })
    hl.curve("overshot", { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.05} } })

    hl.animation({ leaf = "windows",     enabled = true, speed = 5, bezier = "overshot", style = "gnomed" })
    hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5, bezier = "ease",     style = "slide bottom" })
    hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "overshot", style = "slide" })
    hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "ease" })
    hl.animation({ leaf = "border",      enabled = true, speed = 2, bezier = "ease" })
    hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "overshot", style = "slide" })

    hl.layer_rule({
        name = "blur-wlogout",
        match = { namespace = "logout_dialog" },
        blur = true,
    })

    hl.layer_rule({
        name = "blur-quickshell-overview",
        match = { namespace = "quickshell:overview" },
        blur = true,
        ignore_alpha = 0.1,
    })

    hl.layer_rule({
        name = "blur-rofi",
        match = { namespace = "rofi" },
        blur = true,
        ignore_alpha = 0.1,
    })
end
