# Vanilla Bash strict, with local .env.sh
#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
set -eETuo pipefail
shopt -s nullglob failglob extdebug
IFS=$' \t\n'
\builtin . dotenv_common.bash
# Id: setup_common                               vim:set ft=bash sw=2 sts=2 et:
