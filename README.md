# dotfiles

Nix flake replacing the old chezmoi setup. Manages CLI tooling (via
nixpkgs, no more Brewfile/apt-branching) and dotfiles (zsh, tmux, nvim,
posting, rio, Claude skills) declaratively. Works on macOS and Ubuntu.

## Layout

- `flake.nix` — entry point, defines `darwinConfigurations` (macOS) and
  `homeConfigurations` (Ubuntu/Linux).
- `darwin/configuration.nix` — macOS system-level config (nix-darwin):
  flakes enabled, fonts, primary user.
- `home/` — home-manager config shared by both OSes.
  - `packages.nix` — the CLI/TUI tool list (replaces Brewfile + apt).
  - `programs/zsh.nix`, `programs/tmux.nix` — shell/multiplexer config,
    replacing Oh-My-Zsh's git-clone bootstrap and TPM with native
    home-manager plugin management.
- `pkgs/` — custom package derivations for tools not in nixpkgs
  (`resterm`, `sqls`).
- `nvim/`, `posting/`, `rio/`, `claude-skills/`, `p10k.zsh` — the actual
  dotfile contents, symlinked into place by home-manager.

## First-time setup

### 1. Install Nix (both OSes)

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

This installer enables flakes by default. Restart your shell after.

### 2. Fix the placeholder hashes

`pkgs/resterm.nix` and `pkgs/sqls.nix` use `lib.fakeHash` for `src.hash`
and `vendorHash` since there's no way to compute them without a nix
build. Build once, Nix will refuse and print the real hash, paste it in:

```sh
nix build .#resterm   # fails, prints correct src hash → paste it in, rerun
                       # fails again, prints correct vendorHash → paste it in
nix build .#sqls      # same dance
```

### 3a. macOS — nix-darwin + home-manager

```sh
nix run nix-darwin -- switch --flake .#MacBook-Pro-de-Lucas
```

After the first run, `darwin-rebuild` is on PATH:

```sh
sudo darwin-rebuild switch --flake .
```

### 3b. Ubuntu — standalone home-manager (no root)

Pick the attr matching `uname -m` (`x86_64-linux` or `aarch64-linux`):

```sh
nix run home-manager -- switch --flake .#x86_64-linux
```

Subsequent runs:

```sh
home-manager switch --flake .#x86_64-linux
```

## What's NOT managed by Nix (install manually, one-time)

GUI apps with no nixpkgs equivalent, and system daemons that need root
outside what a user-level flake should touch:

| App | Why it's manual |
|---|---|
| Docker Desktop (macOS) | Proprietary GUI installer |
| OrbStack (macOS) | Proprietary GUI installer, Mac-only |
| Claude desktop app (macOS) | Proprietary GUI installer, Mac-only |
| Docker Engine (Ubuntu) | System daemon, needs systemd + root |
| PostgreSQL server (Ubuntu) | System daemon, needs systemd + root |

Everything else that used to be a brew formula/cask or an apt package —
including `rainfrog`, `dbeaver`, `rio`, `claude-code` CLI, `opencode`,
`posting`, `kubectl`, `lazygit`, Go/Node/Postgres client tools, and the
Iosevka Nerd Font — is now a plain nixpkgs package in `home/packages.nix`,
identical on both OSes.

## Updating

```sh
nix flake update          # bump nixpkgs/home-manager/nix-darwin
# macOS
sudo darwin-rebuild switch --flake .
# Ubuntu
home-manager switch --flake .#x86_64-linux
```
