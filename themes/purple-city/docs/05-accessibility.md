# Purple City — Accessibility

Target: **WCAG 2.x AA** — 4.5:1 for body text, 3:1 for UI/large text and borders.
Ratios below are against `bg` (`#010005`) unless noted; verify with a contrast
checker after any palette edit.

## Contrast matrix

| Pair | Foreground | Background | Ratio (approx) | AA | AAA |
| --- | --- | --- | --- | --- | --- |
| Body text | fg `#F5F0FF` | bg `#010005` | ~19:1 | ✅ | ✅ |
| Muted text | muted `#B9A6CC` | bg `#010005` | ~10:1 | ✅ | ✅ |
| Accent | accent `#C89DEA` | bg `#010005` | ~9:1 | ✅ | ✅ |
| Error | error `#FF4D8D` | bg `#010005` | ~6.6:1 | ✅ | — |
| Warn | warn `#F2D26B` | bg `#010005` | ~14:1 | ✅ | ✅ |
| Success | success `#3FE1B0` | bg `#010005` | ~12:1 | ✅ | ✅ |
| Info | info `#7AA2F7` | bg `#010005` | ~8:1 | ✅ | ✅ |
| Selected row | fg `#F5F0FF` | overlay `#2C094C` | ~15:1 | ✅ | ✅ |
| Button (selected) | bg `#010005` | accent `#C89DEA` | ~9:1 | ✅ | ✅ |

## Notes

- Body text far exceeds AA; the theme is comfortable for extended reading.
- `error` clears AA for normal text but not AAA (7:1) — acceptable for a status
  hue that also carries an icon/label.
- Borders (`overlay` on `surface`) are decorative, not the sole state indicator;
  selection also changes background and border color together.
