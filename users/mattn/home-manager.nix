# Order 5
{ inputs, ... }:
{ config, lib, pkgs, ... }:
# https://mipmip.github.io/home-manager-option-search

let
  inherit (pkgs)
    fetchFromBitbucket
    ;
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  # MN - not needed, but keeping in case of future breakage
  manpager = (pkgs.writeShellScriptBin "manpager" ''
    col -bx < "$1" | bat --language man -p
  '');

  # Note: Nix Search for package, click on platform to find binary build status
  # Get specific versions of packages here:
  # https://lazamar.co.uk/nix-versions/
  # To get the sha256 hash:
  # nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs/archive/e49c28b3baa3a93bdadb8966dd128f9985ea0a09.tar.gz
  # or use an empty sha256 = ""; string, it'll show the hash; prefetch is safer
  #
  oldPkgs = import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/e49c28b3baa3a93bdadb8966dd128f9985ea0a09.tar.gz";
      sha256 = "14xrf5kny4k32fns9q9vfixpb8mxfdv2fi4i9kiwaq1yzcj1bnx2";
    })
    { system = builtins.trace "aarch64-linux" "aarch64-linux"; };
  # TODO - where is system arch config var?
  # { system = builtins.trace config._module.args config._module.args; };
  # { inherit config; };

in
{
  imports = [
    ./sway/sway.nix
    # ./hyprland/hyprland.nix
  ];

  #cat "$1" | col -bx | bat --language man --style plain
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = [
    #GUI Apps
    pkgs.authy
    #pkgs.google-chrome #no arm64 package
    oldPkgs.chromium
    pkgs.obsidian
    pkgs.baobab
    pkgs.xfce.thunar
    pkgs.vlc
    pkgs.jellyfin-media-player
    # pkgs.spotify #no arm64 package

    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "RobotoMono" ]; })
    pkgs.fd
    pkgs.bat
    pkgs.fzf
    pkgs.git-crypt
    pkgs.gotop
    pkgs.jq
    pkgs.jqp
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch
    pkgs.zathura
    pkgs.zip
    pkgs.unzip
    pkgs.gcc
    pkgs.buildkit
    pkgs.neofetch

    # network
    pkgs.wget
    pkgs.speedtest-cli
    pkgs.nmap
    pkgs.inetutils
    pkgs.httpstat
    pkgs.tshark
    pkgs.sshfs

    pkgs.ffmpeg

    pkgs.gum
    pkgs.yt-dlp
    pkgs.tealdeer

    pkgs.go
    pkgs.gopls
    pkgs.nodejs-18_x
    #pkgs.dotnetCorePackages.sdk_6_0
    pkgs.python3Minimal
    #pkgs.postgresql_11

    #pkgs.redshift
    #pkgs.kubectl
    #pkgs.krew
    #pkgs.terraform
    #pkgs.vault
    #pkgs.awscli2
    #pkgs.azure-cli
    #(pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    #pkgs.krew

    ##try out
    #pkgs.ChatGPT.nvim
    pkgs.shell_gpt

    #nvim LSPs, Linters,
    pkgs.nodePackages.pyright
    pkgs.nodePackages.typescript-language-server
    pkgs.lazygit
    pkgs.sumneko-lua-language-server
    pkgs.rnix-lsp
    pkgs.stylua
    pkgs.nil
    pkgs.nixpkgs-fmt
    pkgs.marksman
    pkgs.nodePackages.markdownlint-cli

    #TODO Need to add this to Mason somehow...
    #CARGO_NET_GIT_FETCH_WITH_CLI=true cargo build
    #pkgs.omnisharp-roslyn
    #pkgs.mono
  ];

  fonts.fontconfig.enable = true;

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };
  #MANPAGER = "${manpager}/bin/manpager";

  home.file.".inputrc".source = ./inputrc;

  xdg.configFile = {
    "aliases".text = builtins.readFile ./aliases;
    "m-os.sh".text = builtins.readFile ./m-os.sh;
    "shellConfig".text = builtins.readFile ./shellConfig;
    "i3/config".text = builtins.readFile ./i3;
    "fzf-m-os-preview-function.sh".source = config.lib.file.mkOutOfStoreSymlink ./fzf-m-os-preview-function.sh;
    "rofi/rofi-theme-deathemonic.rasi".text = builtins.readFile ./rofi-theme-deathemonic.rasi;
    # After defaults repo is pushed; change the rev to commit hash; make sha254 empty string
    # Then nx-update; Then update sha256 from the failed build
    "defaults".source = fetchFromBitbucket {
      owner = "nodu";
      repo = "defaults";
      rev = "6481752";
      sha256 = "ho+/UrZROa+mm17FbJv3SjP3lYKPjI7yprFetYnAZz0=";
    };
  };


  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
    pinentryFlavor = "gtk2";
  };

  programs.rofi = {
    enable = true;
    # theme = "slate";
    plugins = [
      pkgs.rofi-calc
      pkgs.rofi-emoji
    ];

    extraConfig = {
      modes = "combi";
      modi = "calc,run,filebrowser,emoji";
      combi-modes = "window,drun";
      show-icons = true;
      sort = true;
      matching = "fuzzy";
      dpi = 220;
      font = "FiraCode Nerd Font 10";
      terminal = "alacritty";
      sorting-method = "fzf";
      kb-mode-next = "Tab";
      kb-mode-previous = "ISO_Left_Tab";
      kb-element-prev = "";
      kb-element-next = "";
      combi-hide-mode-prefix = true;
      display-combi = "";
      display-calc = " ";
      display-drun = "";
      display-window = "";
      drun-display-format = "{icon} {name}";
      disable-history = false;
      click-to-exit = true;
    };
    "theme" = "./rofi-theme-deathemonic.rasi";
  };

  programs.bash = {
    enable = true;
    shellOptions = [ ];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.direnv = {
    enable = true;

    config = {
      whitelist = {
        prefix = [
          "$HOME/code/go/src/github.com/mattn"
        ];

        exact = [ "$HOME/.envrc" ];
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    history.expireDuplicatesFirst = true;
    history.extended = true;
    #completionInit

    shellAliases = {
      vv = "nvim .";
      znix = "nix-shell --run zsh";

      # Two decades of using a Mac has made this such a strong memory
      # that I'm just going to keep it consistent.
      pbcopy = "xclip";
      pbpaste = "xclip -o";
      nx-update = "cd ~/repos/sys/nixos-config/ && make switch; cd -";
      nx-update-flake = "cd ~/repos/sys/nixos-config/ && nix flake update; cd -";
      nx-search = "nix search nixpkgs";
    };

    history = {
      size = 10000;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "z" "fzf" "kubectl" "kube-ps1" ];
      theme = "robbyrussell";
    };

    initExtraBeforeCompInit = ''
    '';

    initExtraFirst = ''
    '';

    initExtra = ''
      source $HOME/.config/aliases
      source $HOME/.config/m-os.sh
      source $HOME/.config/defaults/basic.sh
      source $HOME/repos/sys/dotenv/shortcuts/work
      source $HOME/.config/shellConfig
      eval "$(direnv hook zsh)"
    '';
  };

  programs.git = {
    enable = true;
    userName = "Matt Nodurfth";
    userEmail = "mnodurft@gmail.com";
    signing = {
      key = "";
      signByDefault = false;
    };
    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      core = {
        editor = "nvim";
      };
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      branch.autosetuprebase = "always";
      color.ui = true;
      github.user = "nodu";
      push.default = "tracking";
      init.defaultBranch = "main";
      url = {
        "git@bitbucket.com:" = {
          insteadOf = "https://bitbucket.com/";
        };
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
    };
  };

  programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";

      font = {
        size = 12.0;
        #use_thin_strokes = true;

        normal.family = "FiraCode Nerd Font";
        bold.family = "FiraCode Nerd Font";
        italic.family = "FiraCode Nerd Font";
      };

      cursor.style = "Block";
      dynamic_title = true;
      decorations = "transparent";
      #padding.y = 27;

      key_bindings = [
        { key = "K"; mods = "Command"; chars = "ClearHistory"; } #remap
        # { key = "V"; mods = "Command"; action = "Paste"; } #no more command for  copy paste
        # { key = "C"; mods = "Command"; action = "Copy"; } #cmd is system wide ctrl shift c/v
        { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Plus"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "NumpadAdd"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Command"; action = "DecreaseFontSize"; }
        { key = "NumpadSubtract"; mods = "Command"; action = "DecreaseFontSize"; }
        { key = "F"; mods = "Command"; action = "SearchBackward"; }
        { key = "I"; mods = "Command"; action = "ToggleViMode"; }
      ];

      # Colors (Solarized Dark)
      # https://github.com/alacritty/alacritty-theme/tree/master/themes
      colors = {
        # Default colors
        primary = {
          # Dark
          #background= "#011318"; # black
          background = "0x002b36"; #original
          foreground = "0x839496";

          # Light
          #background= "0xfdf6e3";
          #foreground= "0x586e75";
        };
        # Cursor colors
        cursor = {
          text = "#002b36"; # base3
          cursor = "#839496"; # base0
        };
        # Normal colors
        normal = {
          black = "#073642"; # base02
          red = "#dc322f"; # red
          green = "#859900"; # green
          yellow = "#b58900"; # yellow
          blue = "#268bd2"; # blue
          magenta = "#d33682"; # magenta
          cyan = "#2aa198"; # cyan
          white = "#eee8d5"; # base2
        };
        # Bright colors
        bright = {
          black = "#002b36"; # base03
          red = "#cb4b16"; # orange
          green = "#586e75"; # base01
          yellow = "#657b83"; # base00
          blue = "#839496"; # base0
          magenta = "#6c71c4"; # violet
          cyan = "#93a1a1"; # base1
          white = "#fdf6e3"; # base3
        };
      };
    };
  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
      interval = 5;
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
      "disk /" = {
        position = 1;
        settings = { format = "󰨣 %free (%avail)/ %total"; };
      };
      load = {
        position = 2;
        settings = { format = "󰝲 %1min"; };
      };
      memory = {
        position = 3;
        settings.format = "󰍛 F:%free A:%available (U:%used) / T:%total";
      };
      "ethernet _first_" = {
        position = 4;
        settings = {
          format_up = "E: %ip (%speed)";
          format_down = "E: down";
        };
      };
      "volume master" = {
        position = 5;
        settings = {
          mixer = "Master";
          format = " %volume";
          format_muted = "♪ muted (%volume)";
          device = "default";
        };
      };
      "tztime local" = {
        position = 6;
        settings = { format = "%Y-%m-%d %H:%M:%S"; };
      };
    };
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs; [
    ];

    #extraConfig = (import ./vim-config.nix) { inherit sources; };
    extraConfig = ''
      source ~/.config/nvim/bootstrap.init.lua
      source ~/repos/sys/dotenv/nix/vimwip.lua
    '';
  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}
