{
  inputs = {
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/master";
  };

  outputs =
    inputs@{flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem =
        {config, pkgs, ...}:
        {
          packages.modular = pkgs.callPackage ./modular {};
          devShells.modular = pkgs.callPackage ./modular/devShell.nix {inherit (config.packages) modular;};
        };
    };
}
