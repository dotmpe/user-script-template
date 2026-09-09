#!/usr/bin/env bash

# common_build.sh is the home for all target recipes

:uc-diag:forbidden-patterns() {
  # NOTE: keep patterns in plain text config, outside scans
  redo-ifchange etc/diag_forbidden_patterns.bash.lines &&
  :pass "$(< $_ )" &&
  \builtin . <(printf "forbidden=(\m%s\n)" "$_") &&
  [[ ${forbidden[*]:+set} ]] ||
    :failerr "No forbidden patterns configured" || return

  # Search (grep) file for certain expressions, warn about match(es)
  for x in "${forbidden[@]}"; do
    :to-v grep -HPn "^[^#:]*$x" "$script" || continue
    :failerr "Found forbidden ${x@Q}, see before lines" || return
  done

  redo-stamp <<< "${forbidden[*]}"
}

:uc-diag:shell-lint-check() {
  \builtin command shellcheck "$script" >&${USER_FD:?}
}

:uc-diag:shell-load-plus-lint-check() {
  ( \builtin . "$script" ) ||
    :failerr "E$? on test-loading ${script@Q}" || return
  \builtin . <(:uc-diag:shell-lint-check) &&
  say.v "Load and shellcheck passed for ${script@Q}"
}

:uc-diag:todo-comments() {
  TODO "implement comment scan"
}

:uc-diag:unguarded-tooling-invocations() {

  # FIXME: this does not work right yet; should require \builtin command for
  # certain toolkit commands (for recognition)
  # And for source/. (eval is kept in forbidden expressions)
  # But for other may introduce \reserved or \uc_reserved or similar. And should
  # know (scan/index) those with us-pp.
  # Same for some other commands, should require \inline prefix (later).
  redo-ifchange etc/diag_core_tooling.list &&
  mapfile -t cmds < $_ &&
  [[ ${cmds[*]:+set} ]] ||
    :failerr "No cmds configured" || return

  :pass "$(IFS='|'; echo "${cmds[*]}")" &&
  :to-v grep -HPn "^[^#:]*(?<!\\\bbuiltin[ \t])(?<!\\\)\b(${_:?})\b" -- "$script" ||
    return 0
  :failerr "Found unguarded tooling invocation(s), see before lines"
}

:xredo-build-target() {
  redo-always &&
  :cache-load ./$ETC/redo_default.bash &&
  redo-ifchange "${xredo_build_targets[@]:?}"
}

:xredo-build-ns1-target() {
  local src
  if [[ ! ${sources[*]} ]]; then
    :cache-load ./$VAR/redo_default.bash || return
  fi
  for src in "${sources[@]:?}"; do
    src=${src#src/}
    targets+=( "@index:${src:?}" )
    targets+=( "pack/ns1/${src%.inc}.bash" )
  done &&
  redo-ifchange "${sources[@]}" "${targets[@]}"
}

:xredo-check-recipe() {
  local diag script
  : "${XREDO_TARGET#@check:}"; IFS=: read -r script diag <<<"${_}" &&
  : "${script:?$(:unset-err script 'Input source file')}"

  redo-ifchange "$script" &&
  # TODO: act on and handle $diag setting
  case "$script" in

  ( pack/* )
      # TODO: rewrite parts so they can be used as recipe target
      #: "${diag:=@uc-diag:shell-lint-check}"
      :uc-diag:shell-load-plus-lint-check
    ;;

  ( src/* | tool/local/common* )
      :uc-diag:shell-load-plus-lint-check &&
      :uc-diag:forbidden-patterns &&
      #:uc-diag:unguarded-tooling-invocations &&
      : # :uc-diag:todo-comments
    ;;

  ( *.do | test/* | tool/* )
      :uc-diag:shell-lint-check &&
      :uc-diag:forbidden-patterns &&
      : #:uc-diag:todo-comments
    ;;

  ( *.yaml | *.md )
      # :uc-diag:forbidden-patterns &&
      :uc-diag:todo-comments
    ;;

  ( * ) :failerr "There is no check action for script ${script@Q}"
  esac
}

:xredo-check-target() {
  if [[ ! ${REDO_ALL:+set} ]]; then
    redo-ifdone @build ||
      :failerr "Build incomplete, cancelling @check" || return
  fi
  redo-always
  local files targets
  files=(
    {,.}*.yaml
    *.md
    doc/*.md
    default.do
    src/*/*.inc
    test/*.*
    tool/bash/part/*
    tool/local/{,exec/}*.*
  )
  for file in "${files[@]}"; do
    # TODO: make some grouping(s) of diag/src sets, not all should always need
    # to be on. CI would have the most complete set, then the (full) test
    # branch, but other envs/branches may get fewer diag (or none; ie "dev")
    # @uc-diag:regression-grep
    targets+=( "@check:$file" )
  done
  redo-ifchange "${targets[@]}"
}

:xredo-config-target() {
  local sources tools
  redo-ifchange ${scr_pre:?}/build-select.sh &&
  if [[ -d src/ ]]; then
    sources=( src/*/*.inc )
    :dump-pretty-globals sources >| ./$VAR/redo_default.bash &&
    redo-stamp <<< "${sources[@]}" || return
  fi
  if [[ -d tool/local/exec ]]; then
    tools=( tool/local/exec/*.* )
  fi
  for tool in "${tools[@]}"; do
    [[ -x "$tool" ]] || continue
    scr=${tool##*/}
    if [[ -h $scr && ! -e $scr ]]; then rm "$scr"; fi
    if [[ ! -h $scr ]]; then
      if [[ -e $scr ]]; then
        say.err "config: Local tool path exists: ${scr@Q} (ignored)"
        continue
      fi
      :to-v ln -sv "$tool" ${tool##*/} || return
    fi
  done
}

:xredo-index-recipe() {
  src=src/${XREDO_TARGET#@index:}

  redo-ifchange "$src" &&
  \builtin . ${scr_pre:?}/init-pp.sh >&${USER_FD:?} &&
  .run "$src" .match-line > /dev/null || :failerr "Indexing ${src@Q}"
}

:xredo-pack-recipe() {
  : "${XREDO_TARGET#pack/ns[0-9]/}"
  src=src/${_%.bash}.inc

  redo-ifchange ${scr_pre:?}/build-select.sh "$src" &&
  mkdir -p "${XREDO_TARGET%/*}" &&
  \builtin . ${scr_pre:?}/init-pp.sh >&${USER_FD:?} &&
  .run "$src" .match-line > "$BUILD_TARGET_TMP" ||
    :failerr "Building ns1 for ${src@Q}"
}

:xredo-pack-target() {
  redo-always
  TODO package
}

:xredo-test-recipe() {
  modid=${XREDO_TARGET#@test:}
  if ! (shopt -s failglob; : test/"${modid:?}"_test.* ) 2>/dev/null; then
    say.err "No tests for $modid"
    # TODO: require tests later
    return
  fi

  :cache-load ./etc/bash/us_bbb_specials.bash &&
  export -f "${us_bbb_specials[@]:?}" ||
    say.err "Failed at loading specials" || return

  #shellcheck disable=2295
  tests=( test/"${modid:?}"_test.* ) &&
  redo-ifchange @test:config "${tests[@]}" &&
  testid=$(sha256sum < <(printf '%s\n' "${tests[@]}")) &&
  : $'[\t ]' &&
  testid=${testid%%$_*} &&
  # :to-v declare -p testid &&
  mkdir -p .local/build &&
  \builtin command bashunit \
    --env test/_test_bootstrap.sh \
    --log-junit .local/build/test-report-$testid.xml \
    --coverage --coverage-min 80 \
    "${tests[@]}" >&${USER_FD:?}
}

:xredo-test-target() {
  # Makes no sense to test after incomplete build (ie. running redo -k)
  if [[ ! ${REDO_ALL:+set} ]]; then
    redo-ifdone @build ||
      :failerr "Build incomplete, cancelling @test" || return
  fi
  redo-always
  # TODO: validate actual data with schema
  say.debug "Starting pre-test checks"
  if [[ -d pack/ns1 ]]; then
    :failerr "Nothing to test" || return
  fi
  for x in pack/ns1/usrtools_usr{conf,scr}/*.bash; do
    targets+=( @check:"$x" )
  done
  redo-ifchange "${targets[@]}" || return
  unset targets
  say.info "All current packs checked OK, starting tests..."
  for x in pack/ns1/usrtools_usr{conf,scr}/*.bash; do
    : "${x##pack/ns1/}"
    : "${_%.bash}"
    : "${_/usrconf\/}"
    : "${_/usrscr\/}"
    targets+=( @test:"$_" )
  done
  redo-ifchange "${targets[@]}" || return
}

# Id: common_build                               vim:set ft=bash sw=2 sts=2 et:
