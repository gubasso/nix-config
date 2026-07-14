# fd file finder (used by fzf widgets, fzf-lua, and general search).
{ pkgs, ... }:

{
  home.packages = [ pkgs.fd ];
}
