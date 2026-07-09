# orion (gear onyx, Lenovo ThinkPad P1 Gen 7), user gubasso.
#
# The shared system modules and Home Manager base are injected by
# nix-config's mkHost; this module carries only what is per-machine: the
# hardware profile, disk layout, host packages, user, and stateVersion.
{
  pkgs,
  hostname,
  username,
  ...
}:

{
  imports = [
    ./disko.nix
    ./packages.nix
    ../../modules/hardware/thinkpad-p1.nix
  ];

  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.bashInteractive;
  };

  programs.bash.completion.enable = true;

  # Deliberate first-install state version for orion.
  system.stateVersion = "25.11";
}
