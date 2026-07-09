# Reference — `lib.mkDisko`

Shared disko layout template. Every host uses the same topology, so it is defined
once and cannot drift. Source: `lib/mk-disko.nix`. Available to consumer host
modules as `mkDisko` via `specialArgs` (injected by `mkHost`).

## Topology

GPT → 1G ESP (vfat, `/boot`) + LUKS partition (`cryptlvm`) → LVM VG → swap LV +
root LV (ext4, `/`, `100%FREE`).

## Arguments

| Arg | Required | Default | Purpose |
| --- | --- | --- | --- |
| `device` | yes | — | Block device to wipe (**DESTRUCTIVE**); verify with `lsblk` first. |
| `vgName` | yes | — | LVM volume-group name (e.g. `"myhostvg"`). |
| `diskName` | yes | — | disko `disk.<name>` attribute (e.g. `"myhost-system"`). |
| `swapSize` | no | `"32G"` | Swap LV size. |
| `luksPasswordFile` | no | `null` | `null` → interactive `askPassword` (metal). A store-path file → shellcheck-clean generated script for `nixos-anywhere --vm-test`. |

## Usage (consumer `hosts/<name>/disko.nix`)

```nix
{ mkDisko, diskDevice ? "/dev/nvme0n1", luksPasswordFile ? null, ... }:
mkDisko {
  device = diskDevice;
  vgName = "myhostvg";
  diskName = "myhost-system";
  inherit luksPasswordFile;
}
```
## Notes

- The GPT partlabel `cryptlvm` is taken from the partition attribute name; disko
  auto-generates `boot.initrd.luks.devices.cryptlvm`, so `boot.nix` must not
  redeclare it.
- The swap LV lives inside LUKS, so it sets `randomEncryption = false` (no
  double-encryption).
