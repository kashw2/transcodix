{ lib, pkgs, config, ... }:
let
  cfg = config.services.transcodix;
in
{
  imports = [];

  options.services.transcodix = {
    enable = lib.mkEnableOption "transcodix";

    watchDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${config.users.users.keanu.home}/Downloads";
    };

    watchExtension = lib.mkOption {
      type = lib.types.either lib.types.str (lib.types.enum [ "mkv" "avi" ]);
    };

    outputDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${config.users.users.keanu.home}/Downloads";
    };

    transcodingPackage = lib.mkOption {
      type = lib.types.either lib.types.str (lib.types.enum [ "handbrake" "ffmpeg" ]);
      default = "handbrake";
      example = "ffmpeg";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.transcodix = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.inotify-tools pkgs.handbrake pkgs.bash pkgs.ffmpeg ];

      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash ${./transcoder.sh} ${cfg.watchDirectory} ${cfg.outputDirectory} ${cfg.watchExtension} ${cfg.transcodingPackage}";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
