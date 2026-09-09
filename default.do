#!/bin/bash
#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
#
set -euo pipefail
shopt -s failglob nullglob
IFS=$' \t\n'

default_do_env() {
: env "${_E_GAE:=193}"
: env "${_E_MA:=194}"
: env "${_E_continue:=195}"
: env "${_E_next:=196}"
: env "${_E_break:=197}"
: env "${_E_retry:=198}"
  ! (($#)) || return ${_E_GAE:?}

  [[ ! -e .env.sh ]] || \builtin . ./.env.sh
  if [[ -e ${XREDO_ENV:=.local/build/xredo_env.bash} ]]; then
    \builtin . "${XREDO_ENV:?}" || return
  else
    case "${XREDO_TARGET}" in @config )
        bash ./configure.bash &&
        \builtin . "${XREDO_ENV:?}" || return
      ;; ( * )
        >&2 echo "Config build required"
        exit 1
        # : "${BUILD_SELECT_SH:=.build-select.sh}"
    esac
  fi
}

default_do_main() {
  declare BUILD_TARGET=${1:?}
  declare BUILD_TARGET_BASE=$2
  declare BUILD_TARGET_TMP=$3

  default_do_env ||
    :failerr "E$? $_" || return

  if [[ ! -e "${BUILD_SELECT_SH:?}" ]]; then
    unset BUILD_SELECT_SH
    echo "No custom build rules (BUILD_SELECT_SH=${BUILD_SELECT_SH@Q})" >&2
  else
    \builtin . "${BUILD_SELECT_SH:?}" && exit || {
      local st=$?
      (( st == _E_next )) || exit $st
    }
  fi

  case "${1:?}" in

  ( "${HELP_TARGET:-help}"|-help|-h )
        ${BUILD_TOOL:?}-always &&
        TODO
      ;;

    # Default build target
  ( all|@all|:all )
        redo-always && redo-ifchange "${xredo_all_targets[@]:?}"
      ;;

  ( * ) false
      ;;

  esac

  # End build if handler has not exit already
  exit $?
}

[[ ! ${REDO_RUNID:+set} ]] || {

  : "${US_DEBUG:=${DEBUG:=0}}"

  default_do_main "$@"
}

# Id: default                                    vim:set ft=bash sw=2 sts=2 et:
