{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-plugins "cpu-usage battery time weather"
          set -g @dracula-show-powerline true
          set -g @dracula-show-left-icon " #S"
          set -g @dracula-hg-colors "light_purple dark_gray"
          set -g @dracula-cpu-usage-colors "cyan dark_gray"
          set -g @dracula-time-colors "orange dark_gray"
          set -g @dracula-show-fahrenheit false
          set -g @dracula-battery-label "󰂄 "
          set -g @dracula-time-format "%d/%m/%Y %R"
        '';
      }
    ];

    extraConfig = ''
      unbind r
      bind r source-file ~/.tmux.conf \; display-message "Configuração recarregada!"
      unbind C-b
      bind C-a send-prefix

      bind-key & kill-window

      bind | split-window -h
      bind "_" split-window -v

      bind -n C-h select-pane -L
      bind -n C-l select-pane -R
      bind -n C-k select-pane -U
      bind -n C-j select-pane -D

      bind < resize-pane -L 20
      bind > resize-pane -R 20
      bind + resize-pane -U 5
      bind - resize-pane -D 5

      set -g status-bg black
      set -g status-fg white
      set -g status-left-length 40
      set -g status-right-length 100
      set -g status-left "#[fg=green]#S #[fg=yellow]| #[fg=cyan]%Y-%m-%d %H:%M"
      set -g status-right "#[fg=magenta]#(whoami) #[fg=blue]| #[fg=red]%H:%M"

      bind-key -n C-n next-window
      bind-key -n C-p previous-window

      set-option -g status-position top
    '';
  };
}
