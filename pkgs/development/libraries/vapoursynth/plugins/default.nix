{ pkgs }:

{
  autocrop = pkgs.callPackage ./autocrop { };

  beziercurve = pkgs.callPackage ./beziercurve { };

  bifrost = pkgs.callPackage ./bifrost { };

  bilateral = pkgs.callPackage ./bilateral { };

  bm3d = pkgs.callPackage ./bm3d { };

  continuityfixer = pkgs.callPackage ./continuityfixer { };

  f3kdb = pkgs.callPackage ./f3kdb { };

  # why ffms2? it's the real name of the library and how it's referred to in vapoursynth
  ffms2 = pkgs.ffms;

  mvtools = pkgs.callPackage ./mvtools { };
}
