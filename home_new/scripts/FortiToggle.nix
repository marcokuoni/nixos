{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "forti-toggle" ''
      #!/usr/bin/env bash

      VPN_PROC="openfortivpn"

      if pgrep -x "$VPN_PROC" > /dev/null; then
        # Stop VPN
        kitty -e sudo pkill -x openfortivpn
      else
        # Start VPN in background (redirect output)
        kitty -e bash -c "sudo forti-start"
      fi
    '')
  ];
}
