{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/default.nix
    ../profiles/desktop.nix
    ../profiles/development.nix
    ../profiles/desktop-development.nix
    ../profiles/gaming.nix
    #../profiles/qemu.nix
  ];

  environment.systemPackages = with pkgs; [
    gcal2org

    acbuild
    rkt
  ];

  services.xserver = {
    xrandrHeads = [ "DFP3" "DFP4" ];
    videoDrivers = [ "ati" ];
  };

  virtualisation.virtualbox.host.enable = true;
  nixpkgs.config.virtualbox.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "dtulig" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.opengl.driSupport32Bit = true;

  boot.initrd.mdadmConf = ''
    ARRAY /dev/md0 UUID=912385cd:c0a1b495:b752d81b:fa0837fe
  '';

  boot.kernelModules = [ "dm_mod" "dm_crypt" "raid1" "aes" "sha256"
"cbc" "xts" ];

  boot.initrd.luks.cryptoModules = ["aes" "sha1" "sha256" "dm_crypt"
"cbc" "xts" ];

  boot.initrd.luks.devices = [
   { name = "luksroot";
      device = "/dev/md0";
      preLVM = true;
   }
   { name = "lukshome"; device = "/dev/sda2"; }
  ];

  fileSystems."/" = {
    mountPoint = "/";
    device = "/dev/mapper/vg-system";
  };

  fileSystems."/boot" = {
    mountPoint = "/boot";
    device = "/dev/sda1";
  };

  fileSystems."/home" = {
    mountPoint = "/home";
    device = "/dev/mapper/lukshome";
  };

  fileSystems."/data" = {
    mountPoint = "/data";
    device = "/dev/mapper/vg-data";
  };

  swapDevices = [ {
      device = "/var/swapfile";
      size = 16384;
    }
  ];

  boot.loader.grub.extraEntries = ''
    menuentry "Windows 7" {
      chainloader (hd0,3)+1
    }
  '';

  networking.networkmanager.enable = true;

  # TODO: Get android development working
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"
  '';

  networking.firewall.allowedTCPPorts = [ 8080 9876 9000 ];

  fileSystems."/mnt/backup" = {
    device = "192.168.0.60:/c/backup";
    fsType = "nfs";
    options = ["nolock"];
  };

  fileSystems."/mnt/media" = {
    device = "192.168.0.60:/c/media";
    fsType = "nfs";
    options = ["nolock"];
  };

  services.duplicity = {
    enable = true;
    user = "dtulig";
    archives = {
      home = {
        sourceDirectory = "/home/dtulig";
        targetUrl = "file:///mnt/backup/dtulig-desktop";
        period = "02:15";
        encryptKey = "CD754EB8";
        fullFreq = "1W";
        fullLife = "6W";
        keepFull = "2";
      };
      home-gcs = {
        sourceDirectory = "/home/dtulig";
        targetUrl = "gs://backup-davidtulig-com/athens";
        period = "01:15";
        encryptKey = "CD754EB8";
        fullFreq = "1M";
        fullLife = "6M";
        keepFull = "1";
        trickleUpload = "400";
      };
      storage-gcs = {
        sourceDirectory = "/mnt/backup/storage";
        targetUrl = "gs://backup-davidtulig-com/readynas-storage";
        period = "01:15";
        encryptKey = "CD754EB8";
        fullFreq = "6M";
        fullLife = "2Y";
        keepFull = "1";
        trickleUpload = "400";
      };
    };
  };

  services.redshift = {
    enable = false;
    latitude = "30.28";
    longitude = "-97.76";
  };

  services.syncthing = {
    enable = true;
    systemService = false;
    user = "dtulig";
    group = "users";
  };
}
