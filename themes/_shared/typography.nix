# Shared typography SoT (design tokens), imported by the themes that want the
# default font set. A theme's `typography` need not use this — it may import it
# verbatim, spread-and-override it (`import ../_shared/typography.nix // { ... }`),
# or define its own inline. Kept out of the theme registry (leading `_`, and
# themes/default.nix imports themes by explicit name) so it is never mistaken for
# a selectable theme.
#
#   families : token -> fontconfig family string, DERIVED from the single font
#              catalogue (catalog/fonts.nix) so family strings are never duplicated
#              between here and the fontPackages map. Resolved by themeLib.fontOf;
#              each is provisioned from the same catalogue by lib/theme/fonts.nix
#              `fontPackagesFor`.
#   sizes    : named point-size scale (token -> int).
#   roles    : bind a semantic role to a family+size token; an app picks a role
#              default and a host may override per app via my.apps.<app>.font.
#   weights  : named weight scale (design token; not yet emitted).
#
# Schema + resolution rules: docs/reference/theming.md.
{
  families = builtins.mapAttrs (_: entry: entry.family) (import ../../catalog/fonts.nix);
  sizes = {
    xs = 10;
    sm = 11;
    md = 13;
    lg = 15;
    xl = 17;
  };
  roles = {
    mono = {
      family = "hack";
      size = "xl";
    };
    ui = {
      family = "inter";
      size = "sm";
    };
    glyphs = {
      family = "symbols";
    };
  };
  weights = {
    regular = 400;
    medium = 500;
    bold = 700;
  };
}
