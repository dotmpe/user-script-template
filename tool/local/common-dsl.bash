#
# Copyright 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

if [[ ${0##*/} = common-dsl.bash ]]; then
  scr_pre=tool/local
  \builtin . ${scr_pre:?}/common_setup.bash
  shopt -s extdebug expand_aliases
  \builtin . ${scr_pre:?}/common_env.bash
fi

:-() {
: about 'Marker for pseudo-macro in pre-processor'
: param '~ <Sub-command...>'
  ! (($#)) || "$@"
}

:ignore() { "$@" || :; }
:pass() { return; }
:failerr () {
  local stat=${2:-$?}
: about "Output message and set or pass-trough non-zero status (input 256 for 0)"
: extended "Default is 1, and cannot be 0."
: extended "The number is truncated to 255 and then rolls over again, so 256 equals 0, etc."
: input "${1?$(:argv-err 1 'Failure message')}"
  ((stat)) || stat=1
  if [[ $stat -gt 255 ]]; then
    ((stat-=256))
  fi
  # FIXME: use USER_FD as output
  if [[ -n ${_os_script_path['us-palette']:+set} && -n ${COLORTERM:+set} ]]; then
    if [[ $stat -eq 0 ]]; then
      echo "${C_PASS-}$1${NORMAL-}" 1>&2
    else
      if [[ $stat == 1 ]]; then
        echo "${C_ABNORMAL-}$1${NORMAL-}" 1>&2
      else
        if [[ $stat == 2 ]]; then
          echo "${C_ERROR-}$1${NORMAL-}" 1>&2
        else
          if [[ $stat -gt 2 && $stat -lt 128 ]]; then
            echo "${C_ABNORMAL-}$1${NORMAL-}" 1>&2
          else
            if [[ $stat -gt 127 && $stat -lt 193 ]]; then
              echo "${C_AUXILIARY-}$1${NORMAL-}" 1>&2
            else
              if [[ $stat -gt 192 && $stat -lt 255 ]]; then
                echo "${C_CONTEXT-}$1${NORMAL-}" 1>&2
              else
                echo "${C_SECONDARY-}$1${NORMAL-}" 1>&2
              fi
            fi
          fi
        fi
      fi
    fi
  else
    echo "$1" 1>&2
  fi
  return ${stat}
}

:append-path () {
: name User-Script.OS.path-assert
  assert=1 :path-append "$@" || test 1 -eq $? || return $_
}

:path-append() {
: name User-Script.OS.path-append
: about "Simple PATH helper to append only new, unique instance"
: param "<Directory ...> [<Var=PATH>]"
: extended "Using this helps keeping PATH cleaner, but it doesnt behave like \path_append but returns false (1) if already found"
: notes TODO "Really should write sys-wordv-add or something"
: notes "This does not export PATH"
: notes "This does not require explicit PATH name for single dir argument, and last argument can always be left empty for default"
: notes "Not exactly like the same implementation as shipped with Debian/Ubuntu, see -assert variant"
: completion 'complete -A directory'
  local dirc _var
  ! (($#-1)) && dirc=1 || dirc=$#-1 _var=${*: $#:1}
  :lookup-append "${@:1: $dirc}" "${_var:-PATH}"
}

:lookup-append() {
: name User-Script.OS.lookup-append
: about "Simple PATH-var helper to append only new, unique instance"
: param "<Directory ...> [<Var=PATH>]"
: extended "Using this helps keeping PATH cleaner, but it doesnt behave like \path_append but returns false (1) if already found"
: notes TODO "Really should write sys-wordv-add or something"
: notes "This does not export the variable"
: notes "This requires the variable name, use _OS_Path_* alternatively"
: completion 'complete -A directory'
  (($#-1)) || return ${_E_MA:-194}
  local _PATHNAME=${*:$#:1}
: input ${_PATHNAME:?$(:argv-err 1 'Lookup variable')}
  local -n _PATH=$_PATHNAME
  local _arg
  for _arg in "${@:1: $#-1}"; do
: input "${_arg:?$(:unset-err _arg 'Path value'):}"
    case ":${_PATH:-:}:" in
      ( *:"${_arg}":*)
          ((${assert:-0})) || return 1
        ;;
      ( *)
          _PATH="${_PATH:+${_PATH}:}${_arg}"
        ;;
    esac
  done
}

:isfun() {
: name User-Script.Shell.function-exists
: param ' ~ <Funcname> ...'
: completion 'complete -A function'
: input "${1?$(:argv-err 1 'Function name')}"
  :pass "$(declare -F -- "${_}")"
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

:cache-load () {
: param '~ <Data-file> ...'
: name User-Conf.Cache.load-file
: tag util aux cache
  (($#)) || return ${_E_MA:?}
: input "${1?$(:argv-err 1 'Data file')}"

  [[ -s "${1}" ]] &&
  \builtin . "${1}" && {
    ! ((VERBOSE)) || {
      :pass "$(du -hs "${1}")" && : "${_%%[$'\t	']*}" &&
      say.debug "Cache loaded ($_ bytes)" || :
    }
  } || say.debug "Missing or empty ${1@Q} cache (E$?, ignored)"
}

:cache-loadmaps () {
: name User-Conf.Cache.load-maps
: param '~ <Data-file> <Map-exports...>'
: about 'Helper to retrieve map arrays from Shell cache file'
: tag cache
  (($#)) || return ${_E_MA:?}
: input "${1?$(:argv-err 1 'Shell script cache file')}"
: input "${2?$(:argv-err 2 'Associative array name(s)')}"

  declare -gA "${@:2}" ||
    :failerr "Cannot declare global maps ${*@Q}" || return
  [[ -x "${1}" ]] &&
  \builtin . "${1}" && {
    ! ((VERBOSE)) || {
      # Print summary of loaded bytes/items
      :pass "$(du -hs "${1}")" && : "${_%%[$'\t	']*}" &&
      say.debug "Cache loaded ($_ bytes) for ${*:2}" || :
      local -n _ref
      for _ref in "${@:2}"; do
        [[ ! -n "${_ref[*]:+set}" ]] ||
          say.info "Found ${#_ref[@]} ${!_ref} items in cache"
      done
    }
  } || say.debug "Missing or empty ${1@Q} cache (E$?, ignored)"
}


:argv-err() {
: about 'Output helper for unset/undefined argument position expressions'
: param '~ <Position> <Label> <"expected "> <"at position "> ...'
  set -- "${FUNCNAME[1]}" "$2" "${3:-expected }" "${4:-at position }" "$1"
  printf '%s: %s %s%s%i\n' "$@"
}

:say-when() {
  local min_level=${1:-2}
  (( VERBOSITY >= min_level )) || return 0
  printf '%s\n' "${*:2}" >&${USER_FD}
}

:unset-err() {
: about 'Output helper for unset/undefined name expressions'
: param '~ <Symbol> <Label> <"expected "> <"at name "> ...'
  set -- "${FUNCNAME[1]}" "$2" "${3:-expected }" "${4:-at name }" "$1"
  printf '%s: %s %s%s%s\n' "$@"
}

:to-v() {
: about 'Put output on USER output (regardless of verbosity)'
: param '~ <...>'
: tag dev
  "$@" >&${USER_FD}
}

inline() {
  ! (($#)) || say.err "Inline broken (fun call)"
}

# sometimes when writing it might help to have dev-mode only defs, like this:
if shopt -q expand_aliases; then
  alias printf.lines="printf '%s\\n'"
  alias 'say@v=:say-when $VERBOSITY'
  #shellcheck disable=2142  # alias referencing positionals is fine, actually
  alias functxln='say@v "$FUNCNAME: ${*@Q} [$#]"'
  alias inline='\inline;'
else
  printf.lines() { printf '%s\\n' "$@"; }
  say@v() { :say-when $VERBOSITY "$1"; }
  functxln() {
    say@v "${FUNCNAME[1]}: $(TODO "bash call arg inspection for outer function?")"
  }
fi

printf.lines.arr() {
  local -n _pfl_arr=${1:?Array name}
  printf.lines "${_pfl_arr[@]}"
}
printf.lines.array-map.tab() {
  local _pfl_k
  local -n _pfl_arr=${1:?Array name} _pfl_item='_pfl_arr["$_pfl_k"]'
  shift
  (($#)) || set -- "${!_pfl_arr[@]}"
  for _pfl_k; do
    : "${_pfl_item//$'\n'/$'\n  '}"
    printf '%s\t%s\n' "$_pfl_k" "${_-NULL}"
  done
}

say.err() { :say-when 1 "$1"; }
say.info() { :say-when 2 "$1"; }
say.v() { :say-when 3 "$1"; }
say.debug() { :say-when 4 "$1"; }

# XXX: helpers for user-equiv. for log, temporary until better init
:_debug() {
  ((QUIET)) || ! ((DEBUG)) || :say-when 4 "$1"
}
:_info() {
  ((QUIET)) || :say-when 2 "$@"
}
:_notice() {
  ((QUIET)) || :say-when 3 "$@"
}

# other dev-mode impl. helper, to be stripped/replaced before pack and dist
TODO() {
  (($#)) && : "To-do: $*" || {
    ((${#FUNCNAME[*]} > 1)) && : "${FUNCNAME[1]}()" || : "main"
    : "Unspecified to-do in ${_@Q}"
  }
  ${TODO_call:-:say-when} ${VERBOSITY:-1} "${_}"
  return ${_E_todo:-125}
}

# TODO: move :* to other "DSL" groups

:_args+names() {
  local -a names
  \builtin . <(printf "names=( %s )" "$1") &&
  [[ ${names[*]:+set} ]] ||
    say.err "Null expansion ${1@Q}" ${_E_usage:-64}
}

# Vanilla bash 'inlining' / definition reuse
# around current sh-funbody

# XXX: real inlining is possible once loader takes over source.
# It also looks a bit nicer. Var ___ is used as 'input' to the Bash alias. And
# _%_ is a sort of recognition of the special alias template scripts' status.

:inline.fun() {
: about 'Include body of function, as-is as source'
  \builtin . <(:funbody ${_%_})
}

:inline.fun.status() {
: about 'Include body of function with return status'
  \builtin . <(:funbody ${_%_} _fb_script && echo "${_fb_script:?} || return")
}

# TODO: strip (most) : lines in sh_funscr <fun>, or use specific call: sh_funscr_nometa {als,tag,about,type} ...
_inline_fun_tpl=$(:funbody :inline.fun)
#shellcheck disable=2139  # var is expanded from tpl on assign
alias inline-fun="${_inline_fun_tpl//_%_/___}"
_inline_fun_status_tpl=$(:funbody :inline.fun.status)
#shellcheck disable=2139  # var is expanded from tpl on assign
alias inline-fun-status="${_inline_fun_status_tpl//_%_/___}"


# Utilities for Args module, or to keep with us-arr Arr module as special
# templates / cases for the generic User-Script.Arr.zip-{bind,copy,assign} impl.
# that work on arrays.

:bind-args() {
: about 'Expand variable names and zip-bind remaining arguments as reference name'
: param '~ <Expansion> <Variables...>'
: input "${1:?$(:argv-err 1 'Brace or glob expression')}"
: input "${2:?$(:argv-err 2 'Variable references')}"
  ___=:_args+names; inline-fun-status
  :zip-bind.args names "${@:2}"
}

:copy-args() {
: about 'Expand variable names and zip-copy values from remaining arguments as variable names'
: param '~ <Expansion> <Variables...>'
: input "${1:?$(:argv-err 1 'Brace or glob expression')}"
: input "${2:?$(:argv-err 2 'Source variables')}"
  ___=:_args+names; inline-fun-status
  :zip-copy.args names "${@:2}"
}

:read-args() {
: about 'Expand variable names and zip-assign remaining arguments as values'
: param '~ <Expansion> <Values...>'
: input "${1:?$(:argv-err 1 'Brace or glob expression')}"
: input "${2:?$(:argv-err 2 'Assignment values')}"
  ___=:_args+names; inline-fun-status
  :zip-assign.args names "${@:2}"
}

:read-args.all-words() {
: about 'Variant that concatenates remaining arguments at the last variable'
  ___=:_args+names; inline-fun-status
  :zip-assign.all-args names "${@:2}"
}

:read-setting() {
: about 'A read-args wrapper that takes the expression from a variable'
: param '~ <Expression-name> <Values...>'
: input "${1:?$(:argv-err 1 'Expansion variable name')}"
  local -n _sk=${1}
: input "${_sk:?$(:unset-err $1 "Expansion expression")}"
  :read-args "$_sk" "${@:2}"
}

:zip-assign.all-args() {
: param '~ <Array> <Values...>'
: input "${1:?$(:argv-err 1 'Array name')}"
: input "${2:?$(:argv-err 2 'Assignment values')}"
  local -n _Vars=${1}
  local -n _lastVar='_Vars[-1]'
  local offset

  :zip-assign.args "$@" &&
  (( offset=${#_Vars[@]} )) && _lastVar+=${_lastVar:+ }${*:offset}
}

:zip-assign.args() {
: about 'Pair names from array with given values and assign'
: param '~ <Array> <Values...>'
: input "${1:?$(:argv-err 1 'Array name')}"
: input "${2:?$(:argv-err 2 'Assignment values')}"
  local -n _za_names=$1
  local i
  for i in "${!_za_names[@]}"; do
    ((i+=2))
    printf -v "${_za_names[i-2]}" '%s' "${!i}"
  done
}

:zip-bind.args() {
: about 'Make by-name variables from names in array paired with given variables'
: param '~ <Array> <Variables...>'
: input "${1:?$(:argv-err 1 'Array name')}"
: input "${2:?$(:argv-err 2 'Variable references')}"
  local -n _zb_names=$1
  local _zb_{i,global_ref}
  for _zb_i in "${!_zb_names[@]}"; do
    ((_zb_i+=2))
    _zb_global_ref="${!_zb_i}"
    declare -gn "${_zb_names[_zb_i-2]}=${_zb_global_ref}"
  done
}

:zip-copy.args() {
: about 'Zip-assign current values, pairing variables to variable names in array'
: param '~ <Array> <Variables...>'
: input "${1:?$(:argv-err 1 'Array name')}"
: input "${2:?$(:argv-err 2 'Source variables')}"
  local -n _zc_names=$1
  local _zc_{i,global_ref}
  for _zc_i in "${!_zc_names[@]}"; do
    ((_zc_i+=2))
    _zc_global_ref="${!_zc_i}"
    printf -v "${_zc_names[_zc_i-2]}" '%s' "${!_zc_global_ref}"
  done
}


# Temp copy from str tools (us_str.inc)

:globmatch() {
: about "Inline glob match of String to Pattern"
: param " ~ <Pattern> <String> ..."
: input "${1:?$(:argv-err 1 'Pattern')}"
: input "${2:?$(:argv-err 2 'String name')}"
  local -n _gm_str_name=${2}
: input "${_gm_str_name:?$(:unset-err $2 "String value")}"
  #shellcheck disable=2254  # Unquoted var is meant as case/esac glob expansion
  case "${_gm_str_name}" in ( ${1} ) ;; ( * ) false; esac
}

:globmatch.str() {
: about "Inline glob match of String to Pattern"
: param " ~ <Pattern> <String> ..."
: input "${1:?$(:argv-err 1 'Pattern')}"
: input "${2:?$(:argv-err 2 'String value')}"
  #shellcheck disable=2254  # Unquoted var is meant as case/esac glob expansion
  case "${2}" in ( ${1} ) ;; ( * ) false; esac
}

:globstrip-charsleft() {
: param '~ <String-name> [<Match-expression>] ...'
: input "${1:?$(:argv-err 1 'String name')}"
  local -n _us_gs_cl_str=${1:?}
: input "${_us_gs_cl_str:?$(:unset-err $1 'String value')}"
  local _us_gs_cl_prefc=${2:-"[ ]"}

  while :globmatch "$_us_gs_cl_prefc*" _us_gs_cl_str
  do
    #shellcheck disable=SC2295  # Match expansion from var is the idea here
    _us_gs_cl_str="${_us_gs_cl_str#$_us_gs_cl_prefc}"
    [[ "$_us_gs_cl_str" ]] || break
  done
}

:globstrip-charsright() {
: param '~ <String-name> [<Match-expression>] ...'
: input "${1:?$(:argv-err 1 'String name')}"
  local -n _us_gs_cr_str=${1:?}
: input "${_us_gs_cr_str:?$(:unset-err $1 'String value')}"
  local _us_gs_cr_prefc=${2:-"[ ]"}

  while :globmatch "*$_us_gs_cr_prefc" _us_gs_cr_str
  do
    #shellcheck disable=SC2295  # Match expansion from var is the idea here
    _us_gs_cr_str="${_us_gs_cr_str%$_us_gs_cr_prefc}"
    [[ "$_us_gs_cr_str" ]] || break
  done
}

declare -gA us_shell_tspec

User-Script.Shell.variable-type-cache() {
: about '~ <Symbols...>'
: about 'Cache for just the declare flags'
# XXX: not using ${var@A} bc that abbreviates non-export globals so not sure if
# that is better/faster
  local sym
  local -n _sh_vfl='us_shell_tspec["$sym"]'
  for sym; do
    if [[ ! ${_sh_vfl:+set} ]]; then
      :pass "$(2>/dev/null declare -p "${sym}")" ||
        :failerr "E$? getting ${sym@Q} typeset" || return
      : "${_:8}"
      : "${_%% *}"
      _sh_vfl=$_
    fi
  done
}

:sort-array() {
: param "<Arr-in> ..."
: input "${1?$(:argv-err 1 'Input array(s) expected')}"
  local -n __arr_in=${1}
  local -n __arr_out=${2:-$1}
  IFS=$'\n'
  :pass "$(<<<"${__arr_in[*]}" sort)" && mapfile -t ${!__arr_out} <<< "$_"
  IFS=$' \t\n'
}

:dump-pretty-global-array() {
: input "${1:?$(:argv-err 1 '<Variable[:alias]>')}}"
  local var=${1:?} als assoc=0
  case "$var" in ( *:* ) als=${var#*:} var=${var%:*};; ( * ) als=; esac

  local -n _sh_vfl='us_shell_tspec["$var"]'
  [[ $_sh_vfl == -A ]] && assoc=1 ||
  [[ $_sh_vfl == -a ]] ||
    :failerr "$FUNCNAME: Not an array ${var@Q}" || return
  local -n value=$var'["$key"]' input=$var
  local key{,s} output

  ((assoc)) && : A || : a
  printf -v output 'declare -g%s %s=(\n' "$_" "${als:-${var}}"
  if [[ "${input[*]:+set}" ]]; then
    keys=( "${!input[@]}" )
    # FIXME: sort is for dictionary (assoc arrays)
    ! ((assoc)) || :sort-array keys
    for key in "${keys[@]}"; do
      [[ "${value:+set}" ]] ||
        :failerr "Empty value in array ${var@Q} at key ${key@Q}" || return

      : "${value@Q}"
      #: "${_//'\n'/$'\n'}"
      ((assoc)) &&
        output+="  [\"$key\"]=${_:?}"$'\n' ||
        output+="  [$key]=${_:?}"$'\n'
    done
  fi
  output+=')'
  printf '%s\n' "$output"
}

:dump-pretty-globals() {
: about 'Helper to make readable, formatted variable dumps'
: param '~ <Var[:alias] ...>'
: completion 'complete -A variable -A arrayvar'
: input "${*:?$(:argv-err \* 'Variable name(s)')}"
  local var als
  local -n _sh_vfl='us_shell_tspec["$var"]'

  for var; do
    case "$var" in ( *:* ) als=${var#*:} var=${var%:*};; ( * ) als=; esac
    User-Script.Shell.variable-type-cache "$var" &&
    case "$_sh_vfl" in
    ( -[Aa] ) :dump-pretty-global-array "$var:$als" ;;
    ( * ) :failerr "TODO: dump pretty ${var@Q}" || return
    esac || :failerr "E$? making pretty dump for ${var@Q}:${als@Q}" || return
  done
}

..Cache.load-maps() { .load-maps "$@"; }
..Cache.load-data() { .load-data "$@"; }

# :isfun User-Conf.Cache.load-data ||
# User-Conf.Cache.load-data() { .load-file "$@"; }

..Namespace.map-to-ns1() { .map-to-ns1 "$@"; }

..Operating-System.path-append() { :path-append "$@"; }
# :isfun User-Script.Operating-System.path-append ||
# User-Script.Operating-System.path-append() { :path-append "$@"; }

..String.join-array() { .join-array "$@"; }

..Shell.dump-globals() { .dump-globals "$@"; }



if [[ ${0##*/} = common-dsl.bash ]]; then

  myArgsRead() {
    :read-args 'myArgsRead{A,B}' "$@"
    :to-v declare -p myArgsRead{A,B}
  }
  myArgsCopy() {
    :copy-args 'myArgsCopy{A,B}' "$@"
    :to-v declare -p myArgsCopy{A,B}
  }
  myArgsBind() {
    :bind-args 'myArgsBind{A,B}' "$@"
    :to-v declare -p myArgsBind{A,B}
  }

  exec {USER_FD}>&2
  trap 'exec {USER_FD}>&-' EXIT

  myArgsRead 123 abc
  myArgsCopy myArgsRead{A,B}
  myArgsBind myArgsCopy{A,B}

  :to-v declare -F :read-args
  :to-v declare -f :read-args
  :to-v declare -f myArgsRead
fi

# Id: common-dsl                                 vim:set ft=bash sw=2 sts=2 et:
