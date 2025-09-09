{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "forti-status" ''
      #!/usr/bin/env bash

      if pgrep -x openfortivpn > /dev/null; then
          echo "{\"text\": \"  Forti\", \"class\": \"on\"}"
      else
          echo "{\"text\": \"  Forti\", \"class\": \"off\"}"
      fi
    '')
  ];
}
