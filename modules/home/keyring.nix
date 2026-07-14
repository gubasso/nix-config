# GPG agent wiring. SSH agent, askpass, and KWallet assets live in co-located
# home/apps modules.
{ pkgs, ... }:

{
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 604800;
    enableSshSupport = false;
    # TODO: switch to a KWallet-specific pinentry if nixpkgs exposes one.
    pinentry.package = pkgs.pinentry-qt;
  };
}
