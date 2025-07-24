{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "vpn-int-start" ''
      #!/usr/bin/env bash

      read -p "VPN Password: " -s VPN_PASS
      echo

      # Save password to temp file
      echo "$VPN_PASS" > /tmp/vpn-pass.txt
      chmod 600 /tmp/vpn-pass.txt

      # Start OpenVPN using password file
      openvpn --config /home/progressio/lemonbrain/vpn/int/int-vpn.conf --askpass /tmp/vpn-pass.txt &

      # Clean up
      sleep 5
      rm /tmp/vpn-pass.txt
      unset VPN_PASS
    '')
  ];
}
