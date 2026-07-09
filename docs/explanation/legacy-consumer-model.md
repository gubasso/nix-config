# How this consumes nix-config

## The edge

```text
  nix-config (public framework)  ──►  nix-secrets (this repo)
  lib.mkHost / lib.mkDisko            inputs.nix-config → mkHost per host
  shared modules + overlay           hosts/ · modules/hardware/ · home/assets/ · secrets/
```
This repo depends on the framework; the framework never depends on this repo.
Personal data flows *into* `mkHost` at evaluation time and is never committed
upstream. See the framework's
[public/private model](https://github.com/gubasso/nix-config/blob/develop/docs/explanation/public-private-model.md).

## One input, everything transitive

`flake.nix` declares a single real input, `nix-config`. nixpkgs, home-manager,
disko, sops-nix, and nixos-hardware all arrive through it, and
`nixpkgs.follows = "nix-config/nixpkgs"` keeps this repo on the framework's pin.
`mkHost` runs against the framework's nixpkgs, so a host build is reproducible
from `nix-config`'s lock plus this repo's `flake.lock`.

## What a host module carries

`mkHost` injects the shared system modules and the Home Manager base. A host
module here therefore holds only what is genuinely per-machine:

- `hosts/<host>/default.nix` — hardware profile import, user, `networking.hostName`,
  `stateVersion`.
- `hosts/<host>/disko.nix` — a thin call into the injected `mkDisko` (a
  `specialArg`), with the host's `vgName`/`diskName`.
- `hosts/<host>/home.nix` — host-only Home Manager extras (usually empty; the base
  is injected).
- `hostSettings` (in `flake.nix`) — `dpi`/`scale`/`vmSshPort` the framework reads.

No host module imports a shared module or references `inputs.nix-config` — the
framework's `mkHost` does all the wiring.

## Assets and secrets

- `home/assets/` is the `assetsDir` passed to `mkHost`; the framework's home
  modules read every dotfile from there. This is the only home for personal
  config (and the physical location in `gammastep/config.ini`).
- `.sops.yaml` + `secrets/` hold age recipients and encrypted files. The sops-nix
  module is injected by `mkHost`; see
  [ADR-0002](../decisions/ADR-0002-sops-nix-age-per-host-recipients.md).

## Two-step changes

Shared behavior lives upstream. To change it: edit + push `nix-config`, then
`nix flake update nix-config` here and commit the lock. Local iteration without a
push uses `--override-input nix-config path:/path/to/nix-config`.
