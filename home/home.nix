{ pkgs, lib, username, isDarwin ? pkgs.stdenv.isDarwin, ... }:

{
  imports = [
    ./programs/zsh.nix
    ./programs/tmux.nix
  ];

  home.username = username;
  home.homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "24.11";

  home.packages = import ./packages.nix { inherit pkgs; }
    ++ lib.optionals (!isDarwin) [ pkgs.nerd-fonts.iosevka pkgs.xclip ];

  fonts.fontconfig.enable = !isDarwin;

  home.sessionPath = [ "$HOME/go/bin" ];

  xdg.configFile."nvim" = {
    source = ../nvim;
    recursive = true;
  };

  xdg.configFile."posting" = {
    source = ../posting;
    recursive = true;
  };

  xdg.configFile."rio" = {
    source = ../rio;
    recursive = true;
  };

  home.file.".claude/skills" = {
    source = ../claude-skills;
    recursive = true;
  };

  programs.home-manager.enable = true;
}
