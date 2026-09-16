{ pkgs, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";
  users.users.${username}.shell = pkgs.zsh;

  # Registers the nix-provided zsh in /etc/shells so chsh/dscl accept it.
  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  fonts.packages = [ pkgs.nerd-fonts.iosevka ];

  # Bumping this has no effect on already-managed state; it just marks
  # which nix-darwin release's defaults this config was written against.
  system.stateVersion = 5;
}
