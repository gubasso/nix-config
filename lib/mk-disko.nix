# Shared disko layout template. Every host uses the identical topology --
# GPT (1G ESP + LUKS) -> LVM VG with a swap LV and a root LV taking the rest --
# so the layout is defined once and cannot drift between hosts. Only the disk
# device, VG name, and disk attribute name differ per host.
#
# Args:
#   device   - block device to wipe (DESTRUCTIVE); verify with `lsblk` first.
#   vgName   - LVM volume-group name (e.g. "orionvg", "lyravg").
#   diskName - disko `disk.<name>` attribute (e.g. "orion-system").
#   swapSize - swap LV size (default 32G).
#   luksPasswordFile - path to a file holding the LUKS password. Default null,
#              which leaves disko in interactive `askPassword` mode (the metal
#              install prompts for the password). Set it (to a throwaway
#              store-path password) only for the `*-vmtest` variants: with a
#              passwordFile, disko's `askPassword` is false, so the generated
#              format script drops the `$password` subshell block that trips
#              shellcheck SC2030/SC2031 under `nixos-anywhere --vm-test`.
{
  device,
  vgName,
  diskName,
  swapSize ? "32G",
  luksPasswordFile ? null,
}:

{
  disko.devices = {
    disk.${diskName} = {
      type = "disk";
      device = device;

      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          # GPT partlabel = "cryptlvm" (taken from this attribute name).
          # disko auto-generates boot.initrd.luks.devices.cryptlvm pointing at
          # this partition, so boot.nix must NOT redeclare it.
          cryptlvm = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptlvm";
              # null => interactive askPassword (metal). A store-path file =>
              # shellcheck-clean generated script for `--vm-test`.
              passwordFile = luksPasswordFile;
              content = {
                type = "lvm_pv";
                vg = vgName;
              };
            };
          };
        };
      };
    };

    lvm_vg.${vgName} = {
      type = "lvm_vg";
      lvs = {
        # Device node becomes <vg>-swap. Already inside LUKS, so no
        # randomEncryption (it would double-encrypt for no benefit).
        swap = {
          size = swapSize;
          content = {
            type = "swap";
            randomEncryption = false;
          };
        };

        # Device node becomes <vg>-root.
        root = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
