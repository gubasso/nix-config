# SSH agent (fixed socket) + GPG agent + KWallet wiring. Asset files come from
# the consumer's tree via `publicAssetsDir` (threaded by lib/mk-host.nix).
{ pkgs, publicAssetsDir, ... }:

{
  # Back the SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket exported in
  # env-shell.nix. NixOS does not enable the openssh-shipped ssh-agent user unit
  # automatically. Run the agent on the fixed path at login; ExecStartPre clears
  # a stale socket so `ssh-agent -a` can rebind. gpg-agent SSH support stays off
  # so the two do not contend for the socket.
  systemd.user.services.ssh-agent = {
    Unit.Description = "SSH authentication agent (fixed socket)";
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/ssh-agent.socket";
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.socket";
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 604800;
    enableSshSupport = false;
    # TODO: switch to a KWallet-specific pinentry if nixpkgs exposes one.
    pinentry.package = pkgs.pinentry-qt;
  };

  # dock-audio ships inside pkgs.dwm-session; no HM user unit is needed.
  xdg.configFile."kwalletrc".source = publicAssetsDir + "/kwallet/kwalletrc";

  home.file.".local/bin/ssh-askpass-rofi" = {
    source = publicAssetsDir + "/bin/ssh-askpass-rofi";
    executable = true;
  };
}
