{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];

    # LVM activation in the initrd, after disko-generated LUKS unlock.
    # disko emits boot.initrd.luks.devices.cryptlvm itself -- do NOT add it here.
    services.lvm.enable = true;
  };

  hardware.cpu.intel.updateMicrocode = true;

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };
}
