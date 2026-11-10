# Dotfiles

Arch Linux, Hyprland 0.55 (Lua config), Quickshell, matugen, kitty, zsh + Powerlevel10k, Neovim.
Screens: eDP-1 1366x768 (primary, the hard constraint) and HDMI-A-1 2560x1440.
Managed with GNU stow: every top-level folder mirrors $HOME. Edit files in this repo.

## Themes

Two themes: `zzz` (current) and `lain`.

- Read design/THEMES.md before touching anything related to theme switching.
- Read design/<theme>/DESIGN.md and look at every image in design/<theme>/refs before any visual change to that theme.

## Hard rules

- Colors only from matugen tokens. No hex literals in QML, Lua, kitty or nvim config.
- No polling timers, no idle animation, no blur, no ShaderEffect, no blur layer rules.
- Animations use the Anim/CAnim components and the curves in UI.qml, never linear.
- Text under 14px uses the mono or pixel font. Every label has a fixed width, elides, and never overflows its container.
- Shared code lives in Core/ and Services/. A theme folder contains only what differs. Never copy a component between themes.
- No explanatory inline comments in code.
- zzz: keep the bottom-group spacing at -6 and the orb ring at its current size.
- Hyprland dispatch strings use Lua syntax: hl.dsp.focus({ workspace = n }).
- Never read or commit secrets. Never touch ~/.ssh, ~/.gnupg or browser profiles.

## Verify every change

1. `qs log --tail 50` shows no errors or warnings.
2. `grim -o eDP-1 /tmp/shot.png`, then read the screenshot and compare it against the refs.
3. It fits and stays readable at 1366x768.
4. After any theme-related change, run `rice lain` then `rice zzz` and confirm nothing from one theme leaks into the other.

## Workflow

Use plan mode for anything visual. One component per change. Commit after each working step.
