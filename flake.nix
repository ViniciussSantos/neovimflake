{
  description = "Portable Neovim Flake via NixVim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    
    myNvimConfig = {
      url = "github:ViniciussSantos/nvimconfig";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixvim, myNvimConfig }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      nvim = nixvim.legacyPackages.${system}.makeNixvim {
        opts = {
          number = true;
          shiftwidth = 2;
        };

        plugins = {
          treesitter = {
            enable = true;
            nixGrammars = true;
          };
          lsp = {
            enable = true;
            servers = {
              lua_ls.enable = true;
              nixd.enable = true;
            };
          };
          telescope.enable = true;
          conform-nvim.enable = true;
          luasnip.enable = true;
        };

        extraConfigLua = ''
          vim.opt.rtp:prepend("${myNvimConfig}")
          
          dofile("${myNvimConfig}/init.lua")
        '';

        extraPackages = with pkgs; [
          stylua
          nixd
          ruff
          mypy
        ];
      };
    in
    {
      packages.${system}.default = nvim;
    };
}
