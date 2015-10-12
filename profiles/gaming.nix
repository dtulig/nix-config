{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dwarf_fortress
    dwarf-therapist
    dfhack
  ];
}
