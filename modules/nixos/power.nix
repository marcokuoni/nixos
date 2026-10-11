# Battery, power profiles and firmware updates.
{
  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;

    # firmware updates (BIOS, Thunderbolt, SSD, …) from LVFS:
    # fwupdmgr refresh && fwupdmgr update
    fwupd.enable = true;
  };
}
