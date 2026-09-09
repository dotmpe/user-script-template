#!/usr/bin/env bash

:xredo-build-schema-recipe() {
  local {in,out}put
  IFS=: read -r input output <<<"${XREDO_TARGET##@build:schema:}"

  # :to-v declare -p {in,out}put &&
  :to-v mkdir -vp "$output" &&
  [[ -s $input ]] && gen_args=( "$input" --dir "$output" \
      --config-file etc/linkml_generator_config.yaml
    ) &&
  \builtin command gen-project "${gen_args[@]}" >&${USER_FD:?} ||
    :failerr "E$? from LinkML generator" || return
  redo-ifchange "$input" &&
  say.v "Generated output for schema ${input##*/}"
}

:xredo-build-schema-target() {
  local {in,out}put targets base
  output=.local/build/schema

  redo-always
  if [[ ! -d var/schema ]]; then
    :failerr "No LinkML schema(s) to generate code for" || return
  fi
  for input in var/schema/*.yaml; do
    base=${input%.yaml}
    base=${base##*/}
    targets+=( @build:schema:"$input:$output/${base}" )
  done
  redo-ifchange "${targets[@]}" &&
  redo-stamp <<< "${targets[*]}"
}

#
