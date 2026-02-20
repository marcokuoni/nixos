{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "vpn-pub-status" ''
      #!/usr/bin/env bash
      UNIT="openvpn-lb-pub.service"
      if systemctl is-active --quiet "$UNIT"; then
        IP=$(ip -o -4 addr show dev tun0 2>/dev/null | awk "{print \$4}" | cut -d/ -f1)
        [ -n "$IP" ] && TEXT="  Pub $IP" || TEXT="  Pub"
        echo "{\"text\":\"$TEXT\",\"class\":\"on\"}"
      else
        if systemctl is-failed --quiet "$UNIT"; then
          echo "{\"text\":\"  Pub\",\"class\":\"error\"}"
        else
          echo "{\"text\":\"  Pub\",\"class\":\"off\"}"
        fi
      fi
    '')
  ];
}
