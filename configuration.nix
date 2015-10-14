# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let hostName = "${builtins.readFile ./hostname}";
in
rec {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Bring in custom modules.
      ./services/backup/duplicity.nix

      (./machines + "/${hostName}.nix")
    ];

  nix.extraOptions = ''
    auto-optimise-store = true
    build-use-substitutes = false
  '';

  nix.useChroot = true;

  boot.kernelModules = [ "ecryptfs" ];
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;

  time.timeZone = "America/Chicago";

  networking.hostName = "${hostName}";
  #networking.hostId = "03850442";

  nix.gc.automatic = true;
  nix.gc.dates = "03:15";
  nix.gc.options = "--delete-older-than 30d";

  services.dbus.enable = true;

  security.pam.enableEcryptfs = true;

  hardware.pulseaudio.enable = true;

  users.extraUsers.dtulig = {
    isNormalUser = true;
    home = "/home/dtulig";
    name = "dtulig";
    #group = "dtulig";
    description = "David Tulig";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = "/run/current-system/sw/bin/zsh";
    #createHome = true;
    uid = 1000;
  };

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
      enableWideVine = true;
    };
  };

  nixpkgs.config.packageOverrides = self: rec {
    sddm = self.callPackage pkgs/applications/display-managers/sddm/default.nix { };
    gcal2org = self.callPackage pkgs/gcal2org/default.nix { };
    idea = self.idea // {
      idea-ultimate = self.idea.idea-ultimate.override {
        jdk = pkgs.oraclejdk8;
      };
      android-studio = self.idea.android-studio.override {
        jdk = pkgs.oraclejdk8;
      };
    };
  };
}
