# ADR-0018: Apps own their theme emitters

## Context and Problem Statement

The theme system (ADR-0017) put every app's string formatter — `mkKittyTheme`,
`mkRofiColors`, `mkDwmXresources`, `mkDunstColors`, `mkStarshipPalette`,
`mkXsecurelockEnv`, `mkBashPalette`, plus the `mkKittyFont`/`mkRofiFont` font
strings — in the shared `lib/theme` (`emitters.nix`/`fonts.nix`). Each emitter is
consumed by exactly one app module, yet lived in the central library, so
`lib/theme` carried app-specific knowledge (kitty's `current-theme.conf` layout,
rofi's `.rasi` vars) and `mkKittyTheme` had to reach back into the font subsystem
to fold in a font block. This mixed two concerns: the shared *token algebra* and
the per-app *formatting*.

## Considered Options

- Keep all emitters centralized in `lib/theme` (status quo, ADR-0017).
- Inject each app's font emitter into `lib/theme` (dependency inversion — the
  library would import app paths).
- Move each app's string formatter into that app's own directory; keep only the
  shared primitives in `lib/theme`.

## Decision Outcome

Chosen: **each app owns its emitter in `home/apps/<app>/theme.nix`**, a plain
helper the app's `default.nix` imports (never auto-loaded — `home/apps` imports
only `default.nix`). `lib/theme` keeps only the shared token algebra: `resolve`,
`fontOf`, `fontPackagesFor` (`fonts.nix`) and `colorOf`, `hexToRgb`, `ansiSlots`
(`colors.nix`, renamed from `emitters.nix`). Emitters compose from those
primitives, passed in as `themeLib`. Dependency arrows point app → lib only; no
app name appears in `lib/theme`. A behaviour-preserving refactor — every emitted
string is byte-identical.

## Consequences

- Good: true co-location (ADR-0014) and atomic artifacts (ADR-0015) — an app's
  format lives with the app; adding an app never edits the library.
- Good: `mkKittyTheme` composes its own local `mkKittyFont`; the old
  library→font-subsystem coupling is gone.
- Neutral: shared primitives (`colorOf`, `hexToRgb`, `ansiSlots` — used by kitty
  *and* dwm) stay central to avoid duplication; only the formatters moved.
- Bad: the `mk*` names left the public `pkgs.themeLib` surface (safe — no
  cross-app or external consumers).

## Status

Implemented. `lib/theme/{default,colors,fonts}.nix` (primitives); `home/apps/
{kitty,rofi,dwm,dunst,starship,xsecurelock,shell-core}/theme.nix` (emitters).
Supersedes the emitter placement in [ADR-0017](ADR-0017-theme-system.md). The
private consumer extends the same app-ownership rule from emitters to app-owned
values in its ADR-0019.
Schema: `docs/reference/theming.md`.
