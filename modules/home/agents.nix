# AI coding-agent session wrappers: the declarative config for the
# `claude-session` and `codex-session` host wrappers. Only static, portable
# config lives here — never live/mutable state (credentials, auth caches,
# session directories, lock files), which the wrappers manage under HOME on
# their own. Work-specific and personal layers (the `suse` claude profile, the
# codex trusted-projects list) are overlaid by the private consumer.
#
# Each config tree is deployed as a SINGLE whole-directory symlink (via
# pkgs.mkRealConfigDir, which copies real files into one store path) instead
# of the usual per-file store symlinks. A dctl devcontainer bind-mounts these
# dirs but has its own /nix: Docker dereferences a whole-dir symlink source at
# mount time (so it resolves in the container), whereas per-file symlinks inside
# a mounted real dir dangle against the foreign /nix and the wrapper falls back
# to stock mode — losing claude-session's base layer (bypassPermissions, deny
# rules, hooks, statusLine). See overlays/default.nix for the full rationale.
#
# These are the portable BASE trees only (mkDefault). The private consumer
# re-materializes the tree with its own overlay via mkForce where it applies —
# codex trusted-projects on every private host, the `suse` claude profile on the
# SUSE work host — so per-host scope is preserved (no work profile leaks onto
# personal hosts).
{
  lib,
  pkgs,
  publicAssetsDir,
  ...
}:

{
  xdg.configFile = {
    "claude-session".source = lib.mkDefault (
      pkgs.mkRealConfigDir "claude-session" publicAssetsDir null
    );
    "codex-session".source = lib.mkDefault (pkgs.mkRealConfigDir "codex-session" publicAssetsDir null);
  };
}
