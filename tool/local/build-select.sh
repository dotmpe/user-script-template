#!/bin/bash
#
# .build-select.sh - Configurable main project build file for default.do
#
# Copyright 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
#
XREDO_TARGET="${REDO_PWD:+$REDO_PWD/}${REDO_TARGET:?}"
# XRedo/Base: Actual initial (path, name or id) spec for target
XREDO_BASE=${XREDO_TARGET%%:*}
XREDO_NODE=${XREDO_TARGET%:*}

ETC=.local/etc
VAR=.local/var
scr_pre=tool/local

case "${XREDO_TARGET}" in @config | @*:config ) ;; ( * )

  # FIXME: cleanup
  #\builtin command -v redo-ifdone >/dev/null 2>&1 &&
  #if ! >/dev/null 2>&1 redo-ifdone @config; then
  redo_targets="$(redo-targets)" &&
  if ! grep -q '^@config' <<< "$redo_targets"; then
      say.err "Must run redo @config first (to build ${XREDO_TARGET@Q})"
      exit 1
  fi ||
    :ignore :failerr "Warning: Ignored redo-ifdone (targets=${redo_targets@Q})"

esac

case "${XREDO_TARGET}" in

( @build )
    :xredo-build-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @build:config )
    redo-ifchange ${scr_pre:?}/build-select.sh &&
    redo-ifchange $scr_pre/common_build.sh &&
    redo-stamp < <(grep -Po '^\(\ [^\)]+\ \)$' $scr_pre/build-select.sh) &&
    redo-stamp < <(grep -Po '^:xredo-[A-Za-z0-9-]+(?=\(\))' $scr_pre/common_build.sh)
  ;;

( @build:schema:* )
    \builtin . $scr_pre/build_schema.sh &&
    :xredo-build-schema-recipe &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @build:schema )
    \builtin . $scr_pre/build_schema.sh &&
    :xredo-build-schema-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @build:ns1 )
    :xredo-build-ns1-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @check )
    :xredo-check-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @check:* )
    :xredo-check-recipe &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @config )
    :xredo-config-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @index:* )
    :xredo-index-recipe &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @pack )
    :xredo-pack-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @test )
    :xredo-test-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @test:config )
    redo-ifchange test/_test_bootstrap.sh &&
    redo-stamp < <(grep -Pv '^([\t ]*|[\t ]*\#.*)$' test/_test_bootstrap.sh)
  ;;

( @test:* )
    :xredo-test-recipe &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;


( pack/*/* )
    :xredo-pack-recipe &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;


( * )
    :cache-load ./$ETC/redo_default.bash

    return ${_E_next:-196}

esac

# Id: build-select                               vim:set ft=bash sw=2 sts=2 et:
