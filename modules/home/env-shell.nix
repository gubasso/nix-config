# Session environment: variables, PATH, and the environment.d fragments.
# Asset files come from the consumer's tree via `assetsDir` (threaded by
# lib/mk-host.nix through home-manager.extraSpecialArgs), so this module carries
# no personal config of its own.
{ assetsDir, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    DOTFILES = "$HOME/.dotfiles";
    DOCS_NOTES_REPO = "$HOME/DocsNNotes";
    SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-agent.socket";
    SSH_ASKPASS = "\${HOME}/.local/bin/ssh-askpass-rofi";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  home.sessionPath = [
    "$HOME/.cache/.bun/bin"
    "$HOME/.bun/bin"
    "$HOME/.local/bin"
    "$HOME/.local/npm/bin"
    "$HOME/.cargo/bin"
  ];

  xdg.configFile."environment.d/50-dotfiles.conf".source = assetsDir + "/environment.d/50-dotfiles.conf";
  xdg.configFile."environment.d/50-docs-n-notes.conf".source = assetsDir + "/environment.d/50-docs-n-notes.conf";
  xdg.configFile."environment.d/50-editor.conf".source = assetsDir + "/environment.d/50-editor.conf";
  xdg.configFile."environment.d/50-paths.conf".source = assetsDir + "/environment.d/50-paths.conf";
  xdg.configFile."environment.d/60-kwallet-ssh.conf".source = assetsDir + "/environment.d/60-kwallet-ssh.conf";
  xdg.configFile."environment.d/60-gpg.conf".source = assetsDir + "/environment.d/60-gpg.conf";

  # Portable TTY/SSH fallback body (sources environment.d, ruby gem-bin cache,
  # SUDO/SYSTEMD editor exports). Home Manager's programs.bash module owns
  # ~/.profile itself (to splice hm-session-vars.sh), so writing ~/.profile via
  # home.file would collide. Install the body as a sourced fragment and pull it
  # in from the login profile Home Manager generates.
  xdg.configFile."dotfiles/profile.sh".source = assetsDir + "/profile";

  programs.bash.profileExtra = ''
    if [ -r "$HOME/.config/dotfiles/profile.sh" ]; then
      . "$HOME/.config/dotfiles/profile.sh"
    fi
  '';
}
