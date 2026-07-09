# orion disk layout: thin call into the shared LUKS/LVM template (mkDisko is
# injected by mkHost via specialArgs — no cross-repo import).
#
# `diskDevice` is a specialArgs-provided placeholder (default the real NVMe).
# The installer MUST verify the path with `lsblk` before running disko -- a
# wrong path wipes the wrong device. For `nixos-anywhere --vm-test`, the device
# is overridden to the VM disk (e.g. /dev/vda) via specialArgs.
#
# `luksPasswordFile` is null for the metal `orion` config (interactive LUKS) and
# a throwaway store-path password for the `orion-vmtest` variant (see flake.nix).
{
  mkDisko,
  diskDevice ? "/dev/nvme0n1",
  luksPasswordFile ? null,
  ...
}:

mkDisko {
  device = diskDevice;
  vgName = "orionvg";
  diskName = "orion-system";
  inherit luksPasswordFile;
}
