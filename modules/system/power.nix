{ ... }:

{
  # TLP owns power management; disable the conflicting profile daemon.
  services.power-profiles-daemon.enable = false;

  # Shared TLP posture: CPU governors + energy/boost policy for every host.
  # Battery charge thresholds are machine-specific and live in the per-machine
  # hardware profile (modules/hardware/<machine>.nix), not here.
  services.tlp = {
    enable = true;

    settings = {
      # AC = performance
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      PLATFORM_PROFILE_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_BOOST_ON_AC = 1;

      # BAT = conservative/longevity posture ("conservative" is not a real
      # governor; this is the documented low-power mapping).
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_BAT = 0;
    };
  };
}
