# ADR-0017: Canonical theme system

## Context and Problem Statement

Theming was scattered per app, each with its own selector and its own copies:
`rofi` vendored five full `.rasi` files picked by `hostSettings.rofiTheme`, `kitty`
vendored a `current-theme.conf` picked by `hostSettings.kittyTheme`, `dwm` colors
were compiled defaults, and `nvim` used a hostname map. Changing a host's look
meant editing several unrelated files, and palettes were duplicated across apps.

## Considered Options

- Adopt Stylix (global auto-theming) or nix-colors (base16 attrsets).
- Keep per-app theme files, just standardise their names.
- One pure-Nix theme SoT per theme + emitter functions that derive each app's
  native color config.

## Decision Outcome

Chosen option: **pure-Nix theme SoT + emitters** — a theme is a host-agnostic
attrset under `themes/<name>` (base16 palette + a semantic-alias layer +
typography + name-referenced sibling schemes); `lib/theme` emitters transform it
into rofi/kitty/dwm color config; a host selects one via `hostSettings.theme`.
Typography is a token SoT — a family registry + size scale + roles — resolved by
`fontOf` (with per-app defaults and per-host app-scoped font overrides)
and provisioned via `pkgs.fontPackages`; kitty/rofi fonts are emitted from it.
Rejected Stylix/nix-colors (extra dependency, weak per-app control) and no
wallpaper-driven generation. Sibling schemes (tokyonight, catppuccin…) are
name references only — the app loads them natively. Design stays Stylix-compatible
for a possible future.

## Consequences

- Good: one selector per host; palette defined once and derived everywhere (DRY);
  no duplicated color files (Atomic Artifact Principle, ADR-0015); themes are
  self-contained and documented (per-theme brand-book under `themes/<name>/docs`).
- Good: dwm re-themes live via Xresources (`loadxrdb`), no rebuild.
- Bad: adding a target app means writing an emitter; the semantic layer adds a
  small indirection over raw base16.

## Status

Implemented. `lib/theme` (resolver + `fontOf` + emitters, incl. `mkRofiFont` and
font-bearing `mkKittyTheme`), `themes/` (registry + `purple-city`, `everforest`),
`pkgs.themeLib` + `pkgs.fontPackages` (`overlays/default.nix`), and `flake.lib.theme`;
consumed by `home/apps/{rofi,kitty,dwm}` (kitty/rofi fonts from the SoT typography).
The font subsystem (`fontOf`/`fontPackagesFor`) is factored into
`lib/theme/fonts.nix`; default font tokens are shared in
`themes/_shared/typography.nix`. The app-specific `mk*` emitters have since been
relocated out of `lib/theme` into each app's `home/apps/<app>/theme.nix`, leaving
`lib/theme` as the shared token algebra only ([ADR-0018](ADR-0018-apps-own-theme-emitters.md)).
Consumer app-owned value placement has since moved from central host settings to
app-scoped options.
Schema: `docs/reference/theming.md`.
Authoring: `docs/guides/authoring-a-theme.md`. Rationale: `docs/explanation/theming-model.md`.
