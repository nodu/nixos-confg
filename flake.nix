{
  description = "NixOS systems and tools by mattn";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";

      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other packages
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    mkVM = import ./lib/mkvm.nix;

    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      inputs.neovim-nightly-overlay.overlay
      inputs.zig.overlays.default

      (final: prev: {
        # We need to pin to this version because master is currently broken
        zig-master = final.zigpkgs.master-2022-08-19;

        # Go we always want the latest version
        go = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.go_1_19;
      })
    ];
  in {
    nixosConfigurations.vm-aarch64 = mkVM "vm-aarch64" {
      inherit nixpkgs home-manager;
      system = "aarch64-linux";
      user   = "mattn";

      overlays = overlays ++ [(final: prev: {
        # TODO: drop after release following NixOS 22.05
        open-vm-tools = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.open-vm-tools;

        # We need Mesa on aarch64 to be built with "svga". The default Mesa
        # build does not include this: https://github.com/Mesa3D/mesa/blob/49efa73ba11c4cacaed0052b984e1fb884cf7600/meson.build#L192
        mesa = prev.callPackage "${inputs.nixpkgs-unstable}/pkgs/development/libraries/mesa" {
          llvmPackages = final.llvmPackages_latest;
          inherit (final.darwin.apple_sdk.frameworks) OpenGL;
          inherit (final.darwin.apple_sdk.libs) Xplugin;

          galliumDrivers = [
            # From meson.build
            "v3d" "vc4" "freedreno" "etnaviv" "nouveau"
            "tegra" "virgl" "lima" "panfrost" "swrast"

            # We add this so we get the vmwgfx module
            "svga"
          ];
        };
      })];
    };

    nixosConfigurations.vm-aarch64-prl = mkVM "vm-aarch64-prl" rec {
      inherit overlays nixpkgs home-manager;
      system = "aarch64-linux";
      user   = "mattn";
    };

    nixosConfigurations.vm-aarch64-utm = mkVM "vm-aarch64-utm" rec {
      inherit overlays nixpkgs home-manager;
      system = "aarch64-linux";
      user   = "mattn";
    };

    nixosConfigurations.vm-intel = mkVM "vm-intel" rec {
      inherit nixpkgs home-manager overlays;
      system = "x86_64-linux";
      user   = "mattn";
    };
  };
}
