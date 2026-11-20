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
    ./zsh
    ./nvim
    ./nvim/diff-plugins.nix
    ./niri/beamer-mirror.nix
    ./zen
    ./default-apps
  ];

  # Nextcloud desktop sync client
  services = {
    nextcloud-client.enable = true;
  };

  # systemd starts Nextcloud as soon as niri's session is up, but the tray
  # (Noctalia, spawned by niri) appears a moment later. Nextcloud only looks
  # for a tray once, at startup, so its icon would never show. Wait for the
  # tray first (at most 60 s, then start anyway).
  systemd.user.services.nextcloud-client.Service.ExecStartPre =
    "${pkgs.writeShellScript "wait-for-tray" ''
      for _ in $(seq 60); do
        ${pkgs.systemd}/bin/busctl --user status org.kde.StatusNotifierWatcher >/dev/null 2>&1 && exit 0
        sleep 1
      done
    ''}";

  programs = {
    git = {
      enable = true;
      settings.user = me;
    };

    jujutsu = {
      enable = true;
      settings.user = me;
    };

    # per-project environments: a project with `use flake` in its .envrc
    # gets its own toolchain when you cd into it (zsh hook included);
    # nvim started there sees the project's compilers and tools too
    direnv = {
      enable = true;
      nix-direnv.enable = true; # caches the flake env, survives garbage collection
    };

    vscode.enable = true;

    chromium.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      # OpenSSH directive names, as in ssh_config(5)
      settings = {
        # keep connections alive across all hosts
        "*" = {
          ServerAliveInterval = 60;
          ServerAliveCountMax = 5;
        };
        # exigo servers need a plain TERM — their SSH daemon doesn't know screen-256color
        "*.exigo.ch".SetEnv.TERM = "xterm-256color";
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
    ];
    stateVersion = "25.05";
  };
}
