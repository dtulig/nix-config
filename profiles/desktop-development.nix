{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    idea.android-studio
    idea.idea-ultimate
  ];
}
