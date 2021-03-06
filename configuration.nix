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
    build-fallback = true
  '';

  nix.useSandbox = true;

  boot.kernelModules = [ "ecryptfs" ];
  boot.cleanTmpDir = true;

  time.timeZone = "America/Chicago";

  networking.hostName = "${hostName}";
  #networking.hostId = "03850442";

  nix.gc.automatic = true;
  nix.gc.dates = "03:15";
  nix.gc.options = "--delete-older-than 30d";

  services.dbus.enable = true;

  services.logind.extraConfig = ''
    KillUserProcesses=yes
  '';

  security.pam.enableEcryptfs = true;

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
      enableWideVine = false;
    };
    #stdenv.userHook = ''
    #  NIX_CFLAGS_COMPILE+=" -march=nehalem -mmmx -mno-3dnow -msse -msse2 -msse3 -mssse3 -mno-sse4a -mcx16 -msahf -mno-movbe -mno-aes -mno-sha -mno-pclmul -mpopcnt -mno-abm -mno-lwp -mno-fma -mno-fma4 -mno-xop -mno-bmi -mno-bmi2 -mno-tbm -mno-avx -mno-avx2 -msse4.2 -msse4.1 -mno-lzcnt -mno-rtm -mno-hle -mno-rdrnd -mno-f16c -mno-fsgsbase -mno-rdseed -mno-prfchw -mno-adx -mfxsr -mno-xsave -mno-xsaveopt -mno-avx512f -mno-avx512er -mno-avx512cd -mno-avx512pf -mno-prefetchwt1 -mno-clflushopt -mno-xsavec -mno-xsaves -mno-avx512dq -mno-avx512bw -mno-avx512vl -mno-avx512ifma -mno-avx512vbmi -mno-clwb -mno-pcommit -mno-mwaitx --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=8192 -mtune=nehalem"
    #'';
  };

  nixpkgs.config.packageOverrides = self: rec {
    #sddm = self.callPackage pkgs/applications/display-managers/sddm/default.nix { };
    gcal2org = self.callPackage pkgs/gcal2org/default.nix { };
    idea = self.idea // {
      idea-ultimate = self.idea.idea-ultimate.override {
        jdk = pkgs.oraclejdk8;
      };
      # android-studio = self.idea.android-studio.override {
      #   jdk = pkgs.oraclejdk8;
      # };
    };
    mesa_noglu = self.mesa_noglu.override {
      enableTextureFloats = true;
    };
    duplicity = self.duplicity.override {
      gnupg = pkgs.gnupg1orig;
    };
  };
}
