# nix-config

Public NixOS + Home Manager framework: shared modules, libraries, overlays,
packages, and public-safe assets.

Concrete hosts, user identities, private hardware facts, work assets, recipient
scaffolding, and encrypted secret values live in the private consumer repo. This
repo intentionally does not emit concrete host outputs.

## Outputs

| Output | Purpose |
| --- | --- |
| `lib.mkHost` | NixOS host factory for private/public consumers. |
| `lib.mkHomeHost` | Standalone Home Manager host factory. |
| `lib.mkDisko` | Generic disko topology helper. |
| `nixosModules.*` | Shared system modules. |
| `homeModules.*` | Shared Home Manager modules. |
| `packages.x86_64-linux.*` | Public package outputs. |

`nix-secrets -> nix-config` is the only supported private dependency direction.
This public flake must not import private inputs because `flake.lock` would
record their URL and revision.
