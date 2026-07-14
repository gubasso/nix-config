# SSH agent service and rofi askpass helper.
{ pkgs, ... }:

{
  systemd.user.services.ssh-agent = {
    Unit.Description = "SSH authentication agent (fixed socket)";
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/ssh-agent.socket";
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.socket";
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.file.".local/bin/ssh-askpass-rofi" = {
    source = ./ssh-askpass-rofi;
    executable = true;
  };
}
