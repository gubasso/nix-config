# ADR-0019: Canonical semantic-token vocabulary + build-time theme validation

## Context and Problem Statement

The theme system (ADR-0017/0018) defined a semantic layer, but the set of roles
was implicit: each theme happened to define the same twelve, and app emitters
referenced roles with no guarantee they existed. `colorOf` resolves a role in a
single hop (`palette.${semantic.role}`), yet the docs claimed a role could point
at "another role" — untrue, and undetected until an app crashed at eval. Nothing
checked that a theme was well-formed: a missing role, a semantic value naming a
slot that doesn't exist, a malformed `#RRGGBB`, or a bad `polarity` would surface
only as an opaque failure deep inside some emitter, or not at all.

Two gaps, one root cause — no agreed vocabulary and no shape check:

- Emitters could not safely reference a role without a per-theme existence guard.
- New tokens (`primary`, `secondary`, `surface2`, `text_dim`, `urgent`) had no
  home, and adding one silently risked partial coverage across themes.

## Considered Options

- Status quo: implicit role set, validation-by-crash inside emitters.
- A separate `flake check` derivation that lints theme files.
- A **canonical required vocabulary** plus a pure `validateTheme` run inside
  `resolve`, so every consumer validates on eval.

## Decision Outcome

Chosen: **a canonical semantic vocabulary that every theme must define, enforced
by a pure validator in `resolve`.** The required roles are `bg surface surface2
overlay muted text_dim fg emphasis border accent primary secondary error warn
success info urgent`. `validateTheme` (in `lib/theme/default.nix`) asserts:
required roles present; every semantic value names a defined palette slot
(the one-hop contract); palette is exactly `base00`…`base0F`; every palette value
matches `#RRGGBB`; `meta.polarity ∈ {dark,light}`; `cursor` has string `theme` +
int `size`. It returns the theme unchanged on success and throws a theme-named
error otherwise. Kept in the token-algebra layer (ADR-0018), not a check
derivation, so it runs everywhere the theme is resolved.

App-specific tokens may still exist locally, but they consume from this canonical
SoT vocabulary — the convention is the source of truth, ahead of any single
consumer.

## Consequences

- Good: any emitter may reference any canonical role without an existence guard.
- Good: malformed themes fail fast on `nix flake check` / switch, with a legible,
  theme-named message — the declarative analogue of the RFC's JSON Schema.
- Neutral: adding a canonical role means editing every theme (enforced), which is
  the intended completeness guarantee.
- Bad: a token defined ahead of any consumer is deliberate vocabulary, not dead
  weight (it is data, invisible to deadnix); documented here to avoid confusion.

## Status

Implemented. `lib/theme/default.nix` (`validateTheme` + `requiredSemantic`);
`themes/{purple-city,everforest}/theme.nix` (full vocabulary); consumed by
`home/apps/{dwm,dunst}/theme.nix` (`urgent`, `text_dim`). Extends
[ADR-0017](ADR-0017-theme-system.md)/[ADR-0018](ADR-0018-apps-own-theme-emitters.md).
Schema: `docs/reference/theming.md`.
