
# Copyright 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

: "${DEBUG:=0}"
: "${ASSERT:=0}"
: "${DEBUG:=0}"
: "${INIT:=0}"
: "${DIAG:=0}"
: "${QUIET:=0}"
: "${SILENT:=0}"
: "${VERBOSE:=1}"

! ((QUIET)) || VERBOSE=0

# TODO: v/q/s option handling and FD filter/redir setups
((DEBUG)) && VERBOSITY=4 || {
  ((QUIET)) &&
    : "${VERBOSITY:=1}" ||
    : "${VERBOSITY:=2}"
}


declare -ga uc_cb_exit
:exit() {
  [[ ! ${uc_cb_exit[*]:+set} ]] ||
    \builtin . <(printf '%s\n' "${uc_cb_exit[@]}") ||
      :failerr "E$? During :ex it cleanup"
}


ENV_CTX="$$"'$'"$-/${0##*/}"

if [[ ! ${REDO_RUNID:+set} ]]; then
  #exec 2> >(str_prefix "  $ENV_CTX: ")
  trap ':exit' EXIT
  exec {USER_FD}> >(str_prefix "  $ENV_CTX: ")
  USER_FILTER_PID=$!
  uc_cb_exit+=(
    'exec {USER_FD}>&-'
    "wait ${USER_FILTER_PID} 2>/dev/null || true"
  )
else
  shopt -s expand_aliases
  shopt -s extdebug
  declare -gA _os_script_{load,path}

  exec {USER_FD}>&2
fi

# TODO: use copy from us-core:hook:global
: env "${_E_GAE:=193}"      "Generic argument error"
: env "${_E_MA:=194}"       "Arguments expected (missing-arguments) error"
: env "${_E_continue:=195}"
: env "${_E_next:=196}"
: env "${_E_break:=197}"
: env "${_E_retry:=198}"


: env "${US_PP_CACHE:=${CACHE_DIR:-.local/cache}}"
: env "${US_PP_DATADIR:=${USER_DATA_DIR:-.local/user/data}}"
: env "${US_PP_STATE:=${US_PP_DATADIR:?}/us_pp_state.data.bash}"


: env "${C_INC:=$HOME/.local/composure}"

# Id: common_env                                 vim:set ft=bash sw=2 sts=2 et:
