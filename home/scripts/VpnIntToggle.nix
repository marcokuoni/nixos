{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "vpn-int-toggle" ''
      #!/usr/bin/env bash

      if pgrep -af "openvpn.*int-vpn.conf" > /dev/null; then
        # Stop VPN
        kitty -e sudo kill "$(pgrep -af 'openvpn.*int-vpn.conf' | awk '{print $1}')"
      else
        # Start VPN in background (redirect output)
        kitty -e bash -c "sudo vpn-int-start"
      fi
    '')
  ];
}
