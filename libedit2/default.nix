{fetchurl, libedit}:
# Ubuntu/Debian ship with a newer version of libedit than Nixpkgs does.
# Use the newer version and create a symlink in /lib to mimic their setup,
# which is what Mojo's libraries expect.
libedit.overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "libedit";
    version = "20230828-3.1";
    src = fetchurl {
      url = "https://thrysoee.dk/editline/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
      hash = "sha256-TugYK25WkpDn0fRPD3jayHFrNfZWt2Uo9pnGnJiBTa0=";
    };
    postInstall =
      prevAttrs.postInstall
      + ''
        ln -s "$out/lib/libedit.so" "$out/lib/libedit.so.2"
      '';
  }
)
