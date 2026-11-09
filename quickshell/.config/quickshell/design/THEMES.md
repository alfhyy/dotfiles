# Theme switching

## Command

`rice <theme>` (bin/.local/bin/rice) switches everything in one step. Running it twice is harmless.

## Source of truth

~/.local/state/rice/theme holds the active theme name. Every surface reads it. Nothing else stores theme state.

## Per surface

| Surface                                 | Mechanism                                                                                                                                             |
| --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Colors                                  | matugen regenerates every template. Each theme passes its own mode and scheme type (zzz: current settings; lain: dark, scheme-monochrome)             |
| Wallpaper                               | each theme remembers its own last wallpaper and restores it                                                                                           |
| Quickshell                              | one config. shell.qml watches the state file with FileView, and a Loader swaps Themes/Zzz and Themes/Lain. Core/ and Services/ are shared. No restart |
| Hyprland                                | hyprland.lua loads hypr/themes/<theme>.lua (gaps, borders, rounding, animations), then `hyprctl reload`                                               |
| kitty                                   | matugen colors plus a per-theme font include, reloaded with SIGUSR1                                                                                   |
| Neovim                                  | matugen-generated colorscheme, reloaded in running instances on FocusGained                                                                           |
| rofi, hyprlock, wlogout, fastfetch, GTK | per-theme config chosen by include or symlink                                                                                                         |

## Rules

- Switching never restarts Quickshell or logs out.
- Adding a third theme means adding folders, not editing switching logic.
- Behavior (workspaces, media, drawers, keybinds) is identical across themes. Only appearance changes.
