{
  description = "NixOS configuration of my laptop (progressio)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    # go2hs.url = "path:/home/progressio/ost/git/go2/devvm/data/go2hs"; # or a git URL
    go2hs.url = "path:/home/progressio/ost/git/go2/go2-voice-agent"; # or a git URL

    # the ESP32-C6 board project: waac, waa-lsp and the Neovim plugin for .waa
    board = {
      url = "path:/home/progressio/ost/git/gpio-wasm-project-vm/data/gpio-wasm-project/new_setup_guestInControl_v7"; # or git+file:///… (only tracked files)
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    projecteur-src = {
      url = "github:gbin/Projecteur/develop";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
        # makes the flake inputs available to all modules (hosts/laptop uses them)
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/laptop ];
      };

      # `nix fmt` formats every .nix file git knows about
      formatter.x86_64-linux = pkgs.nixfmt-tree;

      # `nix develop -c statix check .` etc. — the same tools CI uses
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.nixfmt-tree
          pkgs.statix
          pkgs.deadnix
        ];
      };
    };
}
