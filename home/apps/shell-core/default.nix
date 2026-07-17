# Core interactive shell behavior shared by every host.
{
  lib,
  pkgs,
  hostname,
  privateAppsDir ? null,
  hostSettings,
  ...
}:

let
  desktop = hostSettings.desktop or "none";
  # shell-core owns its theme emitter (ADR-0018), built from lib/theme primitives.
  emit = import ./theme.nix { inherit (pkgs) themeLib; };
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historySize = 5000;
    historyFileSize = 10000;
    historyControl = [
      "ignoreboth"
      "erasedups"
    ];
    historyIgnore = [
      "ls"
      "ll"
      "cd"
      "pwd"
      "exit"
      "clear"
      "cl"
    ];
    shellOptions = [
      "histappend"
      "checkwinsize"
      "globstar"
      "cdspell"
      "dirspell"
    ];
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      cl = "printf \"\\033[3J\" && clear";
      md = "mkdir -p";
      rms = "shred -n10 -uz";
      so = "source ~/.bashrc";
      su = "systemctl --user";
      ss = "sudo systemctl";
      sn = "sudoedit";
    }
    // lib.optionalAttrs (desktop == "dwm" || desktop == "kde") {
      clip = "xclip -selection clipboard";
    };
    # bebash: load the standalone bebash framework (installed under
    # ~/.local/lib/bebash by the bebash project) if present. It autoloads the
    # personal overlay from ~/.local/share/bebash and ~/.config/bebash.
    #
    # Sourced from bashrcExtra (which HM renders BEFORE its shellAliases/initExtra
    # block) so the fully-composed bebash setup (stock < user overlay) is the
    # base, and the personal Home-Manager config layers on top and WINS on any
    # conflict. bashrcExtra runs before HM's own interactive guard, and bebash is
    # interactive-only, so guard it ourselves.
    bashrcExtra = ''
      # Theme-driven UI palette (ADR-0002 __UI_SGR). Sourced before bebash so the
      # framework and scripts read the active theme's colors.
      if [[ $- == *i* ]] && [ -r "$HOME/.config/bash/theme-palette.bash" ]; then
        . "$HOME/.config/bash/theme-palette.bash"
      fi

      if [[ $- == *i* ]] && [ -r "$HOME/.local/lib/bebash/init.bash" ]; then
        . "$HOME/.local/lib/bebash/init.bash"
      fi
    '';
    initExtra = ''
      # GPG_TTY is terminal-specific, so it stays out of the session env SoT
      # (env-shell.nix). Set it per interactive shell and refresh the agent's
      # tty so pinentry can prompt over TTY/SSH sessions.
      GPG_TTY="$(tty)"
      export GPG_TTY
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true

      if [ -r "$HOME/.config/bash/hosts/${hostname}.bash" ]; then
        . "$HOME/.config/bash/hosts/${hostname}.bash"
      fi

      if [[ $- == *i* ]]; then
        bind 'set show-mode-in-prompt on'
        bind 'set vi-cmd-mode-string "\1\033[2 q\2[N] "'
        bind 'set vi-ins-mode-string "\1\033[6 q\2"'

        __readline_edit_buffer_no_exec() {
          local tmp_file editor_rc
          local -a editor_cmd

          tmp_file=$(mktemp "''${TMPDIR:-/tmp}/bash-editline.XXXXXX") || return 1
          printf '%s' "$READLINE_LINE" >"$tmp_file"

          if [[ -n "''${VISUAL:-}" ]]; then
            editor_cmd=("$VISUAL")
          elif [[ -n "''${EDITOR:-}" ]]; then
            editor_cmd=("$EDITOR")
          else
            editor_cmd=(vi)
          fi

          "''${editor_cmd[@]}" "$tmp_file"
          editor_rc=$?
          if [[ $editor_rc -eq 0 && -r "$tmp_file" ]]; then
            READLINE_LINE=$(<"$tmp_file")
            READLINE_POINT=''${#READLINE_LINE}
          fi
          rm -f -- "$tmp_file"
        }

        bind -m vi-insert '"\e[A": history-search-backward'
        bind -m vi-insert '"\e[B": history-search-forward'
        bind -m vi-command '"\e[A": history-search-backward'
        bind -m vi-command '"\e[B": history-search-forward'
        bind -m vi-insert '"\C-p": history-search-backward'
        bind -m vi-insert '"\C-n": history-search-forward'
        bind -m vi-command '"\C-p": history-search-backward'
        bind -m vi-command '"\C-n": history-search-forward'
        bind -m vi-insert '"\e[1;5C": forward-word'
        bind -m vi-insert '"\e[1;5D": backward-word'
        bind -m vi-command '"\e[1;5C": forward-word'
        bind -m vi-command '"\e[1;5D": backward-word'
        bind -m vi-insert -x '"\C-g": __readline_edit_buffer_no_exec'
        bind -m vi-command -x '"\C-g": __readline_edit_buffer_no_exec'
      fi
    '';
  };

  home.packages = lib.optionals (desktop == "dwm" || desktop == "kde") [ pkgs.xclip ];

  home.file.".inputrc".source = ./inputrc;

  xdg.configFile = {
    "bash/theme-palette.bash".text = emit.mkBashPalette theme;
  }
  //
    lib.optionalAttrs
      (
        privateAppsDir != null
        && builtins.pathExists (privateAppsDir + "/shell-core/hosts/${hostname}.bash")
      )
      {
        "bash/hosts/${hostname}.bash".source = privateAppsDir + "/shell-core/hosts/${hostname}.bash";
      };
}
