# Starship prompt themes and TTY variant switch.
_:

{
  programs.starship.enable = true;
  xdg.configFile = {
    "starship.toml".source = ./starship.toml;
    "starship-tty.toml".source = ./starship-tty.toml;
  };
  programs.bash.initExtra = ''
    if [[ -t 1 && -z "''${DISPLAY:-}" && -z "''${WAYLAND_DISPLAY:-}" ]]; then
      export STARSHIP_CONFIG="$HOME/.config/starship-tty.toml"
    fi
  '';
}
