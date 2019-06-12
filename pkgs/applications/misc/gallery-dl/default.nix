{ lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "gallery_dl";
  version = "1.8.5";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "ee5b14e83080b6390f9bf8d9bbfab03f628aebe863efd16a4b2f8536b149cc4f";
  };

  doCheck = false;
  propagatedBuildInputs = with python3Packages; [ requests ];

  meta = {
    description = "Command-line program to download image-galleries and -collections from several image hosting sites";
    homepage = https://github.com/mikf/gallery-dl;
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ dawidsowa ];
  };
}
