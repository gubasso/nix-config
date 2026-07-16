# Theme library: the resolver + emitters over the public theme registry.
#
# A "theme" is a pure, host-agnostic Nix attrset under ../../themes/<name> (see
# docs/reference/theming.md for the schema). Hosts select one by name via
# `hostSettings.theme`; app modules resolve it here and call an emitter to derive
# their native color config. Exposed to app modules as `pkgs.themeLib` (overlay)
# and on the flake as `lib.theme`.
{ lib }:
let
  emitters = import ./emitters.nix { inherit lib; };
  registry = import ../../themes;

  # name -> resolved theme attrset (throws on unknown name).
  resolve =
    name:
    let
      n = if name == null then throw "themeLib.resolve: theme name is null" else name;
    in
    registry.${n} or (throw (
      "themeLib.resolve: unknown theme ${builtins.toJSON n} "
      + "(known: ${lib.concatStringsSep ", " (lib.attrNames registry)})"
    ));

  # Validate a host's per-app sibling-scheme pick against the theme's declared
  # associatedSchemes. Returns the scheme (or null) so callers can use it inline.
  assertAppScheme =
    theme: app: scheme:
    if scheme == null then
      null
    else if lib.elem scheme (theme.associatedSchemes.${app} or [ ]) then
      scheme
    else
      throw (
        "theme ${theme.meta.name}: appSchemes.${app} = ${builtins.toJSON scheme} "
        + "is not in associatedSchemes.${app} "
        + "(${lib.concatStringsSep ", " (theme.associatedSchemes.${app} or [ ])})"
      );
in
emitters
// {
  inherit
    registry
    resolve
    emitters
    assertAppScheme
    ;
}
