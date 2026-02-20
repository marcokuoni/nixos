{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "vpn-int-status" ''
      #!/usr/bin/env bash
      UNIT="openvpn-lb-int.service"
      if systemctl is-active --quiet "$UNIT"; then
        IP=$(ip -o -4 addr show dev tun0 2>/dev/null | awk "{print \$4}" | cut -d/ -f1)
        [ -n "$IP" ] && TEXT="  Int $IP" || TEXT="  Int"
        echo "{\"text\":\"$TEXT\",\"class\":\"on\"}"
      else
        if systemctl is-failed --quiet "$UNIT"; then
          echo "{\"text\":\"  Int\",\"class\":\"error\"}"
        else
          echo "{\"text\":\"  Int\",\"class\":\"off\"}"
        fi
      fi
    '')
  ];
}
