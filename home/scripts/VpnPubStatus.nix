{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "vpn-pub-status" ''
      #!/usr/bin/env bash

      if pgrep -af "openvpn.*pub-vpn.conf" > /dev/null; then
          echo "{\"text\": \"  Pub\", \"class\": \"on\"}"
      else
          echo "{\"text\": \"  Pub\", \"class\": \"off\"}"
      fi
    '')
  ];
}
