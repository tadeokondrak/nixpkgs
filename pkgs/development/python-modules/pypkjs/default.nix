{ lib
, buildPythonPackage
, fetchFromGitHub
, backports_ssl_match_hostname
, gevent
, gevent-websocket
, greenlet
, peewee
, pygeoip
, pypng
, python-dateutil
, requests
, sh
, six
, websocket_client
, wsgiref
, libpebble2
, netaddr
}:

buildPythonPackage rec {
  pname = "pypkjs";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "pebble";
    repo = pname;
    rev = "v${version}";
    sha256 = "1h7lckrfb4blynsvqnccm31lv3350pdvxba2xsx2mdlyp0rnrspl";
  };

  propagatedBuildInputs = [
    backports_ssl_match_hostname
    gevent
    gevent-websocket
    greenlet
    peewee
    pygeoip
    pypng
    python-dateutil
    requests
    sh
    six
    websocket_client
    wsgiref
    libpebble2
    netaddr
  ];

  postPatch = ''
    substituteInPlace requirements.txt --replace "==" ">="
  '';
}
