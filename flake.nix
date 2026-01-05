{
  description = "My Neovim Flake with Pre-compiled Treesitter & LSPs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        myNvimConfig = pkgs.fetchFromGitHub {
          owner = "ViniciussSantos";
          repo = "nvimconfig";
          rev = "main"; 
          hash = "sha256-9njnAvVu1zHIoBFuLjsDSVnm3XoR6Zl4atyZOLPUoB4=";
        };

        configDir = pkgs.runCommand "nvim-config-dir" { } ''
          mkdir -p $out/nvim
          cp -r ${myNvimConfig}/* $out/nvim
        '';

        customNeovim = pkgs.neovim.override {
          configure = {
            packages.myPlugins = {
              start = [ 
                pkgs.vimPlugins.nvim-treesitter.withAllGrammars 
              ];
            };
          };
        };

      in
      {
        packages.default = pkgs.writeShellApplication {
          name = "nvim";
          runtimeInputs = with pkgs; [ 
            customNeovim 
            git 
            ripgrep 
            fd
            unzip
            
            lua-language-server
            stylua

            nodePackages.typescript-language-server
            prettierd
            vscode-langservers-extracted 

            rust-analyzer
            
            mypy
            ruff
            pyright

            shfmt
            nodePackages.bash-language-server
            
            nil
          ];
          
          text = ''
            export XDG_CONFIG_HOME="${configDir}"
            exec nvim "$@"
          '';
        };
      }
    );
}
