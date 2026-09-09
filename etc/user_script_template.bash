#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

us_skeleton_copy=(
  ./default.do
  ./.gitignore
  ./.markdownlint.yaml
  ./.shellcheckrc
  ./.yamllint.yaml

  ./.github/workflows/ci.yml
  ./tool/local/ubuntu_ci_install.bash
  ./tool/local/ci_run.bash
)

us_skeleton_symlink=(
  ./tool/local/exec/aider.sh
)

# Id: user_script_template         vim:set ft=bash sw=2 sts=2 et:
