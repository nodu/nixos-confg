{
  description = "NixOS systems and tools by mattn";
  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";

      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other packages
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      mkVM = import ./lib/mkvm.nix;

      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];
    in
    {
      nixosConfigurations.vm-aarch64 = mkVM "vm-aarch64" {
        inherit nixpkgs home-manager;
        system = "aarch64-linux";
        user = "mattn";

        overlays = overlays ++ [
          (final: prev: {
            # Example of bringing in an unstable package:
            # open-vm-tools = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.open-vm-tools;
          })
        ];
      };

      nixosConfigurations.vm-aarch64-prl = mkVM "vm-aarch64-prl" rec {
        inherit overlays nixpkgs home-manager;
        system = "aarch64-linux";
        user = "mattn";
      };

      nixosConfigurations.vm-aarch64-utm = mkVM "vm-aarch64-utm" rec {
        inherit overlays nixpkgs home-manager;
        system = "aarch64-linux";
        user = "mattn";
      };

      nixosConfigurations.vm-intel = mkVM "vm-intel" rec {
        inherit nixpkgs home-manager overlays;
        system = "x86_64-linux";
        user = "mattn";
      };
    };
}
