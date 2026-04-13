export EDITOR="${EDITOR:-code --wait}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less -FRX}"
export LESS="${LESS:--FRX}"

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

path_prepend() {
  local dir="$1"
  [[ -d "${dir}" ]] || return 0
  case ":${PATH}:" in
    *":${dir}:"*) ;;
    *) export PATH="${dir}:${PATH}" ;;
  esac
}

path_prepend "${HOME}/.local/bin"
path_prepend "/usr/local/bin"
path_prepend "/usr/local/sbin"

case "$(uname -s)" in
  Darwin)
    path_prepend "/opt/homebrew/bin"
    path_prepend "/opt/homebrew/sbin"
    ;;
esac

export ZSH="${HOME}/.oh-my-zsh"
plugins=(git history-substring-search zsh-autosuggestions zsh-syntax-highlighting)

if [[ -d "${ZSH}" ]]; then
  ZSH_THEME="${ZSH_THEME:-robbyrussell}"
  source "${ZSH}/oh-my-zsh.sh"
else
  autoload -Uz compinit
  compinit
  bindkey -e
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --decorate --graph -20'
alias v='code .'

gacp() {
  [[ $# -gt 0 ]] || { echo "usage: gacp <commit message>"; return 1; }
  git add -A &&
  git commit -m "$*" &&
  git push origin HEAD
}

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if [[ -f "${HOME}/.zshrc.local" ]]; then
  source "${HOME}/.zshrc.local"
fi
