#!/bin/bash
#
# Copyright 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
#
set -euo pipefail
shopt -s failglob nullglob
IFS=$' \t\n'

default_do_env() {
  [[ ! -e .env.sh ]] || \builtin . ./.env.sh
  if [[ -e .local/cache/xredo_env.bash ]]; then
    \builtin . .local/cache/xredo_env.bash || return
  else
    if declare -F xredo_do_env; then
      xredo_do_env || return
    else
      : "${scr_pre:=tool/local}"
      [[ ${xredo_env_sources[*]:+ne} ]] ||
        xredo_env_sources=(
          "$scr_pre/common_env.bash"
          "$scr_pre/common_build.sh"
          "$scr_pre/common-dsl.bash"
        )
      for xredo_env_src in "${xredo_env_sources[@]}"; do
        \builtin . "${xredo_env_src:?}" || return
      done
    fi
  fi
}

default_do_main() {
  declare BUILD_TARGET=${1:?}
  declare BUILD_TARGET_BASE=$2
  declare BUILD_TARGET_TMP=$3

  default_do_env ||
    :failerr "E$? $_" || return

  declare -I BUILD_SELECT_SH
  if [[ ! -e "${BUILD_SELECT_SH:=${scr_pre:?}/build-select.sh}" ]]
  then unset BUILD_SELECT_SH
    echo "No custom build rules (BUILD_SELECT_SH not found)" >&2
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
        redo-always && redo-ifchange "${xredo_all_targets[@]}"
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
