{ ... }:

{
  # Let NetworkManager own DNS (VPN split-DNS, captive portals). Do NOT use
  # dns = "none" or freeze /etc/resolv.conf. Mirrors _docs/hosts/nova/firewall-and-dns.md.
  networking.networkmanager = {
    enable = true;
    dns = "default";
  };

  # Default-deny inbound, default-allow outbound (NixOS firewall defaults).
  # mDNS (5353/udp) is optional per nova's doc, not baseline -> not opened here.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };
}
