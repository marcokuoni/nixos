# My NixOS Configurations

## Rebuild

`sudo nixos-rebuild switch --flake '.#laptop'`

## Update

`nix flake update`

## Checks (same as CI)

CI only runs formatting and lint checks (the `go2hs` input is a local path,
so GitHub can't build the system). Run them before pushing, with the tools
from the nixpkgs revision in `flake.lock`:

```sh
NIXPKGS="github:NixOS/nixpkgs/$(jq -r .nodes.nixpkgs.locked.rev flake.lock)"
nix run "$NIXPKGS#nixfmt" -- .          # format (CI: --check)
nix run "$NIXPKGS#statix" -- check .
nix run "$NIXPKGS#deadnix" -- --fail .
```
