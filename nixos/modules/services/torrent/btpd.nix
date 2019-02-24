{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.btpd;
in {
  options = {
    services.btpd = {
      enable = mkEnableOption "the BitTorrent protocol daemon";
      package = mkOption {
        type = types.package;
        default = pkgs.btpd;
        defaultText = "pkgs.btpd";
        description = ''
          The btpd package to use.
        '';
      };
      baseDir = mkOption {
        type = types.str;
        default = "/var/lib/btpd";
        description = ''
          Base directory for btpd. State, logs, a socket, and torrent downloads are stored here.
        '';
      };
      user = mkOption {
        type = types.str;
        default = "btpd";
        description = ''
          User which to run btpd as.
        '';
      };
      group = mkOption {
        type = types.str;
        default = "btpd";
        description = ''
          Group which to run btpd as.
        '';
      };
      address = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          IP address to send to trackers.
          Null sends no address, so trackers will advertise the one they see btpd connect from.
        '';
      };
      port = mkOption {
        type = types.port;
        default = 6681;
        description = ''
          Port for btpd to listen on.
        '';
      };
      ipv4 = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable IPv4 support for btpd.
        '';
      };
      ipv6 = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable IPv6 support for btpd.
        '';
      };
      bandwidthLimitIn = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = ''
          Limit incoming BitTorrent traffic to n kB/s. 0 is unlimited.
        '';
      };
      bandwidthLimitOut = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = ''
          Limit outgoing BitTorrent traffic to n kB/s. 0 is unlimited.
        '';
      };
      emptyStart = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Start btpd without any active torrents.
        '';
      };
      ipcPermission = mkOption {
        type = types.ints.unsigned;
        default = 0600;
        description = ''
          Permission mode of the btpd socket.
        '';
      };
      maxPeers = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = ''
          Limit the amount of peers to n.
        '';
      };
      maxUploads = mkOption {
        type = types.int;
        default = -2;
        description = ''
          Controls the number of simultaneous uploads.
          The possible values are:
          <literallayout>
          n &lt; -1 : Choose n >= 2 based on bandwidthLimitOut (default).
          n = -1 : Upload to every interested peer.
          n =  0 : Don't upload to anyone.
          n &gt;  0 : Upload to at most n peers simultaneously.
          </literallayout>
        '';
      };
      prealloc = mkOption {
        type = types.ints.unsigned;
        default = 2048;
        description = ''
          Preallocate disk space in chunks of n kB.
          Note that n will be rounded up to the closest multiple of the
          torrent piece size. If n is zero no preallocation will be done.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.btpd = {
      after = [ "network.target" ];
      description = "BitTorrent Protocol Daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Type = "forking";
        PIDFile = "${cfg.baseDir}/pid";
        TimeoutSec = 300;
        ExecStart = ''
          ${cfg.package}/bin/btpd \
              -d ${escapeShellArg cfg.baseDir} \
              ${optionalString (cfg.ipv4 && cfg.ipv6) "-4"} \
              ${optionalString cfg.ipv6 "-6"} \
              ${optionalString (cfg.bandwidthLimitIn != 0) "--bw-in ${toString cfg.bandwidthLimitOut}"} \
              ${optionalString (cfg.bandwidthLimitOut != 0) "--bw-out ${toString cfg.bandwidthLimitOut}"} \
              ${optionalString cfg.emptyStart "--empty-start"} \
              ${optionalString (cfg.ipcPermission != 0600) "--ipcprot ${toString cfg.ipcPermission}"} \
              ${optionalString (cfg.maxPeers != 0) "--max-peers ${toString cfg.maxPeers}"} \
              ${optionalString (cfg.maxUploads != -2) "--max-uploads ${toString cfg.maxUploads}"} \
              ${optionalString (cfg.address != null) "--ip ${cfg.address}"} \
              ${optionalString (cfg.port != 6681) "--port ${toString cfg.port}"} \
              ${optionalString (cfg.prealloc != 2048) "--prealloc ${toString cfg.prealloc}"}
        '';
        ExecStop = ''
          ${cfg.package}/bin/btcli -d ${escapeShellArg cfg.baseDir} kill
        '';
      };
    };
    users.users.btpd = {
      group = "btpd";
      description = "BitTorrent protocol daemon user";
      home = "/var/lib/btpd";
      createHome = true;
      uid = config.ids.uids.btpd;
    };
    users.groups.btpd.gid = config.ids.gids.btpd;
  };
  meta.maintainers = with maintainers; [ tadeokondrak ];
}
