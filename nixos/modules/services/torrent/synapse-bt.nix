{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.synapse-bt;
  stateDirectory = "/var/lib/synapse-bt";
in {
  options = {
    services.synapse-bt = {
      enable = mkEnableOption "the Synapse BitTorrent daemon";

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
    users.users.synapse-bt = mkIf (cfg.user == "synapse-bt") { group = mkDefault "synapse-bt"; };
    users.groups.synapse-bt = mkIf (cfg.group == "synapse-bt") {};

    # for sycli
    environment.systemPackages = [ pkgs.synapse-bt ];

    systemd.services.synapse-bt = {
      description = "Synapse BitTorrent daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      preStart = mkIf (cfg.extraConfigPath != null) ''
        touch ${stateDirectory}/synapse.toml
        chmod 600 ${stateDirectory}/synapse.toml
        ${pkgs.coreutils}/bin/cat \
            ${configFile} \
            ${cfg.extraConfigPath} \
            > ${stateDirectory}/synapse.toml
      '';
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "synapse-bt";
        ExecStart = ''
          ${pkgs.synapse-bt}/bin/synapse -c ${if cfg.extraConfigPath != null then "${stateDirectory}/synapse.toml" else configFile}
        '';
      };
    };
  };

  meta.maintainers = with maintainers; [ tadeokondrak ];
}
