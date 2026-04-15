#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"
STAMP="$(date +%Y%m%d%H%M%S)"
OH_MY_ZSH_REPO_URL="${OH_MY_ZSH_REPO_URL:-https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git}"
OH_MY_ZSH_REPO_FALLBACK_URL="${OH_MY_ZSH_REPO_FALLBACK_URL:-https://github.com/ohmyzsh/ohmyzsh.git}"
ZSH_AUTOSUGGESTIONS_REPO_URL="${ZSH_AUTOSUGGESTIONS_REPO_URL:-https://github.com/zsh-users/zsh-autosuggestions.git}"
ZSH_SYNTAX_HIGHLIGHTING_REPO_URL="${ZSH_SYNTAX_HIGHLIGHTING_REPO_URL:-https://github.com/zsh-users/zsh-syntax-highlighting.git}"
VIM_SENSIBLE_REPO_URL="${VIM_SENSIBLE_REPO_URL:-https://github.com/tpope/vim-sensible.git}"

mkdir -p "${TARGET_HOME}/.config"

ensure_repo() {
  local dir="$1"
  shift
  local urls=("$@")
  local url=""

  mkdir -p "$(dirname "${dir}")"

  if [[ -d "${dir}/.git" ]]; then
    for url in "${urls[@]}"; do
      [[ -n "${url}" ]] || continue
      if git -C "${dir}" remote set-url origin "${url}" \
        && git -C "${dir}" fetch --depth=1 --single-branch --filter=blob:none origin HEAD \
        && git -C "${dir}" reset --hard FETCH_HEAD; then
        return 0
      fi
    done
    echo "failed to update ${dir} from configured remotes" >&2
    return 1
  fi

  for url in "${urls[@]}"; do
    [[ -n "${url}" ]] || continue
    rm -rf "${dir}"
    if git clone --depth=1 --single-branch --filter=blob:none "${url}" "${dir}"; then
      return 0
    fi
  done

  echo "failed to clone ${dir} from configured remotes" >&2
  return 1
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

ensure_repo "${TARGET_HOME}/.oh-my-zsh" "${OH_MY_ZSH_REPO_URL}" "${OH_MY_ZSH_REPO_FALLBACK_URL}"
ensure_repo "${TARGET_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" "${ZSH_AUTOSUGGESTIONS_REPO_URL}"
ensure_repo "${TARGET_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "${ZSH_SYNTAX_HIGHLIGHTING_REPO_URL}"
ensure_repo "${TARGET_HOME}/.vim/pack/yigao/start/vim-sensible" "${VIM_SENSIBLE_REPO_URL}"

link_file "${REPO_ROOT}/zsh/.zshrc" "${TARGET_HOME}/.zshrc"
link_file "${REPO_ROOT}/tmux/.tmux.conf" "${TARGET_HOME}/.tmux.conf"
link_file "${REPO_ROOT}/starship/starship.toml" "${TARGET_HOME}/.config/starship.toml"
link_file "${REPO_ROOT}/vim/.vimrc" "${TARGET_HOME}/.vimrc"

echo "Installed dotfiles from ${REPO_ROOT}"
