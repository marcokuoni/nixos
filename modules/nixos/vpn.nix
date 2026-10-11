# VPN connections, created in NetworkManager on every rebuild.
# Certificates and keys stay in ~/vpn (not in this repo).
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
      };

      # Exigo VPN (Fortinet via OpenConnect)
      exigo = {
        connection = {
          id = "exigo";
          type = "vpn";
          autoconnect = false;
          permissions = "user:progressio:;";
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
          permissions = "user:progressio:;";
        };
        vpn = {
          service-type = "org.freedesktop.NetworkManager.openconnect";
          gateway = "vpn.ost.ch";
          protocol = "anyconnect";
          useragent = "AnyConnect";
          username = "marco.kuoni@ost.ch";
          authtype = "password";
        };
        ipv6 = {
          method = "disabled";
        };
        vpn-secrets = { };
      };
    };
  };
}
