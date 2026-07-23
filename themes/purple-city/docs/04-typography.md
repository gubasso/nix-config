# Purple City — Typography

Source of truth: [`../theme.nix`](../theme.nix) (`typography`).

| Role | Family | Size | Notes |
| --- | --- | --- | --- |
| Monospace | Hack | 17 | Terminal + editor; fixed-width for alignment. |
| UI | Inter | 11 | Bar/launcher labels (sans-serif). |
| Glyphs | Symbols Nerd Font | — | Icons, powerline, status glyphs (fallback). |

Weights: regular 400 · medium 500 · bold 700. The `typography` block is a token
SoT: a `families` registry (`hack` `inter` `ibmplex` `symbols`) + a `sizes` scale
(`xs`=10 … `xl`=17) + `roles` binding the tokens above.

## Guidance

- Monospace is mandatory for terminal contexts (kitty, dwm status).
- Keep one mono family across apps so column widths and glyph metrics match.
- Nerd-font glyphs supply icons; don't embed colored emoji in status output.

> Fonts are wired from this SoT: kitty (mono role) and rofi resolve via
> `themeLib.fontOf` and are provisioned through `pkgs.fontPackages`; a host can
> override per app with `my.apps.<app>.font`. dwm's font is a follow-up.
> See `docs/reference/theming.md`.
