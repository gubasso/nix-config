# rofi: Home-Manager-generated config (programs.rofi) plus the shared layout.
# Colors come from the host's `hostSettings.theme` (lib/theme emitter) and the
# per-host font from `hostSettings.rofiFont`. The generated active-theme.rasi
# (theme color block + @import of layout.rasi) is bridged in via the module's
# `theme` option, so config.rasi is generated from Nix -- no hand-authored file.
{ pkgs, hostSettings, ... }:

let
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
  activeTheme = pkgs.writeText "rofi-active-theme.rasi" ''
    ${pkgs.themeLib.mkRofiColors theme}
    @import "~/.config/rofi/layout.rasi"
  '';
in
{
  # Per-host generated theme (colors + layout import); color SoT stays lib/theme.
  home.file.".local/state/rofi/active-theme.rasi".source = activeTheme;

  # Shared static assets.
  xdg.configFile."rofi/layout.rasi".source = ./layout.rasi;
  xdg.configFile."rofi/rofimoji.rc".source = ./rofimoji.rc;

  # Home Manager owns config.rasi and the rofi package (single owner).
  programs.rofi = {
    enable = true;
    font = hostSettings.rofiFont or "IBM Plex Mono 10";
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
      sorting-method = "fzf-v2";
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
