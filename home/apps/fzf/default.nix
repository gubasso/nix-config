# fzf command-line fuzzy finder and bash completion tuning.
#
# fzf-tab-completion (lincheney's bash port) is a fully nix-managed dependency:
# it is vendored as `pkgs.fzf-tab-completion` (derivations/fzf-tab-completion, wired in
# overlays/default.nix) and sourced below directly from the nix store — no
# runtime `/usr/share`/homebrew/XDG discovery.
{ pkgs, lib, ... }:

let
  # Directory names fzf's built-in walker skips (CTRL-T, ALT-C, bare fzf,
  # ** completion). Bare names, matched at any depth — no globs.
  walkerSkipDirs = [
    # VCS
    ".git"
    ".hg"
    ".svn"
    ".jj"
    # Nix / direnv ("result" = nix-build symlink; the walker follows symlinks
    # into /nix/store without it)
    ".direnv"
    "result"
    # JS / web dev
    "node_modules"
    "dist"
    "coverage"
    ".next"
    ".nuxt"
    ".svelte-kit"
    ".astro"
    ".turbo"
    ".vite"
    ".parcel-cache"
    ".cache"
    ".output"
    ".vercel"
    ".netlify"
    # Rust
    "target"
    # Zig (cache dir renamed zig-cache → .zig-cache in 0.13; both in the wild)
    ".zig-cache"
    "zig-cache"
    "zig-out"
    # Python
    ".venv"
    "venv"
    "__pycache__"
    ".mypy_cache"
    ".pytest_cache"
    ".ruff_cache"
    ".tox"
    ".nox"
    ".eggs"
    ".ipynb_checkpoints"
    ".hypothesis"
    "htmlcov"
    # Terraform
    ".terraform"
  ];
in
{
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--layout=reverse"
      "--border=rounded"
      "--info=inline-right"
      "--marker='▏'"
      "--pointer='▌'"
      "--prompt='  '"
      "--bind='ctrl-/:toggle-preview'"
      "--bind='ctrl-d:half-page-down'"
      "--bind='ctrl-u:half-page-up'"
      # Include directories (not just files) in fzf's built-in walker. This is
      # FZF_DEFAULT_OPTS, inherited by every bare `fzf` — including the one
      # `fzf.yazi` spawns for yazi's `z` jump, which then cd's into a chosen dir
      # and reveals a chosen file. `--walker-skip` (below) still prunes the noise.
      "--walker=file,dir,follow,hidden"
      "--walker-skip=${lib.concatStringsSep "," walkerSkipDirs}"
    ];
    fileWidget.options = [
      "--preview 'bat -n --color=always --line-range :500 {} 2>/dev/null || cat {}'"
      "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
    ];
    changeDirWidget.options = [
      # ALT-C is change-dir: keep it directories-only. FZF_ALT_C_OPTS is appended
      # after FZF_DEFAULT_OPTS, and fzf takes the last `--walker`, so this re-pins
      # dirs-only and overrides the global `file,dir` walker above for ALT-C.
      "--walker=dir,follow,hidden"
      "--preview 'ls -1 --color=always {} | head -50'"
    ];
  };

  programs.bash.initExtra = ''
    export FZF_COMPLETION_AUTO_COMMON_PREFIX=true
    export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART=true

    # fzf-tab-completion, sourced from the nix store (fully nix-managed).
    #
    # Guarded on readability because ~/.bashrc is a HOST Home-Manager artifact
    # that dctl bind-mounts into containers with their own, separate /nix. Every
    # absolute store path baked in here is a bet that the container's store holds
    # the identical derivation; most win by coincidence (same nixpkgs rev), and
    # this one cannot — fzf-tab-completion is vendored in THIS repo's overlay, so
    # nothing built from plain nixpkgs will ever have the path. Unguarded it
    # printed "No such file or directory" on every container shell. Degrade to
    # stock readline completion instead of erroring.
    if [ -r "${pkgs.fzf-tab-completion}/share/fzf-tab-completion/bash/fzf-bash-completion.sh" ]; then
      source "${pkgs.fzf-tab-completion}/share/fzf-tab-completion/bash/fzf-bash-completion.sh"

      # The \t binding calls fzf_bash_completion, so it only makes sense once the
      # source above actually defined it — keep it inside the guard.
      if [[ $- == *i* ]]; then
        bind '"\e[0n": complete' 2>/dev/null || true
        __fzf_tab_or_trigger() {
          local trigger=''${FZF_COMPLETION_TRIGGER-**}
          if [[ "''${READLINE_LINE:0:$READLINE_POINT}" == *"$trigger" ]]; then
            builtin printf '\033[5n'
          else
            fzf_bash_completion
          fi
        }
        bind -x '"\t": __fzf_tab_or_trigger' 2>/dev/null || true
      fi
    fi
  '';
}
