# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set the theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins to load
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search autojump)

source $ZSH/oh-my-zsh.sh

# NVM integration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Kubernetes Aliases
alias k="kubectl"
alias kn="kubectl get nodes"
alias kgp="kubectl get pods"
alias kdp="kubectl describe pod"
alias kx="kubectl exec -it"
alias kl="kubectl logs"
alias kctx="kubectl config use-context"
alias kns="kubectl config set-context --current --namespace"

# Git Aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gco="git checkout"
alias gl="git log --oneline --graph --decorate --all"
alias gcb="git checkout -b"
alias gm="git merge"
alias gr="git rebase"
alias gcp="git cherry-pick"

# Navigation Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"

# File and System Utility Aliases
alias cls="clear"
alias la="ls -la"
alias ll="ls -l"
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"
alias df="df -h"
alias du="du -h"

# Zshrc backup Alias
alias backupzsh="cp ~/.zshrc ~/.zshrc.bak.$(date +%F)"

# General Productivity Aliases
alias editzsh="hx ~/.zshrc"
alias reloadzsh="source ~/.zshrc"
alias today="date +%Y-%m-%d"

# Add buildpack auto-completion
. $(pack completion --shell zsh)

#Define paths
LOCAL_BIN='/home/jls/.local'

paths=(
  "$LOCAL_BIN/bin"
)

# Append to PATH without overwriting
for dir in "${paths[@]}"; do
  if [ -d "$dir" ]; then
     [[ ! "$PATH" =~ "$dir" ]] && export PATH="$dir:$PATH"
  else
    echo "Warning: $dir does not exist"
  fi
done

export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')

# Persistent command history

# Enable fzf keybindings for Zsh
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh

# Optional: Enable fzf auto-completion for commands
[ -f /usr/share/fzf/shell/completion.zsh ] && source /usr/share/fzf/shell/completion.zsh

. "$HOME/.asdf/asdf.sh"
autoload -Uz compinit && compinit

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history
setopt share_history
bindkey '^R' fzf-history-widget  # Use fzf for history search

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
