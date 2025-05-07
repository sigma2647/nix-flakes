{ lib, config, pkgs, pkgs-unstable, ... }:

{
  # 基本用户信息
  home = {
    username = "lawrence"; # 替换为你的用户名
    homeDirectory = "/home/lawrence"; # Linux 路径，macOS 用 "/Users/your-username"
    stateVersion = "24.11"; # 保持与 Home Manager 版本一致
  };

  imports = [
    ./cli/yazi
    ./git
  ];

  # 启用 Home Manager 管理自身
  programs.home-manager.enable = true;

  # 安装一些常用包
  home.packages = with pkgs; [
    # htop
    # neovim
    # git
    ripgrep
    fzf
    httpie
    code-cursor
    element-desktop
  ];


  # 示例：配置 zsh
  # programs.zsh = {
  #   enable = true;
  #   shellAliases = {
  #     ll = "ls -l";
  #     update = "home-manager switch --flake .";
  #   };
  #   oh-my-zsh = {
  #     enable = true;
  #     plugins = [ "git" "fzf" ];
  #     theme = "robbyrussell";
  #   };
  # };

  # 示例：管理 dotfiles
  # home.file.".config/nvim/init.vim".text = ''
  #   set number
  #   set tabstop=2
  #   set shiftwidth=2
  #   set expandtab
  # '';
}
