{
  autoPatchelfHook,
  dpkg,
  fetchurl,
  lib,
  ncurses,
  stdenv,
  zlib,
  # passthru.updateScript
  common-updater-scripts,
  curl,
  gnugrep,
  gnused,
  gzip,
  writeShellApplication,
}:
stdenv.mkDerivation (
  finalAttrs: {
    __structuredAttrs = true;
    strictDeps = true;

    pname = "modular";
    version = "0.2.2";
    src = fetchurl {
      url = "https://dl.${finalAttrs.pname}.com/public/installer/deb/debian/pool/any-version/main/m/mo/${finalAttrs.pname}_${finalAttrs.version}/${finalAttrs.pname}-v${finalAttrs.version}-amd64.deb";
      hash = "sha256-986jujNFyl5y9JjclxrbTyXbZBJSey5+NAVtxyiQptg=";
    };

    unpackCmd = "${lib.getExe' dpkg "dpkg"} -x $src ./${finalAttrs.pname}-${finalAttrs.version}";
    dontBuild = true;

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
    ];

    buildInputs = [
      zlib # libz.so.1
      stdenv.cc.cc # libgcc_s.so.1, libstdc++.so.6
      ncurses # libtinfo.so.6
    ];

    installPhase = ''
      runHook preInstall
      cp -r ./usr "$out"
      cp -r ./etc "$out/etc"
      runHook postInstall
    '';

    passthru.updateScript =
      let
        packageUrl = "https://dl.modular.com/public/installer/deb/debian/dists/wheezy/main/binary-amd64/Packages.gz";
      in
      writeShellApplication {
        name = "update-${finalAttrs.pname}";
        runtimeInputs = [
          common-updater-scripts
          curl
          gnugrep
          gnused
          gzip
        ];
        text = ''
          version="$(curl -s "${packageUrl}" | gunzip | grep "Version" | sed 's|Version: ||' | sort -h | tail -1)"
          update-source-version modular "$version"
        '';
      };

    meta = with lib; {
      description = "Modular.";
      homepage = "https://www.modular.com";
      platforms = platforms.linux;
      mainProgram = finalAttrs.pname;
    };
  }
)
