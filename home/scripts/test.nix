# scripts.nix
{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "hello-script" ''
      #!/usr/bin/env bash
      echo "Hello from a script managed by Home Manager!"
    '')
  ];
}

