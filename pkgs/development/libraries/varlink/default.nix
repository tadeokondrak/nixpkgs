{ stdenv
, fetchFromGitHub
, meson
, ninja
, python3
}:

stdenv.mkDerivation rec {
  pname = "varlink";
  version = "18";

  src = fetchFromGitHub {
    owner = "varlink";
    repo = "libvarlink";
    rev = version;
    sha256 = "15r4nh2ak8gl99mnd8vvalsvx95zvi9wxydrjy5i1vvz20gd369g";
  };

  nativeBuildInputs = [ meson ninja python3 ];

  preConfigure = "patchShebangs .";

  meta = with stdenv.lib; {
    homepage = https://varlink.org/;
    description = ''
      An interface description format and protocol that aims to make services
      accessible to both humans and machines in the simplest feasible way
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ tadeokondrak ];
    platforms = platforms.unix;
  };
}
