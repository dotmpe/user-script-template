. env_common.bash

sudo apt-get update -qq &&
sudo apt-get install -qqy shellcheck &&
\builtin command -v shellcheck >/dev/null 2>&1 ||
  :failerr "Failed to provision shellcheck (E$?)"

{ curl -s https://bashunit.com/install.sh | bash; } &&
sudo mv -v lib/bashunit /usr/local/bin/ &&
\builtin command -v bashunit >/dev/null 2>&1 ||
  :failerr "Failed to provision bashunit (E$?)"

pip install -q linkml ||
  :failerr "Failed to provision linkml (E$?)"

REDO_TMP="$(mktemp -d)"
# NOTE: need tags and cannot specify --depth 1
# TODO: check out github distributions +redo
git clone --quiet --branch ifdone https://github.com/dotmpe/redo.git "$REDO_TMP" &&
(
  cd "$REDO_TMP" &&
  ./do -j10 build &&
  sudo DESTDIR= PREFIX=/usr/local ./do -j10 install &&
  \builtin command -v redo >/dev/null 2>&1 &&
  sudo rm -rf "$REDO_TMP"
) ||
  :failerr "Failed to provision redo (E$?)"

# Id: ubuntu_ci_install                          vim:set ft=bash sw=2 sts=2 et:
