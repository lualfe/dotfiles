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

  # Everything but lazy-lock.json is immutable, symlinked straight from
  # the store. lazy.nvim rewrites lazy-lock.json as plugins update, and
  # the store is read-only, so that one file is seeded as a real,
  # writable copy by the activation script below instead.
  xdg.configFile."nvim/init.lua".source = ../nvim/init.lua;
  xdg.configFile."nvim/thisisfine.cat".source = ../nvim/thisisfine.cat;
  xdg.configFile."nvim/lua" = {
    source = ../nvim/lua;
    recursive = true;
  };

  home.activation.seedNvimLazyLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.config/nvim/lazy-lock.json"
    if [ ! -e "$target" ] || [ -L "$target" ]; then
      run rm -f "$target"
      run install -m 644 ${../nvim/lazy-lock.json} "$target"
    fi
  '';

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
