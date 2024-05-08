{
  description =
    "Collection of nix-compatible color schemes, and a home-manager module to make theming easier.";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    # upstream source of .yaml schemes
    schemes-source = {
      url = "github:austinliuigi/schemes";
      flake = false;
    };
  };

  outputs = { self, nixpkgs-lib, schemes-source }:
    import ./. {
      nixpkgs-lib = nixpkgs-lib.lib;
      schemes-source = schemes-source.outPath;
    };
}
