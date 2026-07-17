# Explanation: the theming model

Why the theme system is shaped the way it is (ADR-0017). Reference:
[../reference/theming.md](../reference/theming.md).

## One SoT, many outputs

The industry pattern for design systems is **design tokens**: a single
machine-readable source of truth from which every platform's artifact is
generated (the W3C Design Tokens Community Group format; tools like Amazon's
Style Dictionary transform one token file into CSS, Android XML, iOS Swift, C
headers…). We adopt the *idea* — one source, many derived outputs — but not the
tooling: our source is a **pure Nix attrset**, `lib/theme` holds the shared
token algebra (the resolver + color/font primitives), and each "transform" is a
pure function **owned by the app it targets**, under `home/apps/<app>/theme.nix`
(ADR-0018) — so no app-specific formatting lives in the shared library. Nix
already evaluates natively at build time, so a JSON+transformer toolchain (Style
Dictionary, matugen, pywal) would be pure overhead. This keeps the system
dependency-free and lets a palette be defined once and derived into rofi, kitty,
and dwm config.

## Three tiers

Mature design systems (Material 3, IBM Carbon, GitHub Primer, Shopify Polaris)
layer tokens:

1. **Primitive** — raw values. Ours is **base16**: `base00`…`base0F`, a widely
   supported 16-color model with an established slot meaning
   (tinted-theming/base16). Porting an existing scheme is copy-paste.
2. **Semantic** — role names (`bg`, `fg`, `accent`, `error`, …) that reference
   primitives. This is the layer apps read; it lets a green theme and a purple
   theme share one layout while pointing `accent` at different hues.
3. **Component** — per-widget tokens. We deliberately stop at semantic; for a
   handful of terminal-first apps, per-component tokens are ceremony without
   payoff. The schema can grow one later without breaking the first two tiers.

## Sibling schemes are name references, not injected colors

Editors and terminals have rich, hand-tuned upstream themes (tokyonight,
catppuccin, everforest) whose quality exceeds anything derived from 16 colors.
So a theme *names* the sibling schemes each such app may load, and the app loads
it **natively** (nvim's colorscheme plugin, kitty's built-in theme). We do not
inject base16 values into those apps. Apps without a native theme ecosystem
(rofi, dwm) are the ones driven by the emitted palette.

## Accessibility

Every theme documents a **WCAG 2.x** contrast matrix (`05-accessibility.md`):
4.5:1 for body text, 3:1 for UI elements and large text. Low-contrast palettes
are a design choice, but the ratios are recorded so regressions are visible.

## Non-goals

No Stylix or nix-colors dependency (weak per-app control / extra input), no
wallpaper-driven generation, no theme-switch CLI yet. The design stays
Stylix-compatible should that trade-off change.

## Sources

- W3C Design Tokens Format — https://www.designtokens.org/tr/drafts/format/
- Style Dictionary — https://github.com/amzn/style-dictionary
- base16 / tinted-theming — https://github.com/tinted-theming/home
- WCAG 2.1 contrast — https://www.w3.org/TR/WCAG21/
- GitHub Primer color — https://primer.style/foundations/color
