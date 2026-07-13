# kitty terminal — native Home Manager config (SoT for both the package and the
# config; replaces the former vendored ~/.config/kitty whole-dir asset).
#
# - `programs.kitty` GENERATES ~/.config/kitty/kitty.conf. Simple scalars live in
#   `settings`; the font and theme use the native `font`/`themeFile` knobs; the
#   keymaps, custom keyboard modes, quoted tab templates and post-theme border
#   block live in `extraConfig` (the module can't model modes/`--when-focus-on`,
#   and `settings` renders unquoted `key value` which would drop template quoting).
# - THEME is per-host: `hostSettings.kittyTheme` selects an upstream
#   `pkgs.kitty-themes` theme (validated at eval time). Set it per host in the
#   consumer flake; the default preserves the prior everforest-dark-hard look.
# - nixGL: the module adds `cfg.package` to `home.packages`, so we hand it the
#   nixGL-wrapped kitty — a no-op on NixOS, the real GL wrapper on generic-linux
#   (without this the module would install a bare pkgs.kitty and reintroduce the
#   `GLX: No GLXFBConfigs` failure on non-NixOS hosts).
# - Kittens (Python) and the copy/editor mode `include`d confs are logic, not
#   settings; they ship per-file into the config dir. `tab_bar_style custom`
#   auto-loads tab_bar.py; `paste_actions …,filter` loads filter_paste from
#   paste-actions.py.
{
  pkgs,
  config,
  publicAssetsDir,
  hostSettings,
  ...
}:

let
  kittyTheme = hostSettings.kittyTheme or "everforest_dark_hard";
in
{
  programs.kitty = {
    enable = true;
    # nixGL-wrapped (identity on NixOS). This is what installs kitty into the
    # profile — do NOT also list kitty in apps.nix's home.packages.
    package = config.lib.nixGL.wrap pkgs.kitty;

    font = {
      name = "Hack";
      size = 17.0;
    };

    # Per-host theme from upstream kitty-themes (module emits its include at
    # order 520, before settings/extraConfig — so the border block below wins).
    themeFile = kittyTheme;

    # Disable the module's own shell-integration wiring: keep kitty's native
    # auto-integration exactly as the vendored config did (the `shell_integration`
    # line is set in `settings` below). mode=null requires the three enable*
    # options to be off (module assertion) and prevents any shell-rc injection.
    shellIntegration = {
      mode = null;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    # Plain scalar settings (rendered as `key value`). Quoted values
    # (tab_separator, tab_title templates) stay in extraConfig to preserve quoting.
    settings = {
      # Reload config is a keybinding (see extraConfig).
      # Socket-only remote control: accepts the Unix socket, denies TTY escape
      # codes. Safe for kitty-scrollback.nvim (its recommended setting).
      allow_remote_control = "socket-only";
      # Filesystem socket (not abstract @) so devcontainers can bind-mount it.
      listen_on = "unix:/tmp/kitty-{kitty_pid}";
      # Shell integration (required for @last_cmd_output, kitty-scrollback.nvim).
      shell_integration = "enabled no-title no-cursor";
      enabled_layouts = "splits:split_axis=horizontal,stack";
      tab_bar_style = "custom";
      tab_bar_min_tabs = 1;
      # Paste filter: strip trailing newlines only (filter_paste in paste-actions.py).
      paste_actions = "quote-urls-at-prompt,filter";
    };

    extraConfig = ''
      # ================================================================
      # Global
      # ================================================================

      # Reload config
      map ctrl+shift+r load_config_file

      # ================================================================
      # Layouts / "Zoom"
      # ================================================================

      # IMPORTANT: replace builtin toggle_layout with a kitten that forces relayout.
      # This prevents the "active border disappears after zoom-out" state.
      map ctrl+space>z kitten zoom_toggle_borders.py

      # ================================================================
      # Window focus / navigation / resize
      # ================================================================

      # Smart navigation: Ctrl+h/j/k/l moves between kitty panes OR neovim splits
      map ctrl+h neighboring_window left
      map ctrl+j neighboring_window down
      map ctrl+k neighboring_window up
      map ctrl+l neighboring_window right

      # When neovim is focused, unmap Ctrl+h/j/k/l so smart-splits receives keys
      map --when-focus-on var:IS_NVIM ctrl+h
      map --when-focus-on var:IS_NVIM ctrl+j
      map --when-focus-on var:IS_NVIM ctrl+k
      map --when-focus-on var:IS_NVIM ctrl+l

      # Swap / move active pane directionally
      map ctrl+shift+h move_window left
      map ctrl+shift+j move_window down
      map ctrl+shift+k move_window up
      map ctrl+shift+l move_window right

      map alt+shift+h resize_window wider 5
      map alt+shift+j resize_window shorter 5
      map alt+shift+k resize_window taller 5
      map alt+shift+l resize_window narrower 5
      map alt+shift+equal reset_window_sizes

      # ================================================================
      # Splits
      # ================================================================

      # Create splits
      map ctrl+space>minus     launch --cwd=current --location=hsplit
      map ctrl+space>backslash launch --cwd=current --location=vsplit

      # Fine resize via remote control
      map alt+h remote_control resize-window -i 2  -a horizontal
      map alt+l remote_control resize-window -i -2 -a horizontal
      map alt+j remote_control resize-window -i 2  -a vertical
      map alt+k remote_control resize-window -i -2 -a vertical

      # Close the focused split (kitty window)
      map ctrl+space>x close_window

      # ================================================================
      # Tabs
      # ================================================================

      # Tab "move mode"
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

      # ================================================================
      # UI / Tabs (quoted values — kept here to preserve quoting)
      # ================================================================

      tab_separator " ┋ "

      # Optional (recommended): always show the current layout name in the tab title.
      # This gives you a second "zoom" cue even if you miss the border change.
      # (layout_name is a supported variable for tab_title_template)
      # NB: the triple single-quote below is the Nix escape for a literal empty
      # string; kitty receives a standard Python empty-string in the template.
      tab_title_template "{index}:{title}{' [Z]' if layout_name == 'stack' and num_windows > 1 else '''}"
      active_tab_title_template "{index}:{title}{(' [' + ('…' if keyboard_mode == '__sequence__' else keyboard_mode) + ']') if keyboard_mode else '''}{' [Z]' if layout_name == 'stack' and num_windows > 1 else '''}"

      # ================================================================
      # Borders / Visual cues (KEEP THIS AFTER THE THEME INCLUDE)
      # ================================================================

      # 1) Hide border when only one window is visible (cleaner look).
      #    Borders appear when splits exist: active gets active_border_color.
      draw_window_borders_for_single_window no

      # 2) Minimal borders: thin line only where windows touch (no full rectangles).
      #    Requires window_margin_width 0 (margin overrides minimal mode).
      draw_minimal_borders yes
      window_margin_width 0
      single_window_margin_width 0

      # Border appearance (colors come from theme, inactive matches background)
      window_border_width 0.5pt

      # Fade inactive windows for visual distinction
      inactive_text_alpha 0.5

      # ================================================================
      # Copy/Selection Workflow
      # ================================================================
      include kitty-copy-mode.conf
      include kitty-editor-mode.conf

      # ================================================================
      # Agents mode (ctrl+space>a)
      # ================================================================
      map --new-mode agents --on-action end ctrl+space>a
      map --mode agents esc pop_keyboard_mode
      map --mode agents a launch --type=background --allow-remote-control --cwd=current kitty-dctl-pair
      map --mode agents i set_tab_title (agents-idle)
    '';
  };

  # Kittens + mode-include confs (logic, not settings) shipped per-file into the
  # config dir. relative_resize.py/split_window.py are intentionally omitted —
  # superseded by the builtin remote_control resize / launch --location splits.
  xdg.configFile = {
    "kitty/kitty-copy-mode.conf".source = publicAssetsDir + "/kitty/kitty-copy-mode.conf";
    "kitty/kitty-editor-mode.conf".source = publicAssetsDir + "/kitty/kitty-editor-mode.conf";
    "kitty/tab_bar.py".source = publicAssetsDir + "/kitty/tab_bar.py";
    "kitty/neighboring_window.py".source = publicAssetsDir + "/kitty/neighboring_window.py";
    "kitty/zoom_toggle_borders.py".source = publicAssetsDir + "/kitty/zoom_toggle_borders.py";
    "kitty/rename_tab_from_cwd.py".source = publicAssetsDir + "/kitty/rename_tab_from_cwd.py";
    "kitty/paste-actions.py".source = publicAssetsDir + "/kitty/paste-actions.py";
  };
}
