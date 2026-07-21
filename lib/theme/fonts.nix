# Font token algebra: the shared, app-agnostic font primitives, keyed off a
# theme's `typography` tokens (see themes/_shared/typography.nix). Holds the
# resolver (`fontOf`) and the family→package provisioning map (`fontPackagesFor`,
# applied in the overlay as `pkgs.fontPackages`). App-specific font formatters
# (kitty/rofi font strings) live with their app under home/apps/<app>/theme.nix
# (ADR-0018). Exposed on `pkgs.themeLib` via lib/theme/default.nix. Pure functions
# of a theme attrset — no build inputs.
{ lib }:
rec {
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

  # Font family (fontconfig string) -> the nixpkgs package that provides it, as a
  # function of a package set (so this pure module can hold the map without a
  # build-input dependency; the overlay applies it as `fontPackagesFor prev`).
  # DERIVED from the single font catalogue (catalog/fonts.nix) by
  # re-keying token -> {family; pkg;} to family -> package, so no family string or
  # package is written twice (it is also the source of typography.families). An app
  # module installs the package for the font it resolves via fontOf, so a named
  # "official" font is guaranteed present; the whole set is installed on opt-in
  # hosts by modules/home/fonts.nix. Keyed by the resolved family STRING so both
  # token-resolved and literal families match; ad-hoc / unregistered families
  # install nothing. See docs/reference/theming.md.
  fontPackagesFor =
    pkgs:
    lib.mapAttrs' (_: entry: lib.nameValuePair entry.family (entry.pkg pkgs)) (
      import ../../catalog/fonts.nix
    );
}
