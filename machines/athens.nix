{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/default.nix
    ../profiles/desktop.nix
    ../profiles/development.nix
    ../profiles/gaming.nix
  ];

  environment.systemPackages = with pkgs; [
    gcal2org
  ];

  services.xserver.xrandrHeads = [ "DVI-0" "DVI-1" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

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

  networking.firewall.allowedTCPPorts = [ 8080 8081 3000 ];

  fileSystems."/mnt/Storage" = {
    device = "192.168.0.60:/c/Storage";
    fsType = "nfs";
    options = "nolock";
  };

  fileSystems."/mnt/backup" = {
    device = "192.168.0.60:/c/backup";
    fsType = "nfs";
    options = "nolock";
  };

  fileSystems."/mnt/media" = {
    device = "192.168.0.60:/c/media";
    fsType = "nfs";
    options = "nolock";
  };

  services.duplicity = {
    enable = true;
    user = "dtulig";
    archives = {
      home = {
        sourceDirectory = "/home/dtulig";
        targetUrl = "file:///mnt/backup/dtulig-desktop";
        period = "02:00";
        encryptKey = "CD754EB8";
      };
    };
  };
}
