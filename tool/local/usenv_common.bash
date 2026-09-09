#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

us-env -R us-env
declare -gA _os_script_{load,path}
: "${US_SCR_EXT:=.us.group.bash .group.bash .bash .sh}"
us_part --hooks:declare,define,init us-term
: "${usp_opts:=--alias --hooks:declare,define,init --export}"
usp() { us_part $usp_opts "$@"; }

# Id: usenv_common                               vim:set ft=bash sw=2 sts=2 et:
