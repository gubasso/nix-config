# Purple City — Typography

Source of truth: [`../theme.nix`](../theme.nix) (`typography`).

| Role | Family | Size | Notes |
| --- | --- | --- | --- |
| Monospace | Hack | 17 | Terminal + editor; fixed-width for alignment. |
| UI | Inter | 11 | Bar/launcher labels (sans-serif). |
| Glyphs | Symbols Nerd Font | — | Icons, powerline, status glyphs (fallback). |

Weights: regular 400 · medium 500 · bold 700.

## Guidance

- Monospace is mandatory for terminal contexts (kitty, dwm status).
- Keep one mono family across apps so column widths and glyph metrics match.
- Nerd-font glyphs supply icons; don't embed colored emoji in status output.

> Note: fonts are defined here as the single source; app-side font wiring
> (kitty/rofi/dwm) from the SoT is a follow-up — colors are wired today. See
> `docs/reference/theming.md`.
