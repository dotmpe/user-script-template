#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
#

. "funenv_common.bash"

# More, standard verbosity helpers and settings

V_ERR=1 V_NORMAL=2 V_INFO=3 V_DEBUG=4

say.err() { :say-when 1 "$1"; }
say.v() { :say-when 2 "$1"; }
say.info() { :say-when 3 "$1"; }
say.debug() { :say-when 4 "$1"; }

:_debug() {
  ((QUIET)) || ! ((DEBUG)) || :say-when 4 "$1"
}
:_info() {
  ((QUIET)) || :say-when 3 "$@"
}
:_notice() {
  ((QUIET)) || :say-when 2 "$@"
}

# Standard script (or any) env
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
  ((QUIET)) && : "${VERBOSITY:=1}" || : "${VERBOSITY:=2}"
}

# Further setup/configure shell session for env_common usage

declare -ga uc_cb_exit
:exit() {
  if [[ ${uc_cb_exit[*]:+set} ]]; then
    local cb=()
    for scr in "${uc_cb_exit[@]}"; do
      \builtin . <(printf '%s\n' "$scr") ||
        :failerr "E$? During exit cleanup (ignored)" || cb+=( $? )
    done
    [[ ${cb[*]:+set} ]] && : " (${#cb[*]} abnormal states)" || : ""
    say.debug "Finished ${#uc_cb_exit[*]} callbacks$_"
  fi
}

ENV_CTX="$$"'$'"$-/${0##*/}"

if [[ ! ${REDO_RUNID:+set} ]]; then
  trap ':exit' EXIT
  # Setup USER channel
  exec {USER_FD}> >(:line-prefix "  $ENV_CTX: ")
  USER_FILTER_PID=$!
  uc_cb_exit+=(
    'exec {USER_FD}>&-'
    "wait ${USER_FILTER_PID} 2>/dev/null || true"
  )
else
  shopt -s extdebug
  # NB: no override for redo env traps, better testing needed
  # just tie USER_FD to stderr
  exec {USER_FD}>&2
fi

# TODO: use copies from us-core:hook:global, etc.
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

# Id: env_common                                 vim:set ft=bash sw=2 sts=2 et:
