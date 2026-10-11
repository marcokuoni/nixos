{ pkgs, ... }:
let
  # who you are in Git and jj commits
  me = {
    name = "Marco Kuoni";
    email = "mail@marcokuoni.ch";
  };
in
{
  imports = [
    ./niri
    ./noctalia
    ./tmux
    ./ghostty
    ./nushell
    ./nvim
    ./scripts/LazyvimDiffPlugins.nix
    ./scripts/BeamerMirror.nix
    ./zen
  ];

  # Nextcloud desktop sync client
  services = {
    nextcloud-client.enable = true;
  };

  programs = {
    git = {
      enable = true;
      settings.user = me;
    };

    jujutsu = {
      enable = true;
      settings.user = me;
    };

    vscode.enable = true;

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
      # Research
      pandoc
      obsidian
      zotero
      pdfannots2json # for zotero integration in obsidium
      zathura # pdf viewer

      nautilus
      curl
      ripgrep
      openfortivpn
      openvpn
      libreoffice
      qutebrowser
      projecteur # laser pointer for presentations
      zip
      unzip
      libarchive # provides bsdtar — same extraction backend as GNOME
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
