# Default env, there is not much of a setup needed for the template+boilerplate.
# But projects can use either .env.sh .local/etc/env.bash etc/env.bash for now
# as a starting point for customization.
#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

if [[ "${CI:+ne}" ]]; then

  export GIT_ORIGIN_NETPATH="https://github.com/"
  export US_SKELETON_DIR=$PWD
  #export US_CONFIGURE_SCRIPT=configure+ci+boilerplate

  : "${GIT_TEMPLATE_REPOSITORY:=dotmpe/user-scripts-template}"
  declare -x GITHUB_REPOSITORY
  if [[ ${GITHUB_REPOSITORY} == dotmpe/user-scripts-template ]]; then
    :
  elif [[ ${GITHUB_REPOSITORY} == user-tools/user-scripts-template ]]; then
    export GIT_TEMPLATE_REPOSITORY=$GITHUB_REPOSITORY
  fi

  export REDO_ALL=${REDO_ALL:-y}

  BRANCH_NAME=${GITHUB_REF##*/}

  if [[ $BRANCH_NAME == dev ]]; then
    export DEBUG=1
  elif [[ $BRANCH_NAME == test ]]; then
    :
  fi

  #if [[ ${DEBUG:+set} && ${DEBUG-} = 1 ]]; then
  #  declare -p | grep -E 'declare -[gaAx]+' >&2
  #fi
fi

# Id: env                                        vim:set ft=bash sw=2 sts=2 et:
