{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.synapse-bt;
in {
  options = {
    services.synapse-bt = {
      enable = mkEnableOption "the Synapse BitTorrent daemon";

      installClient = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Add the synapse-bt package, which includes a client,
          <command>sycli</command>, to
          <option>environment.systemPackages</option>.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "synapse-bt";
        description = ''
          User under which synapse-bt will run.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "synapse-bt";
        description = ''
          Group under which synapse-bt will run.
        '';
      };

      config = mkOption {
        type = types.attrs;
        default = {};
        description = ''
          Configuration for synapse.toml. See
          <link xlink:href="https://github.com/Luminarys/synapse/blob/${pkgs.synapse-bt.version}/example_config.toml"/>
          for options.

          Warning: this file will be world-readable in the Nix store,
          so any authentication setup should be set up in
          <option>services.synapse-bt.extraConfigPath</option>.
        '';
        example = literalExample ''
          {
            port = 16943;
            max_dl = 10;
            rpc = {
              port = 8412;
              local = true;
            };
          }
        '';
      };

      extraConfigPath = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          Path to a TOML file that will be appended to the synapse.toml file defined in
          <option>services.synapse-bt.config</option>.

          This is intended to store authentication info for its RPC interface.
        '';
      };
    };
  };

  config = let
    configFile = pkgs.runCommand "synapse.toml" {
      buildInputs = [ pkgs.remarshal ];
    } ''
      remarshal -if json -of toml < ${pkgs.writeText "synapse.json" (builtins.toJSON cfg.config)} > $out
    '';
  in mkIf cfg.enable {
    users.users.synapse-bt = mkIf (cfg.user == "synapse-bt") { group = "synapse-bt"; };
    users.groups.synapse-bt = mkIf (cfg.group == "synapse-bt") {};

    environment.systemPackages = mkIf cfg.installClient [ pkgs.synapse-bt ];

    systemd.tmpfiles.rules = ([
      "d /var/lib/synapse-bt              0750 ${cfg.user} ${cfg.group} - -"
    ] ++ optional (cfg.extraConfigPath != null)
      "f /var/lib/synapse-bt/synapse.toml 0600 ${cfg.user} ${cfg.group} - -");

    systemd.services.synapse-bt = {
      description = "Synapse BitTorrent daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStartPre = mkIf (cfg.extraConfigPath != null) ''
          ${pkgs.bash}/bin/bash -c ${escapeShellArg ''
            ${pkgs.coreutils}/bin/cat \
                ${configFile} \
                ${cfg.extraConfigPath} \
                > /var/lib/synapse-bt/synapse.toml \
          ''}
        '';
        ExecStart = ''
          ${pkgs.synapse-bt}/bin/synapse -c ${if cfg.extraConfigPath != null then "/var/lib/synapse-bt/synapse.toml" else configFile}
        '';
      };
    };
  };

  meta.maintainers = with maintainers; [ tadeokondrak ];
}
