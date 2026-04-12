# remarkable-sync — NixOS system module
#
# Import in your SYSTEM configuration.nix (NOT inside home-manager):
#
#   imports = [ ./remarkable-sync.nix ];
#
#   services.remarkable-sync = {
#     enable  = true;
#     user    = "progressio";
#   };
#
# One-time auth after first rebuild:
#   rmapi  ->  visit https://my.remarkable.com/connect/desktop, paste code
#
# USB PDF export (optional, best quality):
#   Plug tablet in via USB, enable Settings -> Storage -> USB web interface.
#   The sync will automatically use it when detected.
#
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.remarkable-sync;
  stateDir = builtins.dirOf cfg.stateFile;

  syncScript = pkgs.writers.writePython3Bin "remarkable-sync" {
    flakeIgnore = [
      "E"
      "W"
    ];
  } (builtins.readFile ./remarkable-sync.py);

in
{

  options.services.remarkable-sync = {

    enable = lib.mkEnableOption "reMarkable two-way cloud sync";

    user = lib.mkOption {
      type = lib.types.str;
      example = "progressio";
      description = "Username that owns the sync folder and rmapi credentials.";
    };

    syncDir = lib.mkOption {
      type = lib.types.str;
      description = "Local directory synced with the reMarkable cloud.";
      default = "/home/${cfg.user}/remarkable";
    };

    stateFile = lib.mkOption {
      type = lib.types.str;
      description = "JSON file used to track sync state between runs.";
      default = "/home/${cfg.user}/.local/share/remarkable-sync/state.json";
    };

    remoteRoot = lib.mkOption {
      type = lib.types.str;
      default = "/";
      description = "Root folder on the reMarkable cloud to sync against.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      example = "15min";
      description = "How often to run the sync (systemd OnUnitActiveSec value).";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--verbose" ];
      description = "Extra arguments forwarded to the remarkable-sync script.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.rmapi ];

    systemd = {
      tmpfiles.rules = [
        "d '${cfg.syncDir}'  0755 ${cfg.user} users - -"
        "d '${stateDir}'     0755 ${cfg.user} users - -"
      ];

      services.remarkable-sync = {
        description = "reMarkable two-way cloud sync";
        wants = [ "network-online.target" ];
        after = [
          "network-online.target"
          "systemd-tmpfiles-setup.service"
        ];

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Nice = 10;

          Environment = [
            "HOME=/home/${cfg.user}"
            "REMARKABLE_SYNC_DIR=${cfg.syncDir}"
            "REMARKABLE_STATE_FILE=${cfg.stateFile}"
            "REMARKABLE_REMOTE_ROOT=${cfg.remoteRoot}"
            "RMAPI_BIN=${pkgs.rmapi}/bin/rmapi"
          ];

          ExecStart =
            "${syncScript}/bin/remarkable-sync"
            + lib.optionalString (cfg.extraArgs != [ ]) (" " + lib.escapeShellArgs cfg.extraArgs);

          SuccessExitStatus = "0 1";
        };
      };

      timers.remarkable-sync = {
        description = "Trigger reMarkable sync every ${cfg.interval}";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = cfg.interval;
          Persistent = true;
        };
      };
    };
  };
}
