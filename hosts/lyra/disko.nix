# lyra disk layout: thin call into the shared LUKS/LVM template (mkDisko is
# injected by mkHost via specialArgs — no cross-repo import).
#
# quartz (Dell Precision 5680) system disk confirmed as /dev/nvme0n1 (Samsung
# PM9A1) via `lsblk`. Still re-verify with `lsblk` at install time -- a wrong
# path wipes the wrong device. For `nixos-anywhere --vm-test`, the device is
# overridden to the VM disk (e.g. /dev/vda) via specialArgs.
#
# `luksPasswordFile` is null for the metal `lyra` config (interactive LUKS) and
# a throwaway store-path password for the `lyra-vmtest` variant (see flake.nix).
{
  mkDisko,
  diskDevice ? "/dev/nvme0n1",
  luksPasswordFile ? null,
  ...
}:

mkDisko {
  device = diskDevice;
  vgName = "lyravg";
  diskName = "lyra-system";
  inherit luksPasswordFile;
}
