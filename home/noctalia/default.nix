{
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "normal";
        position = "left"; # vertical bar on the left, suits niri's column layout
        showCapsule = false;
        widgets = {
          left = [
            {
              # system menu / distro logo area
              id = "ControlCenter";
              useDistroLogo = false;
              icon = "home";
            }
            {id = "Network";}
            {id = "Bluetooth";}
            # KDE Connect — phone integration
            {id = "plugin:kde-connect";}
            # shows mic/camera indicator when in use
            {id = "plugin:privacy-indicator";}
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "none"; # show dots only, no workspace numbers
            }
          ];
          right = [
            {
              id = "Battery";
              alwaysShowPercentage = false;
              warningThreshold = 30;
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };

      appLauncher = {
        enableClipboardHistory = true;
        # use ghostty as terminal for launching terminal apps
        terminalCommand = "ghostty -e";
        showCategories = false;
      };

      colorSchemes.predefinedScheme = "Ayu";

      general = {
        avatarImage = "";
        radiusRatio = 0.2;
      };

      location = {
        monthBeforeDay = false; # Swiss date format: day before month
        name = "Zurich, Switzerland";
      };

      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          kde-connect = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          privacy-indicator = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 2;
      };
    };
  };
}
