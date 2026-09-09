This is a skeleton file tree for a User-Script project. For the current features / status refer to the `configure+skeleton.bash` script source and its references.

## Getting Started

```bash
git clone "git@github.com:user-tools/user-scripts-template" --branch dev "/src/local/user-scripts-template+dev"
```

And then for latest dev:

```bash
curl 'https://raw.githubusercontent.com/dotmpe/user-scripts-template/dev/configure+skeleton.bash' | bash
```

There is just the dev version currently. And it is only in rudimentary shape still.

If you want to keep a local copy, just make one. But the `+skeleton` tag keeps the copy up-to-date.
It's steps are (to be) to make a clone of this template and use that as skeleton, but cloning is currently part of CI workflows only.

See the 'Features' sections for details, the manual steps are:

```bash
: "${US_SKELETON_DIR:="/src/local/user-scripts-template+dev"}"
cp "$US_SKELETON_DIR"/configure+skeleton.bash ./configure.bash
chmod +x ./configure.bash
./configure.bash
```

Start the configure script command from the project to configure and copy the files into.

## Features

- Copies or symlinks boilerplate files and scripts.
- It has etc/, doc/, and dotfiles, for linting project files, for a Github workflow, and LLM documents.
- It does **not** update *anything* currently, other than 1. `configure.bash` and 2. fix broken symlinks.

The main purpose (currently) is to preconfigure the **build**, so that a local redo setup can then take over project targets and life cycle;

- this does not pre-preprocess anything yet (tbd)
- also to-be done are tagged files and templates, and predefined heuristics to handle them.

  - Ie. "+template" is associated with different methods/formats/engines,
    and used to (re)generate and update local files, or just to build initial
    versions.
  - Other stand-ins for missing local files are literal, tag "+boilerplate".
  - The "+skeleton" tag scenario accesses the template at a local but separate
    work tree, where content actually lives.

Applying configuration depends on data, schema and policy further to be documented. The above is a work in progress.
