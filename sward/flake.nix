{
  description = "Nuclei development environment with TUNA mirror";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # 配置 TUNA 镜像
  nixConfig = {
    extra-substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ]; # 可选：保留默认 nixpkgs 缓存的公钥
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
	        inherit system;
          config = { allowUnfree = true; };
	      };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "nuclei-dev-env";
          nativeBuildInputs = with pkgs; [ go git ];
          buildInputs = with pkgs; [ nuclei ];
          shellHook = ''
            export NUCLEI_TEMPLATES="$HOME/.config/nuclei/templates"
            mkdir -p $HOME/.config/nuclei
            echo "Nuclei 开发环境已准备就绪！"
            nuclei -version
            echo "模板路径：$NUCLEI_TEMPLATES"
          '';
        };
      }
    );
}
