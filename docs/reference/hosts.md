# Reference — Hosts

Every NixOS host is one `lib.mkHost { ... }` call in
[`flake.nix`](../../flake.nix). Every standalone Home Manager host is one
`lib.mkHomeHost { ... }` call.

## Inventory

| Attr | hostname | user | gear | machine | hardware profile | disko VG / disk |
| --- | --- | --- | --- | --- | --- | --- |
| `orion` | `orion` | `gubasso` | onyx | Lenovo ThinkPad P1 Gen 7 | `modules/hardware/thinkpad-p1.nix` | `orionvg` / `orion-system` |
| `lyra` | `lyra` | `gbasso` | quartz | Dell Precision 5680 | `modules/hardware/precision-5680.nix` | `lyravg` / `lyra-system` |
| `orion-vmtest` | `orion` | `gubasso` | — | orion + throwaway LUKS password | (as orion) | (as orion) |
| `lyra-vmtest` | `lyra` | `gbasso` | — | lyra + throwaway LUKS password | (as lyra) | (as lyra) |
| `gubasso@nova` | `nova` | `gubasso` | onyx | Lenovo ThinkPad P1 Gen 7 on Arch | standalone HM | n/a |
| `gbasso@tumblesuse` | `tumblesuse` | `gbasso` | quartz | Dell Precision 5680 on openSUSE TW | standalone HM | n/a |

## Per-host `hostSettings`

Passed to `mkHost`; consumed by the framework (`graphics.nix`, `vm.nix`).

| Host | `dpi` | `scale` | `vmSshPort` | Display |
| --- | --- | --- | --- | --- |
| `orion` | 192 | 2 | 2221 | onyx 4K OLED eDP-1 3840×2400 |
| `lyra` | 96 | 1 | 2222 | quartz 1920×1200 16" |
| `nova` | 192 | 2 | n/a | onyx 4K OLED eDP-1 3840x2400 |
| `tumblesuse` | 96 | 1 | n/a | quartz 1920x1200 16" |

## Hardware notes

- `precision-5680.nix` — **real** GPU bus IDs from `lspci -D` on quartz
  (`PCI:0:2:0` Intel Iris Xe, `PCI:1:0:0` RTX 2000 Ada).
- `thinkpad-p1.nix` — GPU bus IDs are **placeholders** (`PCI:0:0:0`); confirm on
  orion metal with `lspci -D` and replace before relying on PRIME offload.

## Disk device

`mkDisko` defaults `device = /dev/nvme0n1`. Override per host by passing
`diskDevice` to `mkHost`, or edit `hosts/<host>/disko.nix`. **Verify with `lsblk`
at install time.**

## Adding a host

1. `hosts/<name>/` with `default.nix` (hardware import + user + `stateVersion`),
   `disko.nix` (thin `mkDisko` call, unique `vgName`/`diskName`), `home.nix`,
   `packages.nix`.
2. `modules/hardware/<name>.nix` if a new machine profile is needed.
3. A `nixosConfigurations.<name> = mkHost { ... }` block in `flake.nix` with its
   `hostSettings`.
4. Assets already live in `home/assets/`; add `home/assets/bash/hosts/<name>.bash`.
5. Add a `&<name>_age` recipient + `creation_rules` entry to `.sops.yaml`.
