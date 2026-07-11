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

        # bebash: load the standalone bebash framework (installed under
        # ~/.local/lib/bebash by the bebash project) if present. It autoloads
        # the personal overlay from ~/.local/share/bebash and ~/.config/bebash.
        if [ -r "$HOME/.local/lib/bebash/init.bash" ]; then
          . "$HOME/.local/lib/bebash/init.bash"
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
    git-cliff
    pi-coding-agent
    ripgrep
    shfmt
    trash-cli
  ];

  xdg.configFile = {
    "starship.toml".source = publicAssetsDir + "/starship/starship.toml";
    "starship-tty.toml".source = publicAssetsDir + "/starship/starship-tty.toml";
    "git/allowed_signers".source = publicAssetsDir + "/git/allowed_signers";
    "direnv/direnvrc".source = publicAssetsDir + "/direnv/direnvrc";
    "direnv/direnv.toml".source = publicAssetsDir + "/direnv/direnv.toml";
    "nvim".source = publicAssetsDir + "/nvim";
    "gnupg/gpg-agent.conf".source = publicAssetsDir + "/gpg/gpg-agent.conf";
  }
  // lib.optionalAttrs (privateAssetsDir != null) {
    "bash/hosts/${hostname}.bash".source = privateAssetsDir + "/bash/hosts/${hostname}.bash";
  };

  home.file = {
    ".inputrc".source = publicAssetsDir + "/bash/inputrc";
  };
}
