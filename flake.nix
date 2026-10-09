{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    go2hs.url = "path:/home/progressio/ost/git/go2/devvm/data/go2hs"; # or a git URL

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4"; # stay on v4 for now
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    projecteur-src = {
      url = "github:gbin/Projecteur/develop";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      niri,
      noctalia,
      zen-browser,
      go2hs,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hardware/laptop.nix
            ./laptop.nix

            {
              nixpkgs.overlays = [
                # Projecteur from GitHub instead of the old Qt5 version in nixpkgs
                (final: prev: {
                  projecteur = final.callPackage ./pkgs/projecteur.nix {
                    src = inputs.projecteur-src;
                    version = "1.0.0-${inputs.projecteur-src.shortRev or "dev"}";
                  };
                })
              ];
            }

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                # use system nixpkgs instead of a separate home-manager instance
                useGlobalPkgs = true;
                # install user packages into /etc/profiles instead of ~/.nix-profile
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };

                # shared home-manager modules available to all users
                sharedModules = [
                  niri.homeModules.niri
                  noctalia.homeModules.default
                  zen-browser.homeModules.beta
                ];

                users.progressio.imports = [
                  ./home/progressio.nix
                ];
              };
            }

            go2hs.nixosModules.default
            {
              go2.enable = true;
              go2.interface = "enp1s0f0";
              go2.address = "192.168.123.99"; # default
            }
          ];
        };
      };
    };
}
