#!/usr/bin/env bash
set -euo pipefail
IFS=$' \t\n'

[[ ! -e .env.sh ]] || \builtin . ./.env.sh

\builtin command aider \
  --no-show-release-notes --no-gitignore \
  --no-auto-commits \
  --no-dirty-commits \
  --no-attribute-author \
  --vim \
  --attribute-commit-message-author \
  --input-history-file .local/user/data/input/aider.input.history \
  --chat-history-file .local/user/data/chat/aider.chat.history.md \
  --config $HOME/.local/share/dotfiles/etc/aider/aider.conf.yml \
  --model "${model:?}"
