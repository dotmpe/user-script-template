#
# Copyright 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

LOG() { # ~ pri tag msg ctx stat
  local stat=${5-}
  echo "$*" >&2
  return ${stat-}
}
LOG=LOG
PATH+=:$U_S/src/sh/lib
PATH+=:$U_S/src/bash/lib
PATH+=:$US_BIN
#usp us-arr
us_arr_pre=User-Script.Array.
lib_require envd >&2
lib_init envd >&2
echo ${0##*/}: libenv_common: Load OK >&2
# Id: libenv_common                          vim:set ft=bash sw=2 sts=2 et:
