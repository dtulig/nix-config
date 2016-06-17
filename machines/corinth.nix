{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/default.nix
    ../profiles/headless.nix
    ../profiles/development.nix
    ../profiles/email.nix
  ];

  security.pam.enableEcryptfs = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.extraConfig = "serial; terminal_input serial; terminal_output serial";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  networking.firewall.allowedTCPPorts = [ 8080 8081 3000 80 443 ];

  services.nginx = {
    enable = true;
    config = pkgs.lib.readFile /var/lib/nginx/nginx.conf;
  };

  security.acme.certs."davidtulig.com" = {
    webroot = "/var/lib/http";
    extraDomains = {
      "wiki.davidtulig.com" = null;
    };
    email = "david.tulig@gmail.com";
    user = "nginx";
    group = "nginx";
    postRun = "systemctl reload nginx.service";
  };
}
