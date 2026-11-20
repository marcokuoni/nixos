# Packages nixpkgs marks as insecure that I still use.
# Remove entries once the build passes without them.
{ lib, ... }:
{
  nixpkgs.config.allowInsecurePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "firefox-esr-140-bin-unwrapped" # Zotero: waits for Zotero 11 (Firefox 153)
      "qutebrowser" # still trusts eMudhra TLS certs
    ];
}
