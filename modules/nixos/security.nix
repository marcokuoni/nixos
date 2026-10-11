# Login security: YubiKey (U2F) and unlocking the keyring at login.
{ pkgs, lib, ... }:
{
  security.pam = {
    # unlock the GNOME keyring with your login password
    # (greetd uses the login rules)
    services = {
      login.enableGnomeKeyring = true;
      greetd.enableGnomeKeyring = true;
    };

    # YubiKey for every PAM service (login/greetd, sudo, polkit, su, run0, …):
    # YubiKey + PIN, or your password as fallback.
    # Mappings generated with pamu2fcfg.
    u2f = {
      enable = true;
      settings = {
        # always ask for the YubiKey PIN, not just a touch
        pinverification = 1;
        authfile = pkgs.writeText "u2f-mappings" (
          lib.concatStrings [
            "progressio"
            ":Dld2Hwn9kVGjImdI2x37Iho6m8dG/H/INYW+5DjGn6s6s8rzH9SjjFUS4fas88WtHLC6hlOni5RlANRzGzvKhgbu7VkO6IKe4r+RSv8lZrg3/jVc/7jZ+0OQ5h90LOwx,GFi3pUUcIpF7fWAZ/1FBGoG84osWS7z2LbYiYY0e2uJGGNfdQfPDfoBJzayOvyDK9nAW5hs9vU1JGIGbYZoC1Q==,es256,+presence"
            ":X1FGyZEu3GwF6ILuT3cDFE9yElO60EvmXRw1XjCDNj/TLjOoAkCSrnIxT6S1pK+oW1vaicCHDk46slBMvCt+0BB937mOyBQb4bPXjv5RnMeTcodfFPd90IeFY/nBRxtg,G8mdY+E9qmQv89VC/AGH0qtC+iQEJtKDVmzqLvBFZZOEq1B829FOVpd9pAsp7JYiy6uaSxt7YDt0urGlXkptRg==,es256,+presence"
          ]
        );
      };
    };
  };
}
