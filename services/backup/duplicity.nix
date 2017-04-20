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
          Enable periodic duplicity backups.
        '';
      };

      user = mkOption {
        type = types.string;
        default = "";
        description = ''
          User to run the script as. Useful to make sure the GPG key id is accessible.
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

              fullFreq = mkOption {
                type = types.string;
                default = "1W";
                description = "How often should a new full backup be performed.";
              };

              fullLife = mkOption {
                type = types.string;
                default = "1M";
                description = "Delete any backup older than this.";
              };

              keepFull = mkOption {
                type = types.string;
                default = "1";
                description = "How many full backups should be kept.";
              };

              trickleUpload = mkOption {
                type = types.string;
                default = "";
                description = "Limit upload speed using trickle.";
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

      path = [ pkgs.duplicity pkgs.coreutils pkgs.trickle ];
      scriptArgs = "%i";
      script = ''
        SOURCE_DIRECTORY=`cat /etc/duplicity/$1.sourceDirectory`
        TARGET_URL=`cat /etc/duplicity/$1.targetUrl`
        ENCRYPT_KEY=`cat /etc/duplicity/$1.encryptKey`
        FULL_FREQ=`cat /etc/duplicity/$1.fullFreq`
        FULL_LIFE=`cat /etc/duplicity/$1.fullLife`
        KEEP_FULL=`cat /etc/duplicity/$1.keepFull`
        TRICKLE_UPLOAD=`cat /etc/duplicity/$1.trickleUpload`

        echo "Starting backup."

        if [[ -z "$TRICKLE_UPLOAD" ]]; then
          echo "duplicity --full-if-older-than $FULL_FREQ --file-prefix-manifest manifest_ --file-prefix-archive archive_ --file-prefix-signature signature_ --encrypt-key $ENCRYPT_KEY $SOURCE_DIRECTORY $TARGET_URL"

          duplicity --full-if-older-than $FULL_FREQ --file-prefix-manifest manifest_ --file-prefix-archive archive_ --file-prefix-signature signature_ --encrypt-key $ENCRYPT_KEY $SOURCE_DIRECTORY $TARGET_URL
        else
          echo "trickle -s -u $TRICKLE_UPLOAD duplicity --full-if-older-than $FULL_FREQ --file-prefix-manifest manifest_ --file-prefix-archive archive_ --file-prefix-signature signature_ --encrypt-key $ENCRYPT_KEY $SOURCE_DIRECTORY $TARGET_URL"
          trickle -s -u $TRICKLE_UPLOAD duplicity --full-if-older-than $FULL_FREQ --file-prefix-manifest manifest_ --file-prefix-archive archive_ --file-prefix-signature signature_ --encrypt-key $ENCRYPT_KEY $SOURCE_DIRECTORY $TARGET_URL
        fi

        echo "Removing older than $FULL_LIFE."
        duplicity remove-older-than $FULL_LIFE --file-prefix-manifest manifest_ --file-prefix-archive archive_ --file-prefix-signature signature_ --force $TARGET_URL
        echo "Removing all incremental except $KEEP_FULL full."
        duplicity remove-all-inc-of-but-n-full $KEEP_FULL --file-prefix-manifest manifest_ --file-prefix-archive archive_ --file-prefix-signature signature_ --force $TARGET_URL
      '';

      serviceConfig = {
        IOSchedulingClass = "idle";
        NoNewPrivileges = "true";
        CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
        User=cfg.user;
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
        }) cfg.archives) //
      (mapAttrs' (name: cfg: nameValuePair "duplicity/${name}.fullFreq"
        { text = cfg.fullFreq;
        }) cfg.archives) //
      (mapAttrs' (name: cfg: nameValuePair "duplicity/${name}.fullLife"
        { text = cfg.fullLife;
        }) cfg.archives) //
      (mapAttrs' (name: cfg: nameValuePair "duplicity/${name}.trickleUpload"
        { text = cfg.trickleUpload;
        }) cfg.archives) //
      (mapAttrs' (name: cfg: nameValuePair "duplicity/${name}.keepFull"
        { text = cfg.keepFull;
        }) cfg.archives);

    environment.systemPackages = [ pkgs.duplicity pkgs.trickle ];
  };
}
