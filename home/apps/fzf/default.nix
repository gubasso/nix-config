# fzf command-line fuzzy finder and bash completion tuning.
#
# fzf-tab-completion (lincheney's bash port) is a fully nix-managed dependency:
# it is vendored as `pkgs.fzf-tab-completion` (pkgs/fzf-tab-completion, wired in
# overlays/default.nix) and sourced below directly from the nix store — no
# runtime `/usr/share`/homebrew/XDG discovery.
{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline-right"
      "--marker='▏'"
      "--pointer='▌'"
      "--prompt='  '"
      "--bind='ctrl-/:toggle-preview'"
      "--bind='ctrl-d:half-page-down'"
      "--bind='ctrl-u:half-page-up'"
    ];
    fileWidget.options = [
      "--walker-skip .git,node_modules,target,.venv,__pycache__"
      "--preview 'bat -n --color=always --line-range :500 {} 2>/dev/null || cat {}'"
      "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
    ];
    changeDirWidget.options = [
      "--walker-skip .git,node_modules,target,.venv,__pycache__"
      "--preview 'ls -1 --color=always {} | head -50'"
    ];
  };

  programs.bash.initExtra = ''
    export FZF_COMPLETION_AUTO_COMMON_PREFIX=true
    export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART=true

    # fzf-tab-completion, sourced from the nix store (fully nix-managed).
    source "${pkgs.fzf-tab-completion}/share/fzf-tab-completion/bash/fzf-bash-completion.sh"
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
  '';
}
