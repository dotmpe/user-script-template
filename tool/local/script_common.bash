#
# Copyright 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
#
test -d "$PWD/${scr_pre:?}" &&
PATH+=:$_ && export PATH || :failerr "Not a valid script prefix: ${scr_pre@Q}"

\builtin . setup_common.bash
shopt -s extdebug expand_aliases

\builtin . usenv_common.bash
\builtin . env_common.bash
METADIR=.local

# Id: script_common                              vim:set ft=bash sw=2 sts=2 et:
