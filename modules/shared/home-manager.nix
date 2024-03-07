{ config, pkgs, lib, ... }:

let name = "Sven Lito";
    user = "svenlito";
    email = "me@svenlito.com"; in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = false;

    syntaxHighlighting = {
      enable = true;
    };

    historySubstringSearch= {
      enable = true;
    };

    antidote = {
      enable = true;
      plugins = [
        "zsh-users/zsh-completions"
        "robbyrussell/oh-my-zsh path:plugins/git"
        "robbyrussell/oh-my-zsh path:plugins/command-not-found"
        "robbyrussell/oh-my-zsh path:plugins/common-aliases"
      ];
    };

    initExtraFirst = ''
      source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
      autoload -U promptinit; promptinit

      autoload -Uz compinit
      typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
      if [ $(date +'%j') != $updated_at ]; then
        compinit -i
      else
        compinit -C -i
      fi

      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # Define variables for directories
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      export ALTERNATE_EDITOR=""
      export EDITOR="vim"
      export VISUAL="code"

      export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

      # Always color ls and group directories
      alias ls='ls --color=auto'
      alias c='clear'

      # Set the prompt
      SPACESHIP_CHAR_SYMBOL="➜ "
      SPACESHIP_CHAR_SUFFIX=" "
      SPACESHIP_PROMPT_ADD_NEWLINE=true
      SPACESHIP_PROMPT_SEPARATE_LINE=true
      SPACESHIP_DIR_PREFIX=false

      SPACESHIP_PROMPT_ORDER=(
        time          # Time stamp section
        user          # Username section
        host          # Hostname section
        dir           # Current directory section
        aws           # AWS section
        git           # Git section (git_branch + git_status)
        node          # Node.js section
        terraform     # Terraform workspace section
        exec_time     # Execution time
        line_sep      # Line break
        char          # Prompt character
      )

      alias vim='nvim'
      alias t='terraform'
      alias ll='eza -alF --color=always --sort=size'
      alias la='eza -A --color=always'
      alias l='eza -l --color=always'
      alias c='clear'
      alias h='history'
      alias cat='bat'
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFYK1c6kxYT6FzMEqckP04e2unQgTvFPyNEFzT/q/eXR";
      };
      init.defaultBranch = "main";
      core = { 
        pager = "diff-so-fancy | less --tabs=2 -RFX";
        editor = "vim";
        autocrlf = "input";
      };
      gpg = {
        format = "ssh";
        ssh = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
      };
      commit = {
        gpgsign = true;
      };
      merge = {
        verbosity = 5;
      };
      pull = {
        rebase = "true";
      };
      rebase.autoStash = true;
      credential = {
        helper = "osxkeychain";
      };
    };
  };

  ssh = {
    enable = true;

    extraConfig = lib.mkMerge [
      ''
        Host snocko-vm
          HostName 13.228.251.47
          User svenlito
          Port 22
          Compression yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 
        ''
        Host *
          IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
          ForwardX11Trusted yes
          ForwardX11 yes
          ForwardAgent yes
	        ServerAliveInterval 240
        '')
    ];
  };

  awscli = {
    enable = true;
  };

  gh = {
    enable = true;
    settings = {
      gitProtocol = "https";
      editor = "vim";
      prompt = true;

      aliases = {
        co = "pr checkout";
        pr = "pr status";
      };
    };
  };

  tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      set -g history-limit 10000

      set-option -g default-command "reattach-to-user-namespace -l $SHELL"

      set-option -ga terminal-overrides ",xterm-256color:Tc"
      set-option -g default-terminal "screen-256color"

      # start windows and panes at 1
      set -g base-index 1
      set -g pane-base-index 1

      # use vi mode
      setw -g mode-keys vi

      # don't detach tmux when killing a session
      set -g detach-on-destroy off

      # focus events enabled for terminals that support them
      set -g focus-events on

      # Setup 'v' to begin selection as in Vim
      bind-key -Tcopy-mode-vi 'v' send -X begin-selection
      bind-key -Tcopy-mode-vi 'y' send -X copy-pipe "reattach-to-user-namespace pbcopy"

      # Update default binding of `Enter` to also use copy-pipe
      unbind -Tcopy-mode Enter
      bind-key -Tcopy-mode Enter send -X copy-pipe "reattach-to-user-namespace pbcopy"

      # remap prefix to Control + a
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      # move around panes with hjkl, as one would in vim after pressing ctrl-w
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # force a reload of the config file
      unbind r
      bind r source-file ~/.tmux.conf \; display "Reloaded!"

      # quick pane cycling with Ctrl-a
      unbind ^A
      bind ^A select-pane -t :.+

      set -g mouse on

      bind-key -T copy-mode-vi WheelUpPane send -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send -X scroll-down

      setw -g mode-keys vi
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy" \; display-message "highlighted selection copied to system clipboard"

      # resize panes
      bind Right resize-pane -R 8
      bind Left resize-pane -L 8
      bind Up resize-pane -U 4
      bind Down resize-pane -D 4

      # New window with default path set to last path
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };

}
