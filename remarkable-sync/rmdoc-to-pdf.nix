# rmdoc-to-pdf — NixOS module
#
# Converts .rmdoc notebooks from ~/remarkable into PDFs in ~/remarkable-pdf.
# Uses rmc (SVG pipeline) + inkscape. Runs after the sync service.
#
# Import alongside remarkable-sync.nix:
#   imports = [ ./remarkable-sync.nix ./rmdoc-to-pdf.nix ];
#
#   services.rmdoc-to-pdf = {
#     enable = true;
#     user   = "progressio";
#   };
#
{ config, lib, pkgs, ... }:

let
  cfg = config.services.rmdoc-to-pdf;

  rmscene-new = pkgs.python3Packages.buildPythonPackage rec {
    pname   = "rmscene";
    version = "0.8.0";
    format  = "pyproject";
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-25QXprjMhugMG+jO+inOwk1NSXd0M9SdH8dBdz8Q1b4=";
    };
    build-system     = [ pkgs.python3Packages.poetry-core ];
    doCheck          = false;
    pythonRemoveDeps = [ "packaging" ];
  };

  rmc = pkgs.python3Packages.buildPythonPackage {
    pname   = "rmc";
    version = "unstable-2024";
    format  = "pyproject";
    src = pkgs.fetchFromGitHub {
      owner  = "ricklupton";
      repo   = "rmc";
      rev    = "main";
      sha256 = "sha256-oNBzJ8ce1RQG8Lz77fBIz+8nM7si07KEnlXA1GesKEk=";
    };
    build-system = [ pkgs.python3Packages.poetry-core ];
    propagatedBuildInputs = with pkgs.python3Packages; [
      rmscene-new packaging pypdf reportlab click
    ];
    doCheck = false;
  };

  python = pkgs.python3.withPackages (ps: [
    rmc rmscene-new ps.packaging ps.pypdf ps.reportlab ps.cairosvg
  ]);

  converterScript = pkgs.writers.writePython3Bin "rmdoc-to-pdf"
    { flakeIgnore = [ "E" "W" ]; }
    (builtins.readFile ./rmdoc-to-pdf.py);

in {

  options.services.rmdoc-to-pdf = {

    enable = lib.mkEnableOption "reMarkable .rmdoc to PDF converter";

    user = lib.mkOption {
      type        = lib.types.str;
      example     = "progressio";
      description = "User to run as.";
    };

    inputDir = lib.mkOption {
      type    = lib.types.str;
      default = "/home/${cfg.user}/remarkable";
      description = "Folder containing .rmdoc files (sync output).";
    };

    outputDir = lib.mkOption {
      type    = lib.types.str;
      default = "/home/${cfg.user}/remarkable-pdf";
      description = "Folder where converted PDFs are written.";
    };

    interval = lib.mkOption {
      type    = lib.types.str;
      default = "10min";
      description = "How often to run the converter.";
    };

    extraArgs = lib.mkOption {
      type    = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {


    systemd.tmpfiles.rules = [
      "d '${cfg.outputDir}'  0755 ${cfg.user} users - -"
    ];

    systemd.services.rmdoc-to-pdf = {
      description = "Convert reMarkable notebooks to PDF";
      after       = [ "remarkable-sync.service" "systemd-tmpfiles-setup.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Nice = 15;

        Environment = [
          "HOME=/home/${cfg.user}"
          "RMC_PYTHON=${python}/bin/python3"
        ];

        ExecStart =
          "${converterScript}/bin/rmdoc-to-pdf"
          + " --input ${cfg.inputDir}"
          + " --output ${cfg.outputDir}"
          + " --python ${python}/bin/python3"
          + lib.optionalString (cfg.extraArgs != [])
              (" " + lib.escapeShellArgs cfg.extraArgs);

        SuccessExitStatus = "0 1";
      };
    };

    systemd.timers.rmdoc-to-pdf = {
      description = "Run rmdoc-to-pdf converter every ${cfg.interval}";
      wantedBy    = [ "timers.target" ];

      timerConfig = {
        OnBootSec       = "3min";
        OnUnitActiveSec = cfg.interval;
        Persistent      = true;
      };
    };
  };
}
