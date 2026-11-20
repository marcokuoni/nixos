# Boot loader and the encrypted root disk.
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # boot menu shows the last 5 generations
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      luks.devices.cryptroot = {
        device = "/dev/disk/by-partlabel/CRYPTROOT";
        # unlock with a YubiKey; without one, a passphrase is asked after the
        # token timeout (if a passphrase key slot exists)
        # https://nixos.org/manual/nixos/stable/#sec-luks-file-systems-fido2-systemd
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };
  };
}
