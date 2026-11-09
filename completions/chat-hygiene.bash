# bash completion for chat-hygiene
_chat_hygiene() {
  local cur prev cmds
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  cmds="help h doc docs report r check c dismiss d undismiss ud snip x sample extract preview p dry-run select s compress zip z compact expand unzip restore"

  if [[ ${COMP_CWORD} -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "${cmds}" -- "${cur}") )
    return 0
  fi

  case "${COMP_WORDS[1]}" in
    help|h|doc|docs)
      COMPREPLY=( $(compgen -W "overview stack architecture report check preview snip compress expand dismiss examples naming paths agents flags" -- "${cur}") )
      ;;
    compress|zip|z|compact)
      case "${prev}" in
        --summary|--summary-dir|--path|--zip) COMPREPLY=( $(compgen -f -- "${cur}") );;
        *) COMPREPLY=( $(compgen -W "--top --rank --all --summary --summary-dir --path" -- "${cur}") );;
      esac
      ;;
    expand|unzip|restore)
      case "${prev}" in
        --zip|--path) COMPREPLY=( $(compgen -f -- "${cur}") );;
        *) COMPREPLY=( $(compgen -W "--zip --path" -- "${cur}") );;
      esac
      ;;
    preview|p|dry-run|snip|x|sample|extract|select|s|dismiss|d|undismiss|ud)
      COMPREPLY=( $(compgen -W "--top --rank --all --path" -- "${cur}") )
      ;;
    report|r|check|c)
      COMPREPLY=( $(compgen -W "--all --all-rows" -- "${cur}") )
      ;;
  esac
}
complete -F _chat_hygiene chat-hygiene
complete -F _chat_hygiene chr
complete -F _chat_hygiene chz
