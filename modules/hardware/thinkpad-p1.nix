# Per-machine hardware profile: gear onyx (Lenovo ThinkPad P1 Gen 7), host orion.
# Self-contained chassis + GPU + power thresholds for this machine only.
#
# GPUs per _docs/gear/onyx/README.md:
#   Intel Arc Graphics (Meteor Lake-P) iGPU  -> PRIME primary
#   NVIDIA AD106GLM [RTX 3000 Ada]           -> PRIME offload
{ inputs, ... }:

{
  imports = [
    # ThinkPad P1 generic: pulls in common-cpu-intel, SSD, common-pc, backlight
    # params, fpd. No GPU/TLP/videoDrivers set here, so it composes cleanly.
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1

    # common-gpu-nvidia == common/gpu/nvidia/prime.nix == OFFLOAD PRIME module
    # (matches nova's Intel-primary + nvidia-offload posture, not sync).
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia

    # No `ada-lovelace` flake attr exists; import the Ada module by path.
    # It sets hardware.nvidia.open via mkOverride 990 when the driver supports it.
    (inputs.nixos-hardware + "/common/gpu/nvidia/ada-lovelace")
  ];

  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # Ada is open-kernel-module capable. ada-lovelace module also sets this
    # (mkOverride 990); the explicit value documents intent and wins harmlessly.
    open = true;

    # Suspend/resume + VRAM-preserve posture nova depends on (avoids black
    # screens). finegrained requires offload (enabled below) and is
    # driver/hardware sensitive -> validate on metal.
    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      # TO BE CONFIRMED on onyx. Real bus IDs come from `lspci -D` on orion
      # hardware; see _docs/gear/onyx/. Do NOT treat these as known-good --
      # the metal install's hardware-discovery step replaces them.
      intelBusId = "PCI:0:0:0"; # PLACEHOLDER: Intel Arc iGPU bus ID
      nvidiaBusId = "PCI:0:0:0"; # PLACEHOLDER: RTX 3000 Ada dGPU bus ID

      # common-gpu-nvidia already enables offload (mkOverride 990); explicit
      # here for clarity. enableOffloadCmd provides `nvidia-offload`
      # (nova's prime-run equivalent).
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # onyx battery charge thresholds (start 40 / stop 80, restore on battery),
  # translated from _docs/gear/onyx/tlp-power-management.md. The shared TLP
  # posture (governors, energy policy) lives in modules/system/power.nix.
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 40;
    STOP_CHARGE_THRESH_BAT0 = 80;
    RESTORE_THRESHOLDS_ON_BAT0 = 1;
  };
}
