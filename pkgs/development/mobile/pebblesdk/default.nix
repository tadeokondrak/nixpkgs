{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, ncurses5
, zlib
, python2
, expat
, pixman
, SDL
, libX11
, dtc
, glib
}:

stdenv.mkDerivation rec {
  pname = "pebble-sdk";
  version = "4.5";

  src = fetchurl {
    url = "https://developer.rebble.io/s3.amazonaws.com/assets.getpebble.com/pebble-tool/pebble-sdk-${version}-linux64.tar.bz2";
    sha256 = "15yiypx9rnwyzsn4s4z1wmn1naw6mk7dpsiljmw3078ag66z1ca7";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [
    zlib
    ncurses5
    expat
    stdenv.cc.cc
    pixman
    SDL
    libX11
    dtc
    glib
    (python2.withPackages (ps: with ps; [
      libpebble2
      pypkjs
      # incompatible with pytestrunner 3
      (python2.pkgs.buildPythonPackage rec {
        pname = "progressbar2";
        version = "2.7.3";
        src = fetchPypi {
          inherit pname version;
          sha256 = "155pf01ca6jrl9jyjr80fprnzjy33mxrnsdj1pjwiqzbab3zyrl3";
        };
      })
      colorama
      httplib2
      oauth2client
      packaging
      pyasn1
      pygeoip
      pyparsing
      pyqrcode
      requests
      virtualenv
      websocket_client
    ]))
  ];

  postPatch = ''
    # the server doesn't exist anymore, and answering yes
    # to the prompt only gives you connection errors
    substituteInPlace pebble-tool/pebble_tool/__init__.py \
        --replace 'analytics_prompt()' 'pass'
  '';

  installPhase = ''
    mkdir $out
    cp -r * $out
    ln -sf ../pebble-tool/pebble.py $out/bin/pebble
  '';

  postFixup = ''
    wrapProgram $out/bin/pebble \
        --set PYTHONPATH : "$PYTHONPATH"
  '';
}
