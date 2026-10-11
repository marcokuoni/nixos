# Extra devices: Bluetooth, keyboard config in the browser, presenter.
{ pkgs, ... }:
{
  hardware.bluetooth.enable = true;

  # virtual input devices (needed by Projecteur)
  hardware.uinput.enable = true;

  services.udev = {
    # configure the Bastard Keyboard in the browser (WebHID)
    extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
    # Projecteur (presenter / laser pointer)
    packages = [ pkgs.projecteur ];
  };
}
