{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    emacs
    git

    fail2ban

    tmux
    unzip
    wget
    htop

    binutils
    lm_sensors
    lshw
    pciutils

    gnupg1

    duplicity
  ];

  programs.zsh.enable = true;
}
