{ stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "cum";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Hamuko";
    repo = pname;
    rev = "v${version}";
    sha256 = "1by2r056qqxl15dpggw4pjm70cm03hhdkf63krqc7lx6zqnzm8v8";
  };

  propagatedBuildInputs = with python3Packages; [
    alembic beautifulsoup4 click natsort requests sqlalchemy
  ];

  doCheck = false;

  postInstall = ''
    rm -rf $out/tests $out/LICENSE
  '';

  meta = with stdenv.lib; {
    description = "comic updater, mangafied";
    homepage = "https://github.com/Hamuko/cum";
    license = licenses.asl20;
    maintainers = with maintainers; [ tadeokondrak ];
    platforms = platforms.all;
  };
}
