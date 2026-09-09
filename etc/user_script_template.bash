# Default copy/symlinker setting for template project.
# Copy to etc/ or .local/etc for project customization.
#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.

# Copies (standard files, and tagged stand-ins or generated artefacts)
us_skeleton_copy=(

  ./default.do
  ./.gitignore
  ./.markdownlint.yaml
  ./.shellcheckrc
  ./.yamllint.yaml

  # TODO: a configurator really should be able to help setup the whole project
  #
  # ./LICENSE+license
  # ./.local/etc/LICENSE+licence.head

  # ./README+boilerplate.md
  # ./doc/README+boilerplate.md
  # ./doc/CONVENTIONS+boilerplate.md

  ./.github/workflows/ci.yml
  ./tool/local/ubuntu_ci_install.bash
  ./tool/local/ci_run.bash
)

# Symlinks (use latest local version always, and don't leave copies)
us_skeleton_symlink=(
  ./tool/local/exec/aider.sh
)

# Id: user_script_template         vim:set ft=bash sw=2 sts=2 et:
