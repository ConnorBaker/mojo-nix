{
  inputs = {
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:connorbaker/nixpkgs/fix/ncurses-no-unicode";
  };

  outputs =
    inputs@{flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem =
        {config, pkgs, ...}:
        {
          packages = {
            libedit = pkgs.callPackage ./libedit {};
            modular = pkgs.callPackage ./modular {};
            ncurses = pkgs.callPackage ./ncurses {};
          };
          devShells.mojo = pkgs.callPackage ./mojo/devShell.nix {
            inherit (config.packages) libedit modular ncurses;
          };
        };
    };
}
