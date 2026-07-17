# Color token algebra: the shared, app-agnostic primitives every app color
# emitter is built from. A "theme" carries a base16 palette + a semantic-alias
# layer; these functions resolve and transform colors but emit no app-specific
# config — each app owns its own emitter under home/apps/<app>/theme.nix
# (ADR-0018). Pure functions of a theme attrset; exposed on `pkgs.themeLib` via
# lib/theme/default.nix. See docs/reference/theming.md.
{ lib }:
rec {
  # base16 slot order for terminal ANSI color0..color15 (the canonical
  # base16 → 16-color-terminal mapping used by kitty and dwm alike).
  ansiSlots = [
    "base00"
    "base08"
    "base0B"
    "base0A"
    "base0D"
    "base0E"
    "base0C"
    "base05"
    "base03"
    "base08"
    "base0B"
    "base0A"
    "base0D"
    "base0E"
    "base0C"
    "base07"
  ];

  # Resolve a semantic role name (e.g. "accent") OR a raw slot name (e.g.
  # "base0E") to its hex string. Semantic names win; unknown names are treated
  # as raw palette slots.
  colorOf = theme: name: theme.palette.${theme.semantic.${name} or name};

  # "#RRGGBB" -> "R;G;B" (decimal), for truecolor SGR escapes (\033[38;2;R;G;Bm).
  # Nix has no hex parser, so map digits by hand.
  hexToRgb =
    hex:
    let
      s = lib.removePrefix "#" hex;
      digit =
        c:
        {
          "0" = 0;
          "1" = 1;
          "2" = 2;
          "3" = 3;
          "4" = 4;
          "5" = 5;
          "6" = 6;
          "7" = 7;
          "8" = 8;
          "9" = 9;
          a = 10;
          b = 11;
          c = 12;
          d = 13;
          e = 14;
          f = 15;
          A = 10;
          B = 11;
          C = 12;
          D = 13;
          E = 14;
          F = 15;
        }
        .${c};
      pair = i: digit (builtins.substring i 1 s) * 16 + digit (builtins.substring (i + 1) 1 s);
    in
    "${toString (pair 0)};${toString (pair 2)};${toString (pair 4)}";
}
