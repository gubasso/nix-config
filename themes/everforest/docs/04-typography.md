# Everforest — Typography

Source of truth: [`../theme.nix`](../theme.nix) (`typography`).

| Role | Family | Size | Notes |
| --- | --- | --- | --- |
| Monospace | Hack | 17 | Terminal + editor; fixed-width. |
| UI | Inter | 11 | Bar/launcher labels. |
| Glyphs | Symbols Nerd Font | — | Icons / status glyphs (fallback). |

Weights: regular 400 · medium 500 · bold 700.

## Guidance

- One mono family across apps for consistent metrics.
- Nerd-font glyphs for icons; no colored emoji in status output.

> Note: fonts are the SoT's single source; app-side font wiring from the SoT is
> a follow-up — colors are wired today.
