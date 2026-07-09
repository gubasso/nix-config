# Shared VM-share config for `nixos-rebuild build-vm` / `system.build.vm`.
#
# Everything is under `virtualisation.vmVariant`, so it ONLY affects the
# throwaway QEMU VM and NEVER the installed system -- the metal hosts stay fully
# independent. The module is shared by every host, but each VM is isolated: the
# disk image and SSH forward port are per-host, so building and running each
# host's VM never collides.
{
  lib,
  hostname,
  username,
  hostSettings ? { },
  ...
}:

{
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;

      # VM display resolution. Feeds services.xserver.resolutions (applied
      # unconditionally via mkVMOverride in nixpkgs qemu-vm.nix), so it takes
      # effect even on this direct-kernel-boot VM. If modesetting + QEMU's
      # default std-VGA ignores it (long-standing behaviour), fall back to a
      # better virtual GPU: qemu.options = [ "-vga virtio" ]. Kept below the
      # host viewport so the 1:1 QEMU window fits with room to spare.
      resolution = {
        x = 1600;
        y = 900;
      };

      # Host-side QEMU display (X11 KDE host). zoom-to-fit lets us resize the
      # window freely with the guest scaling into it. Keyboard grab is left
      # manual for now -- toggle it with Ctrl+Alt+G so dwm/sxhkd (Mod/Super)
      # keys reach the guest instead of KWin. To auto-grab later, append
      # grab-on-hover=on.
      qemu.options = [ "-display gtk,zoom-to-fit=on" ];

      # Per-host isolated disk image (relative to the cwd you run the VM from).
      # Distinct filename per host so VMs never share state. These qcow2 files
      # are throwaway (gitignored).
      diskImage = "./${hostname}.qcow2";

      # Distinct host-side SSH port per host so multiple VMs can be prepared
      # without port clashes. Set `hostSettings.vmSshPort` per host in the
      # consumer; defaults to 2222.
      forwardPorts = [
        {
          from = "host";
          host.port = hostSettings.vmSshPort or 2222;
          guest.port = 22;
        }
      ];

      # Mount the host's real dotfiles repo into the VM over 9p. Edit on the
      # host, test in the VM (or edit in-place under /mnt/dotfiles).
      sharedDirectories.dotfiles = {
        source = "$HOME/.dotfiles";
        target = "/mnt/dotfiles";
        securityModel = "mapped-xattr";
      };
    };

    # VM-only test credential so you can actually log in (console or SSH).
    # Never applied to the installed system.
    users.users.${username}.initialPassword = "nixos";
    users.users.root.initialPassword = "nixos";

    # VM-only prompt cue. vmVariant never touches metal, so this env var is
    # present ONLY inside the throwaway VM; starship's [env_var.IN_VM] module
    # renders it (and shows nothing on metal, where the var is unset). Written
    # to /etc/set-environment (sourced by /etc/profile), so it reaches the
    # interactive SSH login shell -- where the VM hostname alone (identical to
    # the metal hostname) can't disambiguate the VM from metal.
    environment.variables.IN_VM = "${hostname}-vm";

    # SSH into the guest on the forwarded port for the edit-on-host/test-in-VM
    # loop. Password auth is VM-only.
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };

    # No NVIDIA in the VM: drive the virtual display with modesetting so the
    # graphical session can come up. The real nvidia stack stays in the metal
    # hardware profile, untouched.
    services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
  };
}
