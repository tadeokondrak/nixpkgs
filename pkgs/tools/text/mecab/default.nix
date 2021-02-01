{ lib, stdenv, fetchurl, mecab-ipadic, charset ? "euc-jp" }:

let
  mecab-base = import ./base.nix { inherit fetchurl; };
in
stdenv.mkDerivation (mecab-base // {
    name = "mecab-${mecab-base.version}";

    postInstall = ''
      sed -i 's|^dicdir = .*$|dicdir = ${mecab-ipadic}|' "$out/etc/mecabrc"
    '';

    configureFlags = [
      "--with-charset=${charset}"
    ];

    meta = with lib; {
      description = "Japanese morphological analysis system";
      homepage = "http://taku910.github.io/mecab/";
      license = licenses.bsd3;
      platforms = platforms.unix;
      maintainers = with maintainers; [ auntie ];
    };
})
