# dotfiles

Personal dotfiles for dev containers and remote Linux shells.

This repo is intentionally split into:

- portable shell/editor UX config that is safe to commit
- no secrets, no SSH keys, no auth, no machine-specific tokens

## What it installs

- `~/.zshrc`
- `~/.tmux.conf`
- `~/.config/starship.toml`

## Install locally

```bash
./install.sh
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

