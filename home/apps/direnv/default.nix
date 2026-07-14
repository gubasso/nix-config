# direnv and nix-direnv, plus dctl one-shot env export support.
_:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  xdg.configFile = {
    "direnv/direnvrc".source = ./direnvrc;
    "direnv/direnv.toml".source = ./direnv.toml;
  };

  programs.bash.initExtra = ''
    if [[ -n "''${DCTL_SANDBOX:-}" && -n "''${BASH_EXECUTION_STRING:-}" ]]; then
      eval "$(direnv export bash)"
    fi
  '';
}
