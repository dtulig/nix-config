{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cabal2nix
    haskellPackages.stack

    nix-prefetch-scripts

    gdb
    binutils

    nix-repl

    haskellPackages.structured-haskell-mode
    haskellPackages.stylish-haskell
  ];
}
