# Everything the laptop runs, one file per topic.
{
  imports = [
    ./boot.nix
    ./nix.nix
    ./locale.nix
    ./networking.nix
    ./vpn.nix
    ./desktop.nix
    ./audio.nix
    ./security.nix
    ./printing.nix
    ./power.nix
    ./devices.nix
    ./development.nix
    ./remarkable
    ./remarkable/rmdoc-to-pdf.nix
  ];
}
