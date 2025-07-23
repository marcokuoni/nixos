{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "forti-start" ''
      #!/usr/bin/env bash

      read -p "VPN Password: " -s VPN_PASS
      # echo

      # Start openfortivpn with password via stdin
      openfortivpn gate2.exigo.ch \
          --username lemonbrain \
          --password "$VPN_PASS" \
          --trusted-cert 3308ac43ca0749e1f24756b3eacc5d16db3833f0830da7f780ca567a4c4969e8 &

      unset VPN_PASS
    '')
  ];
}
