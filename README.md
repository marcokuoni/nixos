# My NixOS Configurations

NixOS + home-manager configuration of my laptop (`progressio`).

## Layout

```
flake.nix               inputs, the laptop host, nix fmt, dev shell
hosts/laptop/
  default.nix           the machine: user, home-manager, reMarkable, go2
  hardware.nix          generated hardware part (safe to regenerate)
modules/nixos/          system settings, one file per topic
  boot.nix              boot loader, encrypted disk (YubiKey unlock)
  nix.nix               flakes, binary caches, garbage collection
  locale.nix            time zone, language, keyboard
  networking.nix        NetworkManager, firewall, /etc/hosts
  vpn.nix               VPN profiles
  desktop.nix           login screen, niri session, portals, fonts
  audio.nix             PipeWire
  security.nix          YubiKey (PAM), keyring
  printing.nix          CUPS, printer discovery
  power.nix             battery, firmware updates
  devices.nix           Bluetooth, keyboard (WebHID), Projecteur
  development.nix       Docker, nix-ld, SSHFS
  remarkable/           reMarkable sync + PDF conversion services
home/                   user environment (home-manager), one folder per app
pkgs/                   own packages and the overlay that adds them
```

## Rebuild

```
sudo nixos-rebuild switch --flake '.#laptop'
```

To try a change without making it the boot default, use `test` instead of
`switch`; a reboot then returns to the previous generation.

## Update

```
nix flake update
```

## Checks (same as CI)

```
nix fmt                          # format all .nix files git knows about
nix develop -c statix check .    # lint
nix develop -c deadnix --fail .  # unused code
```

CI runs these checks only (with the same tool versions); it can't build the
system because the `go2hs` input is a local path.
