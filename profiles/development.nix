{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cabal2nix
    nix-prefetch-scripts

    gdb
    binutils

    nix-repl
  ];
}
