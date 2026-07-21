# Naming Grammar

Layout naming grammar for the public framework and its private consumers: a root-level plural directory is a shared/global registry; the same word as a file inside a domain slice is scoped to that domain.

## Root Registries

| Root | Meaning |
| --- | --- |
| `lib/` | Shared pure functions (Nix canon). |
| `modules/` | Shared NixOS/Home Manager modules that emit config (Nix canon). |
| `catalog/` | Shared pure-data source-of-truth lookup tables, such as font token -> `{ family; pkg; }`. |
| `assets/` | Shared runtime deployed files with no single app, host, or theme owner. |
| `derivations/` | Custom build recipes feeding `packages.<system>`. |
| `hosts/` | Owned host domain slices. |
| `home/apps/` | Owned app domain slices. |
| `themes/` | Owned theme domain slices. |

## Domain-Slice Sub-Parts

| Part | Meaning |
| --- | --- |
| `default.nix` | Module or behavior entrypoint. |
| `catalog.nix` | Pure data local to that app, host, or theme. |
| `packages.nix` | Install-list contents for `home.packages` or `environment.systemPackages`. |
| `assets/` | Runtime files owned by that slice. |

## Decision Rule

Ask where the owner lives. If there is no single owner, use a root registry. If an app, host, or theme owns it, keep it inside that slice.

## `pkgs` / `packages`

`packages` means install lists in source files, such as `hosts/<host>/packages.nix`. Custom build recipes use `derivations/` so one word does not mean both install lists and package definitions.

## Flake Caveat

`packages.<system>` is a reserved Nix flake output name. Nix commands such as `nix build`, `nix run`, `nix flake show`, and `nix flake check` key off it, so it stays unchanged even though source build recipes live under `derivations/`.

Flow example: `derivations/dwm/default.nix` -> overlay `pkgs.dwm` -> output `packages.${system}.dwm`.
