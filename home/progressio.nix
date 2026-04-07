{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./niri
    ./noctalia
    ./scripts/LazyvimDiffPlugins.nix
    ./ghostty
    ./zsh
    ./ghostty
    ./tmux
    ./lazyvim
  ];

  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  services = {
    nextcloud-client = {
      enable = true;
    };
  };

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
        "*" = {
          serverAliveInterval = 60;
          serverAliveCountMax = 5;
        };

        "*.exigo.ch" = {
          extraOptions = {
            SetEnv = "TERM=xterm-256color";
          };
        };
      };
    };
  };
  home.packages = with pkgs; [
    curl
    ripgrep
    openfortivpn
    openvpn
    libreoffice
    qutebrowser
    projecteur
    k9s

    # zip
    zip
    unzip

    #IDE
    git

    # Desktop
    libnotify
    brightnessctl
    jq
    wl-mirror
    wlr-randr

    vscode

    xwayland-satellite # xwayland support
  ];

  home.stateVersion = "25.05";
}
