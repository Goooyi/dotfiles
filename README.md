# dotfiles

Personal dotfiles for macOS, remote Linux shells, and dev containers.

This repo is intentionally opinionated:

- keep one shared shell UX across macOS and Linux
- commit only portable config
- keep secrets, tokens, and machine-specific paths out of git

## What it installs

- `~/.zshrc`
- `~/.tmux.conf`
- `~/.config/starship.toml`
- `~/.vimrc`

## Cross-platform approach

The committed `zsh/.zshrc` is shared across macOS and Linux. It does a few things to stay portable:

- detects the OS with `uname`
- adds common PATH entries only when the directory exists
- uses Oh My Zsh as the shell framework on both macOS and Linux
- expects `history-substring-search` from stock Oh My Zsh
- installs `zsh-autosuggestions` and `zsh-syntax-highlighting` into `~/.oh-my-zsh/custom/plugins`
- initializes `starship` and `zoxide` only when those binaries exist
- leaves machine-specific overrides to `~/.zshrc.local`

Put things like these in `~/.zshrc.local`, not in the repo:

- Windsurf / Codeium local paths
- Antigravity local paths
- machine-specific aliases
- work-only or personal-only environment variables

## Install locally

```bash
./install.sh
```

The installer is conservative:

- it bootstraps `~/.oh-my-zsh` if missing
- it installs or updates `zsh-autosuggestions` and `zsh-syntax-highlighting`
- it installs `vim-sensible` under `~/.vim/pack/yigao/start/vim-sensible`
- if a target file is already linked to this repo, it leaves it alone
- otherwise it backs up the existing file to `*.pre-dotfiles-<timestamp>`
- then it creates the symlink

For Bash-first dev containers, you can skip all zsh-related setup:

```bash
DOTFILES_SKIP_ZSH=1 ./install.sh
```

## Use with VS Code Dev Containers

Push this repo to GitHub, then set these VS Code user settings on your MacBook:

```json
{
  "dotfiles.repository": "Goooyi/dotfiles",
  "dotfiles.targetPath": "~/dotfiles",
  "dotfiles.installCommand": "install.sh"
}
```

VS Code Dev Containers will clone and run it when a container is created.

Reference:
- https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories
