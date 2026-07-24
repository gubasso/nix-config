# Theme library: the resolver + shared token algebra over the public theme
# registry.
#
# A "theme" is a pure, host-agnostic Nix attrset under ../../themes/<name> (see
# docs/reference/theming.md for the schema). Hosts select one by name via
# `hostSettings.theme`; app modules resolve it here and compose their own native
# config from these primitives (each app owns its emitter under
# home/apps/<app>/theme.nix, ADR-0018). Exposed to app modules as `pkgs.themeLib`
# (overlay) and on the flake as `lib.theme`.
{ lib }:
let
  fonts = import ./fonts.nix { inherit lib; };
  colors = import ./colors.nix { inherit lib; };
  registry = import ../../themes;

  # The canonical semantic vocabulary every theme must define. Apps read these
  # roles; each must resolve to a base16 slot in one hop (see colorOf). Keeping
  # the set complete-and-required is what lets any app emitter reference any role
  # without a per-theme existence check (ADR-0019).
  requiredSemantic = [
    "bg"
    "surface"
    "surface2"
    "overlay"
    "muted"
    "text_dim"
    "fg"
    "emphasis"
    "border"
    "accent"
    "primary"
    "secondary"
    "error"
    "warn"
    "success"
    "info"
    "urgent"
  ];

  # The base16 palette slots every theme must define (base00..base0F).
  requiredSlots = map (i: "base0${lib.toHexString i}") (lib.range 0 15);

  # Validate a resolved theme's shape at eval time — the declarative analogue of
  # a JSON Schema. Returns the theme unchanged on success; throws a legible,
  # theme-named error otherwise. Runs inside resolve, so every app module that
  # resolves a theme surfaces violations on `nix flake check` / switch (ADR-0019).
  validateTheme =
    theme:
    let
      id = theme.meta.name or "<unnamed>";
      fail = msg: throw "themeLib: theme ${builtins.toJSON id}: ${msg}";
      has = attrs: k: builtins.hasAttr k attrs;

      missingSemantic = lib.filter (k: !has theme.semantic k) requiredSemantic;
      danglingSemantic = lib.filter (v: !has theme.palette v) (builtins.attrValues theme.semantic);
      missingSlots = lib.filter (k: !has theme.palette k) requiredSlots;
      badHex = lib.filter (v: builtins.match "#[0-9a-fA-F]{6}" v == null) (
        builtins.attrValues theme.palette
      );
      polarity = theme.meta.polarity or null;
    in
    if missingSemantic != [ ] then
      fail "missing required semantic role(s): ${lib.concatStringsSep ", " missingSemantic}"
    else if danglingSemantic != [ ] then
      fail (
        "semantic role(s) resolve to unknown palette slot(s): "
        + "${lib.concatStringsSep ", " (lib.unique danglingSemantic)}"
      )
    else if missingSlots != [ ] then
      fail "palette missing base16 slot(s): ${lib.concatStringsSep ", " missingSlots}"
    else if badHex != [ ] then
      fail "palette value(s) are not #RRGGBB: ${lib.concatStringsSep ", " (lib.unique badHex)}"
    else if
      !(lib.elem polarity [
        "dark"
        "light"
      ])
    then
      fail "meta.polarity must be \"dark\" or \"light\" (got ${builtins.toJSON polarity})"
    else if !(builtins.isString (theme.cursor.theme or null)) then
      fail "cursor.theme must be a string"
    else if !(builtins.isInt (theme.cursor.size or null)) then
      fail "cursor.size must be an int"
    else
      theme;

  # name -> resolved theme attrset (throws on unknown name or invalid shape).
  resolve =
    name:
    let
      n = if name == null then throw "themeLib.resolve: theme name is null" else name;
    in
    validateTheme (
      registry.${n} or (throw (
        "themeLib.resolve: unknown theme ${builtins.toJSON n} "
        + "(known: ${lib.concatStringsSep ", " (lib.attrNames registry)})"
      ))
    );

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
        "theme ${theme.meta.name}: ${app} scheme = ${builtins.toJSON scheme} "
        + "is not in associatedSchemes.${app} "
        + "(${lib.concatStringsSep ", " (theme.associatedSchemes.${app} or [ ])})"
      );
in
# The public themeLib is the shared token algebra only: color primitives
# (colors.nix) + font primitives (fonts.nix) + the registry/resolver/validator.
# App-specific string emitters live with each app under home/apps/<app>/theme.nix
# (ADR-0018), composed from these primitives.
colors
// fonts
// {
  inherit
    registry
    resolve
    assertAppScheme
    ;
}
