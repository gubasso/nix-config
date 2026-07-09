# Install cookbook

Bring a brand-new machine up on its `nix-config` host config. Two flows —
pick one:

| Flow | When | Guide |
| --- | --- | --- |
| **Disko from ISO** | Fresh disk, clean install, you want the exact LUKS-on-LVM layout. | [disko-from-iso.md](disko-from-iso.md) |
| **Adopt a running install** | NixOS is already installed and booting; adopt it in place. | [adopt-running-install.md](adopt-running-install.md) |

Both flows share the same end state: the machine builds
`nixosConfigurations.<host>` from this repo and (optionally) decrypts sops
secrets with a per-host age key.

## Shared facts

| Host   | User      | Machine                  | disko VG  |
| ------ | --------- | ------------------------ | --------- |
| `orion` | `gubasso` | Lenovo ThinkPad P1 Gen 7 | `orionvg` |
| `lyra`  | `gbasso`  | Dell Precision 5680      | `lyravg`  |

- **Disk layout** (`nix-config` `mkDisko`): GPT → 1G ESP + LUKS → LVM VG →
  32G swap + ext4 root. Default device `/dev/nvme0n1` — **verify with `lsblk`
  before running disko; a wrong device wipes the wrong disk.**
- **Hostname must match** the flake attribute: `--flake .#orion` requires
  `networking.hostName = "orion"`.
- **Enable flakes** everywhere the installer's `nix` runs:
  `export NIX_CONFIG="experimental-features = nix-command flakes"`.
- **Age key** lives at `/var/lib/sops-nix/key.txt`. No secrets are declared yet,
  so the very first build needs no key; set the key up when you add the first
  secret (both guides show the step).

## Prerequisites (both flows)

1. Working network on the target.
2. This **private** repo reachable from the target. It lives on GitLab
   (`gitlab.com/gubasso.g/nix-config`), so cloning needs auth — use a GitLab
   token over HTTPS, an SSH deploy key, or copy the tree over `scp`/USB.

## After either flow

Day-to-day rebuilds:

```bash
sudo nixos-rebuild switch --flake .#<host>
```
Bumping the framework (after changes land in `nix-config`):

```bash
nix flake update nix-config && sudo nixos-rebuild switch --flake .#<host>
```