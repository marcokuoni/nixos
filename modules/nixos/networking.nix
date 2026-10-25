# Network: NetworkManager, firewall, local host names.
# VPN profiles are in vpn.nix.
{ pkgs, ... }:
{
  # Local DNS-over-HTTPS proxy. lb-pub blocks normal DNS (port 53/853),
  # but HTTPS works, so lb-pub sends its DNS here.
  systemd.services.doh-proxy = {
    description = "Local DNS-over-HTTPS proxy (used by lb-pub)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.dnsproxy}/bin/dnsproxy --listen=127.0.0.1 --port=53 --upstream=https://1.1.1.1/dns-query --upstream=https://9.9.9.9/dns-query --cache";
      DynamicUser = true;
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      Restart = "on-failure";
    };
  };
  networking = {
    networkmanager = {
      enable = true;
      # VPN plugins for OpenVPN and OpenConnect (Cisco/Fortinet)
      plugins = with pkgs; [
        networkmanager-openvpn
        (networkmanager-openconnect.override { withGnome = true; })
      ];
    };

    # local dev domains and the lab server
    extraHosts = ''
      127.0.0.1 bank-avera.local
      127.0.0.1 ksgl.local
      127.0.0.1 lemonbrain.local
      127.0.0.1 backoffice.local
      127.0.0.1 formidable.local
      127.0.0.1 kulturkarussell.local
      127.0.0.1 innovationsbox.internal
      152.96.10.67 ins-lab
    '';

    # Xdebug (PHP) connects from containers to the host. Open it only on the
    # Docker bridges (docker0, and br-* for docker-compose networks), not on
    # Wi-Fi. PHP on the host itself uses localhost, which is always allowed.
    firewall.interfaces = {
      docker0.allowedTCPPorts = [ 9003 ];
      "br-+".allowedTCPPorts = [ 9003 ];
    };

    # needed for VPN DNS to work correctly with NetworkManager
    resolvconf.enable = true;

    nat = {
      enable = true;
      internalInterfaces = [ "enp1s0f0" ]; # robot cable
      externalInterface = "wlp2s0"; # your Wi-Fi
    };
  };
}
