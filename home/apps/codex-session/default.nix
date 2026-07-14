# Public codex-session base config tree.
{ lib, pkgs, ... }:

{
  xdg.configFile."codex-session".source = lib.mkDefault (
    pkgs.mkRealConfigDir "codex-session" ./config null
  );
}
