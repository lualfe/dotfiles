{
  description = "lualfe's dotfiles and dev tooling (macOS + Ubuntu)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      username = "lualfe";

      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];

      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };

      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor system;
        extraSpecialArgs = { inherit username; isDarwin = false; };
        modules = [ ./home/home.nix ];
      };
    in
    {
      overlays.default = final: prev: {
        resterm = final.callPackage ./pkgs/resterm.nix { };
        sqls = final.callPackage ./pkgs/sqls.nix { };
      };

      # `nix build .#resterm` / `.#sqls` — mainly useful for resolving the
      # placeholder hashes in pkgs/*.nix before the first real switch.
      packages = nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) (system: {
        inherit (pkgsFor system) resterm sqls;
      });

      # Ubuntu (and any other non-Darwin Linux): standalone home-manager,
      # no root/system changes.
      #   nix run home-manager -- switch --flake .#x86_64-linux
      #   nix run home-manager -- switch --flake .#aarch64-linux
      homeConfigurations = nixpkgs.lib.genAttrs linuxSystems mkHome;

      # macOS: nix-darwin owns the system, home-manager runs as its module.
      #   sudo darwin-rebuild switch --flake .#MacBook-Pro-de-Lucas
      darwinConfigurations."MacBook-Pro-de-Lucas" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit username; };
        modules = [
          { nixpkgs.overlays = [ self.overlays.default ]; }
          ./darwin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit username; isDarwin = true; };
            home-manager.users.${username} = import ./home/home.nix;
          }
        ];
      };
    };
}
