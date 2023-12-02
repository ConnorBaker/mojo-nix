{fetchurl, ncurses}:
(ncurses.override {abiVersion = "6";}).overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "6.1";
    # TODO: Unclear how to find which version of ncurses provides NCURSES6_5.0.19991023.
    src = fetchurl {
      url = "https://invisible-mirror.net/archives/ncurses/ncurses-${finalAttrs.version}.tar.gz";
      hash = "sha256-qgV+7rShTUcBAe/0WX1YM9zvWWUzG+NSjAjZnOuqDRc=";
    };
  }
)
