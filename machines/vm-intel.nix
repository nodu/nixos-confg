{ config, pkgs, ... }: {
  imports = [
    ./hardware/vm-intel.nix
    ./vm-shared.nix
  ];

}
