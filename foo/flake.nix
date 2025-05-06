{
  description = "Lawrence's config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-unstable, ... } @ inputs:
  let
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    forAllSystems = nixpkgs-unstable.lib.genAttrs supportedSystems;
    
    pkgsBySystem = forAllSystems (system: {
      stable = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    });

    lib = nixpkgs.lib;

    mkSystem = { hostname, username, system ? "x86_64-linux", extraModules ? [] }: 
    let
      specialArgs = {
        inherit username hostname inputs;
        pkgs = pkgsBySystem.${system}.stable;
        pkgs-unstable = pkgsBySystem.${system}.unstable;
      };
    in
    assert lib.assertMsg (builtins.elem system supportedSystems) "Unsupported system: ${system}";
    nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./hosts/${hostname}/configuration.nix
        ./modules/base.nix
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = inputs // specialArgs;
            users.${username} = import ./users/${hostname}/home.nix;
          };
        }
      ] ++ extraModules;
    };

    mkHomeConfig = { system, configFile, username, extraModules ? [] }: 
    let
      pkgs = pkgsBySystem.${system}.stable;
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        configFile
        {
          home = {
            username = username;
            homeDirectory = if system == "x86_64-darwin" || system == "aarch64-darwin" 
                           then "/Users/${username}" 
                           else "/home/${username}";
            stateVersion = "24.11";
          };
        }
      ] ++ extraModules;
      extraSpecialArgs = {
        inherit inputs;
        pkgs-unstable = pkgsBySystem.${system}.unstable;
      };
    };
  in
  {
    nixosConfigurations = {
      jy-vm-nix = mkSystem {
        hostname = "jy-vm-nix";
        username = "lawrence";
      };
      nix-home = mkSystem {
        hostname = "nix-home";
        username = "sigma";
      };
      nix-gpd = mkSystem {
        hostname = "nix-gpd";
        username = "lawrence";
      };
      nix-lab = mkSystem {
        hostname = "nix-lab";
        username = "lawrence";
      };
    };

    homeConfigurations = {
      "mini" = mkHomeConfig {
        system = "aarch64-darwin";
        configFile = ./home/darwin/home.nix;
        username = "lawrence";
      };
      "darwin-arm" = mkHomeConfig {
        system = "x86_64-darwin";
        configFile = ./home/darwin/home.nix;
        username = "lawrence";
      };
      "linux-x86" = mkHomeConfig {
        system = "x86_64-linux";
        configFile = ./home/linux/home.nix;
        username = "lawrence";
      };
      "linux-arm" = mkHomeConfig {
        system = "aarch64-linux";
        configFile = ./home/linux/home.nix;
        username = "lawrence";
      };
      "arch" = mkHomeConfig {
        system = "x86_64-linux";
        configFile = ./home/arch/home.nix;
        username = "lawrence";
      };
    };
  };
}
