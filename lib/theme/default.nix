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

  # Resolve a font request against a theme's typography registry.
  #
  #   fontOf theme { role ? null; family ? null; size ? null; }
  #     -> { family = "<literal family string>"; size = <int | null>; }
  #
  # `role` picks a default { family; size; } from theme.typography.roles; an
  # explicit `family`/`size` in the spec overrides it. Callers layer precedence
  # (theme role -> app default -> per-host override) by merging attrs BEFORE the
  # call: fontOf theme (roleDefault // appDefault // hostOverride).
  #
  #   family: a registry token ("ibmplex") -> its family string; OR a literal
  #           family string (has a space, or is Capitalised) -> passed through
  #           (the escape hatch); an unknown lowercase token throws.
  #   size:   a scale token ("lg") -> its int; OR a raw int (15) -> passed
  #           through; an unknown token throws.
  fontOf =
    theme: spec:
    let
      t = theme.typography;
      role =
        if (spec.role or null) == null then
          { }
        else
          t.roles.${spec.role} or (throw (
            "themeLib.fontOf: unknown role ${builtins.toJSON spec.role} in theme ${theme.meta.name} "
            + "(known: ${lib.concatStringsSep ", " (lib.attrNames t.roles)})"
          ));

      famTok = spec.family or (role.family or null);
      sizeTok = spec.size or (role.size or null);

      resolveFamily =
        f:
        if f == null then
          throw "themeLib.fontOf: no family resolved (theme ${theme.meta.name}, spec ${builtins.toJSON spec})"
        else
          t.families.${f} or (
            # Escape hatch: a literal family string (spaced or Capitalised) is
            # used verbatim; a bare lowercase word that is not a token is a typo.
            if lib.hasInfix " " f || builtins.match "[A-Z].*" f != null then
              f
            else
              throw (
                "themeLib.fontOf: unknown family token ${builtins.toJSON f} in theme ${theme.meta.name} "
                + "(known: ${lib.concatStringsSep ", " (lib.attrNames t.families)})"
              )
          );

      resolveSize =
        s:
        if s == null then
          null
        else if builtins.isInt s then
          s
        else
          t.sizes.${s} or (throw (
            "themeLib.fontOf: unknown size token ${builtins.toJSON s} in theme ${theme.meta.name} "
            + "(known: ${lib.concatStringsSep ", " (lib.attrNames t.sizes)})"
          ));
    in
    {
      family = resolveFamily famTok;
      size = resolveSize sizeTok;
    };

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
    fontOf
    assertAppScheme
    ;
}
