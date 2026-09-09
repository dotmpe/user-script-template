# Local CI run script file, for sourcing from workflows YAML but with more
# flexible tooling.
#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

if [[ ${DEBUG:+set} && ${DEBUG-} = 1 ]]; then
  >&2 echo CI Run Env: "${LOCAL_ENV:-.local/env/default.bash}"
  >&2 cat $_
fi
. "env_common.bash"

# Reset caches including user-data state (for now.. TODO: CI build env finetune)
rm -rf .local/build/ .local/cache/ .local/user/data/
mkdir -vp .local/user/data >&2

redo @config &&
redo -j10 -k all

# Id: ci_run                                     vim:set ft=bash sw=2 sts=2 et:
