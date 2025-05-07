{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux"; # 根据你的系统架构调整，例如 "aarch64-darwin" 用于 Apple M1/M2
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      username = "lawrence"; # 替换为你的用户名
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/lawrence.nix ];
      };

    };
}

