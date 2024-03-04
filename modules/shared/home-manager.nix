{ config, pkgs, lib, ... }:

let name = "Sven Lito";
    user = "sven";
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

    antidote = {
      enable = true;
      plugins = [
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-completions"
        "zsh-users/zsh-history-substring-search"
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

      alias vim=nvim
      alias tf=terraform
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
      init.defaultBranch = "main";
      core = { 
	    editor = "vim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  ssh = {
    enable = true;

    extraConfig = lib.mkMerge [
      ''
        Host github.com
          Hostname github.com
          IdentitiesOnly yes

        Host *
          IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
          IdentityFile /home/${user}/.ssh/id_github
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          IdentityFile /Users/${user}/.ssh/id_github
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

}
