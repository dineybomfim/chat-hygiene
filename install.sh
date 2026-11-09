#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
SHARE="${HOME}/.local/share/chat-hygiene"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/chat-hygiene"
SKILL_DIR="${HOME}/.cursor/skills/chat-hygiene"
ARCHIVES="${HOME}/Documents/chat-archives"

need_python() {
  if command -v python3 >/dev/null 2>&1; then
    return 0
  fi
  echo "chat-hygiene needs python3 on PATH." >&2
  echo "Install Python 3, then re-run: sh install.sh" >&2
  exit 1
}

need_python

if [ ! -f "${ROOT}/bin/chat-hygiene" ]; then
  echo "Missing ${ROOT}/bin/chat-hygiene" >&2
  echo "Run this script from a clone of the chat-hygiene repo." >&2
  exit 1
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

# Copy project files into the runtime install. Keep existing summaries/.
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
