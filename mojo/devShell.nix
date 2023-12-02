{
  autoPatchelfHook,
  lib,
  libedit,
  libxml2,
  mkShell,
  modular,
  ncurses,
  python3,
  stdenv,
}:
let
  # Required libraries
  neededLibs = [
    libxml2 # libxml2.so.2
    libedit # libedit.so.2
    stdenv.cc.cc # libgcc_s.so.1, libstdc++.so.6
    ncurses # libtinfo.so.6, libncurses.so.6, libform.so.6
  ];
in
mkShell {
  __structuredAttrs = true;
  strictDeps = true;

  name = "${modular.pname}-devShell";

  packages = [
    autoPatchelfHook
    modular
    python3
  ] ++ neededLibs;

  env = {
    LD_LIBRARY_PATH = lib.makeLibraryPath neededLibs;
    MODULAR_HOME = "/tmp/modular";
  };

  shellHook =
    # Make sure we have a clean modular home directory.
    ''
      rm -rf "$MODULAR_HOME"
      mkdir -p "$MODULAR_HOME"
    ''
    # Copy the bootstrap.json file to the modular home directory and set the last modified
    # time to the current time.
    + ''
      cp "${modular}/etc/modular/bootstrap.json" "$MODULAR_HOME/bootstrap.json"
      touch -m "$MODULAR_HOME/bootstrap.json"
    ''
    # Set user.id. Error if it's not present in the environment.
    + ''
      if [[ "''${MODULAR_AUTH-}" == "" ]]; then
        echo "MODULAR_AUTH environment variable is not set. Please set it to your user.id."
        exit 1
      fi
      modular config-set "user.id=$MODULAR_AUTH"
    ''
    # Install mojo. This will fail with an error if libstdc++.so.6 is not found.
    # TODO: Find out how to force this. LD_PRELOAD doesn't seem to work -- Python's fault?
    + ''
      modular install mojo
    ''
    # Fixup the shebangs and rpath. We need to add items in the LD_LIBRARY_PATH to the
    # paths autoPatchelf searches for libraries so it can find the libraries we need.
    + ''
      patchShebangs "$MODULAR_HOME/pkg/packages.modular.com_mojo"
      addAutoPatchelfSearchPath ''${LD_LIBRARY_PATH//:/ }
      autoPatchelf "$MODULAR_HOME/pkg/packages.modular.com_mojo"
    ''
    # Add the modular bin directory to the PATH.
    + ''
      export PATH="$MODULAR_HOME/pkg/packages.modular.com_mojo/bin/:$PATH"
    '';
}
