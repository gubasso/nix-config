{ ... }:

{
  # Allow unfree packages. Required by the nvidia driver (graphics.nix, round 3)
  # and brave (home-manager desktop.nix, round 5). home-manager.useGlobalPkgs is
  # true in flake.nix, so this system-level nixpkgs.config also governs the
  # gubasso Home Manager package set.
  # TODO: narrow to an allowUnfreePredicate (nvidia + brave only) if a tighter
  # unfree posture is wanted.
  nixpkgs.config.allowUnfree = true;
}
