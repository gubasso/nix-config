# lyra (gear quartz, Dell Precision 5680), user gbasso.
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
    ../../modules/hardware/precision-5680.nix
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

  # Deliberate first-install state version for lyra.
  system.stateVersion = "25.11";
}
