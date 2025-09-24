{pkgs, ...}: {
  home.packages = [
    pkgs.kitty
    (pkgs.writeShellScriptBin "vpn-int-toggle" ''
      #!/usr/bin/env bash
      set -euo pipefail

      UNIT="openvpn-lb-int.service"
      SYSTEMCTL="systemctl"
      JOURNALCTL="journalctl"
      KITTY="kitty"
      BASH="bash"
      PASSFILE="/tmp/openvpn-lb-int.pass"

      if $SYSTEMCTL is-active --quiet "$UNIT"; then
        # Stop in a kitty window (so you see any output/errors)
        exec "$KITTY" -T "OpenVPN stop: $UNIT" "$BASH" -lc "sudo $SYSTEMCTL stop $UNIT"
      else
        # Start: prompt for pass, write temp file, start unit, clean up
        exec "$KITTY" -T "OpenVPN start: $UNIT" "$BASH" -lc '
          set -e
          read -p "Certificate passphrase: " -s P; echo
          umask 177
          printf "%s" "$P" > "'"$PASSFILE"'"
          unset P

          # Ensure root can read it, nothing else
          sudo chown root:root "'"$PASSFILE"'"
          sudo chmod 600 "'"$PASSFILE"'"

          # Start the systemd unit
          if ! sudo "'"$SYSTEMCTL"'" start "'"$UNIT"'"; then
            echo "Failed to start '"$UNIT"'"
            sudo rm -f "'"$PASSFILE"'"
            exit 1
          fi

          # Wait up to ~10s for it to become active
          for i in {1..20}; do
            if sudo "'"$SYSTEMCTL"'" is-active --quiet "'"$UNIT"'"; then
              break
            fi
            sleep 0.5
          done

          # Show a few recent log lines
          sudo "'"$JOURNALCTL"'" -u "'"$UNIT"'" -n 8 --no-pager || true

          # Clean up the passfile
          sudo rm -f "'"$PASSFILE"'"
        '
      fi
    '')
  ];
}
