# kitty-specific theme emitter: formats a resolved theme + font into kitty's
# `current-theme.conf` (colors AND font). Composed from the shared color-token
# primitives in lib/theme (ADR-0018). A plain helper imported by ./default.nix —
# NOT auto-loaded as an HM module (home/apps/default.nix imports only default.nix).
{ lib, themeLib }:
let
  inherit (themeLib) colorOf ansiSlots;
in
rec {
  # kitty font lines. Folded into mkKittyTheme so the font rides inside the
  # already-generated, already-included `current-theme.conf` — no new file and no
  # second `include` to keep in sync. `font` is a resolved { family; size; }.
  mkKittyFont = font: ''
    font_family             ${font.family}
    font_size               ${toString font.size}.0
  '';

  # kitty color theme + font (the `current-theme.conf` include target). Takes the
  # resolved font so the font rides inside the same generated file as the colors.
  mkKittyTheme =
    theme: font:
    let
      c = colorOf theme;
      ansi = lib.imap0 (i: slot: "color${toString i}            ${theme.palette.${slot}}") ansiSlots;
    in
    ''
      # Generated from theme "${theme.meta.name}" by nix-config lib/theme. Do not edit.
      ${mkKittyFont font}
      foreground              ${c "fg"}
      background              ${c "bg"}
      selection_foreground    ${c "bg"}
      selection_background    ${c "accent"}
      cursor                  ${c "accent"}
      cursor_text_color       ${c "bg"}
      url_color               ${c "info"}
      active_border_color     ${c "accent"}
      inactive_border_color   ${c "muted"}
      active_tab_background    ${c "bg"}
      active_tab_foreground    ${c "fg"}
      inactive_tab_background  ${c "surface"}
      inactive_tab_foreground  ${c "muted"}
      tab_bar_background       ${c "bg"}
      ${lib.concatStringsSep "\n" ansi}
    '';
}
