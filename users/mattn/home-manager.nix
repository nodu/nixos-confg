{ config, lib, pkgs, ... }:

let
  inherit (pkgs)
    fetchFromBitbucket
    ;
    sources = import ../../nix/sources.nix;

    # For our MANPAGER env var
    # https://github.com/sharkdp/bat/issues/1145
    # MN - not needed, but keeping in case of future breakage
    manpager = (pkgs.writeShellScriptBin "manpager" ''
      col -bx < "$1" | bat --language man -p
    '');
in {

  #cat "$1" | col -bx | bat --language man --style plain
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.firefox
    pkgs.chromium
    pkgs.fzf
    pkgs.git-crypt
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.rofi
    pkgs.tree
    pkgs.watch
    pkgs.zathura

    pkgs.gum
    pkgs.yt-dlp
    pkgs.tealdeer

    pkgs.go
    pkgs.gopls
    pkgs.nodejs-18_x
    pkgs.dotnetCorePackages.sdk_6_0
    pkgs.python3Minimal

    pkgs.postgresql_11

    pkgs.xfce.thunar
    pkgs.redshift
    pkgs.wget
    pkgs.nmap
    pkgs.kubectl
    pkgs.krew
    pkgs.terraform
    pkgs.awscli2
    pkgs.azure-cli
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.buildkit
    pkgs.krew
    pkgs.nodePackages.pyright
    pkgs.nodePackages.typescript-language-server
    pkgs.zip
    pkgs.obsidian
    pkgs.httpstat

    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
    pkgs.gcc
    pkgs.unzip
    pkgs.lazygit

    /* nvim stuff */
    pkgs.sumneko-lua-language-server
    pkgs.rnix-lsp
    pkgs.stylua

    pkgs.ffmpeg
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

  home.file.".gdbinit".source = ./gdbinit;
  home.file.".inputrc".source = ./inputrc;

  xdg.configFile."aliases".text = builtins.readFile ./aliases;
  xdg.configFile."shellConfig".text = builtins.readFile ./shellConfig;

  xdg.configFile."defaults".source = fetchFromBitbucket {
    owner = "nodu";
    repo = "defaults";
    rev = "89cca28";
    sha256 = "mHvsIpdD0xVOQBjoRogG/H7V87kVSV9hgMZNhhvBkUk=";
  };

  xdg.configFile."i3/config".text = builtins.readFile ./i3;
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi;
  xdg.configFile."devtty/config".text = builtins.readFile ./devtty;

  # tree-sitter parsers
  xdg.configFile."nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
  xdg.configFile."nvim/queries/proto/folds.scm".source =
    "${sources.tree-sitter-proto}/queries/folds.scm";
  xdg.configFile."nvim/queries/proto/highlights.scm".source =
    "${sources.tree-sitter-proto}/queries/highlights.scm";
  xdg.configFile."nvim/queries/proto/textobjects.scm".source =
    ./textobjects.scm;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = true;

  programs.bash = {
    enable = true;
    shellOptions = [];
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

  programs.direnv= {
    enable = true;

    config = {
      whitelist = {
        prefix= [
          "$HOME/code/go/src/github.com/hashicorp"
          "$HOME/code/go/src/github.com/mitchellh"
        ];

        exact = ["$HOME/.envrc"];
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    autocd= true;
    history.expireDuplicatesFirst = true;
    history.extended = true;
    #completionInit

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gst = "git status";
      gt = "git tag";
      V = "nvim .";
      znix = "nix-shell --run zsh";

      # Two decades of using a Mac has made this such a strong memory
      # that I'm just going to keep it consistent.
      pbcopy = "xclip";
      pbpaste = "xclip -o";
      nx-update = "cd ~/nixos-config/ && make switch && cd -";
      nx-search = "nix search nixpkgs";
    };

    history = {
      size = 10000;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "z" "fzf" "kubectl" "kube-ps1"];
      theme = "robbyrussell";
    };

    initExtraBeforeCompInit = ''
    '';

    initExtraFirst = ''
    '';

    initExtra = ''
      source $HOME/.config/aliases
      source $HOME/.config/defaults/basic
      source $HOME/dotenv/shortcuts/work
      source $HOME/.config/shellConfig
      eval "$(direnv hook zsh)"
    '';
  };

  programs.fish = {
    enable = false;
    interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" [
      "source ${sources.theme-bobthefish}/functions/fish_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_right_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_title.fish"
      (builtins.readFile ./config.fish)
      "set -g SHELL ${pkgs.fish}/bin/fish"
    ]);

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

      # Two decades of using a Mac has made this such a strong memory
      # that I'm just going to keep it consistent.
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    };

    plugins = map (n: {
      name = n;
      src  = sources.${n};
    }) [
      "fish-fzf"
      "fish-foreign-env"
      "theme-bobthefish"
    ];
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

  programs.go = {
    enable = true;
    goPath = "code/go";
    goPrivate = [ "github.com/mitchellh" "github.com/hashicorp" "rfc822.mx" ];
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "l";
    secureSocket = false;

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      set -g @dracula-show-battery false
      set -g @dracula-show-network false
      set -g @dracula-show-weather false

      bind -n C-k send-keys "clear"\; send-keys "Enter"

      run-shell ${sources.tmux-pain-control}/pain_control.tmux
      run-shell ${sources.tmux-dracula}/dracula.tmux
    '';
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
        { key = "K"; mods = "Command"; chars = "ClearHistory"; }
        { key = "V"; mods = "Command"; action = "Paste"; }
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Plus"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "NumpadAdd"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Command"; action = "DecreaseFontSize"; }
        { key = "NumpadSubtract"; mods = "Command"; action = "DecreaseFontSize"; }
        { key = "F"; mods = "Command"; action = "SearchBackward"; }
      ];

      # Colors (Solarized Dark)
      colors= {
        # Default colors
        primary= {
          background= "#002b36"; # original
          #background= "#011318"; # black
          foreground= "#839496"; # base0
        };
        # Cursor colors
        cursor= {
          text=   "#002b36"; # base3
          cursor= "#839496"; # base0
        };
        # Normal colors
        normal= {
          black=   "#073642"; # base02
          red=     "#dc322f"; # red
          green=   "#859900"; # green
          yellow=  "#b58900"; # yellow
          blue=    "#268bd2"; # blue
          magenta= "#d33682"; # magenta
          cyan=    "#2aa198"; # cyan
          white=   "#eee8d5"; # base2
        };
        # Bright colors
        bright= {
          black=   "#002b36"; # base03
          red=     "#cb4b16"; # orange
          green=   "#586e75"; # base01
          yellow=  "#657b83"; # base00
          blue=    "#839496"; # base0
          magenta= "#6c71c4"; # violet
          cyan=    "#93a1a1"; # base1
          white=   "#fdf6e3"; # base3
        };
      };
    };
  };

  programs.kitty = {
    enable = false;
    extraConfig = builtins.readFile ./kitty;
  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs; [
      #customVim.vim-fugitive
      #customVim.vim-pgsql
      #customVim.AfterColors

      #customVim.nvim-comment
      #customVim.nvim-lspconfig
      #customVim.nvim-plenary # required for telescope
      #customVim.nvim-telescope
      #customVim.nvim-treesitter
      #customVim.nvim-treesitter-playground
      #customVim.nvim-treesitter-textobjects

      #vimPlugins.vim-airline
      #vimPlugins.vim-airline-themes
      #vimPlugins.vim-eunuch
      #vimPlugins.vim-gitgutter

      #vimPlugins.vim-markdown
      #vimPlugins.vim-nix
      #vimPlugins.typescript-vim
      #vimPlugins.vim-visual-multi
      #vimPlugins.vim-surround
      #vimPlugins.NeoSolarized
      #vimPlugins.sonokai
      #vimPlugins.edge
      #vimPlugins.gruvbox-material
      #vimPlugins.nvim-cmp
      #vimPlugins.cmp-nvim-lsp
    ];

    #extraConfig = (import ./vim-config.nix) { inherit sources; };
    extraConfig = ''
      source ~/.config/nvim/bootstrap.init.lua

      source ~/dotenv/vimwip.lua
    '';
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
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
