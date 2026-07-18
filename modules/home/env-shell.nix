# Session environment: the single source of truth for user environment
# variables and PATH. One attrset drives BOTH delivery channels:
#   (1) home.sessionVariables / home.sessionPath -> hm-session-vars.sh, sourced
#       by the Home-Manager-generated ~/.profile and ~/.bashrc (login shells
#       incl. TTY/SSH). On the NixOS hosts the dwm startx session is launched
#       from a login shell, so it inherits these too -- no env.d needed there.
#   (2) systemd.user.sessionVariables -> ~/.config/environment.d/10-home-manager.conf
#       (Home Manager's own env.d fragment; this is the exact mechanism HM uses
#       for its locale vars). This is the systemd-user / graphical feed, needed
#       ONLY on the non-NixOS standalone-HM hosts (tumblesuse), whose
#       display-manager session goes through systemd-user and does NOT source
#       hm-session-vars.sh. Gated to standalone HM via `osConfig == null`.
# No static environment.d assets, no hand-written profile.sh bridge.
{
  lib,
  config,
  pkgs,
  hostSettings ? { },
  osConfig ? null,
  ...
}:

let
  # PATH prepends authored once; fed to home.sessionPath (shells) and, on
  # standalone hosts, to the systemd.user.sessionVariables PATH line. The native
  # HM option does not derive PATH from home.sessionPath, so it is set here.
  sessionPathPrepends = [
    "$HOME/.local/bin"
    "$HOME/.local/share/bebash/commands"
    "$HOME/.cargo/bin"
  ];

  # Cursor theme/size follow the active theme (theme.cursor), keeping the
  # X cursor consistent with the rest of the palette-driven look.
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
in
{
  # SoT. Cross-variable references are resolved at Nix eval time (absolute
  # paths) because hm-session-vars.sh writes these in an unspecified order, so
  # no value may depend on another at runtime. ${XDG_RUNTIME_DIR} / ${HOME} are
  # kept as genuine per-session runtime expansions.
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    SYSTEMD_EDITOR = "nvim";
    PROJECTS = "${config.home.homeDirectory}/Projects";
    TODO = "${config.home.homeDirectory}/Todo";
    NOTES = "${config.home.homeDirectory}/Notes";
    XCURSOR_THEME = theme.cursor.theme;
    XCURSOR_SIZE = toString theme.cursor.size;
    SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-agent.socket";
    SSH_ASKPASS = "\${HOME}/.local/bin/ssh-askpass-rofi";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  home.sessionPath = sessionPathPrepends;

  # Graphical / systemd-user feed -- standalone (non-NixOS) hosts only. Derived
  # from the fully-merged sessionVariables (DRY: picks up a consumer's additions
  # automatically, e.g. EXOBRAIN_* in nix-secrets). Reading
  # config.home.sessionVariables to set the independent systemd.user option is a
  # normal module fixpoint -- no recursion. On NixOS the dwm session inherits
  # the vars via the login shell (channel 1), so this is redundant there.
  systemd.user.sessionVariables = lib.mkIf (osConfig == null) (
    config.home.sessionVariables
    // {
      PATH = "${lib.concatStringsSep ":" sessionPathPrepends}:\${PATH}";
    }
  );
}
