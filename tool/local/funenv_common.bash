#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
#

:argv-err() {
: about 'Output helper for unset/undefined argument position expressions'
: param '~ <Position> <Label> <"expected "> <"at position "> ...'
  set -- "${FUNCNAME[1]}" "$2" "${3:-expected }" "${4:-at position }" "$1"
  printf '%s: %s %s%s%i\n' "$@"
}

:failerr () {
  local stat=${2:-$?}
  # FIXME: this should just clamp to 1-255
: about "Output message and set or pass-trough non-zero status (input 256 for 0)"
: extended "Default is 1, and cannot be 0."
: extended "The number is truncated to 255 and then rolls over again, so 256 equals 0, etc."
: input "${1?$(:argv-err 1 'Failure message')}"
  ((stat)) || stat=1
  if [[ $stat -gt 255 ]]; then
    ((stat-=256))
  fi
  :to-v printf '%s\n' "${C_ERR-}$1${NORMAL-}"
  return ${stat}
}

:funbody () {
: name User-Script.Shell.function-body
: param '<Ref-fun> [<Dest-var>] ...'
: input "${1?$(:argv-err 1 'Function name expected')}"
  (($#-1)) &&
  local -n _out=${2?$(:argv-err 2 'Output name expected')} || local _out

  :pass "$(typeset -f "$1")" || return
  : "${_#* () }"
  : "${_:4:-2}"
  _out="$_"
  if [[ ! ${_out:+set} ]]; then
    say.v "Empty function body for ${1@Q} (ignored)"
  else
    (($#>1)) || printf '%s\n' "$_out"
  fi
}

:isfun() {
: name User-Script.Shell.function-exists
: param ' ~ <Funcname> ...'
: completion 'complete -A function'
: input "${1?$(:argv-err 1 'Function name')}"
  :pass "$(declare -F -- "${_}")"
}

:ignore() { "$@" || :; }

:pass() { return; }

:printf-arrlines() {
: param ' ~ <Array> [fmt] ...'
  local -n _pfl_arr=${1:?Array name}
  local _fmt=${2:-'%s\n'}

  printf "$_fmt" "${_pfl_arr[@]}"
}

:printf-arrtab() {
: param ' ~ <Array> [fmt] <Keys...>'
  local _pfl_k _fmt=${2:-'%s\t%s\n'}
  local -n _pfl_arr=${1:?Array name} _pfl_item='_pfl_arr["$_pfl_k"]'
  (($# == 1)) && shift || { shift 2 || return ${_E_GAE:?}; }
  (($#)) || set -- "${!_pfl_arr[@]}"

  for _pfl_k; do
    : "${_pfl_item//$'\n'/$'\n  '}"
    printf "$_fmt"  "$_pfl_k" "${_-NULL}"
  done
}

:read-tty() {
: param ' ~ [Prompt-value] [Initial-value] [Var-name] ...'
  local prompt=${1:-} initial=${2-} var=${3:-REPLY}

  trap 'return 130' INT
  read -r -e -p "$prompt" ${initial:+-i "$initial"} "${var?}" </dev/tty
  local st=$?
  trap - INT
  return "$st"
}

:restore-ifs() {
  local stat=$? ifs=$IFS normal=$' \t\n'
  [[ $ifs = "$normal" ]] || IFS=$normal
  :status $stat
  "$@"
}

:run-cancellable() {
: param ' ~ <Command...>'
  (($#)) || return ${_E_MA:?}

  trap 'return 130' INT
  "$@"
  local st=$?
  trap - INT
  return "$st"
}

:say-when() {
  local min_level=${1:-2}
  (( VERBOSITY >= min_level )) || return 0
  printf '%s\n' "${*:2}" >&${USER_FD}
}

:sleep()   { :run-cancellable sleep "$@"; }

:status() {
  return ${1:?}
}

:to-do() {
  (($#)) && : "To-do: $*" || {
    ((${#FUNCNAME[*]} > 1)) && : "${FUNCNAME[1]}()" || : "main"
    : "Unspecified to-do in ${_@Q}"
  }
  :to-v printf '%s\n' "${_}"
  return ${_E_todo:-125}
}

:to-v() {
: about 'Put output on USER output (regardless of verbosity)'
: param '~ <...>'
: tag dev
  "$@" >&${USER_FD}
}

:line-prefix() {
: input "${1:?"$(:argv-err 1 "Prefix string expected")"}"
  local str prefix=${1}

  while read -r str; do
    printf '%s\n' "${prefix}${str}"
  done
}


:unset-err() {
: about 'Output helper for unset/undefined name expressions'
: param '~ <Symbol> <Label> <"expected "> <"at name "> ...'
  set -- "${FUNCNAME[1]}" "$2" "${3:-expected }" "${4:-at name }" "$1"
  printf '%s: %s %s%s%s\n' "$@"
}

# Id: funenv_common                              vim:set ft=bash sw=2 sts=2 et:
