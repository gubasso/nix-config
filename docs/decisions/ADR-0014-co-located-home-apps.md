# ADR-0014: Co-located Home Manager apps

## Status

Accepted.

## Context

Home Manager app logic previously lived under `modules/home/**` while the files it
deployed lived under a separate `home/assets/**` tree. That made ownership harder
to see, forced broad `publicAssetsDir` threading, and made public/private overlay
apps harder to reason about.

## Decision

Each Home Manager application now lives in `home/apps/<app>/`. The app directory
contains `default.nix` plus the files it deploys. `home/apps/default.nix`
auto-imports app directories that contain a `default.nix`.

Public app modules source co-located files with relative Nix paths. Cross-repo
whole-directory overlays use `pkgs.mkRealConfigDir name pubDir privDir`, where
`pubDir` and `privDir` are explicit config directories, not parent asset roots.

Desktop base apps that were historically imported unconditionally remain
ungated to preserve rendered output. Apps that were already desktop-specific
self-gate in their own modules.

## Consequences

- Adding an app means adding a directory, not editing a shared import list.
- Public modules no longer need broad `publicAssetsDir` asset lookup.
- Private consumers pass `publicAppsDir` and `privateAppsDir` for explicit
  public/private app overlays.
- Historical ADRs may mention `home/assets`; current live code uses
  `home/apps/<app>/`.
