# ADR-0003: Assets live in the consumer

## Context and Problem Statement

The Home Manager modules wire personal dotfiles (`nvim`, `bash`, browser flags,
rofi, dunst, starship, yazi, gammastep with a physical location, per-host bash
fragments) via `xdg.configFile.X.source = ./assets/Y`. Those assets are personal
config, and one of them (gammastep) encodes a physical location. A public
framework must not ship them, but the module structure that wires them is
reusable.

## Considered Options

- Keep assets public (they are config, not secrets).
- Move the asset-wiring line into private modules; public modules keep only
  package installs.
- Keep public modules, but read asset files from a consumer-supplied path.

## Decision Outcome

Chosen option: **read from a consumer-supplied `assetsDir`**. `mkHost` threads
`assetsDir` (a path into the consumer repo) through
`home-manager.extraSpecialArgs`; each home module references
`assetsDir + "/…"` instead of `./assets/…`. The public repo keeps the full,
reusable module structure and ships **zero** personal files; the consumer's
`home/assets/` tree is the only home for dotfiles and location.

## Consequences

- Good: public modules stay complete and reusable; personal config (and the
  location in `gammastep/config.ini`) never enters the public repo.
- Good: the consumer swaps its entire look-and-feel by pointing `assetsDir`
  elsewhere; no module edits.
- Bad: the public modules do not build a home config on their own (no default
  assets) — a host build requires a consumer to supply `assetsDir`. Acceptable:
  the framework is never meant to build a concrete host (see
  [ADR-0001](ADR-0001-public-private-split.md)).

## Status

Superseded by [ADR-0005](ADR-0005-assets-live-in-consolidated-repo.md). The
`assetsDir` module contract remains, but the concrete asset tree now lives in
this consolidated repo at `home/assets/`.
