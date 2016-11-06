{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/default.nix
    ../profiles/headless.nix
    ../profiles/development.nix
    ../profiles/email.nix
    #<nixos/modules/services/misc/gitit.nix>
  ];

  security.pam.enableEcryptfs = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.extraConfig = "serial; terminal_input serial; terminal_output serial";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    config = pkgs.lib.readFile /var/lib/nginx/nginx.conf;
  };

  # services.gitit = {
  #   enable = false;
  #   address = "127.0.0.1";
  #   requireAuthentication = "read";
  #   authenticationMethod = "http";
  #   plugins = [];
  # };

  services.duplicity = {
    enable = true;
    user = "dtulig";
    archives = {
      home = {
        sourceDirectory = "/home/dtulig";
        targetUrl = "gs://backup-davidtulig-com/corinth";
        period = "01:15";
        encryptKey = "CD754EB8";
      };
    };
  };

  security.acme.certs = {
    "davidtulig.com" = {
      webroot = "/var/lib/http/davidtulig.com";
      extraDomains = {
        "wiki.davidtulig.com" = null;
      };
      email = "david.tulig@gmail.com";
      user = "nginx";
      group = "nginx";
      postRun = "systemctl reload nginx.service";
    };
    "anyjot.com" = {
      webroot = "/var/lib/http/anyjot.com";
      extraDomains = {
        "api.anyjot.com" = null;
        "app.anyjot.com" = null;
      };
      email = "david.tulig@gmail.com";
      user = "nginx";
      group = "nginx";
      postRun = "systemctl reload nginx.service";
    };
  };
}
