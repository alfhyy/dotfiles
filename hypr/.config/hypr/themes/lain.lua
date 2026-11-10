return function(c)
    hl.config({
        general = {
            gaps_in = 3,
            gaps_out = { top = 6, right = 6, bottom = 6, left = 6 },
            border_size = 1,
            col = {
                active_border = "rgba(" .. (c.on_surface or c.primary) .. "ff)",
                inactive_border = "rgba(" .. c.outline .. "ff)",
            },
        },

        decoration = {
            rounding = 0,
            active_opacity = 0.92,
            inactive_opacity = 0.85,
            dim_inactive = false,
            shadow = {
                enabled = false,
            },
            blur = {
                enabled = false,
            },
        },
    })

    hl.config({ animations = { enabled = true } })

    hl.curve("settle", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1.0} } })

    hl.animation({ leaf = "windows",     enabled = true, speed = 3, bezier = "settle", style = "popin 96%" })
    hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2, bezier = "settle", style = "popin 96%" })
    hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "settle" })
    hl.animation({ leaf = "fade",        enabled = true, speed = 2, bezier = "settle" })
    hl.animation({ leaf = "border",      enabled = true, speed = 2, bezier = "settle" })
    hl.animation({ leaf = "workspaces",  enabled = true, speed = 3, bezier = "settle", style = "fade" })
end
