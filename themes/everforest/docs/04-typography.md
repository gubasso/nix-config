# Everforest — Typography

Source of truth: [`../theme.nix`](../theme.nix) (`typography`).

| Role | Family | Size | Notes |
| --- | --- | --- | --- |
| Monospace | Hack | 17 | Terminal + editor; fixed-width. |
| UI | Inter | 11 | Bar/launcher labels. |
| Glyphs | Symbols Nerd Font | — | Icons / status glyphs (fallback). |

Weights: regular 400 · medium 500 · bold 700. The `typography` block is a token
SoT: a `families` registry (`hack` `inter` `ibmplex` `symbols`) + a `sizes` scale
(`xs`=10 … `xl`=17) + `roles` binding the tokens above.

## Guidance

- One mono family across apps for consistent metrics.
- Nerd-font glyphs for icons; no colored emoji in status output.

> Fonts are wired from this SoT: kitty (mono role) and rofi resolve via
> `themeLib.fontOf` and are provisioned through `pkgs.fontPackages`; a host can
> override per app with `hostSettings.appFonts.<app>`. dwm's font is a follow-up.
