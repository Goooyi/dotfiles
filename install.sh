#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"
STAMP="$(date +%Y%m%d%H%M%S)"

mkdir -p "${TARGET_HOME}/.config"

ensure_repo() {
  local url="$1"
  local dir="$2"

  mkdir -p "$(dirname "${dir}")"

  if [[ -d "${dir}/.git" ]]; then
    git -C "${dir}" pull --ff-only
  else
    git clone --depth=1 "${url}" "${dir}"
  fi
}

link_file() {
  local src="$1"
  local dst="$2"
  local current_target=""

  mkdir -p "$(dirname "${dst}")"
  if [[ -L "${dst}" ]]; then
    current_target="$(readlink "${dst}")"
    if [[ "${current_target}" == "${src}" ]]; then
      echo "Already linked: ${dst} -> ${src}"
      return 0
    fi
  fi

  if [[ -e "${dst}" || -L "${dst}" ]]; then
    mv "${dst}" "${dst}.pre-dotfiles-${STAMP}"
    echo "Backed up ${dst} -> ${dst}.pre-dotfiles-${STAMP}"
  fi

  ln -s "${src}" "${dst}"
  echo "Linked ${dst} -> ${src}"
}

ensure_repo "https://github.com/ohmyzsh/ohmyzsh.git" "${TARGET_HOME}/.oh-my-zsh"
ensure_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "${TARGET_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
ensure_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${TARGET_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

link_file "${REPO_ROOT}/zsh/.zshrc" "${TARGET_HOME}/.zshrc"
link_file "${REPO_ROOT}/tmux/.tmux.conf" "${TARGET_HOME}/.tmux.conf"
link_file "${REPO_ROOT}/starship/starship.toml" "${TARGET_HOME}/.config/starship.toml"

echo "Installed dotfiles from ${REPO_ROOT}"
