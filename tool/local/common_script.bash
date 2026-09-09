#
# Copyright 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
test -d "$PWD/${scr_pre:?}" &&
PATH+=:$_ && export PATH || :failerr "Not a valid script prefix: ${scr_pre@Q}"

\builtin . common_setup.bash
shopt -s extdebug expand_aliases

us-env -R us-env
declare -gA _os_script_{load,path}
us_part --hooks:declare,define,init us-term
: "${usp_opts:=--alias --hooks:declare,define,init --export}"
usp() { us_part $usp_opts "$@"; }

\builtin . common_env.bash
METADIR=.local

# Id: common_script                              vim:set ft=bash sw=2 sts=2 et:
