# LAIN

## Concept

The desktop is NAVI, Lain's computer: a terminal that looks into the Wired. Quiet, cold, slightly wrong. It never shouts, and things feel observed. Cyber goth through restraint: black, bone white, grey, and one thin vein of red.

Mood: quiet, eerie, humming, clinical, haunted, analog.
Never: neon, glossy, playful, loud, busy, rounded, colorful.

## Palette (matugen, dark mode, default scheme)

The palette follows the wallpaper. Not monochrome: a wallpaper change must be visible in the bar, not only in the window border.

- ink: background, near black, faintly tinted by the wallpaper
- ink_raised: panel fill, barely lighter than ink
- paper: primary text, bone white
- paper_dim: secondary text
- line: hairlines, grids and legends, low contrast
- accent: the wallpaper's colour. Used only for marks: the active layer block, an inverted legend (hover or open drawer), lit level ticks, today in the calendar, the focused window border. Text on it uses on_accent. Never for body text or fills larger than a mark.
- error: alerts only (low battery, mute, failure), plus the NAVI caret. Never bulk decoration.

Emphasis comes from inversion (an accent block with on_accent text), hollow outline text and size.

## Type

- Display: thin or regular wide grotesk in caps, tracked out, 18px and up only (Archivo Expanded or similar)
- System: pixel font, Departure Mono, for labels, numerals, prompts and status lines
- Body: JetBrains Mono, 10–11px
- Texture: Noto Sans JP katakana, outlined or low opacity, never carrying information
- Hollow outline text for big numerals and headlines

## Layout

- Square corners everywhere. Radius 0.
- 1px hairline frames. Panels sit on a visible grid; the gaps are part of the design.
- Every panel carries a small corner label in the system font: LAYER:01, NAVI, NET, AUDIO, SIG.
- Generous empty space. Density lives in drawers, the lock screen, fastfetch and the wallpaper, never the bar.
- Ornaments, at most two per panel: perspective grid lines, crosshair +, tick rulers, barcode, hatched stripe, dotted leaders, `>>` prompt, wireframe ellipse or cylinder, power-line and wire curves.
- Images are grayscale with a dither or halftone treatment.

## Vocabulary

- Workspaces are layers: LAYER:01 to LAYER:05.
- The clock sits under PRESENT DAY / PRESENT TIME.
- The system is NAVI.
- Status reads like a log: `>> NET ........ CONNECTED`, `>> BAT ........ 18% LOW`.
- Copy is terse, never cute. No emoji.

## Motion: quiet

- Emphasized-decelerate curves with no overshoot. Things settle; they never spring.
- Glitch is the only flourish, and only on a real event (workspace change, track change, alert): offset a label 1–2px and back over two frames, or flicker opacity once. Never on a loop.
- Drawers open with the hairline frame drawing first, then the content fading in.
- Nothing moves when nothing happens.

## Signature moments (perfect these; keep everything else quiet)

1. Lock screen as a Wired login: full-screen grid, the time huge in outline, CLOSE THE WORLD, OPEN THE NEXT in small caps, a red caret.
2. Idle: when the session goes idle, one line fades in at the bottom: `you are connected.`
3. Workspace switch: the LAYER number appears large and outlined for a moment, with a one-frame glitch.

## Hyprland in this theme

1px borders: inactive `line`, active `accent`. Rounding 0. Small gaps. No shadows. Short, settled window animations with no overshoot.

Window opacity: windows stay fully opaque. Only the terminal is translucent (kitty `background_opacity 0.85`), so its text stays solid. No blur.

## Surfaces

Quickshell bar and drawers, kitty, Neovim, rofi, hyprlock, wlogout, fastfetch (NAVI ascii), GTK, wallpaper. All use the same tokens and fonts.

## References

design/lain/refs/: look at every image before designing a component. Borrow the grammar; never copy a poster's layout.
