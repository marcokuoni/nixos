{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, nixvim, ... }@inputs:
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./hardware/laptop.nix
            ./laptop.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.progressio.imports = [
                nixvim.homeModules.nixvim
	        ./home/progressio.nix 
	      ];
            }
          ];
        };
      };
    };
}

