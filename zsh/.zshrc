export EDITOR="code --wait"
export VISUAL="$EDITOR"
export PAGER="less -FRX"
export LESS="-FRX"

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

autoload -Uz compinit
compinit

bindkey -e

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --decorate --graph -20'
alias v='code .'

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if [[ -f "${HOME}/.zshrc.local" ]]; then
  source "${HOME}/.zshrc.local"
fi
