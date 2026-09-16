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

  # nixpkgs' gcc wrapper reads these even outside a nix build, so ad-hoc
  # native builds some lazy.nvim plugins run on install (e.g. hererocks
  # compiling its own Lua, which needs readline.h) can still find
  # headers/libs that don't live in a normal FHS path.
  home.sessionVariables = {
    NIX_CFLAGS_COMPILE = "-I${lib.getDev pkgs.readline}/include";
    NIX_LDFLAGS = "-L${lib.getLib pkgs.readline}/lib";
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
