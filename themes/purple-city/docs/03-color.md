# Purple City — Color

Source of truth: [`../theme.nix`](../theme.nix). This document mirrors it for
humans; the file wins on any discrepancy.

## Palette (base16)

| Slot | Hex | Role |
| --- | --- | --- |
| base00 | `#010005` | background |
| base01 | `#16042D` | surface |
| base02 | `#2C094C` | overlay / border / selection |
| base03 | `#B9A6CC` | muted |
| base04 | `#D9CCE8` | dim foreground |
| base05 | `#F5F0FF` | foreground |
| base06 | `#F7F2FF` | bright foreground |
| base07 | `#FFFFFF` | brightest |
| base08 | `#FF4D8D` | red — error |
| base09 | `#F2D26B` | orange — warn |
| base0A | `#FFD166` | yellow |
| base0B | `#3FE1B0` | green — success |
| base0C | `#7AA2F7` | cyan — info |
| base0D | `#8AB4FF` | blue |
| base0E | `#C89DEA` | magenta — **accent** |
| base0F | `#E65FEB` | bright magenta |

## Semantic mapping

| Role | Slot | Hex |
| --- | --- | --- |
| bg | base00 | `#010005` |
| surface | base01 | `#16042D` |
| overlay | base02 | `#2C094C` |
| muted | base03 | `#B9A6CC` |
| fg | base05 | `#F5F0FF` |
| emphasis | base07 | `#FFFFFF` |
| border | base02 | `#2C094C` |
| accent | base0E | `#C89DEA` |
| error | base08 | `#FF4D8D` |
| warn | base09 | `#F2D26B` |
| success | base0B | `#3FE1B0` |
| info | base0C | `#7AA2F7` |

## Usage rules

- `bg`/`surface`/`overlay` build depth: window → panels → selection.
- `accent` only for active/selected states.
- Status hues (`error`/`warn`/`success`/`info`) are reserved for their meaning.
