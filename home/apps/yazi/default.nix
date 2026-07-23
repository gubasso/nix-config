# yazi terminal file manager (backs yazi.nvim) managed via Home Manager's
# programs.yazi so its plugins are declared and pinned by Nix. Plugin sources are
# fetched in this app dir (see the let block), not as loose flake.nix inputs, so
# the whole yazi setup stays self-contained here. The package is WRAPPED
# (pkgs.yazi.override extraPackages) so the
# plugins' CLI dependencies sit on yazi's own private PATH -- they don't have to
# be on the user's PATH. The nixpkgs yazi wrapper already carries the preview
# stack (jq, poppler-utils, _7zz, ffmpeg-headless, fd, ripgrep, fzf, zoxide,
# imagemagick, chafa, resvg), so only the extra plugin tools are added here.
{ pkgs, ... }:

let
  # Source pins fetched in-app, NOT as loose top-level flake.nix inputs: each
  # app's setup (source pins + wiring) stays scoped to home/apps/<app>/. Bump
  # rev + hash to update (a wrong hash fails at build, not `nix flake check`).
  # Official plugins live in subdirectories of the yazi-rs/plugins monorepo.
  yaziPlugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "bb758e2fd774738f14cd260642631ebbd568741a";
    hash = "sha256-uV5KZE+4gT/o7hzer/hwAfU5lyDYgMnRlsQX+BkCRhM=";
  };
  official = name: "${yaziPlugins}/${name}.yazi";

  # Third-party plugins: the repo root is the plugin.
  ouch-yazi = pkgs.fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "406ce6c13ec3a18d4872b8f64b62f4a530759b2c";
    hash = "sha256-14x/bD0aD9hXONaqQD8Dt7rLBCMq7bkVLH6uCPOQ0C8=";
  };
  mediainfo-yazi = pkgs.fetchFromGitHub {
    owner = "boydaihungst";
    repo = "mediainfo.yazi";
    rev = "e079a001f4fefd69007e515bbede4e16b95a811e";
    hash = "sha256-RIVcKJO89R4oaE6sJuFcV8pFK4nvWtq6ILAXehu4FIY=";
  };
in
{
  programs.yazi = {
    enable = true;

    # Launch-and-cd shell wrapper. Pinned explicitly so it doesn't depend on
    # home.stateVersion: HM's default moved from "yy" to "y" at stateVersion
    # 26.05, and pinning silences the transition warning on older stateVersions.
    shellWrapperName = "y";

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
      # Third-party plugins (fetched in the let block above).
      ouch = ouch-yazi;
      mediainfo = mediainfo-yazi;
    };

    # yazi.toml: fetchers (git status column) + previewers/preloaders (ouch, mediainfo).
    settings = {
      # Show dotfiles/hidden files by default (`.` still toggles at runtime).
      mgr = {
        show_hidden = true;
      };
      plugin = {
        # yazi >= v26.1.23 fetcher schema: `url` glob (not `name`), a required
        # `group` (only the first matching fetcher in a group runs), no `id`.
        prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];
        prepend_previewers = [
          # ouch.yazi: list archive contents in the preview pane.
          {
            mime = "application/{zip,gzip,x-bzip,x-bzip2,x-7z-compressed,x-tar,x-rar,x-xz,x-zstd,zstd}";
            run = "ouch";
          }
          {
            url = "*.{zip,rar,7z,tar,gz,tgz,bz2,xz,zst}";
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
          on = "<C-p>";
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
          run = "enter";
          desc = "Enter directory";
        }
        {
          on = "?";
          run = "help";
          desc = "Open help";
        }
        {
          on = [
            "g"
            "?"
          ];
          run = "help";
          desc = "Open help";
        }
        {
          on = [
            "g"
            "d"
          ];
          run = "cd ~/Downloads";
          desc = "Go to Downloads";
        }
        {
          on = [
            "g"
            "p"
          ];
          run = "cd ~/Projects";
          desc = "Go to Projects";
        }
        {
          on = [
            "g"
            "h"
          ];
          run = "cd ~";
          desc = "Go to Home (~)";
        }
        {
          on = [
            "g"
            "n"
          ];
          run = "cd ~/Nextcloud";
          desc = "Go to Nextcloud";
        }
        {
          on = [
            "g"
            "t"
          ];
          run = "cd ~/.local/share/Trash/files";
          desc = "Go to Trash";
        }
      ];
    };
  };
}
