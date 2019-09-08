{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "wsgiref";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    extension = "zip"; # tar.gz gives a 404
    sha256 = "0y8fyjmpq7vwwm4x732w97qbkw78rjwal5409k04cw4m03411rn7";
  };

  meta = with lib; {
    homepage = "http://cheeseshop.python.org/pypi/wsgiref";
    description = "WSGI (PEP 333) Reference Library";
    license = with licences; [ psfl zpl21 ];
    maintainers = with maintainers; [ tadeokondrak ];
  };
}
