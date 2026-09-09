#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

if [[ ${DEBUG:+set} && ${DEBUG-} = 1 ]]; then
  read -ra ghvars < <(compgen -A variable -X '!GITHUB*') &&
  >&2 declare -p "${ghvars[@]}" || :
fi

if [[ ${GITHUB_REPOSITORY} == dotmpe/user-script-template ]]; then
  export US_SKELETON_DIR=$PWD
  PATH+=:tool/local
else
  SKELETON_TMP="$(mktemp -d)" &&
  git clone --quiet --branch dev https://github.com/dotmpe/user-script-template.git "$SKELETON_TMP" || exit
  export US_SKELETON_DIR=$SKELETON_TMP
  PATH+=:tool/local:$US_SKELETON_DIR/tool/local
fi
export PATH

# Id: ci_config                                  vim:set ft=bash sw=2 sts=2 et:
