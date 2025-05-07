{
  description = "Home Manager configuration for lawrence";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      # url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # 让 Home Manager 使用 stable nixpkgs
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


    mkHomeConfig = { username, system, configFile, extraModules ? [] }: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        configFile
      ] ++ extraModules;
      extraSpecialArgs = {
        inherit inputs;
        pkgs = pkgsBySystem.${system}.stable;
        pkgs-unstable = pkgsBySystem.${system}.unstable;
      };
    };


  in
  {
    # 在 homeConfigurations 属性集中定义用户的配置
    homeConfigurations = {
      # 调用 mkHomeConfig 函数来为 lawrence 用户创建配置
      lawrence = mkHomeConfig {
        username = "lawrence";
        system = "x86_64-linux";
        configFile = ./home/lawrence.nix;
      };

    };

  };
}
