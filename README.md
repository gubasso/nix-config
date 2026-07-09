# nix-config

A reusable NixOS + Home Manager **framework**: a host factory, shared system and
Home Manager modules, an overlay, and packages. It carries no concrete hosts, no
identity, and no secrets. A private consumer flake (`nix-secrets`) imports this
one, supplies per-machine hosts + identity + assets, and calls `lib.mkHost`.

```text
nix-config (public, this repo)          nix-secrets (private consumer)
  lib.mkHost / lib.mkDisko       <────    inputs.nix-config.url = github:gubasso/nix-config
  nixosModules.{system-*, vm}             nixosConfigurations.<host> = nix-config.lib.mkHost { … }
  homeModules.{common, …}                 hosts/<host>/, modules/hardware/, home/assets/, secrets/
  overlays.default
  packages.{dwm, dwm-session}
```

## What it exports

| Output | Purpose |
| --- | --- |
| `lib.mkHost` | Host factory. Injects the shared module set and threads identity/data. |
| `lib.mkDisko` | Shared LUKS-on-LVM disko layout template. |
| `nixosModules.*` | System modules (`base`, `boot`, `users`, `secrets`, `power`, `audio`, `network`, `session`, `vm`). |
| `homeModules.*` | Home Manager modules (`common`, `core-cli`, `desktop`, `env-shell`, `graphics`, `keyring`). |
| `overlays.default` | `dwm` (personal fork) + `dwm-session` scripts. |
| `packages.x86_64-linux.*` | `dwm`, `dwm-session`. |

## Using it

See [docs/guides/bootstrap-your-nix-secrets.md](docs/guides/bootstrap-your-nix-secrets.md)
for the full consumer walkthrough. In short, a consumer host is:

```nix
nixosConfigurations.myhost = inputs.nix-config.lib.mkHost {
  hostname = "myhost";
  username = "me";
  hostModule = ./hosts/myhost;        # hardware + disko + user + stateVersion
  homeModule = ./hosts/myhost/home.nix;
  assetsDir = ./home/assets;          # your Home Manager dotfile tree
  hostSettings = { dpi = 192; scale = 2; };
};
```

The consumer imports **none** of the shared modules by hand — `mkHost` injects
them. Everything a host module needs (`inputs`, `mkDisko`, `hostSettings`,
`assetsDir`) arrives via `specialArgs`.

## Design

- **Framework, not config.** No `nixosConfigurations` here; the public repo
  cannot build a concrete host by itself. See
  [docs/explanation/public-private-model.md](docs/explanation/public-private-model.md).
- **Assets live in the consumer.** Home modules read files from `assetsDir`, so
  personal dotfiles never enter this repo.
- **dwm from a personal fork.** `pkgs/dwm` points `src` at the `dwm-fork` input
  (`github:gubasso/dwm/rice`); everything else inherits from nixpkgs.

## Docs

Organized by [Diátaxis](https://diataxis.fr/). Start with [docs/README.md](docs/README.md);
coding agents load [docs/AGENTS.md](docs/AGENTS.md) first.

## Validation

From a Nix-capable environment:

```bash
nix flake check
nix build .#packages.x86_64-linux.dwm-session
```

New files must be `git add`-ed before `nix flake check` — flakes only see
git-tracked files.
