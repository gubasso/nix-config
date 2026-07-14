# Auto-import every co-located Home Manager app module in this directory.
{ lib, ... }:

let
  entries = builtins.readDir ./.;
  appNames = lib.sort (a: b: a < b) (
    builtins.filter (
      name: entries.${name} == "directory" && builtins.pathExists (./. + "/${name}/default.nix")
    ) (builtins.attrNames entries)
  );
in
{
  imports = map (name: ./. + "/${name}") appNames;
}
