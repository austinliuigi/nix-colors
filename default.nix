let
  inherit (builtins.fromJSON (builtins.readFile ./flake.lock)) nodes;

  # fetch using flake lockfile; for legacy compat
  fromFlake = name:
    let inherit (nodes.${name}) locked;
    in fetchTarball {
      url =
        "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz";
      sha256 = locked.narHash;
    };

in
  { nixpkgs-lib ? import ((fromFlake "nixpkgs-lib") + "/lib"),
    schemes-source ? fromFlake "schemes-source",
    ...
  }: rec {
    lib-contrib = import ./lib/contrib;
    lib-core = import ./lib/core { inherit nixpkgs-lib; };
    lib = lib-core // { contrib = lib-contrib; };

    tests = import ./lib/core/tests { inherit nixpkgs-lib; };

    colorSchemes = import ./schemes.nix { inherit lib schemes-source; };
    colorschemes = colorSchemes; # alias

    homeManagerModules = rec {
      colorScheme = import ./module;
      colorscheme = colorScheme; # alias
      default = colorScheme;
    };

    homeManagerModule = homeManagerModules.colorScheme;
  }
