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
          packages = {
            libedit2 = pkgs.callPackage ./libedit2 {};
            modular = pkgs.callPackage ./modular {};
            ncurses_6_5 = pkgs.callPackage ./ncurses_6_5 {};
          };
          devShells.mojo = pkgs.callPackage ./mojo/devShell.nix {
            inherit (config.packages) libedit2 modular ncurses_6_5;
          };
        };
    };
}
