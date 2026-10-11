{
  description = "NixOS configuration of my laptop (progressio)";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri Wayland compositor flake — provides stable + unstable packages
    # and home-manager/nixos modules
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    go2hs.url = "path:/home/progressio/ost/git/go2/devvm/data/go2hs"; # or a git URL

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    projecteur-src = {
      url = "github:gbin/Projecteur/develop";
      flake = false;
    };
  };

  outputs = inputs: {
    nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
      # makes the flake inputs available to all modules (hosts/laptop uses them)
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/laptop ];
    };
  };
}
