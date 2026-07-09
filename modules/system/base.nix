{ ... }:

{
  # Allow unfree packages. Required by the nvidia driver (hardware profiles) and
  # brave (home-manager desktop.nix). home-manager.useGlobalPkgs is true in
  # mkHost, so this system-level nixpkgs.config also governs the Home Manager
  # package set.
  # TODO: narrow to an allowUnfreePredicate (nvidia + brave only) if a tighter
  # unfree posture is wanted.
  nixpkgs.config.allowUnfree = true;
}
