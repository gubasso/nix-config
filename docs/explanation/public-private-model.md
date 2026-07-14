# The public/private model

## The shape

Two repositories, one dependency edge:

```text
  nix-config  (public, GitHub)  ◄─── inputs.nix-config ─── nix-secrets (private, GitLab)
  framework                                                consumer
  - lib.mkHost / lib.mkDisko                               - nixosConfigurations.<host>
  - nixosModules.* / homeModules.*                         - hosts/<host>/*
  - overlays.default                                       - modules/hardware/* (real bus IDs)
  - packages.*                                             - home/apps/** (private overlays)
  (no nixosConfigurations)                                 - .sops.yaml + secrets/** (encrypted)
```
The edge points **one way**: the consumer depends on the framework; the framework
never references the consumer. That is what "the public repo feeds from personal
info internally" means in practice — personal data flows *into* `mkHost` from the
consumer at evaluation time, and none of it is ever committed to the public repo.

## Why split at all

A personal NixOS config mixes two very different things: reusable machinery (a
host factory, module structure, an overlay) and irreducibly personal data
(identity, hardware identifiers, secrets, dotfiles, physical location). Keeping
them in one repo forces an all-or-nothing publish decision. Splitting lets the
machinery be public and genuinely reusable while the personal data stays private
with a single, obvious home.

See [ADR-0001](../decisions/ADR-0001-public-private-split.md).

## Why the consumer stays tiny

The naive split makes each consumer host re-import every shared module via
`inputs.nix-config.nixosModules.*`. Instead, `mkHost` **injects** the shared set
itself and threads everything a host needs (`inputs`, `mkDisko`, `hostSettings`,
`publicAppsDir`, `privateAppsDir`) through `specialArgs`. A consumer host
module ends up carrying only what is genuinely per-machine: its hardware profile,
disk parameters, user, and
`stateVersion`. No consumer module ever writes `inputs.nix-config`.

See [ADR-0002](../decisions/ADR-0002-mkhost-parameterization.md).

## Why apps are co-located

Home Manager app modules and their dotfiles live together under
`home/apps/<app>/`. Public apps source their own files with relative paths. A
private consumer can provide `privateAppsDir` for co-located overrides and uses
`publicAppsDir` only for explicit public/private config-dir merges such as
codex-session. The public modules keep their full structure and ship zero
personal files; the private consumer owns every host-specific overlay.

See [ADR-0003](../decisions/ADR-0003-assets-live-in-consumer.md), superseded for
the public/private asset split by
[ADR-0009](../decisions/ADR-0009-private-overlay-source-of-truth.md).

## Consequences you will feel

- A working host spans two repos. Changing shared behavior is a commit in
  `nix-config`, then a `nix flake update nix-config` + commit in `nix-secrets`.
- Each repo locks its own inputs. The consumer inherits nixpkgs/etc. transitively
  through `nix-config`'s lock.
- The framework is never build-tested against a real host on its own; that proof
  happens in the consumer (or with `--override-input nix-config path:...`).
