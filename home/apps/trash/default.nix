# trash-cli package and safer rm alias.
{ pkgs, ... }:

{
  home.packages = [ pkgs.trash-cli ];
  programs.bash.shellAliases.rm = "trash-put";
}
