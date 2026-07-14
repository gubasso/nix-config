# dctl devcontainer manifests deployed per-file, plus the agents image tree.
{ lib, pkgs, ... }:

let
  listFiles =
    dir:
    lib.concatLists (
      lib.mapAttrsToList (
        name: type:
        let
          path = dir + "/${name}";
        in
        if type == "regular" then
          [ path ]
        else if type == "directory" then
          listFiles path
        else
          [ ]
      ) (builtins.readDir dir)
    );
  relPath = path: lib.removePrefix "${toString ./.}/" (toString path);
  devcontainerFiles = builtins.filter (
    path: relPath path != "default.nix" && !(lib.hasPrefix "images/agents/" (relPath path))
  ) (listFiles ./.);
in
{
  home.packages = [ pkgs.devcontainer ];
  xdg.configFile =
    builtins.listToAttrs (
      map (path: {
        name = "dctl/${relPath path}";
        value.source = path;
      }) devcontainerFiles
    )
    // {
      "dctl/images/agents".source = ./images/agents;
    };
}
