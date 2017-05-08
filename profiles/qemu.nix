{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  users.extraGroups.libvirtd.members = [ "dtulig" ];

  boot.kernelModules = [ "kvm-intel" "tun" "virtio" ];

  environment.systemPackages = with pkgs; [
    libguestfs
    qemu
    spice_gtk
    virtmanager
  ];
}
