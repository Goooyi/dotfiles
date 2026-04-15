#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"
STAMP="$(date +%Y%m%d%H%M%S)"
DOTFILES_SKIP_ZSH="${DOTFILES_SKIP_ZSH:-0}"

mkdir -p "${TARGET_HOME}/.config"
mkdir -p "${TARGET_HOME}/.local/bin"

install_starship() {
  local bin_dir="$1"
  local os="" arch="" target="" tmp_dir=""

  case "$(uname -s)" in
    Linux) os="unknown-linux-gnu" ;;
    Darwin) os="apple-darwin" ;;
    *)
      echo "warning: unsupported OS for starship install: $(uname -s)" >&2
      return 1
      ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64) arch="x86_64" ;;
    arm64|aarch64) arch="aarch64" ;;
    *)
      echo "warning: unsupported architecture for starship install: $(uname -m)" >&2
      return 1
      ;;
  esac

  target="${arch}-${os}"
  tmp_dir="$(mktemp -d)"
  curl -fsSL "https://github.com/starship/starship/releases/latest/download/starship-${target}.tar.gz" -o "${tmp_dir}/starship.tgz"
  tar -xzf "${tmp_dir}/starship.tgz" -C "${tmp_dir}"
  install -m 755 "${tmp_dir}/starship" "${bin_dir}/starship"
  rm -rf "${tmp_dir}"
}

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

if [[ "${DOTFILES_SKIP_ZSH}" != "1" ]]; then
  ensure_repo "https://github.com/ohmyzsh/ohmyzsh.git" "${TARGET_HOME}/.oh-my-zsh"
  ensure_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "${TARGET_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  ensure_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${TARGET_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi
ensure_repo "https://github.com/tpope/vim-sensible.git" "${TARGET_HOME}/.vim/pack/yigao/start/vim-sensible"

if ! command -v starship >/dev/null 2>&1; then
  install_starship "${TARGET_HOME}/.local/bin"
fi

if [[ "${DOTFILES_SKIP_ZSH}" != "1" ]]; then
  link_file "${REPO_ROOT}/zsh/.zshrc" "${TARGET_HOME}/.zshrc"
fi
link_file "${REPO_ROOT}/tmux/.tmux.conf" "${TARGET_HOME}/.tmux.conf"
link_file "${REPO_ROOT}/starship/starship.toml" "${TARGET_HOME}/.config/starship.toml"
link_file "${REPO_ROOT}/vim/.vimrc" "${TARGET_HOME}/.vimrc"

echo "Installed dotfiles from ${REPO_ROOT}"
