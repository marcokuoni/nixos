# Package changes on top of nixpkgs, applied as an overlay (hosts/laptop).
inputs: final: _prev: {
  # Projecteur from GitHub instead of the old Qt5 version in nixpkgs
  projecteur = final.callPackage ./projecteur.nix {
    src = inputs.projecteur-src;
    version = "1.0.0-${inputs.projecteur-src.shortRev or "dev"}";
  };
}
