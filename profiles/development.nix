{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    idea.android-studio
    idea.idea-ultimate
    cabal2nix
    nix-prefetch-scripts

    gdb
    binutils

    nix-repl
  ];
}
