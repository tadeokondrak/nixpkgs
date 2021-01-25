{ lib, stdenv, fetchFromGitHub, pkg-config, autoreconfHook, makeWrapper
, runCommandCC, buildEnv, vapoursynth, writeText, patchelf
, zimg, libass, python3, libiconv
, ApplicationServices
, ocrSupport ?  false, tesseract ? null
, imwriSupport? true,  imagemagick7 ? null
}:

assert ocrSupport   -> tesseract != null;
assert imwriSupport -> imagemagick7 != null;

with lib;

stdenv.mkDerivation rec {
  pname = "vapoursynth";
  version = "R52";

  src = fetchFromGitHub {
    owner  = "vapoursynth";
    repo   = "vapoursynth";
    rev    = version;
    sha256 = "1krfdzc2x2vxv4nq9kiv1c09hgj525qn120ah91fw2ikq8ldvmx4";
  };

  patches = [
    ./0001-Call-weak-function-to-allow-adding-preloaded-plugins.patch
  ];

  nativeBuildInputs = [ pkg-config autoreconfHook makeWrapper ];
  buildInputs = [
    zimg libass
    (python3.withPackages (ps: with ps; [ sphinx cython ]))
  ] ++ optionals stdenv.isDarwin [ libiconv ApplicationServices ]
    ++ optional ocrSupport   tesseract
    ++ optional imwriSupport imagemagick7;

  configureFlags = [
    (optionalString (!ocrSupport)   "--disable-ocr")
    (optionalString (!imwriSupport) "--disable-imwri")
  ];

  enableParallelBuilding = true;

  passthru = {
    # If vapoursynth is added to the build inputs of mpv and then
    # used in the wrapping of it, we want to know once inside the
    # wrapper, what python3 version was used to build vapoursynth so
    # the right python3.sitePackages will be used there.
    inherit python3;

    withPlugins = plugins: let
      pythonEnvironment = python3.buildEnv.override {
        extraLibs = plugins;
      };

      pluginLoader = let
        source = writeText "vapoursynth-nix-plugins.c" ''
          void VSLoadPluginsNix(void (*load)(void *data, const char *path), void *data) {
          ${concatMapStringsSep "" (path: "load(data, \"${path}/lib/vapoursynth\");") plugins}
          }
        '';
      in
      runCommandCC "vapoursynth-plugin-loader" {
        executable = true;
        passAsFile = ["code"];
        preferLocalBuild = true;
        allowSubstitutes = false;
      } ''
        mkdir -p $out/lib
        $CC -shared -fPIC ${source} -o "$out/lib/libvapoursynth-nix-plugins${ext}"
      '';

      ext = stdenv.targetPlatform.extensions.sharedLibrary;
    in
    buildEnv {
      name = "${vapoursynth.name}-with-plugins";
      paths = [ vapoursynth pluginLoader ] ++ plugins;
      buildInputs = [ makeWrapper patchelf ];
      postBuild = ''
        rm $out/lib/libvapoursynth${ext}
        cp ${vapoursynth}/lib/libvapoursynth${ext} $out/lib/libvapoursynth${ext}
        chmod +w $out/lib/libvapoursynth${ext}
        patchelf $out/lib/libvapoursynth${ext} \
            --add-needed libvapoursynth-nix-plugins${ext}
        chmod -w $out/lib/libvapoursynth${ext}
      '';
      passthru = {
        inherit python3;
        withPlugins = plugins': withPlugins (plugins ++ plugins');
      };
    };
  };

  postInstall = ''
    wrapProgram $out/bin/vspipe \
        --prefix PYTHONPATH : $out/${python3.sitePackages}
  '';

  meta = with lib; {
    description = "A video processing framework with the future in mind";
    homepage    = "http://www.vapoursynth.com/";
    license     = licenses.lgpl21;
    platforms   = platforms.x86_64;
    maintainers = with maintainers; [ rnhmjoj tadeokondrak ];
  };

}
