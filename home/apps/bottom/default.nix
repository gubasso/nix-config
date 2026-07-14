# bottom process viewer and top/htop aliases.
{ pkgs, ... }:

{
  home.packages = [ pkgs.bottom ];
  programs.bash.shellAliases = {
    top = "htop";
    htop = "btm";
  };
}
