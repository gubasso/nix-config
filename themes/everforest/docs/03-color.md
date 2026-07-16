# Everforest — Color

Source of truth: [`../theme.nix`](../theme.nix).

## Palette (base16)

| Slot | Hex | Role |
| --- | --- | --- |
| base00 | `#272E33` | background |
| base01 | `#2E383C` | surface |
| base02 | `#374145` | overlay / border / selection |
| base03 | `#4F5B58` | muted |
| base04 | `#859289` | dim foreground |
| base05 | `#D3C6AA` | foreground |
| base06 | `#E0DCC7` | bright foreground |
| base07 | `#FDF6E3` | brightest |
| base08 | `#E67E80` | red — error |
| base09 | `#E69875` | orange — warn |
| base0A | `#DBBC7F` | yellow |
| base0B | `#A7C080` | green — **accent** / success |
| base0C | `#83C092` | aqua |
| base0D | `#7FBBB3` | blue — info |
| base0E | `#D699B6` | purple |
| base0F | `#9DA9A0` | grey |

## Semantic mapping

| Role | Slot | Hex |
| --- | --- | --- |
| bg | base00 | `#272E33` |
| surface | base01 | `#2E383C` |
| overlay | base02 | `#374145` |
| muted | base03 | `#4F5B58` |
| fg | base05 | `#D3C6AA` |
| emphasis | base07 | `#FDF6E3` |
| border | base02 | `#374145` |
| accent | base0B | `#A7C080` |
| error | base08 | `#E67E80` |
| warn | base09 | `#E69875` |
| success | base0B | `#A7C080` |
| info | base0D | `#7FBBB3` |

## Usage rules

- `bg`/`surface`/`overlay` build depth.
- `accent` (green) only for active/selected states.
- Status hues reserved for their meaning.
