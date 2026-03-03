{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./scripts/LazyvimDiffPlugins.nix
    ./scripts/ToggleKeyboard.nix
    ./zsh
    ./tmux
    ./lazyvim
  ];

  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        # disable-user-extensions = true; # Optionally disable user extensions entirely
        enabled-extensions = [
          pkgs.gnomeExtensions.forge.extensionUuid
        ];
      };
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
        name = "Terminal";
        command = "kgx";
        binding = "<Super>t";
      };
    };
  };

  services = {
    nextcloud-client = {
      enable = true;
    };
  };

  programs.vscode.enable = true;
  programs.lazygit.enable = true;
  programs.lazydocker.enable = true;
  programs.chromium.enable = true;
  programs.ssh = {
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

  home.packages = with pkgs; [
    curl
    ripgrep
    openfortivpn
    openvpn
    libreoffice
    qutebrowser
    nautilus
    projecteur
    bibata-cursors
    k9s

    # zip
    zip
    unzip

    #IDE
    git

    # Desktop
    libnotify
    brightnessctl

    vscode

    # https://wiki.nixos.org/wiki/GNOME
    # https://github.com/forge-ext/forge
    gnomeExtensions.forge
  ];

  home.stateVersion = "25.05";
}
