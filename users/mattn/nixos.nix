{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/libexec" "/share/zsh" ];
  environment.localBinInPath = true;

  programs.zsh.enable = true;

  users.users.mattn = {
    isNormalUser = true;
    home = "/home/mattn";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$QnIZYAQV0aB2aSJBXjbjr/$u48oM7nqbbRihf52T4SpahBpniwDvUSVXjoDAhugE40";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA/e7gyFJqNS4S0xlfrZLOaY mattn"
    ];
  };
}
