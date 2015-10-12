{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.duplicity;
in
{
  options = {
    services.duplicity = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable periodic tarsnap backups.
        '';
      };

      archives = mkOption {
        type = types.attrsOf (types.submodule (
          {
            options = {
              period = mkOption {
                type = types.str;
                default = "01:15";
                example = "hourly";
                description = ''
                  Create backup at this interval.
                  The format is described in
                  <citerefentry><refentrytitle>systemd.time</refentrytitle>
                  <manvolnum>7</manvolnum></citerefentry>.
                '';
              };

              sourceDirectory = mkOption {
                type = types.path;
                default = "";
                description = "Source directory.";
              };

              targetUrl = mkOption {
                type = types.string;
                default = "";
                description = "Target URL. Must be a URL such as \"scp://user@host.net:1234/path\" and \"file:///usr/local\"";
              };

              encryptKey = mkOption {
                type = types.string;
                default = "";
                description = "The GPG encryption key id to use to encrypt the backup.";
              };
            };
          }
        ));

        default = {};

        example = literalExample ''
          {
            home =
              { sourceDirectory = "/home";
                targetDirectory = "file:///mnt/backup/home-backup";
              };
          }
        '';

        description = ''
          TODO
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      (mapAttrsToList (name: cfg:
        { assertion = cfg.sourceDirectory != "";
          message = "Source directory must be specified.";
        }) cfg.archives) ++
      (mapAttrsToList (name: cfg:
        { assertion = cfg.targetUrl != "";
          message = "Target URL must be specified.";
        }) cfg.archives);

    systemd.services."duplicity@" = {
      description = "Duplicity backup '%i'";
      requires = [ "network.target" ];

      path = [ pkgs.duplicity pkgs.coreutils ];
      scriptArgs = "%i";
      script = ''
        SOURCE_DIRECTORY=`cat /etc/duplicity/$1.sourceDirectory`
        TARGET_URL=`cat /etc/duplicity/$1.targetUrl`
        ENCRYPT_KEY=`cat /etc/duplicity/$1.encryptKey`
        exec duplicity --full-if-older-than 1W --encrypt-key $ENCRYPT_KEY $SOURCE_DIRECTORY $TARGET_URL
      '';

      serviceConfig = {
        IOSchedulingClass = "idle";
        NoNewPrivileges = "true";
        CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
        User="dtulig";
      };
    };

    systemd.timers = mapAttrs' (name: cfg: nameValuePair "duplicity@${name}"
      { timerConfig.OnCalendar = cfg.period;
        wantedBy = [ "timers.target" ];
      }) cfg.archives;

    environment.etc =
      (mapAttrs' (name: cfg: nameValuePair "duplicity/${name}.sourceDirectory"
        { text = cfg.sourceDirectory;
        }) cfg.archives) //
      (mapAttrs' (name: cfg: nameValuePair "duplicity/${name}.targetUrl"
        { text = cfg.targetUrl;
        }) cfg.archives) //
      (mapAttrs' (name: cfg: nameValuePair "duplicity/${name}.encryptKey"
        { text = cfg.encryptKey;
        }) cfg.archives);

    environment.systemPackages = [ pkgs.duplicity ];
  };
}