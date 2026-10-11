# Graphical session: login screen, niri, portals, fonts, desktop tools.
# The niri configuration itself is in home/niri.
{ pkgs, ... }:
{
  # tuigreet: a small text login screen that starts niri
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
      user = "greeter";
    };
  };

  # stores secrets, SSH keys, VPN passwords; unlocked at login (security.nix)
  services.gnome.gnome-keyring.enable = true;

  # portals let apps open file pickers, share the screen, take screenshots
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome # screen sharing under niri
    ];
    config.niri = {
      default = [ "gnome" ];
      # "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
  };

  fonts = {
    packages = with pkgs; [
      corefonts
      nerd-fonts.ubuntu
      nerd-fonts.fira-code
      nerd-fonts._0xproto
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
    ];
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  programs.firefox.enable = true;

  environment = {
    # needed for xdg-desktop-portal with home-manager's useUserPackages
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
    systemPackages = with pkgs; [
      networkmanagerapplet # nm-applet in the bar
      openconnect # VPN CLI (the NetworkManager plugin is in networking.nix)
      lxqt.lxqt-policykit # password prompts for admin actions
      nwg-displays # monitor layout
      nwg-look # GTK theme, cursor, fonts
      bibata-cursors
      xwayland-satellite # X11 apps under niri
    ];
  };
}
