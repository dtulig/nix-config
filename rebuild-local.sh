#!/usr/bin/env bash

SRC=$HOME/nix-config

sudo rsync --filter="protect /hardware-configuration.nix" \
           --filter="protect /hostname" \
           --filter="protect /nixpkgs" \
           --filter="protect /private" \
           --filter="protect /release" \
           --filter="exclude,s *.gitignore" \
           --filter="exclude,s *.gitmodules" \
           --filter="exclude,s *.git" \
           --filter="exclude .*.swp" \
           --filter="exclude Session.vim" \
           --delete --recursive --perms \
           $SRC/ /etc/nixos/

if [ $# -eq 0 ]; then
  operation='switch'
else
  operation=$@
fi
cd $wd

sudo -i nixos-rebuild --keep-failed --show-trace -I nixos=$HOME/workspace/nix/nixpkgs/nixos -I nixpkgs=$HOME/workspace/nix/nixpkgs $operation
