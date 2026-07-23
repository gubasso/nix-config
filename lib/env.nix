# Environment-variable delivery machinery: render a typed env catalog into one
# delivery channel. The DATA (which vars, which channels) is a consumer-private
# catalog (nix-secrets catalog/env.nix); this file is the pure, generic renderer —
# the env analog of lib/theme/fonts.nix `fontPackagesFor`. Exposed to modules as
# `pkgs.envLib` (overlay) and on the flake as `lib.env`.
#
# A catalog is `{ vars = { NAME = entry; ... }; path = [ ... ]; }` where each
# entry is `{ value; channels; hosts?; }`:
#   value    - a string, or a function of a ctx attrset
#              ({ config, pkgs, lib, hostname, hostSettings, theme }) resolved at
#              module-eval time (keeps the catalog build-input-free, like fonts'
#              `pkg = p: ...`).
#   channels - the delivery channels that carry it: "shell" (hm-session-vars.sh,
#              refreshes per new terminal) and/or "gui" (systemd-user
#              environment.d, refreshes at re-login). A locale-class var uses both.
#   hosts    - optional hostname allowlist; omitted = every host.
{ lib }:
{
  # Render one channel: keep entries tagged for `channel` and permitted on
  # `hostname`, then resolve each value against `ctx`. Returns a NAME -> string
  # attrset ready to assign to home.sessionVariables / systemd.user.sessionVariables.
  renderChannel =
    {
      channel,
      catalog,
      ctx,
      hostname,
    }:
    lib.mapAttrs (_: e: if lib.isFunction e.value then e.value ctx else e.value) (
      lib.filterAttrs (
        _: e: lib.elem channel e.channels && (!(e ? hosts) || lib.elem hostname e.hosts)
      ) catalog
    );
}
