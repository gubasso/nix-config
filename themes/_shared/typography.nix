# Shared typography SoT (design tokens), imported by the themes that want the
# default font set. A theme's `typography` need not use this — it may import it
# verbatim, spread-and-override it (`import ../_shared/typography.nix // { ... }`),
# or define its own inline. Kept out of the theme registry (leading `_`, and
# themes/default.nix imports themes by explicit name) so it is never mistaken for
# a selectable theme.
#
#   families : registry of "official" fonts (token -> fontconfig family string).
#              Resolved by themeLib.fontOf; each is provisioned by a matching
#              entry in the fontPackages map (lib/theme/fonts.nix fontPackagesFor).
#   sizes    : named point-size scale (token -> int).
#   roles    : bind a semantic role to a family+size token; an app picks a role
#              default and a host may override per app via hostSettings.appFonts.
#   weights  : named weight scale (design token; not yet emitted).
#
# Schema + resolution rules: docs/reference/theming.md.
{
  families = {
    hack = "Hack";
    inter = "Inter";
    ibmplex = "IBM Plex Mono";
    symbols = "Symbols Nerd Font";
  };
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
