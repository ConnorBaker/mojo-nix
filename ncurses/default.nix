{
  lib,
  ncurses,
  stdenv,
}:
let
  abiVersion = "6";
  unicodeSupport = false;
in
(ncurses.override {inherit abiVersion unicodeSupport;}).overrideAttrs (
  finalAttrs: prevAttrs: {
    postFixup =
      let
        abiVersion-extension =
          if stdenv.isDarwin then "${abiVersion}.$dylibtype" else "$dylibtype.${abiVersion}";
      in
      ''
        # Determine what suffixes our libraries have
        suffix="$(awk -F': ' 'f{print $3; f=0} /default library suffix/{f=1}' config.log)"
      ''
      # When building a wide-character (Unicode) build, create backward
      # compatibility links from the the "normal" libraries to the
      # wide-character libraries (e.g. libncurses.so to libncursesw.so).
      + lib.optionalString unicodeSupport ''
        libs="$(ls $dev/lib/pkgconfig | tr ' ' '\n' | sed "s,\(.*\)$suffix\.pc,\1,g")"
        suffixes="$(echo "$suffix" | awk '{for (i=1; i < length($0); i++) {x=substr($0, i+1, length($0)-i); print x}}')"

        # Get the path to the config util
        cfg=$(basename $dev/bin/ncurses*-config)

        # symlink the full suffixed include directory
        ln -svf . $dev/include/ncurses$suffix

        for newsuffix in $suffixes ""; do
          # Create a non-abi versioned config util links
          ln -svf $cfg $dev/bin/ncurses$newsuffix-config

          # Allow for end users who #include <ncurses?w/*.h>
          ln -svf . $dev/include/ncurses$newsuffix

          for library in $libs; do
            for dylibtype in so dll dylib; do
              if [ -e "$out/lib/lib''${library}$suffix.$dylibtype" ]; then
                ln -svf lib''${library}$suffix.$dylibtype $out/lib/lib$library$newsuffix.$dylibtype
                ln -svf lib''${library}$suffix.${abiVersion-extension} $out/lib/lib$library$newsuffix.${abiVersion-extension}
                if [ "ncurses" = "$library" ]
                then
                  # make libtinfo symlinks
                  ln -svf lib''${library}$suffix.$dylibtype $out/lib/libtinfo$newsuffix.$dylibtype
                  ln -svf lib''${library}$suffix.${abiVersion-extension} $out/lib/libtinfo$newsuffix.${abiVersion-extension}
                fi
              fi
            done
            for statictype in a dll.a la; do
              if [ -e "$out/lib/lib''${library}$suffix.$statictype" ]; then
                ln -svf lib''${library}$suffix.$statictype $out/lib/lib$library$newsuffix.$statictype
                if [ "ncurses" = "$library" ]
                then
                  # make libtinfo symlinks
                  ln -svf lib''${library}$suffix.$statictype $out/lib/libtinfo$newsuffix.$statictype
                fi
              fi
            done
            ln -svf ''${library}$suffix.pc $dev/lib/pkgconfig/$library$newsuffix.pc
          done
        done
      ''
      # Unconditional patches
      + ''
        # add pkg-config aliases for libraries that are built-in to libncurses(w)
        for library in tinfo tic; do
          for suffix in "" ${lib.optionalString unicodeSupport "w"}; do
            ln -svf ncurses$suffix.pc $dev/lib/pkgconfig/$library$suffix.pc
          done
        done

        # move some utilities to $bin
        # these programs are used at runtime and don't really belong in $dev
        moveToOutput "bin/clear" "$out"
        moveToOutput "bin/reset" "$out"
        moveToOutput "bin/tabs" "$out"
        moveToOutput "bin/tic" "$out"
        moveToOutput "bin/tput" "$out"
        moveToOutput "bin/tset" "$out"
        moveToOutput "bin/captoinfo" "$out"
        moveToOutput "bin/infotocap" "$out"
        moveToOutput "bin/infocmp" "$out"
      '';
  }
)
