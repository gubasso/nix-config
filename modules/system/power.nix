_:

{
  # TLP owns power management; disable the conflicting profile daemon.
  services.power-profiles-daemon.enable = false;

  # Shared TLP posture for every host: CPU governors + energy/boost policy,
  # platform profile, and the unified battery charge thresholds. Thresholds are
  # shared (not per-machine) because both current gears use BAT0 and the Dell
  # Precision 5680 firmware floors START at 50, which is equally valid on the
  # ThinkPad P1 — one 50/80 posture serves both.
  services.tlp = {
    enable = true;

    settings = {
      # ---- AC: maximum performance (always-plugged dev workstation) ----
      # intel_pstate active mode: governor=performance locks EPP=0 (performance);
      # the EPP line documents intent. This is the demonstrated preferred posture.
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      PLATFORM_PROFILE_ON_AC = "performance";
      CPU_BOOST_ON_AC = 1;

      # ---- BAT: conservative / longevity ----
      # powersave governor unlocks EPP so balance_power applies.
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      # Portable platform profile: the Precision 5680 exposes
      # cool/quiet/balanced/performance (no "low-power"); "balanced" is the
      # common valid value on both the ThinkPad P1 and the Dell.
      PLATFORM_PROFILE_ON_BAT = "balanced";
      CPU_BOOST_ON_BAT = 0;

      # ---- Battery charge thresholds: unified 50/80 across both gears ----
      # Both use BAT0. Dell firmware floors START at 50 (kernel dell-laptop
      # clamps <50 -> 50); 50/80 is equally valid on the ThinkPad (start 0-99).
      # On Dell this needs kernel >=6.12 and no BIOS Admin password; TLP flips
      # charge_type to Custom automatically. Harmless no-op on a battery-less host.
      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # Re-apply thresholds after unplug. Canonical non-suffixed key (the
      # _ON_BAT0 form is invalid / silently ignored). TLP >=1.10 defaults to 1.
      RESTORE_THRESHOLDS_ON_BAT = 1;

      # PCIE_ASPM intentionally unset (= "default"): defer to BIOS+kernel, TLP's
      # recommended value. Do NOT set powersupersave (NVMe/NIC instability).
    };
  };
}
