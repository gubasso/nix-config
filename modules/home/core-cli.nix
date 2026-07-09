# CLI shell base: bash + starship + the terminal tool belt, plus the config
# assets they read. Asset files come from the consumer's tree via `assetsDir`
# (threaded by lib/mk-host.nix); `hostname` selects the per-host bash fragment.
{
  pkgs,
  hostname,
  assetsDir,
  ...
}:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      n = "nvim";
      sn = "sudoedit";
      ll = "eza -la";
      ls = "eza";
      cat = "bat";
      tree = "eza --tree --all --git-ignore --ignore-glob .git";
      su = "systemctl --user";
      ss = "sudo systemctl";
    };
    initExtra = ''
      # GPG_TTY is terminal-specific (see environment.d/60-gpg.conf, which only
      # carries a placeholder). Set it per interactive shell and refresh the
      # agent's tty so pinentry can prompt over TTY/SSH sessions.
      GPG_TTY="$(tty)"
      export GPG_TTY
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true

      if [ -r "$HOME/.config/bash/hosts/${hostname}.bash" ]; then
        . "$HOME/.config/bash/hosts/${hostname}.bash"
      fi
    '';
  };

  programs.starship.enable = true;
  programs.git.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;

  # Auto-activate per-project Nix devShells (and their layered Poetry venvs) on
  # cd. nix-direnv caches the flake eval; the default bash integration installs
  # the prompt hook.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Adopt the 26.05 defaults (providers off) instead of the stateVersion<26.05
    # legacy default; no Ruby/Python remote-plugin providers, smaller closure.
    withRuby = false;
    withPython3 = false;
  };

  home.packages = with pkgs; [
    bottom
    fd
    ripgrep
    trash-cli
    yazi
    yt-dlp
  ];

  # Per-host bash fragment; the consumer's assetsDir must carry
  # bash/hosts/<hostname>.bash for each host it builds.
  xdg.configFile."bash/hosts/${hostname}.bash".source = assetsDir + "/bash/hosts/${hostname}.bash";
  xdg.configFile."starship.toml".source = assetsDir + "/starship/starship.toml";
  xdg.configFile."starship-tty.toml".source = assetsDir + "/starship/starship-tty.toml";
  xdg.configFile."git/allowed_signers".source = assetsDir + "/git/allowed_signers";
  xdg.configFile."direnv/direnvrc".source = assetsDir + "/direnv/direnvrc";
  xdg.configFile."direnv/direnv.toml".source = assetsDir + "/direnv/direnv.toml";
  xdg.configFile."nvim".source = assetsDir + "/nvim";
  xdg.configFile."yazi/yazi.toml".source = assetsDir + "/yazi/yazi.toml";
  xdg.configFile."yazi/init.lua".source = assetsDir + "/yazi/init.lua";
  xdg.configFile."yazi/theme.toml".source = assetsDir + "/yazi/theme.toml";
  xdg.configFile."yazi/package.toml".source = assetsDir + "/yazi/package.toml";
  # theme.toml selects the `everforest-medium` flavor, which yazi loads from
  # ~/.config/yazi/flavors/everforest-medium.yazi/. Vendor it so the flavor
  # reference resolves on a fresh activation.
  xdg.configFile."yazi/flavors/everforest-medium.yazi".source =
    assetsDir + "/yazi/flavors/everforest-medium.yazi";
  xdg.configFile."yt-dlp/config".source = assetsDir + "/yt-dlp/config";
  xdg.configFile."gnupg/gpg-agent.conf".source = assetsDir + "/gpg/gpg-agent.conf";
  home.file.".ssh/config".source = assetsDir + "/ssh/config";
}
