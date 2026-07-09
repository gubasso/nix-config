# Per-machine hardware profile: gear quartz (Dell Precision 5680), host lyra.
# Self-contained chassis + GPU for this machine only.
#
# GPUs confirmed via `lspci` on quartz (_docs/gear/quartz/README.md):
#   Intel Iris Xe (Raptor Lake-P) [8086:a7a0], 0000:00:02.0, i915  -> PRIME primary
#   NVIDIA AD107GLM [RTX 2000 Ada] [10de:28b8], 0000:01:00.0, nvidia -> PRIME offload
{ inputs, ... }:

{
  imports = [
    # No Precision 5680 module exists in nixos-hardware; compose the generic
    # laptop set (Intel CPU microcode, laptop + SSD tuning). No GPU/videoDrivers
    # here, so it composes cleanly with the NVIDIA config below.
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    # OFFLOAD PRIME module (Intel-primary + nvidia-offload posture).
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia

    # RTX 2000 Ada is Ada-generation; import the Ada module by path (no flake
    # attr). Sets hardware.nvidia.open via mkOverride 990 when supported.
    (inputs.nixos-hardware + "/common/gpu/nvidia/ada-lovelace")
  ];

  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # Ada is open-kernel-module capable; explicit value documents intent.
    open = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      # Confirmed real bus IDs from `lspci -D` on quartz (0000:00:02.0 iGPU,
      # 0000:01:00.0 dGPU).
      intelBusId = "PCI:0:2:0"; # Intel Iris Xe iGPU
      nvidiaBusId = "PCI:1:0:0"; # RTX 2000 Ada dGPU

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # TODO: Dell Precision 5680 battery charge thresholds. TLP charge-threshold
  # support on Dell is not guaranteed (needs the dell_laptop/libsmbios path);
  # verify on metal before adding START/STOP_CHARGE_THRESH_BAT0. Shared TLP
  # posture (governors, energy policy) lives in modules/system/power.nix.
}
