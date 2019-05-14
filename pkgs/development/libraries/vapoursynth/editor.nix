{ stdenv, fetchFromBitbucket, makeWrapper
, python3, vapoursynth
, qmake, qtbase, qtwebsockets
}:

stdenv.mkDerivation rec {
  pname = "vapoursynth-editor";
  version = "R19";

  src = fetchFromBitbucket {
    owner = "mystery_keeper";
    repo = pname;
    rev = stdenv.lib.toLower version;
    sha256 = "1zlaynkkvizf128ln50yvzz3b764f5a0yryp6993s9fkwa7djb6n";
  };

  nativeBuildInputs = [ qmake makeWrapper python3 ];
  buildInputs = [ qtbase vapoursynth qtwebsockets ];

  preConfigure = ''
    cd pro
  '';

  installPhase = ''
    cd ../build/release*
    mkdir -p $out/bin
    for bin in vsedit{,-job-server{,-watcher}}; do
        mv $bin $out/bin

        wrapProgram $out/bin/$bin \
            --prefix PYTHONPATH : $(toPythonPath ${python3.pkgs.vapoursynth}) \
            --prefix LD_LIBRARY_PATH : ${vapoursynth}/lib
    done
  '';
}
