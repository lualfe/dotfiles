{ pkgs, ... }:

with pkgs; [
  # toolchains / compilers
  gcc
  go
  nodejs

  # go tooling
  gopls
  delve
  golang-migrate
  sqls

  # cli utilities
  fd
  lazygit
  tree-sitter
  kubectl

  # databases
  postgresql_15
  rainfrog
  dbeaver-bin

  # http / api clients
  posting
  resterm

  # editors / terminals
  neovim
  rio

  # python tooling (replaces the old pipx-managed tools)
  sqlfluff
  tmuxp

  # AI coding agents
  claude-code
  opencode
]
