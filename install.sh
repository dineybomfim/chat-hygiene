#!/bin/sh
set -eu

REPO_HTTPS="${CHAT_HYGIENE_REPO:-https://github.com/dineybomfim/chat-hygiene}"
REF="${CHAT_HYGIENE_REF:-main}"
SHARE="${HOME}/.local/share/chat-hygiene"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/chat-hygiene"
SKILL_DIR="${HOME}/.cursor/skills/chat-hygiene"
ARCHIVES="${HOME}/Documents/chat-archives"

ROOT=""
FETCH_DIR=""

cleanup() {
  if [ -n "${FETCH_DIR}" ] && [ -d "${FETCH_DIR}" ]; then
    rm -rf "${FETCH_DIR}"
  fi
}
trap cleanup EXIT INT HUP TERM

need_python() {
  if command -v python3 >/dev/null 2>&1; then
    return 0
  fi
  echo "chat-hygiene needs python3 on PATH." >&2
  echo "Install Python 3, then re-run this installer." >&2
  exit 1
}

resolve_local_root() {
  script="$0"
  case "${script}" in
    /*) ;;
    *)
      if [ -f "${script}" ]; then
        script="$(CDPATH= cd -- "$(dirname "${script}")" && pwd)/$(basename "${script}")"
      else
        return 1
      fi
      ;;
  esac
  dir="$(CDPATH= cd -- "$(dirname "${script}")" && pwd)"
  if [ -f "${dir}/bin/chat-hygiene" ]; then
    ROOT="${dir}"
    return 0
  fi
  return 1
}

fetch_root() {
  FETCH_DIR="$(mktemp -d "${TMPDIR:-/tmp}/chat-hygiene-install.XXXXXX")"
  src="${FETCH_DIR}/src"
  mkdir -p "${src}"

  echo "Fetching ${REPO_HTTPS} @ ${REF} …"

  if command -v git >/dev/null 2>&1; then
    git clone --depth 1 --branch "${REF}" "${REPO_HTTPS}.git" "${src}"
  elif command -v curl >/dev/null 2>&1; then
    archive="${FETCH_DIR}/src.tgz"
    curl -fsSL "${REPO_HTTPS}/archive/refs/heads/${REF}.tar.gz" -o "${archive}"
    tar -xzf "${archive}" -C "${FETCH_DIR}"
    extracted=""
    for candidate in "${FETCH_DIR}"/chat-hygiene-*; do
      if [ -d "${candidate}" ] && [ -f "${candidate}/bin/chat-hygiene" ]; then
        extracted="${candidate}"
        break
      fi
    done
    if [ -z "${extracted}" ]; then
      echo "Download did not contain bin/chat-hygiene." >&2
      exit 1
    fi
    rm -rf "${src}"
    mv "${extracted}" "${src}"
  else
    echo "Need git or curl to install from GitHub." >&2
    exit 1
  fi

  if [ ! -f "${src}/bin/chat-hygiene" ]; then
    echo "Fetched tree is missing bin/chat-hygiene." >&2
    exit 1
  fi
  ROOT="${src}"
}

need_python

if resolve_local_root; then
  echo "Installing from local checkout: ${ROOT}"
else
  fetch_root
fi

mkdir -p \
  "${BIN_DIR}" \
  "${CONFIG_DIR}" \
  "${SHARE}/summaries" \
  "${SHARE}/completions" \
  "${SHARE}/adapters" \
  "${SHARE}/templates" \
  "${SHARE}/lib" \
  "${ARCHIVES}" \
  "${SKILL_DIR}"

for item in bin adapters completions templates lib HELP.md README.md; do
  if [ -e "${ROOT}/${item}" ]; then
    rm -rf "${SHARE}/${item}"
    cp -R "${ROOT}/${item}" "${SHARE}/${item}"
  fi
done
cp "${ROOT}/install.sh" "${SHARE}/install.sh"

chmod +x "${SHARE}/bin/chat-hygiene" "${SHARE}/install.sh"

if [ -e "${BIN_DIR}/chat-hygiene" ] || [ -L "${BIN_DIR}/chat-hygiene" ]; then
  unlink "${BIN_DIR}/chat-hygiene" 2>/dev/null || true
fi
ln -s "${SHARE}/bin/chat-hygiene" "${BIN_DIR}/chat-hygiene"

printf '%s\n' '#!/bin/sh' 'exec chat-hygiene report "$@"' > "${BIN_DIR}/chr"
printf '%s\n' '#!/bin/sh' 'exec chat-hygiene check "$@"' > "${BIN_DIR}/chc"
printf '%s\n' '#!/bin/sh' 'exec chat-hygiene preview "$@"' > "${BIN_DIR}/chp"
printf '%s\n' '#!/bin/sh' 'exec chat-hygiene compress "$@"' > "${BIN_DIR}/chz"
chmod +x "${BIN_DIR}/chr" "${BIN_DIR}/chc" "${BIN_DIR}/chp" "${BIN_DIR}/chz"

if [ ! -f "${CONFIG_DIR}/config.toml" ]; then
  printf '%s\n' \
    'folder_threshold_bytes = 2097152' \
    'jsonl_threshold_bytes = 1048576' \
    'backup_root = "~/Documents/chat-archives"' \
    'summary_root = "~/.local/share/chat-hygiene/summaries"' \
    'top_n = 10' \
    'extract_head_turns = 8' \
    'extract_tail_turns = 12' \
    > "${CONFIG_DIR}/config.toml"
fi

if [ ! -f "${CONFIG_DIR}/state.json" ]; then
  printf '%s\n' '{ "dismissed": {} }' > "${CONFIG_DIR}/state.json"
fi

if [ -e "${SKILL_DIR}/SKILL.md" ] || [ -L "${SKILL_DIR}/SKILL.md" ]; then
  unlink "${SKILL_DIR}/SKILL.md" 2>/dev/null || true
fi
ln -s "${SHARE}/adapters/cursor.md" "${SKILL_DIR}/SKILL.md"

path_hint=""
case ":${PATH}:" in
  *":${BIN_DIR}:"*) ;;
  *)
    path_hint="Add this to your shell profile, then open a new terminal:

  export PATH=\"${BIN_DIR}:\$PATH\"
"
    ;;
esac

echo "Installed chat-hygiene"
echo "  runtime: ${SHARE}"
echo "  command: ${BIN_DIR}/chat-hygiene"
echo "  aliases: chr chc chp chz"
echo "  Cursor skill: ${SKILL_DIR}/SKILL.md"
echo
echo "Try: chat-hygiene help"
if [ -n "${path_hint}" ]; then
  printf '%s\n' "${path_hint}"
fi
echo "zsh completion:  source ${SHARE}/completions/chat-hygiene.zsh"
echo "bash completion: source ${SHARE}/completions/chat-hygiene.bash"
