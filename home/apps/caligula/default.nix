# caligula: user-friendly, lightweight TUI disk imager (dd/Balena-Etcher alternative,
# github.com/ifd3f/caligula) — for writing OS images to USB/SD.
{ pkgs, ... }:

{
  home.packages = [ pkgs.caligula ];
}
