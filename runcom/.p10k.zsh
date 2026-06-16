# Powerlevel10k config — dst color palette
# user: magenta | host: yellow | path: bold blue | git: green/red | time: green

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases' ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob' ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate

  # dst layout:
  #   user@host: path git
  #   $
  #   [time] on the right
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    status
    context
    dir
    vcs
    newline
    prompt_char
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)

  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false

  # dst FAIL line (red) on previous command error
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='FAIL'

  # user (magenta) @ host (yellow)
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='%F{5}%n%f@%F{3}%m%f'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_CONTENT_EXPANSION='%F{1}%n%f@%F{3}%m%f'
  typeset -g POWERLEVEL9K_CONTEXT_SUFFIX=': '

  # path (bold blue)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=4
  typeset -g POWERLEVEL9K_DIR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=4
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=4
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

  # git (green clean, red dirty — like dst git_prompt)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=2
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=1
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=1
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=1
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=2
  typeset -g POWERLEVEL9K_VCS_PREFIX=' '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='!'

  # prompt char ($, # for root — like dst)
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='%(!.#.$)'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='%(!.#.$)'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND=7
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND=7
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '

  # time on the right (green) — dst RPROMPT [%*]
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=2
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_PREFIX='['
  typeset -g POWERLEVEL9K_TIME_SUFFIX=']'

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
  'builtin' 'unset' 'p10k_config_opts'
} "$@"
