{ pkgs }:

{
  autocrop = pkgs.callPackage ./autocrop { };

  beziercurve = pkgs.callPackage ./beziercurve { };

  bifrost = pkgs.callPackage ./bifrost { };

  bilateral = pkgs.callPackage ./bilateral { };

  bm3d = pkgs.callPackage ./bm3d { };

  continuityfixer = pkgs.callPackage ./continuityfixer { };

  fmtconv = pkgs.callPackage ./fmtconv { };

  eedi2 = pkgs.callPackage ./eedi2 { };

  f3kdb = pkgs.callPackage ./f3kdb { };

  # why ffms2? it's the real name of the library and how it's referred to in vapoursynth
  ffms2 = pkgs.ffms;

  lsmashsource = pkgs.callPackage ./lsmashsource { };

  mvtools = pkgs.callPackage ./mvtools { };

  nnedi3 = pkgs.callPackage ./nnedi3 { };

  sangnom = pkgs.callPackage ./sangnom { };

  tcanny = pkgs.callPackage ./tcanny { };
}
