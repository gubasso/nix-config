# yazi terminal file manager (backs yazi.nvim) managed via Home Manager's
# programs.yazi so its plugins are declared and pinned by Nix (flake inputs in
# flake.nix). The package is WRAPPED (pkgs.yazi.override extraPackages) so the
# plugins' CLI dependencies sit on yazi's own private PATH -- they don't have to
# be on the user's PATH. The nixpkgs yazi wrapper already carries the preview
# stack (jq, poppler-utils, _7zz, ffmpeg-headless, fd, ripgrep, fzf, zoxide,
# imagemagick, chafa, resvg), so only the extra plugin tools are added here.
{ pkgs, inputs, ... }:

let
  # Official plugins live in subdirectories of the yazi-rs/plugins monorepo.
  yaziPlugins = inputs.yazi-plugins;
  official = name: "${yaziPlugins}/${name}.yazi";
in
{
  programs.yazi = {
    enable = true;

    # Wrap yazi with the plugin CLI dependencies on its private PATH:
    #   ouch      -> ouch.yazi (archive create/preview)
    #   mediainfo -> mediainfo.yazi (audio/video metadata previews)
    #   udisks    -> mount.yazi (udisksctl)
    #   util-linux-> mount.yazi (lsblk, eject)
    package = pkgs.yazi.override {
      extraPackages = [
        pkgs.ouch
        pkgs.mediainfo
        pkgs.udisks
        pkgs.util-linux
      ];
    };

    # Setup calls for plugins that need them (git, smart-enter).
    initLua = ./init.lua;

    # name -> plugin source. HM symlinks each to ~/.config/yazi/plugins/<name>.yazi.
    plugins = {
      chmod = official "chmod";
      git = official "git";
      mount = official "mount";
      piper = official "piper";
      smart-paste = official "smart-paste";
      smart-enter = official "smart-enter";
      toggle-pane = official "toggle-pane";
      zoom = official "zoom";
      # Third-party plugins: the repo root is the plugin.
      ouch = inputs.ouch-yazi;
      mediainfo = inputs.mediainfo-yazi;
    };

    # yazi.toml: fetchers (git status column) + previewers/preloaders (ouch, mediainfo).
    settings = {
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];
        prepend_previewers = [
          # ouch.yazi: list archive contents in the preview pane.
          {
            mime = "application/{zip,gzip,x-bzip,x-bzip2,x-7z-compressed,x-tar,x-rar,x-xz,x-zstd,zstd}";
            run = "ouch";
          }
          {
            name = "*.{zip,rar,7z,tar,gz,tgz,bz2,xz,zst}";
            run = "ouch";
          }
          # mediainfo.yazi: audio/video metadata. Scoped to audio+video only so
          # images keep yazi's native (Kitty) image preview.
          {
            mime = "{audio,video}/*";
            run = "mediainfo";
          }
        ];
        prepend_preloaders = [
          {
            mime = "{audio,video}/*";
            run = "mediainfo";
          }
        ];
      };
    };

    # keymap.toml: prepend plugin bindings ahead of the defaults.
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod selected files";
        }
        {
          on = "M";
          run = "plugin mount";
          desc = "Mount manager";
        }
        {
          on = "T";
          run = "plugin toggle-pane min-preview";
          desc = "Toggle preview pane";
        }
        {
          on = "+";
          run = "plugin zoom 1";
          desc = "Zoom in preview";
        }
        {
          on = "-";
          run = "plugin zoom -1";
          desc = "Zoom out preview";
        }
        {
          on = "p";
          run = "plugin smart-paste";
          desc = "Smart paste into hovered dir";
        }
        {
          on = "<Enter>";
          run = "plugin smart-enter";
          desc = "Enter dir or open file";
        }
        {
          on = "l";
          run = "plugin smart-enter";
          desc = "Enter dir or open file";
        }
      ];
    };
  };
}
