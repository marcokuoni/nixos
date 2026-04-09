{ pkgs, ... }:
{
  imports = [
    ./niri
    ./noctalia
    ./ghostty
    ./zsh
    ./lazyvim
    ./scripts/LazyvimDiffPlugins.nix
    ./scripts/BeamerMirror.nix
  ];

  # Nextcloud desktop sync client
  services.nextcloud-client.enable = true;

  programs = {
    vscode.enable = true;

    zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };

    chromium.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        # keep connections alive across all hosts
        "*" = {
          serverAliveInterval = 60;
          serverAliveCountMax = 5;
        };
        # exigo servers need a plain TERM — their SSH daemon doesn't know screen-256color
        "*.exigo.ch" = {
          extraOptions.SetEnv = "TERM=xterm-256color";
        };
      };
    };
  };

  home = {
    username = "progressio";
    homeDirectory = "/home/progressio";
    packages = with pkgs; [
      curl
      ripgrep
      openfortivpn
      openvpn
      libreoffice
      qutebrowser
      projecteur # laser pointer for presentations
      zip
      libarchive # provides bsdtar — same extraction backend as GNOME
      git
      libnotify # notify-send for desktop notifications
      brightnessctl # backlight control (used in niri binds)
      jq # JSON processor
      wl-mirror # mirror display output (beamer)
      wlr-randr # Wayland display management
      xwayland-satellite # XWayland support for X11 apps under niri
    ];
    stateVersion = "25.05";
  };
}
