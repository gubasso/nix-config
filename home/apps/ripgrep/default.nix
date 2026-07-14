# ripgrep package and default alias.
{ pkgs, ... }:

{
  home.packages = [ pkgs.ripgrep ];
  programs.bash.shellAliases.rg = "rg --hidden --smart-case";
}
