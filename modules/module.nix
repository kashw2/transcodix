{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.transcodix;
in
{
  imports = [ ];

  options.services.transcodix = {
    enable = lib.mkEnableOption "transcodix";

    watchDirectory = lib.mkOption {
      type = lib.types.str;
      example = "/home/user/Downloads";
    };

    watchExtension = lib.mkOption {
      type = lib.types.either lib.types.str (
        lib.types.enum [
          "mkv"
          "avi"
        ]
      );
    };

    outputDirectory = lib.mkOption {
      type = lib.types.str;
      example = "/home/user/Downloads";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "transcodix";
      example = "kashw2";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "transcodix";
      example = "wheel";
    };

    transcodingPackage = lib.mkOption {
      type = lib.types.either lib.types.str (
        lib.types.enum [
          "handbrake"
          "ffmpeg"
        ]
      );
      default = "handbrake";
      example = "ffmpeg";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.transcodix = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = (if cfg.transcodingPackage == "handbrake" then [ pkgs.handbrake ] else [ pkgs.ffmpeg ]) ++ [
        pkgs.inotify-tools
        pkgs.bash
      ];

      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash ${../transcoder.sh} ${cfg.watchDirectory} ${cfg.watchExtension} ${cfg.outputDirectory} ${cfg.transcodingPackage}";
        Restart = "always";
        RestartSec = "10s";
      };
    };

    users.users.${cfg.user} = {
      description = "System user for the transcodix instance";
      group = cfg.group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = {
      name = cfg.group;
      members = if cfg.user != "" then [ cfg.user ] else [ ];
    };
  };
}
