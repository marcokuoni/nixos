# Network: NetworkManager, firewall, local host names.
# VPN profiles are in vpn.nix.
{ pkgs, ... }:
{
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
  };
}
