#!/bin/bash
#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
set -euo pipefail
shopt -s failglob nullglob
IFS=$' \t\n'

[[ ! -e .env.sh ]] || \builtin . ./.env.sh

: "${US_SKELETON_DIR:=/src/local/user-script-template+dev}"
PATH+=:"${US_SKELETON_DIR:?}/tool/local"

scr_pre=tool/local
PATH+=:$scr_pre

\builtin . setup_common.bash
\builtin . usenv_common.bash
\builtin . env_common.bash

# us-parts config and entry-point example:

SCRIPTPATH+=:$PWD/tool/bash/part

case "${0##*/}" in
  ( run+boilerplate.* )
      :to-do "script stuff"
    ;;
esac
# Id: run+boilerplate                               vim:set ft=bash sw=2 sts=2 et:
