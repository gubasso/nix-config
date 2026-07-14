# autorandr package and profile placeholder.
{ pkgs, ... }:

{
  home.packages = [ pkgs.autorandr ];
  programs.autorandr.enable = true;
  xdg.configFile."autorandr/README.md".source = ./README.md;
}
