{ config, pkgs, lib, username, isDarwin ? pkgs.stdenv.isDarwin, ... }:

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

  # Standalone home-manager on non-NixOS Linux doesn't otherwise add
  # ~/.nix-profile/share to XDG_DATA_DIRS, so GUI apps' .desktop files
  # (rio, dbeaver) never show up in the system app menu.
  targets.genericLinux.enable = !isDarwin;

  home.sessionPath = [ "$HOME/go/bin" ];

  # CPATH/LIBRARY_PATH are real upstream gcc env vars (unlike
  # NIX_CFLAGS_COMPILE, which only nixpkgs' cc-wrapper honors), so these
  # work regardless of which gcc ends up on PATH. Needed for ad-hoc
  # native builds some lazy.nvim plugins run on install (e.g. hererocks
  # compiling its own Lua, which needs readline.h/libreadline, which in
  # turn links against ncurses).
  home.sessionVariables = {
    CPATH = lib.makeSearchPathOutput "dev" "include" [ pkgs.readline pkgs.ncurses ];
    LIBRARY_PATH = lib.makeLibraryPath [ pkgs.readline pkgs.ncurses ];
  };

  # Symlinked straight to the repo on disk (not copied into the nix
  # store), so editing files under these paths edits the repo directly
  # and vice versa - no rebuild needed to pick up changes, and tools
  # that rewrite their own config (lazy.nvim's lazy-lock.json) can do
  # so freely since it's a real writable file, not a store path.
  # Assumes the repo is checked out at ~/dotfiles on every machine.
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";

  home.file.".config/posting".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/posting";

  home.file.".config/rio".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rio";

  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/claude-skills";

  programs.home-manager.enable = true;
}
