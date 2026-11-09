# ZZZ

This describes the rice as it exists on 2026-11-10, read from the code. Paths are as of the theme
switching refactor: zzz lives in Themes/Zzz/ and the per-theme files of each surface.
Where the code disagrees with CLAUDE.md or design/THEMES.md, the code is described as it is and the
disagreement is listed under "Deviations" at the end. Nothing here is aspirational.

## Concept

A comic-print desktop with a "Proxy" persona. Every surface is a flat slab of colour with a hard black
outline and a solid offset shadow, like a sticker or a printed panel lifted off the page. Halftone dots
supply texture. Type is heavy, wide and upper-case. Motion is springy and overshoots. Colour comes
from the wallpaper via matugen, so the rice has no fixed hue: what stays constant is the black stroke,
the offset slab and the type.

Mood: bold, punchy, tactile, playful, printed.
Avoid: blur, glass, soft drop shadows, thin type, gradients as decoration (exception: the deck art
panels, which are halftoned), grey-on-grey low contrast.

## Palette

Source: matugen from the current wallpaper, `--source-color-index 0`, default scheme type, mode read from
`~/.local/state/rice/zzz/mode` (currently `dark`; the profile deck's LIGHT/DARK pill runs
`rice --mode`). Switching settings: ~/.config/rice/themes/zzz.env.
Template: matugen/.config/matugen/templates/quickshell-colors.json → Services/colors.json → Services/Theme.qml.

| Token | matugen role | Current (dark) | Used for |
|---|---|---|---|
| ink | surface_container_lowest, tinted | #0a0f12 | Plate faces: rail, music, notifications, folded deck cards |
| ink_raised | surface_container_high, tinted +0.06 | #262a2e | Secondary chips, art backing, rail tape stripe, inactive pills |
| paper | on_surface | #e0e3e8 | Primary text on ink; halftone ink at low alpha |
| paper_dim | on_surface_variant | #c1c7ce | Secondary text, empty workspaces, timestamps |
| accent | primary | #95cdf7 | Offset slabs, gel pills, minutes, ring backgrounds, first action pill |
| accent_alt | tertiary | #cec0e8 | Orb level rings, power star, avatar slab while profile is open, standby wave |
| on_accent | on_primary | #00344e | Text on accent |
| line | outline | #8b9198 | Low-urgency notifications, dimmed rings |
| sheet | inverse_surface | #e0e3e8 | Inverted surfaces: calendar, the open deck card |
| sheet_ink | inverse_on_surface | #2d3135 | Text on sheet |
| sheet_mark | inverse_primary | #266489 | Accent on sheet: month, weekends, meters, subtitles |
| stroke | shadow | #000000 | Every outline, header strips, number shadows |
| accent_soft | primary_container | #004c6e | Deck tray art gradient, stroke_accent in light mode |
| on_accent_soft | on_primary_container | #c9e6ff | (defined, currently unused in QML) |
| danger | error | #ffb4ab | Low battery, critical notifications, meters over 85% |
| on_danger | on_error | #690005 | Text on danger |

Derived in Services/Theme.qml:

- `ink` and `ink_raised` are tinted toward `accent` (25% in dark mode, 18% in light; `ink_raised` +6%),
  because matugen's surfaces are near neutral and the wallpaper should show in the main colour.
- `light`: `ink.hslLightness > 0.5`.
- `on_stroke`: white. Text on the always-black header strips.
- `stroke_accent`: `accent` in dark mode, `accent_soft` in light. Accent text on black strips.

Inversion is the main emphasis device: the calendar and the open deck card use `sheet`, so they read as
the light card in dark mode and the dark card in light mode.

Other surfaces map the same scheme:

- Hyprland (templates/hypr-colors.lua): `primary`, `secondary`, `tertiary`, `outline`, `shadow`.
- kitty (templates/kitty-colors.conf): `surface` background, `on_surface` foreground,
  `secondary_fixed_dim` selection, `primary` for url and color4. The other 15 ANSI colours are fixed
  desaturated pastels in the template.
- Neovim (templates/nvim-colors.lua): base16 from surface containers, outline, primary, secondary,
  tertiary, error and custom green/yellow (config.toml `custom_colors`). Functions primary bold, keywords
  secondary bold, strings green italic, types tertiary italic, comments outline italic. Markdown headings
  ramp primary → secondary → tertiary → green → yellow → fg_dim.
- rofi: full M3 role set. Window `surface` with 2px `primary` border, selection `primary` / `on_primary`.
- GTK 3/4: `primary_fixed_dim` accent, `surface_dim` windows.

## Type

| Role | Font | Where |
|---|---|---|
| Display | Unbounded (UI.display; falls back through Syne, Krona One, Archivo Black, Rubik Mono One, then the icon font) | All labels, numerals, titles, the clock. Black weight almost everywhere |
| Body | Rubik (UI.body) | Notification summary (14 Black italic) and body (12 Medium), OS line, deck subtitles |
| Icons | JetBrainsMono Nerd Font (UI.icons) | Glyphs in orbs, pills, buttons |
| Terminal / launcher | JetBrainsMono Nerd Font | kitty 11.5, rofi 9, hyprswitch 12, hyprlock clock 100 |
| GTK | SF Pro Text, weight 500 | GTK apps |

Conventions:

- `//@ pragma NativeTextRendering` in shell.qml: hinted native glyphs. Text that moves is snapped to whole
  pixels (drawer slide, marquee) to avoid shimmer.
- Upper case for every label. Numbers zero-padded to two digits: workspaces `01`–`05`, the calendar day
  `09`, deck cards `01`–`03`, notification badge `07`.
- Small labels are tracked out: header strips 1.5–3, workspaces 1.
- Sizes in use: 8–12 for labels and meta, 18 for clock and track title, 34 for deck numbers, 58 for the
  battery number, 62 for the calendar day.
- Italic is reserved for a few highlights: calendar month, notification summary, OS name on the deck.

## Shape language

- **Plate** (Themes/Zzz/Kit/Plate.qml): the base surface. A face filled `ink` (or `sheet`), two offset layers behind
  it (`tone` at +4px, `tone` darkened 1.5× at +2px; UI.depth = 4) and an outline drawn above the content
  so nothing paints over it. Rail edge 2px; music drawer edge 3px.
- **Gel** (Themes/Zzz/Kit/Gel.qml): a solid chip with a 2px `stroke` border. Pills, the workspace indicator, orb
  centres, the today marker, buttons.
- **Halftone** (Themes/Zzz/Kit/Halftone.qml): staggered dots that shrink toward the bottom. pitch 4, rmax 1.5 by
  default. paper at 16% on the rail, 7–10% on cards; stroke at 22% on deck art panels.
- Corners: square by default (rail, header strips, close boxes, cover art, art panels; Hyprland rounding 0).
  Rounded only where stated: notification cards 4, deck cards 10, pills fully round.
- Hard offset slabs instead of shadows, always down-right.
- Tilt: the rail avatar and cover art sit at −4°, tray stickers at −6°; they straighten on hover.
- Black header strips (26px) carry an accent square badge on the left and a stamp on the right
  (calendar, notifications).
- Ornaments in use: the diagonal tape stripe across the lower rail (`ink_raised`, −38°), the 8-point power
  star (two 20px squares at 0° and 45°), segmented meters, halftone.

## Components

### Rail (Themes/Zzz/Strip/Strip.qml)

Left edge of every screen. Margins 5 top/left/bottom, width 60 + 4 depth, exclusive zone 64.
Inner box model: 2 edge + 6 padding, inner width 44.

Top to bottom:

1. **Avatar**: 32×32 `~/.face`, stroke border, offset slab (`accent`, `accent_alt` while the profile
   drawer is open), tilted −4°. Click opens the profile deck.
2. **Workspaces** (y 56): five 30px cells labelled `01`–`05`. Colours: active `on_accent`, occupied
   `accent`, empty `paper_dim`. The active marker is a Gel pill that stretches toward the new workspace
   (the leading edge uses `fast`, the trailing edge `spatial`). Click or drag focuses, middle-click moves
   the window, wheel steps (120ms throttle).
3. **Lane** (centred between workspaces and the bottom group): 36px cover art, tilted, with an accent
   slab; vertical title (display 12 Black, `paper`) and artist (display 9 Bold, `accent`), each up to 150px
   and ping-pong scrolling when longer. Dimmed to 55% when paused. Click opens the music drawer,
   right-click plays/pauses, wheel skips tracks (400ms throttle). The cover pops on track change.
4. **Bottom group**, spacing 0:
   - Orbs, 38px tall: network (no ring; dim when offline, opens nm-connection-editor), volume (ring =
     level, click mutes, wheel ±5%, ring pops on change), battery (ring = charge, `danger` when low, opens
     the battery drawer). Orb: 24px Gel centre, 34px dial, 2.5px ring at radius 15.5 with a round cap.
   - Clock: hours in `paper`, minutes in `accent`, display 18 Black, stacked. Minutes pop when they change.
     Click opens the calendar.
   - Power: the `accent_alt` 8-point star with an `ink` power glyph; rotates 45° on hover; runs wlogout.

### Drawers (Themes/Zzz/Strip/Drawer.qml)

Panels that slide out of the rail at x = 73, vertically centred on the item that opened them and clamped
to the screen. They open with a 40px slide plus fade on the `spatial` curve. Each is built once and kept
mapped: when closed it is transparent and click-through. A Hyprland focus grab closes it on outside
click, and a 250ms guard stops the same click from reopening it. One drawer at a time.

- **Profile deck** (Themes/Zzz/Strip/Profile.qml): three numbered cards, 320 tall. The open card is 300 wide and
  `sheet`-filled; folded cards are 84 wide and `ink`. The deck's total width is fixed, and cards trade
  width on the `spatial` curve. Each card has a framed art panel (140 tall) with its number stamped
  bottom-left (display 34 Black, white with a 2px black offset copy; scaled to 0.72 when folded) and an
  arrow chip top-right (↗ folded, → on hover, ↘ open). Below it: the title (display 12 Black) and a
  subtitle (Rubik 11 Bold). Page content fades in at full width as the card opens. Folded cards lift
  5px on hover.
  - `01 <USER>`: `~/.face` art; OS name, kernel; WALL / LIGHT-DARK / LOCK pills.
  - `02 STATS`: accent→accent_alt gradient with halftone; uptime subtitle; CPU / MEM / DISK / TEMP as
    10-segment meters, polled every 2s while open.
  - `03 TRAY`: accent_alt→accent_soft gradient with up to three app stickers; subtitle `N APPS`. Page: a
    hover label and 44px round stickers (left-click activate, right-click menu, middle-click secondary,
    wheel scroll). With no tray items the card says `ALL QUIET`, dims to 55% and can't be opened.
- **Calendar** (290×322, `sheet`): black header `CALENDAR` + year; big day number; italic month; Monday-first
  grid with weekends in `sheet_mark`; one today pill. The wheel changes month; clicking the big day
  returns to today.
- **Music** (372×188, `ink`, edge 3): `NOW PLAYING` / `PAUSED` / `STANDBY`; 96px cover; title display 18;
  artist; a 28×7 dot-matrix spectrum (libcava in-process, only while this drawer is open; a breathing idle
  wave when there is no player); a squiggle progress bar (sine wave up to the playhead, flat after, pill
  thumb; the wave flattens when paused; click to seek); elapsed/length; prev / play / next Gels.
- **Battery** (≥150×104): `BATTERY` / `CHARGING` / `LOW BATTERY`; a 58px "bubble" number built from glyph
  paths (8px round-joined black stroke, offset shadow copy, white rim), filled `stroke_accent` or
  `danger`; a black `%` pill with a bolt while charging.

### Notifications (Themes/Zzz/Notif/, server in Services/Notifs.qml)

Top-right overlay on the focused monitor, 5px margin, 340-wide cards stacked newest-first with 10px gaps.

- Card: Plate radius 4, faint halftone, offset slab in the urgency colour (`accent`, `line` for low,
  `danger` for critical).
- Header strip: black (or `danger` when critical); badge square with the id mod 100 (`!!` when critical);
  app name; age stamp `NOW` / `5M` / `2H`; square close box.
- Body: a 46px framed icon, summary, body (markup and links, 3 lines max).
- Actions: Gel pills, the first one filled.
- Countdown: 10 segments that drop one by one.
- Hover pulls the card 6px toward the screen and pauses the countdown. Right-click dismisses.
- Timeouts: low 4s, normal 6.5s, critical never, or the app's own value.
- Enter: slide in from 380px on `spatial` plus fade. Leave: slide out on `fast`. Others reflow on `spatial`.
- Server: persistence, markup, links, actions and images are all supported. Low battery (≤20%, once per
  discharge) is raised through it.

### Theme change: the liquid pour (Themes/Zzz/Kit/Liquid.qml)

When colors.json changes (matugen post_hook `qs ipc call theme reload`, or the file watcher), every visible
window snapshots its old look, the colours swap once 50ms later, and the snapshot drains downward behind
a wobbly liquid front with drips and a glossy edge (620ms). Colours are never animated binding-by-binding.
This is the signature moment.

## Motion

Curves (Themes/Zzz/Kit/Style.qml, bound into Core/UI.qml's motion slots by Themes/Zzz/Shell.qml),
always through `Anim` / `CAnim`:

| Name | Duration | Bezier | Feel | Used for |
|---|---|---|---|---|
| spatial | 500ms | 0.38, 1.21, 0.22, 1 | settles with overshoot | drawers, position, list moves, deck width |
| fast | 350ms | 0.42, 1.67, 0.21, 0.9 | strong spring | hover scale/tilt, presses, pop return |
| effects | 200ms | 0.34, 0.8, 0.34, 1 | quick, no overshoot | opacity, colour, pop peak |

Patterns:

- **Pop**: scale to a peak (1.12–1.25) on `effects`, back to 1 on `fast`. Fired by real events: glyph
  change, minute tick, track change, notification arrival, battery value.
- Hover grows to 1.06–1.1; press shrinks to 0.9–0.92; tilted items straighten on hover.
- Nothing animates when nothing changes, with two exceptions: the title marquee while music plays, and
  the music drawer while it is open.

Hyprland matches the bar:

- Windows open with an `overshot` bezier (0.13, 0.99, 0.29, 1.05), style `gnomed`.
- Workspaces slide on `overshot`.
- Window close slides to the bottom on `ease`.
- Quickshell layers have no compositor animation, since Quickshell animates itself.

## Hyprland (hypr/.config/hypr/themes/zzz.lua, loaded by hyprland.lua)

Windows get the same slab language as the bar:

- Border: 2px, black `shadow` on every window.
- Shadow: sharp, range 2, offset 2 2, `primary` when active and `outline` when inactive. This gives a 4px
  slab down-right, matching UI.depth.
- Rounding 0, blur off.
- Gaps: in 4; out top 5, right 9, bottom 9, left 4. This lines windows up with the rail's 5px margin and
  4px slab.

hyprland.conf in the same folder is the old, fully commented-out config. hyprland.lua is the live one.

## Other surfaces

- kitty: JetBrainsMono Nerd Font 11.5, padding 8, no decorations or tab bar, block cursor with a trail.
- Neovim: matugen base16 colorscheme, reloaded on SIGUSR1; rounded float borders; lualine with round
  section separators.
- rofi: centred 550px launcher, rounded 16/12/8, 2px `primary` border, JetBrainsMono 9.
- hyprlock: fixed image with blur, white pill input, JetBrainsMono clock at 100px. Not themed by matugen.
- fastfetch: kitty-protocol image logo (`rei.jpg`), `†` title key, keys in ANSI blue.
- wlogout: no config in the repo (the folder is empty).

## Preferences

From CLAUDE.md:

- eDP-1 at 1366×768 is the primary screen and the hard constraint; HDMI-A-1 is 2560×1440.
- Colours only from matugen tokens.
- No polling timers, idle animation, blur, ShaderEffect or blur layer rules.
- Animations through Anim/CAnim with the theme's curves, never linear.
- Text under 14px in the mono or pixel font; every label has a fixed width and elides.
- Shared code in Core/ and Services/; a theme folder holds only what differs.
- No explanatory inline comments.
- zzz: bottom-group spacing at −6; orb ring at its current size.
- Hyprland dispatch strings in Lua syntax.
- Verify with `qs log`, a grim screenshot of eDP-1 and `rice lain` / `rice zzz`.

Stated in conversation:

- The goal is a rice that would stand out on r/unixporn: cohesive, with at least one signature moment.
  Bold ideas are welcome if they match the theme.
- The profile drawer should follow a three-card reference (numbered tall cards, art on top, title below,
  arrow top-right, one contrasting card), translated into this theme's outlines and slabs. It replaced the
  earlier single "PROXY PROFILE" ID card.
- The tray lives in the profile deck as its own page, and it must never open onto a blank page.
- Resource use matters: work should stop when nothing is visible or changing.

## Deviations

Where the code currently disagrees with CLAUDE.md or design/THEMES.md:

- **Only zzz exists.** The switching machinery is built (rice, the state file, Themes/<Name>, per-surface
  themes/ files), but there is no lain yet: no Themes/Lain, no lain.env, no lain surface files, so
  `rice lain` refuses. wlogout and GTK have no per-theme files.
  The lain design sits at the quickshell root (DESIGN.md), not at design/lain/DESIGN.md.
- **There is no design/zzz/refs folder.** The deck's three-card reference image only exists in conversation.
- **Bottom-group spacing is 0, not −6** (Themes/Zzz/Strip/Strip.qml).
- **ShaderEffect:** Kit/Liquid.qml (theme pour), Strip/Music.qml (squiggle progress) and
  Kit/Halftone.qml (the dots, moved from Canvas to a shader for performance) all use ShaderEffect.
- **Timers and idle animation:**
  - Profile meters poll every 2s while open.
  - The music standby wave ticks every 120ms while the drawer is open with no player.
  - The music drawer runs a per-frame FrameAnimation while playing.
  - The title marquee steps on a Timer while playing.
  - Notifications count down on a Timer.
- **Linear or non-Anim motion:**
  - The marquee moves in linear 1px steps.
  - Liquid uses its own NumberAnimation with a custom bezier.
  - VText's original pauses were replaced by Timer intervals.
- **Hex literals:**
  - Services/Theme.qml fallback colours and `on_stroke` `#ffffff`; Battery's `"white"` rim.
  - hyprland.lua fallback palette.
  - kitty template ANSI colours and matugen `custom_colors`.
  - hyprlock `rgb()` values.
- **Blur:** layer rules for wlogout, rofi and `quickshell:overview` (no such Quickshell layer exists);
  hyprlock background blur.
- **Small text in display/body fonts:** most labels are Unbounded or Rubik at 8–13px. No pixel font is
  installed (Departure Mono is absent).
- **Unfixed widths:** many labels size to their text with no width or elide: the clock, workspace
  labels, calendar header and month, music and battery status labels, notification stamps. The deck
  titles and subtitles, notification text and music title/artist do have fixed widths and elide.
- **Inline comments:** throughout the QML, Lua and shaders.
- **Dead hooks:** volume and brightness keybinds write `/tmp/qs_osd`, but nothing in Quickshell reads it
  (there is no OSD).
- **Off-theme rounding:** rofi (16/12/8), Neovim floats and the GTK font (SF Pro) don't share the
  zzz shape and type language.
