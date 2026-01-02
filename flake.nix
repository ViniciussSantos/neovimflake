{
  description = "My Neovim Flake loading config from GitHub";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # 1. Fetch your configuration directly from GitHub
        myNvimConfig = pkgs.fetchFromGitHub {
          owner = "ViniciussSantos";
          repo = "nvimconfig";
          rev = "main"; # Ensure this matches your default branch
          # When you first run this, Nix will complain about the wrong hash.
          # Replace this with the actual hash it gives you.
          hash = "sha256-bfvnVc6ODA2qEQev7ibQIh1b4q1X2PwDaSNn85Wnofk=";
        };

        # 2. Setup the folder structure Neovim expects ( .../nvim/init.lua )
        #    We copy your repo into a folder named 'nvim' inside the nix store.
        configDir = pkgs.runCommand "nvim-config-dir" { } ''
          mkdir -p $out/nvim
          cp -r ${myNvimConfig}/* $out/nvim
        '';

      in
      {
        packages.default = pkgs.writeShellApplication {
          name = "nvim";
          # 3. Add runtime dependencies your config needs (git, gcc for treesitter, ripgrep, etc.)
          runtimeInputs = with pkgs; [
            neovim
            git
            ripgrep
            fd
            gcc 
            unzip
            # Add other tools your config depends on here (e.g., nodejs, python3)
          ];
          
          # 4. Point XDG_CONFIG_HOME to our custom directory and run nvim
          text = ''
            export XDG_CONFIG_HOME="${configDir}"
            exec nvim "$@"
          '';
        };
      }
    );
}
