{ branch ? "stable", pkgs }:

let
  inherit (pkgs) callPackage fetchurl;
in {
  stable = callPackage ./base.nix {
    pname = "discord";
    binaryName = "Discord";
    desktopName = "Discord";
    version = "0.0.9";
    src = fetchurl {
      url = "https://dl.discordapp.net/apps/linux/0.0.9/discord-0.0.9.tar.gz";
      sha256 = "1i0f8id10rh2fx381hx151qckvvh8hbznfsfav8w0dfbd1bransf";
    };
  };
  ptb = callPackage ./base.nix {
    pname = "discord-ptb";
    binaryName = "DiscordPTB";
    desktopName = "Discord PTB";
    version = "0.0.15";
    src = fetchurl {
      url = "https://dl-ptb.discordapp.net/apps/linux/0.0.15/discord-ptb-0.0.15.tar.gz";
      sha256 = "0znqb0a3yglgx7a9ypkb81jcm8kqgc6559zi7vfqn02zh15gqv6a";
    };
  };
  canary = callPackage ./base.nix {
    pname = "discord-canary";
    binaryName = "DiscordCanary";
    desktopName = "Discord Canary";
    version = "0.0.83";
    src = fetchurl {
      url = "https://dl-canary.discordapp.net/apps/linux/0.0.83/discord-canary-0.0.83.tar.gz";
      sha256 = "100a61x71cgyfm0xk4qdlbp1v41089jy7lajksbpy4y7him6bg2s";
    };
  };
}.${branch}
