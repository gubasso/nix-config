# Purple City — Iconography

Icons come from **Nerd Fonts** glyphs (`Symbols Nerd Font`), not a separate icon
theme — this is a terminal-first rice.

## Conventions

- Status bar (dwm) and launcher (rofi) use nerd-font glyphs for indicators
  (network, battery, volume, workspace).
- Color icons by their **semantic role**, not decoration: a warning glyph takes
  `warn`, an error glyph `error`, otherwise `fg`/`muted`.
- Keep glyphs monochrome; let color carry meaning. No emoji in status output
  (inconsistent width/rendering across the mono font).
- One glyph family across apps so sizing/baseline stay uniform.

Icon *color* follows the palette; icon *shapes* are upstream (Nerd Fonts). There
is no bespoke icon set for this theme.
