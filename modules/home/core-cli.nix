# CLI shell base: bash + starship + the terminal tool belt, plus the config
# assets they read. Generic files come from the public asset tree; private
# consumers can overlay per-host shell fragments from a private asset tree.
{
  lib,
  pkgs,
  hostname,
  publicAssetsDir,
  privateAssetsDir ? null,
  ...
}:

{
  programs = {
    bash = {
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

    starship.enable = true;
    git.enable = true;
    fzf.enable = true;
    zoxide.enable = true;
    eza.enable = true;
    bat.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withRuby = false;
      withPython3 = false;
    };
  };

  home.packages = with pkgs; [
    bottom
    fd
    ripgrep
    trash-cli
    yazi
    yt-dlp
  ];

  xdg.configFile = {
    "starship.toml".source = publicAssetsDir + "/starship/starship.toml";
    "starship-tty.toml".source = publicAssetsDir + "/starship/starship-tty.toml";
    "git/allowed_signers".source = publicAssetsDir + "/git/allowed_signers";
    "direnv/direnvrc".source = publicAssetsDir + "/direnv/direnvrc";
    "direnv/direnv.toml".source = publicAssetsDir + "/direnv/direnv.toml";
    "nvim".source = publicAssetsDir + "/nvim";
    "yazi/yazi.toml".source = publicAssetsDir + "/yazi/yazi.toml";
    "yazi/init.lua".source = publicAssetsDir + "/yazi/init.lua";
    "yazi/theme.toml".source = publicAssetsDir + "/yazi/theme.toml";
    "yazi/package.toml".source = publicAssetsDir + "/yazi/package.toml";
    "yazi/flavors/everforest-medium.yazi".source =
      publicAssetsDir + "/yazi/flavors/everforest-medium.yazi";
    "yt-dlp/config".source = publicAssetsDir + "/yt-dlp/config";
    "gnupg/gpg-agent.conf".source = publicAssetsDir + "/gpg/gpg-agent.conf";
  }
  // lib.optionalAttrs (privateAssetsDir != null) {
    "bash/hosts/${hostname}.bash".source = privateAssetsDir + "/bash/hosts/${hostname}.bash";
  };

  home.file.".ssh/config".source = publicAssetsDir + "/ssh/config";
}
