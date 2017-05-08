{ config, pkgs, ... }:

{
  imports = [
    ./headless.nix
  ];

  environment.systemPackages = with pkgs; [
    rofi
    chromium
    firefox
    haskellPackages.xmobar

    # sound
    pavucontrol

    xautolock
    i3lock
    scrot
    imagemagick

    dunst
    libnotify

    feh
    xcompmgr
    glxinfo
    xclip

    anki

    keepass
    openconnect
  ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    xkbOptions = "ctrl:nocaps";
    displayManager.lightdm.enable = true;
  };
}
