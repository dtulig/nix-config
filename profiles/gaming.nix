{ config, pkgs, ... }:
let
    newSteam = pkgs.steam.override { newStdcpp = true; };
in
{
  environment.systemPackages = with pkgs; [
    #dwarf_fortress
    #dwarf-therapist
    #dfhack

    newSteam

    minecraft
    crawlTiles

    wine
    winetricks
  ];

  fonts.enableCoreFonts = true;
}
