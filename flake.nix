{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
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
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixvim,
    niri,
    noctalia,
    zen-browser,
    ...
  } @ inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hardware/laptop.nix
          ./laptop.nix

          # niri overlay provides pkgs.niri-stable and pkgs.niri-unstable
          {nixpkgs.overlays = [niri.overlays.niri];}

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              # use system nixpkgs instead of a separate home-manager instance
              useGlobalPkgs = true;
              # install user packages into /etc/profiles instead of ~/.nix-profile
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs;};

              # shared home-manager modules available to all users
              sharedModules = [
                niri.homeModules.niri
                noctalia.homeModules.default
                zen-browser.homeModules.beta
                nixvim.homeModules.nixvim
              ];

              users.progressio.imports = [
                ./home/progressio.nix
              ];
            };
          }
        ];
      };
    };
  };
}
