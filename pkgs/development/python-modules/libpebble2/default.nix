{ lib
, buildPythonPackage
, fetchFromGitHub
, backports_ssl_match_hostname
, enum34
, six
, websocket_client
, wsgiref
, pyserial
, pytest
, pytest-mock
}:

buildPythonPackage rec {
  pname = "libpebble2";
  version = "0.0.27";

  # PyPi is only at 0.0.26
  src = fetchFromGitHub {
    owner = "pebble";
    repo = pname;
    rev = "v${version}";
    sha256 = "1hadvqvgxxdd9xkp3084a18zmf66crhh6k7jg2nccq00np0s49wq";
  };

  propagatedBuildInputs = [
    backports_ssl_match_hostname
    enum34
    six
    websocket_client
    wsgiref
    pyserial
  ];

  buildInputs = [
    pytest
    pytest-mock
  ];

  meta = with lib; {
    homepage = "https://github.com/pebble/libpebble2";
    description = "A python library for interacting with Pebble devices";
    license = licences.mit;
    maintainers = with maintainers; [ tadeokondrak ];
  };
}
