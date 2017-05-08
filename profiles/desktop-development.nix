{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    idea.idea-ultimate

    wireshark-qt
  ];
}
