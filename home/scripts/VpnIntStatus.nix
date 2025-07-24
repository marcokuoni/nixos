{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "vpn-int-status" ''
      #!/usr/bin/env bash

      if pgrep -af "openvpn.*int-vpn.conf" > /dev/null; then
          echo "{\"text\": \" Int\", \"class\": \"on\"}"
      else
          echo "{\"text\": \" Int\", \"class\": \"off\"}"
      fi
    '')
  ];
}
