#!/bin/bash
#
# build-select.bash - Configurable main project build file for default.do
#
# Copyright 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
#
XREDO_TARGET="${REDO_PWD:+$REDO_PWD/}${REDO_TARGET:?}"
# XRedo/Base: Actual initial (path, name or id) spec for target
XREDO_BASE=${XREDO_TARGET%%:*}
XREDO_NODE=${XREDO_TARGET%:*}

case "${XREDO_TARGET}" in @config | @*:config ) ;; ( * )

  # FIXME: cleanup; test redo-ifdone and see what is going on
  #\builtin command -v redo-ifdone >/dev/null 2>&1 &&
  #if ! >/dev/null 2>&1 redo-ifdone @config; then
  # This is incomplete; this just checks 'did we ever try to build X'
  #redo_targets="$(redo-targets)" &&
  #if ! grep -q '^@config' <<< "$redo_targets"; then
  if ! >&2 redo-ifdone @config; then
      say.err "Must run @config first (to build ${XREDO_TARGET@Q})"
      exit 1
  fi

esac

\builtin . "${build_common:?}" &&

case "${XREDO_TARGET}" in

( @build )
    :xredo-build-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @build:config )
    redo-ifchange "${build_configs[@]:?}" &&
    redo-stamp < <(grep -Po '^\(\ [^\)]+\ \)$' "${build_select:?}") &&
    redo-stamp < <(grep -Po '^:xredo-[A-Za-z0-9.:+-]+(?=\(\))' "${build_common:?}")
  ;;

( @build:schema:* )
    \builtin . "${build_schema:?}" &&
    :xredo-build-schema-recipe &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-ifchange @build:config
  ;;

( @build:schema )
    \builtin . "${build_schema:?}" &&
    :xredo-build-schema-target &&
    redo-stamp <<< "$(:funbody $_)" &&
    redo-stamp < <(grep -Po '^:xredo-[A-Za-z0-9.:+-]+(?=\(\))' "${build_schema:?}") &&
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
    return ${_E_next:-196}

esac

# Id: build-select                               vim:set ft=bash sw=2 sts=2 et:
