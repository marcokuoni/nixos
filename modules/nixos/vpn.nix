# VPN connections, created in NetworkManager on every rebuild.
# Certificates and keys stay in ~/vpn (not in this repo).
#
# permissions = "user:progressio:;" makes a connection private to you. Only
# the OpenVPN plugin supports that; NetworkManager refuses private OpenConnect
# connections ("The 'openconnect' plugin doesn't support private
# connections"), so exigo and school are system connections.
{
  networking.networkmanager.ensureProfiles = {
    profiles = {
      # Internal LB VPN (certificate-based OpenVPN)
      lb-int = {
        connection = {
          id = "lb-int";
          type = "vpn";
          autoconnect = false;
          permissions = "user:progressio:;";
        };
        vpn = {
          ca = "/home/progressio/vpn/int/lb-vpn-int-ca.crt";
          cert = "/home/progressio/vpn/int/lb-vpn-int-marco-kuoni.crt";
          key = "/home/progressio/vpn/int/lb-vpn-int-marco-kuoni.key";
          cert-pass-flags = "1";
          connection-type = "tls";
          remote = "193.93.23.35";
          ta = "/home/progressio/vpn/int/lb-vpn-ta.key";
          ta-dir = "1";
          service-type = "org.freedesktop.NetworkManager.openvpn";
          remote-cert-tls = "server";
          data-ciphers = "AES-256-GCM";
        };
        ipv4 = {
          method = "auto";
          ignore-auto-dns = true;
          dns = "127.0.0.1;";
          dns-priority = -50;
        };
      };

      # Public LB VPN (certificate-based OpenVPN)
      lb-pub = {
        connection = {
          id = "lb-pub";
          type = "vpn";
          autoconnect = false;
          permissions = "user:progressio:;";
        };
        vpn = {
          ca = "/home/progressio/vpn/pub/lb-vpn-pub-ca.crt";
          cert = "/home/progressio/vpn/pub/vpn-pub-marco.crt";
          key = "/home/progressio/vpn/pub/vpn-pub-marco.key";
          cert-pass-flags = "1";
          connection-type = "tls";
          remote = "193.93.23.34";
          ta = "/home/progressio/vpn/pub/lb-vpn-ta.key";
          ta-dir = "1";
          service-type = "org.freedesktop.NetworkManager.openvpn";
          remote-cert-tls = "server";
          data-ciphers = "AES-256-GCM";
        };
        ipv4 = {
          method = "auto";
          ignore-auto-dns = true;
          dns = "127.0.0.1;";
          dns-priority = -50;
        };
      };

      # Exigo VPN (Fortinet via OpenConnect)
      exigo = {
        connection = {
          id = "exigo";
          type = "vpn";
          autoconnect = false;
        };
        vpn = {
          authtype = "password";
          autoconnect-flags = "0";
          certsigs-flags = "0";
          cookie-flags = "2";
          disable_udp = "no";
          enable_csd_trojan = "no";
          gateway = "gate2.exigo.ch";
          gateway-flags = "2";
          gwcert-flags = "2";
          lasthost-flags = "0";
          pem_passphrase_fsid = "no";
          prevent_invalid_cert = "no";
          protocol = "fortinet";
          resolve-flags = "2";
          stoken_source = "disabled";
          useragent = "";
          xmlconfig-flags = "0";
          service-type = "org.freedesktop.NetworkManager.openconnect";
        };
        vpn-secrets = {
          "certificate:193.93.23.20:443" = "pin-sha256:6EuCXl3bvo3RctLhzkfSRCf4KP4+f5CossNjRokrJ2o=";
          "form:_login:username" = "lemonbrain";
          lasthost = "gate2.exigo.ch";
        };
      };

      # School VPN (Cisco AnyConnect via OpenConnect)
      school = {
        connection = {
          id = "school";
          type = "vpn";
          autoconnect = false;
        };
        vpn = {
          service-type = "org.freedesktop.NetworkManager.openconnect";
          gateway = "vpn.ost.ch";
          protocol = "anyconnect";
          useragent = "AnyConnect";
          authtype = "password";
          # asked at every connect (login window), never stored
          cookie-flags = "2";
          gateway-flags = "2";
          gwcert-flags = "2";
          resolve-flags = "2";
          # internal data of the login window, stored like the OpenConnect
          # editor does. Without these, NetworkManager never checks that you
          # may change this connection and drops the login cookie
          # ("final secrets request failed to provide sufficient secrets").
          autoconnect-flags = "0";
          certsigs-flags = "0";
          lasthost-flags = "0";
          xmlconfig-flags = "0";
        };
        ipv6 = {
          method = "disabled";
        };
        vpn-secrets = { };
      };
    };
  };
}
