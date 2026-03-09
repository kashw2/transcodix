{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.transcodix;

  transcoderScript = import ./package.nix {
    inherit pkgs;
    inherit (cfg)
      watchDirectory
      watchExtension
      outputDirectory
      transcodingPackage
      ;
  };
in
{
  options.services.transcodix = {
    enable = lib.mkEnableOption "transcodix";

    watchDirectory = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Directory to watch for new files to transcode.";
      example = "/home/user/Downloads";
    };

    watchExtension = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "File extension to watch for (e.g. mkv, avi).";
      example = "mkv";
    };

    outputDirectory = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Directory to write transcoded files to.";
      example = "/home/user/Downloads";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "transcodix";
      description = "User account under which transcodix runs.";
      example = "kashw2";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "transcodix";
      description = "Group under which transcodix runs.";
      example = "wheel";
    };

    transcodingPackage = lib.mkOption {
      type = lib.types.enum [
        "handbrake"
        "ffmpeg"
      ];
      default = "handbrake";
      description = "Transcoding backend to use.";
      example = "ffmpeg";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.transcodix = {
      description = "Transcodix - file transcoding service";
      after = [ "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${transcoderScript}/bin/transcodix";
        Restart = "always";
        RestartSec = "10s";
        User = cfg.user;
        Group = cfg.group;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateTmp = true;
        ReadWritePaths = [ cfg.outputDirectory ];
        ReadOnlyPaths = [ cfg.watchDirectory ];
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
