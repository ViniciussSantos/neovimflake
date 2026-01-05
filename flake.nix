{
  description = "My Neovim Flake with Plugins and Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    myNvimConfig = {
      url = "github:ViniciussSantos/nvimconfig";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, myNvimConfig }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      configDir = pkgs.runCommand "nvim-config-dir" { } ''
        mkdir -p $out/nvim
        cp -r ${myNvimConfig}/* $out/nvim
      '';

      customNeovim = pkgs.neovim.override {
        configure = {
          customRC = ''
            set runtimepath^=${configDir}/nvim
            luafile ${configDir}/nvim/init.lua
          '';

          packages.myPlugins = with pkgs.vimPlugins; {
            start = [
              # Syntax Highlighting
              nvim-treesitter.withAllGrammars

              # LSP & Completion
              nvim-cmp
              cmp-nvim-lsp
              luasnip
              cmp_luasnip
              
              nvim-lspconfig
              # Formatting
              conform-nvim
              
              # Fuzzy Finder
              telescope-nvim
              plenary-nvim
            ];
          };
        };
      };

    in
    {
      apps.${system}.default = {
        type = "app";
        program = "${pkgs.writeShellScriptBin "nvim" ''
          # We still set this so plugins like lazy.nvim know where 'stdpath("config")' is
          export XDG_CONFIG_HOME="${configDir}"
          
          # Add external LSP binaries to PATH so Neovim can find them
          export PATH="${pkgs.lib.makeBinPath [
            pkgs.lua-language-server
            pkgs.nixd
            pkgs.stylua
            # Add other LSP servers here (e.g., pyright, gopls, etc.)
          ]}:$PATH"

          # Run the custom wrapped neovim
          exec ${customNeovim}/bin/nvim "$@"
        ''}/bin/nvim";
      };
    };
}
