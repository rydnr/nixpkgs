let pkgs = import <nixpkgs> { };
in
with pkgs;

let
  firefox-file = "FIREFOX_AURORA_52_BASE.tar.gz";
  firefox-src = fetchurl {
    url = "https://hg.mozilla.org/mozilla-central/archive/${firefox-file}";
    sha256 = "10iz6gvxqzxkyp6jy6ri5lwag7rzi6928xw20j7qjssv63jll0ks";
  };
in

stdenv.mkDerivation {
  name = "Moz2D";
  src = fetchFromGitHub {
    owner = "syrel";
    repo = "Moz2D";
    rev = "a43de3dc5dd2ef428b790b03fac4b6386774a5f3";
    sha256 = "15r4ragjr3rwr7ppy684rnhpsx6sbzrip3mrx2823w2kicfyvmjb";
  };
  enableParallelBuilding = true;
  buildPhase = ''
    # Build script will detect the source archive by filename
    cp ${firefox-src} ${firefox-file}
    # Fix for build issue https://bugzilla.mozilla.org/show_bug.cgi?id=1329272
    cp ${./sedm4.patch} patches/sedm4.patch
    # cmake available during build (but not used for this derivation)
    PATH=$PATH:${cmake}/bin
    sh ./build.sh --arch x86_64
    mkdir -p $out/lib
    # Prevent runtime error due to depending on both gtk2 and gtk3
    patchelf --debug --remove-needed libgtk-3.so.0 build/libMoz2D.so
    cp build/libMoz2D.so $out/lib/
  '';
  nativeBuildInputs = [
    atk
    autoconf213
    cairo
    fontconfig
    freetype
    gcc
    gdk_pixbuf
    glib
    gnome2.GConf
    gtk2
    gtk3
    gtk3-x11
    libGL
    libpulseaudio
    nodejs
    pango
    perl
    pkgconfig
    python
    unzip
    which
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXt
    xorg.libxcb
    yasm
    zip
  ];
}
