{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" "/libexec" "/share/zsh" ];

  users.users.mattn = {
    isNormalUser = true;
    home = "/home/mattn";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$5$iZMHfcJMdxMHXMYt$xe.6lr24i3sIInNE7exaKTOl4UE4STjJyuqxLfVrRk0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA/e7gyFJqNS4S0xlfrZLOaY mattn"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
