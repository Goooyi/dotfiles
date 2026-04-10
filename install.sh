#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"

mkdir -p "${TARGET_HOME}/.config"

link_file() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "${dst}")"
  if [[ -e "${dst}" || -L "${dst}" ]]; then
    rm -rf "${dst}"
  fi
  ln -s "${src}" "${dst}"
}

link_file "${REPO_ROOT}/zsh/.zshrc" "${TARGET_HOME}/.zshrc"
link_file "${REPO_ROOT}/tmux/.tmux.conf" "${TARGET_HOME}/.tmux.conf"
link_file "${REPO_ROOT}/starship/starship.toml" "${TARGET_HOME}/.config/starship.toml"

echo "Installed dotfiles from ${REPO_ROOT}"
