# Session environment delivery. Pure wiring: it holds NO variable values — those
# live in a consumer-private env catalog (nix-secrets catalog/env.nix), injected
# as the `envCatalog` specialArg. This module renders that catalog into each
# delivery channel via `pkgs.envLib.renderChannel` (see lib/env.nix).
#
# Two channels, disjoint by design (there is no single mechanism that reaches both
# interactive shells and GUI/systemd-user apps):
#   - "shell" -> home.sessionVariables -> hm-session-vars.sh, sourced by the
#     HM-generated ~/.bashrc/~/.profile. Reaches TTY/SSH/terminal shells; a new
#     terminal picks up changes (no re-login). All hosts.
#   - "gui" -> systemd.user.sessionVariables -> ~/.config/environment.d. Reaches
#     GUI apps and user services on standalone hosts, whose graphical session comes
#     up via systemd-user and never sources the shell profile. environment.d is
#     imported once at login, so these refresh at re-login. Standalone HM only
#     (osConfig == null); on NixOS the dwm login-shell session inherits the shell
#     channel, so no env.d feed is needed there.
# Mirroring shell-only vars into env.d is deliberately avoided: it freezes a stale
# login-time copy that shadows the per-terminal-fresh shell value. Program-owned
# vars (e.g. programs.fzf's FZF_DEFAULT_OPTS) stay program-first and merge into
# home.sessionVariables on their own — they are not in the catalog.
{
  lib,
  config,
  pkgs,
  hostname,
  hostSettings ? { },
  osConfig ? null,
  envCatalog ? { },
  ...
}:

let
  catalog = envCatalog.vars or { };
  path = envCatalog.path or [ ];

  # Value context handed to catalog entries whose `value` is a function. Theme is
  # resolved here (same lever app modules use) so cursor/theme-derived vars stay
  # data in the catalog.
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
  ctx = {
    inherit
      config
      pkgs
      lib
      hostname
      hostSettings
      theme
      ;
  };

  render =
    channel:
    pkgs.envLib.renderChannel {
      inherit
        channel
        catalog
        ctx
        hostname
        ;
    };
in
{
  home.sessionVariables = render "shell";
  home.sessionPath = path;

  # Graphical / systemd-user feed -- standalone (non-NixOS) hosts only. Selective:
  # only "gui"-tagged catalog vars cross into environment.d, plus a PATH prepend so
  # GUI launchers find HM-installed binaries.
  systemd.user.sessionVariables = lib.mkIf (osConfig == null) (
    render "gui"
    // {
      PATH = "${lib.concatStringsSep ":" path}:\${PATH}";
    }
  );
}
