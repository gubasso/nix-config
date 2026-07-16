# Everforest — Accessibility

Target: **WCAG 2.x AA** — 4.5:1 body text, 3:1 UI/large text. Everforest is a
deliberately soft, low-contrast palette; body text still clears AA (and AAA),
but decorative/comment greys are intentionally low. Ratios vs `bg` (`#272E33`)
unless noted; verify with a checker after edits.

## Contrast matrix

| Pair | Foreground | Background | Ratio (approx) | AA | AAA |
| --- | --- | --- | --- | --- | --- |
| Body text | fg `#D3C6AA` | bg `#272E33` | ~8.1:1 | ✅ | ✅ |
| Accent | accent `#A7C080` | bg `#272E33` | ~6.9:1 | ✅ | — |
| Error | error `#E67E80` | bg `#272E33` | ~5.0:1 | ✅ | — |
| Warn | warn `#E69875` | bg `#272E33` | ~6.0:1 | ✅ | — |
| Info | info `#7FBBB3` | bg `#272E33` | ~6.3:1 | ✅ | — |
| Selected row | fg `#D3C6AA` | overlay `#374145` | ~6.2:1 | ✅ | — |
| Button (selected) | bg `#272E33` | accent `#A7C080` | ~6.9:1 | ✅ | — |
| Muted / comments | muted `#4F5B58` | bg `#272E33` | ~1.9:1 | — | — |

## Notes

- `muted` (~1.9:1) is **intentionally** below AA: it is for de-emphasized
  comments and disabled text, never body copy or the sole carrier of meaning.
- Everforest trades peak contrast for eye comfort; if a host needs stronger
  separation, prefer a higher-contrast theme (e.g. `purple-city`).
