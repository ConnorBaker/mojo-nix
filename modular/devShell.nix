{
  lib,
  mkShell,
  modular,
}:
mkShell {
  __structuredAttrs = true;
  strictDeps = true;

  name = "${modular.pname}-devShell";
  packages = [modular];

  env.MODULAR_HOME = "/tmp/modular";

  shellHook =
    # Make sure the modular home directory exists.
    ''
      mkdir -p "$MODULAR_HOME"
    ''
    # If we're missing the bootstrap.json file, copy it from the modular package.
    + ''
      if [[ ! -f "$MODULAR_HOME/bootstrap.json" ]]; then
        cp "${modular}/etc/modular/bootstrap.json" "$MODULAR_HOME/bootstrap.json"
      fi
    ''
    # If modular config-list user.id is not set, read it from the environment variable
    # and set it. Error if it's not set.
    + ''
      if [[ "$(${lib.getExe modular} config-list user.id)" == "" ]]; then
        if [[ "''${MODULAR_AUTH-}" == "" ]]; then
          echo "MODULAR_AUTH environment variable is not set. Please set it to your user.id."
          exit 1
        fi
        modular config-set user.id "$MODULAR_AUTH"
      fi
    '';
}
