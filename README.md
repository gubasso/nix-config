# nix-config

Consolidated NixOS + Home Manager source of truth for the `onyx` and `quartz`
gear. This repo owns concrete hosts, shared modules, Home Manager assets,
hardware profiles, overlays, packages, and sops-encrypted secret structure.

## Outputs

| Output | Purpose |
| --- | --- |
| `lib.mkHost` | NixOS host factory for `nixosConfigurations`. |
| `lib.mkHomeHost` | Standalone Home Manager host factory for non-NixOS hosts. |
| `lib.mkDisko` | Shared LUKS-on-LVM disko layout template. |
| `nixosConfigurations.*` | `orion`, `lyra`, `orion-vmtest`, `lyra-vmtest`. |
| `homeConfigurations.*` | `gubasso@nova`, `gbasso@tumblesuse`. |
| `nixosModules.*` | Shared system modules. |
| `homeModules.*` | Shared Home Manager modules. |
| `overlays.default` | `dwm` and `dwm-session`. |
| `packages.x86_64-linux.*` | `dwm`, `dwm-session`. |

## Model

Gear owns user identity: `onyx -> gubasso`, `quartz -> gbasso`. Hostnames select
the OS target: `nova` and `tumblesuse` are standalone Home Manager on native
Arch/openSUSE; `orion` and `lyra` are NixOS targets.

Home Manager modules copy verbatim files from `home/assets/` through the
`assetsDir` argument. Secret values live only as sops-encrypted files under
`secrets/`; age private keys and decrypted material stay outside the repo.

## Validation

```bash
nix flake check
nix build .#packages.x86_64-linux.dwm-session
home-manager build --flake .#gubasso@nova
home-manager build --flake .#gbasso@tumblesuse
nix build .#nixosConfigurations.orion.config.system.build.toplevel
nix build .#nixosConfigurations.lyra.config.system.build.toplevel
nix fmt
```

Flakes only see git-tracked files. New files in this migration must be added by
a human before full flake validation is meaningful.

## Docs

Start with [docs/README.md](docs/README.md). Coding agents should also load
[docs/AGENTS.md](docs/AGENTS.md).
