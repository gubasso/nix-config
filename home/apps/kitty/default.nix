# kitty terminal package, native config, helper scripts, and titlebar prompt hook.
{
  pkgs,
  config,
  hostSettings,
  ...
}:

let
  kittyTheme = hostSettings.kittyTheme or "everforest_dark_hard";
in
{
  programs.kitty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.kitty;

    font = {
      name = "Hack";
      size = 17.0;
    };

    themeFile = kittyTheme;

    shellIntegration = {
      mode = null;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    settings = {
      allow_remote_control = "socket-only";
      listen_on = "unix:/tmp/kitty-{kitty_pid}";
      shell_integration = "enabled no-title no-cursor";
      enabled_layouts = "splits:split_axis=horizontal,stack";
      tab_bar_style = "custom";
      tab_bar_min_tabs = 1;
      paste_actions = "quote-urls-at-prompt,filter";
    };

    extraConfig = ''
      map ctrl+shift+r load_config_file
      map ctrl+space>z kitten zoom_toggle_borders.py
      map ctrl+h neighboring_window left
      map ctrl+j neighboring_window down
      map ctrl+k neighboring_window up
      map ctrl+l neighboring_window right
      map --when-focus-on var:IS_NVIM ctrl+h
      map --when-focus-on var:IS_NVIM ctrl+j
      map --when-focus-on var:IS_NVIM ctrl+k
      map --when-focus-on var:IS_NVIM ctrl+l
      map ctrl+shift+h move_window left
      map ctrl+shift+j move_window down
      map ctrl+shift+k move_window up
      map ctrl+shift+l move_window right
      map alt+shift+h resize_window wider 5
      map alt+shift+j resize_window shorter 5
      map alt+shift+k resize_window taller 5
      map alt+shift+l resize_window narrower 5
      map alt+shift+equal reset_window_sizes
      map ctrl+space>minus     launch --cwd=current --location=hsplit
      map ctrl+space>backslash launch --cwd=current --location=vsplit
      map alt+h remote_control resize-window -i 2  -a horizontal
      map alt+l remote_control resize-window -i -2 -a horizontal
      map alt+j remote_control resize-window -i 2  -a vertical
      map alt+k remote_control resize-window -i -2 -a vertical
      map ctrl+space>x close_window
      map --new-mode tabmove ctrl+space>m
      map --mode tabmove esc pop_keyboard_mode
      map --mode tabmove m   pop_keyboard_mode
      map --mode tabmove h     move_tab_backward
      map --mode tabmove left  move_tab_backward
      map --mode tabmove l     move_tab_forward
      map --mode tabmove right move_tab_forward
      map ctrl+space>, set_tab_title " "
      map ctrl+space>. kitten rename_tab_from_cwd.py
      map ctrl+space>t new_tab_with_cwd
      map ctrl+space>shift+t new_tab
      map ctrl+space>w close_tab
      map ctrl+space>alt+. move_tab_forward
      map ctrl+space>alt+, move_tab_backward
      map ctrl+space>s select_tab
      map ctrl+tab goto_tab -1
      map ctrl+space>n next_tab
      map ctrl+space>p previous_tab
      map ctrl+1 goto_tab 1
      map ctrl+2 goto_tab 2
      map ctrl+3 goto_tab 3
      map ctrl+4 goto_tab 4
      map ctrl+5 goto_tab 5
      map ctrl+6 goto_tab 6
      map ctrl+7 goto_tab 7
      map ctrl+8 goto_tab 8
      map ctrl+9 goto_tab 9
      map ctrl+0 goto_tab 10
      tab_separator " ┋ "
      tab_title_template "{index}:{title}{' [Z]' if layout_name == 'stack' and num_windows > 1 else '''}"
      active_tab_title_template "{index}:{title}{(' [' + ('…' if keyboard_mode == '__sequence__' else keyboard_mode) + ']') if keyboard_mode else '''}{' [Z]' if layout_name == 'stack' and num_windows > 1 else '''}"
      draw_window_borders_for_single_window no
      draw_minimal_borders yes
      window_margin_width 0
      single_window_margin_width 0
      window_border_width 0.5pt
      inactive_text_alpha 0.5
      include kitty-copy-mode.conf
      include kitty-editor-mode.conf
      map --new-mode agents --on-action end ctrl+space>a
      map --mode agents esc pop_keyboard_mode
      map --mode agents a launch --type=background --allow-remote-control --cwd=current kitty-dctl-pair
      map --mode agents i set_tab_title (agents-idle)
    '';
  };

  xdg.configFile = {
    "kitty/kitty-copy-mode.conf".source = ./kitty-copy-mode.conf;
    "kitty/kitty-editor-mode.conf".source = ./kitty-editor-mode.conf;
    "kitty/tab_bar.py".source = ./tab_bar.py;
    "kitty/neighboring_window.py".source = ./neighboring_window.py;
    "kitty/zoom_toggle_borders.py".source = ./zoom_toggle_borders.py;
    "kitty/rename_tab_from_cwd.py".source = ./rename_tab_from_cwd.py;
    "kitty/paste-actions.py".source = ./paste-actions.py;
  };

  home.file = {
    ".local/bin/kitty-dctl-pair" = {
      source = ./bin/kitty-dctl-pair;
      executable = true;
    };
    ".local/bin/kitty-mode-help" = {
      source = ./bin/kitty-mode-help;
      executable = true;
    };
  };

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
