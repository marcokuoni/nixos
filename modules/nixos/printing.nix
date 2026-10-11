# Printing (CUPS) and printer discovery (mDNS / AirPrint).
{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  # mDNS: .local host names and AirPrint printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
