# kitty terminal: package (GL-wrapped) + whole-directory native config mapped
# with mkRealConfigDir (like nvim), helper scripts, and titlebar prompt hook.
{
  pkgs,
  config,
  lib,
  hostSettings,
  ...
}:

let
  # current-theme.conf (kitty's `include` target) is generated from the host's
  # theme (lib/theme emitter), overlaid onto the vendored ./config dir. Only the
  # colors are derived; kitty.conf keeps its static `include current-theme.conf`.
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
  kittyThemeDir = pkgs.runCommandLocal "kitty-theme" { } ''
    mkdir -p "$out"
    cp ${pkgs.writeText "current-theme.conf" (pkgs.themeLib.mkKittyTheme theme)} "$out/current-theme.conf"
  '';
in
{
  home = {
    # Install kitty GL-wrapped for generic-linux hosts (identity wrap on NixOS),
    # the same pattern as home/apps/browser. Replaces programs.kitty.package.
    packages = [ (config.lib.nixGL.wrap pkgs.kitty) ];

    # Reload running kitties after a switch (replaces programs.kitty's onChange).
    # ctrl+shift+r (load_config_file) is the manual equivalent.
    activation.kittyReload = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD pkill -USR1 -u "$USER" kitty || true
    '';

    file = {
      ".local/bin/kitty-dctl-pair" = {
        source = ./bin/kitty-dctl-pair;
        executable = true;
      };
      ".local/bin/kitty-mode-help" = {
        source = ./bin/kitty-mode-help;
        executable = true;
      };
    };
  };

  # The whole ~/.config/kitty is one vendored directory (kitty.conf + kittens +
  # includes + current-theme.conf), mapped as a single real-file store dir —
  # mirrors nvim. mkDefault yields to a private per-host overlay (nix-secrets
  # shadows host.conf). Replaces programs.kitty's generated kitty.conf and the
  # former per-file xdg.configFile entries.
  xdg.configFile."kitty".source = lib.mkDefault (pkgs.mkRealConfigDir "kitty" ./config kittyThemeDir);

  programs.bash.initExtra = ''
    if [[ -n "''${KITTY_WINDOW_ID:-}" && -z "''${NVIM:-}" ]]; then
      __kitty_title_precmd() {
        local last_status=$?
        local p="''${PWD/#$HOME/\~}" cwd last rest second branch dirty="" exit_str=""

        cwd=$p
        last=''${p##*/}
        rest=''${p%/*}
        second=''${rest##*/}
        [[ "$p" == */*/* ]] && cwd="$second/$last"

        branch=$(command git symbolic-ref --short HEAD 2>/dev/null) ||
          branch=$(command git rev-parse --short HEAD 2>/dev/null) ||
          branch=""
        if [[ -n "$branch" ]]; then
          command git diff --quiet HEAD -- 2>/dev/null || dirty='*'
        fi
        ((last_status != 0)) && exit_str=$last_status

        command kitten @ set-user-vars \
          KITTY_SHELL_CWD="$cwd" \
          KITTY_SHELL_BRANCH="$branch" \
          KITTY_SHELL_DIRTY="$dirty" \
          KITTY_SHELL_EXIT_CODE="$exit_str" \
          KITTY_NVIM="" \
          >/dev/null 2>&1 || true
        command kitten @ set-window-title --temporary "$cwd" >/dev/null 2>&1 ||
          printf '\033]2;%s\a' "$cwd"
        return "$last_status"
      }

      if [[ ";''${PROMPT_COMMAND:-};" != *";__kitty_title_precmd;"* ]]; then
        if [[ -n "''${PROMPT_COMMAND:-}" ]]; then
          PROMPT_COMMAND="__kitty_title_precmd;''${PROMPT_COMMAND}"
        else
          PROMPT_COMMAND='__kitty_title_precmd'
        fi
      fi
    fi
  '';
}
