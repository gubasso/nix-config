# rofi: Home-Manager-generated config (programs.rofi) plus the shared layout.
# Colors come from the host's `hostSettings.theme` (lib/theme emitter) and the
# font from the SoT typography via themeLib.fontOf, overridable per host with
# `hostSettings.appFonts.rofi`. The generated active-theme.rasi (theme color
# block + @import of layout.rasi) is bridged in via the module's `theme` option,
# so config.rasi is generated from Nix -- no hand-authored file.
{
  pkgs,
  lib,
  hostSettings,
  ...
}:

let
  # rofi owns its theme/font emitters (ADR-0018), built from lib/theme primitives.
  emit = import ./theme.nix { inherit (pkgs) themeLib; };
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
  # rofi's bespoke default: IBM Plex Mono at xs (=10), overridable per host.
  rofiFont = pkgs.themeLib.fontOf theme (
    {
      family = "ibmplex";
      size = "xs";
    }
    // (hostSettings.appFonts.rofi or { })
  );
  activeTheme = pkgs.writeText "rofi-active-theme.rasi" ''
    ${emit.mkRofiColors theme}
    @import "~/.config/rofi/layout.rasi"
  '';
in
{
  # Provision the resolved font (registered families only; ad-hoc ones are the
  # user's responsibility — see docs/reference/theming.md).
  home.packages = lib.optional (
    pkgs.fontPackages ? ${rofiFont.family}
  ) pkgs.fontPackages.${rofiFont.family};

  # Per-host generated theme (colors + layout import); color SoT stays lib/theme.
  home.file.".local/state/rofi/active-theme.rasi".source = activeTheme;

  # Shared static assets.
  xdg.configFile."rofi/layout.rasi".source = ./layout.rasi;
  xdg.configFile."rofi/rofimoji.rc".source = ./rofimoji.rc;

  # Home Manager owns config.rasi and the rofi package (single owner).
  programs.rofi = {
    enable = true;
    font = emit.mkRofiFont rofiFont;
    modes = [
      "window"
      "drun"
      "run"
      "ssh"
    ];
    # Bridge to the per-host generated theme; rofi resolves the ~ path.
    theme = "~/.local/state/rofi/active-theme.rasi";
    extraConfig = {
      dpi = 0;
      display-window = "Select:";
      display-drun = "";
      drun-display-format = "{icon} {name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      case-sensitive = false;
      show-icons = true;
      matching = "fuzzy";
      sort = true;
      sorting-method = "fzf";
      timeout = {
        action = "kb-cancel";
        delay = 0;
      };
      filebrowser = {
        directories-first = true;
        sorting-method = "name";
      };
    };
  };
}
