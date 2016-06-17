{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    vim
    emacs
    git

    tmux
    unzip
    wget
    htop

    binutils
    lm_sensors
    lshw
    pciutils

    gnupg1orig

    duplicity
  ];

  programs.zsh.enable = true;

  services.fail2ban.enable = true;
  services.fail2ban.jails.ssh-iptables = "enabled = true";

  services.syncthing = {
    enable = true;
    systemService = false;
  };
}
