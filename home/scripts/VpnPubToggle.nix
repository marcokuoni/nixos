{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "vpn-pub-toggle" ''
      #!/usr/bin/env bash

      if pgrep -af "openvpn.*pub-vpn.conf" > /dev/null; then
        # Stop VPN
        kitty -e sudo kill "$(pgrep -af 'openvpn.*pub-vpn.conf' | awk '{print $1}')"
      else
        # Start VPN in background (redirect output)
        kitty -e bash -c "sudo vpn-pub-start"
      fi
    '')
  ];
}
