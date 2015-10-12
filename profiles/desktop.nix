{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dmenu
    chromium
    haskellPackages.xmobar

    # sound
    pavucontrol
    rxvt_unicode
    xscreensaver

    feh
    xcompmgr
    glxinfo

    dropbox
    irssi

    gcal2org
  ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    xkbOptions = "ctrl:nocaps";
    displayManager.sddm.enable = true;
  };
}
