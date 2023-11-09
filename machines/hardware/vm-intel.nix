# Order 3-1
# This file is normally automatically generated. Since we build a VM
# and have full control over that hardware I can hardcode this into my
# repository.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # x86/amd new vmware
  #MRN, try to increase compatibility
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # virtualbox start

  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # virtualbox nixos-generate-config --root /mnt start
  # Set resolution in virtualbox:
  # xrandr --output Virtual1 --mode 2560x1440
  #
  # TODO What are these?
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];

  # swapDevices =  [{ device = "/dev/disk/by-uuid/f293bb4a-c15f-4615-a016-00cbc2f2aad0"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  virtualisation.virtualbox.guest.enable = true;
  # virtualbox end


  # vmware start
  # Be careful updating this.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # virtualisation.vmware.guest.enable = true;
  #vmware kernelModules
  # boot.initrd.availableKernelModules = [
  #   "ata_piix"
  #   "mptspi"
  #   "uhci_hcd"
  #   "ehci_pci"
  #   "sd_mod"
  #   "sr_mod"
  #   "nvme"
  # ];
  # Interface is this on Intel Fusion
  # networking.interfaces.ens33.useDHCP = true;

  # Shared folder to host works on Intel
  # https://github.com/mitchellh/nixos-config/issues/9; commenting out
  #fileSystems."/host" = {
  #  fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
  #  device = ".host:/";
  #  options = [
  #    "umask=22"
  #    "uid=1000"
  #    "gid=1000"
  #    "allow_other"
  #    "auto_unmount"
  #    "defaults"
  #  ];
  #};
  # vmware end

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];
  fileSystems."/" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };


  nixpkgs.config.allowUnfree = true;
}
