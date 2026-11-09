#compdef chat-hygiene chr chz

_chat_hygiene() {
  local -a cmds
  cmds=(
    'help:Full guide with examples'
    'h:Alias for help'
    'report:Rank chats by size'
    'r:Alias for report'
    'check:List undismissed offenders'
    'c:Alias for check'
    'dismiss:Stop nudges for chat id(s)'
    'd:Alias for dismiss'
    'undismiss:Clear dismissal(s)'
    'ud:Alias for undismiss'
    'snip:Sample head/tail for summarization'
    'x:Alias for snip'
    'preview:Dry-run from→to paths + snip'
    'p:Alias for preview'
    'select:Print selected ids'
    's:Alias for select'
    'compress:Zip chat, store summary, leave stub'
    'zip:Alias for compress'
    'z:Alias for compress'
    'expand:Restore chat to original path from zip'
    'unzip:Alias for expand'
  )

  _arguments -C \
    '1:command:->cmds' \
    '*::arg:->args'

  case $state in
    cmds)
      _describe -t commands 'chat-hygiene command' cmds
      ;;
    args)
      case $words[1] in
        help|h|doc|docs)
          _arguments '*:topic:(overview stack architecture report check preview snip compress expand dismiss examples naming paths agents flags)'
          ;;
        report|r)
          _arguments '--all[all projects]' '--all-rows[every chat]' '*:path:_files -/'
          ;;
        check|c)
          _arguments '--all[all projects]' '*:path:_files -/'
          ;;
        compress|zip|z|compact)
          _arguments \
            '--top[top N]:n:' \
            '--rank[ranks A-B]:spec:' \
            '--all[all projects]' \
            '--summary[INPUT summary file]:file:_files' \
            '--summary-dir[INPUT summary dir]:dir:_files -/' \
            '--path[project path]:dir:_files -/' \
            '*:chat id:'
          ;;
        expand|unzip|restore)
          _arguments '--zip[backup zip]:file:_files' '--path[project path]:dir:_files -/' '*:chat id:'
          ;;
        preview|p|dry-run|snip|x|sample|extract|select|s|dismiss|d|undismiss|ud)
          _arguments \
            '--top[top N]:n:' \
            '--rank[ranks A-B]:spec:' \
            '--all[all projects]' \
            '--path[project path]:dir:_files -/' \
            '*:chat id:'
          ;;
      esac
      ;;
  esac
}

compdef _chat_hygiene chat-hygiene
compdef _chat_hygiene chr
compdef _chat_hygiene chz
