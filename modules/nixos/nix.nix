# Nix itself: flakes, binary caches, garbage collection.
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # deduplicate identical files in the store
      auto-optimise-store = true;
      # start garbage collection when less than 50 GB are free
      min-free = "50G";
      # extra binary caches, so these don't have to be built locally
      substituters = [
        "https://niri.cachix.org"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };

    # weekly cleanup of everything older than 7 days
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
