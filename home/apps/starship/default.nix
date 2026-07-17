# Starship prompt themes and TTY variant switch.
{
  pkgs,
  hostSettings,
  ...
}:

let
  # starship owns its theme emitter (ADR-0018), built from lib/theme primitives.
  emit = import ./theme.nix { inherit (pkgs) themeLib; };
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
  # Select the generated palette and append its [palettes.theme] table. The
  # prompt's styles reference standard color names (blue/red/green/...), which
  # the palette remaps to theme hex — no style edits needed.
  mkStarshipToml =
    base:
    pkgs.writeText "starship.toml" ''
      palette = "theme"
      ${builtins.readFile base}

      ${emit.mkStarshipPalette theme}
    '';
in
{
  programs.starship.enable = true;
  xdg.configFile = {
    "starship.toml".source = mkStarshipToml ./starship.toml;
    "starship-tty.toml".source = mkStarshipToml ./starship-tty.toml;
  };
  programs.bash.initExtra = ''
    if [[ -t 1 && -z "''${DISPLAY:-}" && -z "''${WAYLAND_DISPLAY:-}" ]]; then
      export STARSHIP_CONFIG="$HOME/.config/starship-tty.toml"
    fi
  '';
}
