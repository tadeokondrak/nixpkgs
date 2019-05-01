{ branch ? "stable", pkgs }:

let
  inherit (pkgs) callPackage fetchurl;
in {
  stable = callPackage ./base.nix rec {
    pname = "discord";
    binaryName = "Discord";
    desktopName = "Discord";
    version = "0.0.9";
    src = fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/${pname}-${version}.tar.gz";
      sha256 = "1i0f8id10rh2fx381hx151qckvvh8hbznfsfav8w0dfbd1bransf";
    };
  };

  ptb = callPackage ./base.nix rec {
    pname = "discord-ptb";
    binaryName = "DiscordPTB";
    desktopName = "Discord PTB";
    version = "0.0.15";
    src = fetchurl {
      url = "https://dl-ptb.discordapp.net/apps/linux/${version}/${pname}-${version}.tar.gz";
      sha256 = "0znqb0a3yglgx7a9ypkb81jcm8kqgc6559zi7vfqn02zh15gqv6a";
    };
  };

  canary = callPackage ./base.nix rec {
    pname = "discord-canary";
    binaryName = "DiscordCanary";
    desktopName = "Discord Canary";
    version = "0.0.75";
    src = fetchurl {
      url = "https://dl-canary.discordapp.net/apps/linux/${version}/${pname}-${version}.tar.gz";
      sha256 = "19cn2bw2g3hmbkq1qwsjvq9c8lpfxfq90i3l0c7dv7ph0fxn2y1d";
    };
  };
}.${branch}

