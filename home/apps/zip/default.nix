# zip archiver. General base utility, previously provided by the host package
# manager; brought under Nix so it survives removal of the redundant system
# stack. (unzip stays a system package; only the `zip` creator moved here.)
{ pkgs, ... }:

{
  home.packages = [ pkgs.zip ];
}
