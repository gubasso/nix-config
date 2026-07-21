{ pkgs }:

# fzf-tab-completion — lincheney's fzf-driven TAB completion for bash. It is NOT
# packaged in nixpkgs, so nix-config vendors it here as a first-class,
# fully nix-managed dependency (pinned by rev+hash), exposed as
# `pkgs.fzf-tab-completion` via overlays/default.nix. Only the sourceable bash
# script is installed, into $out/share/fzf-tab-completion/bash/. The fzf app
# module (home/apps/fzf) sources it from the store path — no runtime discovery.
pkgs.stdenvNoCC.mkDerivation {
  pname = "fzf-tab-completion";
  version = "0-unstable-2026-07-14";

  src = pkgs.fetchFromGitHub {
    owner = "lincheney";
    repo = "fzf-tab-completion";
    rev = "8ba35e65bb3792759bf17c134ce04120e5940555";
    hash = "sha256-qod3C01EK5S0Tm6rp2ia0dPVFMKRGaozpNaLQF+O9Xw=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 bash/fzf-bash-completion.sh \
      "$out/share/fzf-tab-completion/bash/fzf-bash-completion.sh"
    runHook postInstall
  '';

  meta = {
    description = "Tab completion using fzf for bash (lincheney's port)";
    homepage = "https://github.com/lincheney/fzf-tab-completion";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.all;
  };
}
