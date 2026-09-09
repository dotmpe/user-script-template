. env_common.bash

ETC=.local/etc
VAR=.local/var
mkdir -vp "$ETC" "$VAR" .local/user/data >&2
etc=./$ETC/redo_default.bash
var=./$VAR/redo_default.bash
[ -e "$var" ] || {
  touch "$var"
  echo "New file $var" >&2
}
[ -e $etc ] || {
  cp ./etc/redo_default+seed.bash "$etc" &&
  echo "New file $etc" >&2
}
export REDO_ALL=${REDO_ALL:-y}

# Reset caches including user-data state (for now.. TODO: CI build env finetune)
rm -rf .local/build/ .local/cache/ .local/user/data/
mkdir -vp .local/user/data >&2

redo @config &&
redo -j10 -k all

# Id: ci_run                                     vim:set ft=bash sw=2 sts=2 et:
