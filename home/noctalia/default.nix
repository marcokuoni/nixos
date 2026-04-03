{ config, pkgs, ... }:

{
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "normal";
        position = "left";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = false;
              icon = "home";
            }
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "plugin:kde-connect";
            }
            {
              id = "plugin:privacy-indicator";
            }
          ];
          center = [
            {
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "none";
            }
          ];
          right = [
            {
              alwaysShowPercentage = false;
              id = "Battery";
              warningThreshold = 30;
            }
            {
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };
      appLauncher = {
        enableClipboardHistory = true;
        terminalCommand = "konsole -e";
        showCategories = false;
      };
      colorSchemes.predefinedScheme = "Ayu";
      general = {
        avatarImage = "";
        radiusRatio = 0.2;
      };
      location = {
        monthBeforeDay = false;
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
