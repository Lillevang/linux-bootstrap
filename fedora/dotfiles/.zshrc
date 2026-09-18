# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ -f "$HOME/.secrets.zsh" ]] && source "$HOME/.secrets.zsh"
export COLORTERM=truecolor

# PATH
typeset -U path PATH
for dir in   "$HOME/.local/bin"   "$HOME/go/bin"   "$HOME/repos/tools/elixir-ls"   "/usr/local/go/bin"
do
  [[ -d "$dir" ]] && path=("$dir" $path)
done

# Homebrew (only present on some machines, e.g. WSL)
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
)

source "$ZSH/oh-my-zsh.sh"

# Fedora fzf integration. Atuin takes Ctrl-R later.
[[ -f /usr/share/fzf/shell/key-bindings.zsh ]] &&
  source /usr/share/fzf/shell/key-bindings.zsh
[[ -f /usr/share/fzf/shell/completion.zsh ]] &&
  source /usr/share/fzf/shell/completion.zsh

# Node.js via NVM for now. mise is intentionally deferred.
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history
setopt share_history

# direnv + Atuin
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
  emulate zsh -c "$(direnv export zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# Project helper
alias ai-army-docs="cp ~/repos/personal/ai-army/docs/architecture.md ~/repos/personal/ai-army/docs/design-principles.md ~/repos/personal/ai-army/docs/vision.md ~/winhome/TechTinker\'s\ Tome/Projects/ai-army/"

# Kubernetes
if command -v kubectl >/dev/null 2>&1; then
  alias k="kubectl"
  alias kn="kubectl get nodes"
  alias kgp="kubectl get pods"
  alias kdp="kubectl describe pod"
  alias kx="kubectl exec -it"
  alias kl="kubectl logs"
  alias kctx="kubectl config use-context"
  alias kns="kubectl config set-context --current --namespace"

  if command -v fzf >/dev/null 2>&1; then
    kctxf() {
      local context
      context="$(kubectl config get-contexts -o name | fzf --prompt='Kubernetes context > ')"
      [[ -n "$context" ]] && kubectl config use-context "$context"
    }

    knsf() {
      local namespace
      namespace="$(kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' |
        fzf --prompt='Namespace > ')"
      [[ -n "$namespace" ]] &&
        kubectl config set-context --current --namespace="$namespace"
    }
  fi
fi

# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gl="git log --oneline --graph --decorate --all"
alias gm="git merge"
alias gr="git rebase"
alias gcp="git cherry-pick"

if command -v fzf >/dev/null 2>&1; then
  gcof() {
    local branch
    branch="$(git branch --all --format='%(refname:short)' |
      sed 's#^origin/##' |
      sort -u |
      fzf --prompt='Git branch > ')"
    [[ -n "$branch" ]] && git checkout "$branch"
  }
fi

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"

# File and system utilities
alias cls="clear"
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"

if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"
  alias ll="eza -lh --icons --git"
  alias la="eza -lah --icons --git"
  alias tree="eza --tree --icons"
else
  alias ll="ls -l"
  alias la="ls -la"
fi

command -v bat >/dev/null 2>&1 && alias b="bat"
command -v btop >/dev/null 2>&1 && alias bt="btop"
command -v duf >/dev/null 2>&1 && alias disks="duf"
command -v dust >/dev/null 2>&1 && alias usage="dust"
command -v procs >/dev/null 2>&1 && alias processes="procs"

# Zsh config helpers
alias backupzsh='cp ~/.zshrc ~/.zshrc.bak.$(date +%F)'
alias editzsh="hx ~/.zshrc"
alias reloadzsh="exec zsh"
alias today="date +%Y-%m-%d"

# Powerlevel10k
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# zoxide last so its hooks survive other shell tooling
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi
