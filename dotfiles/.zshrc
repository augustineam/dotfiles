# Source profile files
source ~/.profile
source ~/.profile.secrets

backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
    zle -f kill
}
zle -N backward-kill-dir

# Basic zsh settings
setopt AUTO_CD              # If command is a path, cd into it
setopt AUTO_REMOVE_SLASH    # Remove trailing slash when completing
setopt CHASE_LINKS         # Resolve symlinks
setopt EXTENDED_GLOB       # Use extended globbing
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
setopt NO_CASE_GLOB        # Case insensitive globbing
setopt NUMERIC_GLOB_SORT   # Sort filenames numerically
setopt PROMPT_SUBST        # Enable parameter expansion in prompts

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY          # Append to history instead of overwriting
setopt EXTENDED_HISTORY        # Save timestamp
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt HIST_VERIFY            # Don't execute immediately upon history expansion

# Key bindings
bindkey -v                          # Vim mode
bindkey '^[[A' up-line-or-search    # Up arrow
bindkey '^[[B' down-line-or-search  # Down arrow
bindkey '^[[H' beginning-of-line    # Home
bindkey '^[[F' end-of-line          # End
bindkey '^[[3~' delete-char         # Delete
bindkey '^[[1;5C' forward-word      # Ctrl + right arrow
bindkey '^[[1;5D' backward-word     # Ctrl + left arrow
bindkey '^[^?' backward-kill-dir    # Alt + Backspace

PROMPT='%F{red}%n@%m%f %F{blue}%~%f %F{yellow}$(parse_git_branch)
%F{red}$(nonzero_return)%f$ '

# The following lines were added by compinstall
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
zstyle :compinstall filename '/home/augus/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
