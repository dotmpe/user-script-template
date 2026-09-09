# Project conventions

Preamble:
: I am developing a template project.
  Remind and help me to further clarify the purpose of this project.

## Getting started

- The current choice of tool chain favors \*nix style tools, with in-terminal, text-based UI.

* This document is one of several CONVENTIONS and AGENT files, found at ``doc/`` for several projects.
  It is the primary project file for guidance and LLM/agentic interactions, of which we see two or more modes:

  - 'Full edit' or a "coding" mode, where file updates are given.
  - A conversational 'ask' mode with output restricted to examples and answers.

  In ask mode:

    - Do not restate or paraphrase the question.
    - Only add a brief note if there is a possible mismatch in topic or references.
    - Otherwise answer directly and concisely.

  In coding mode:

    - Ensure to summarize steps or actions in the answer before the actual edits.

  The CONVENTIONS document shares several parallel copies. These keep versions and editions with changes that do not fit-in with the internal structure well; the copies help to keep easy to compare parallel versions, sharing certain stanza's and overall structure while allowing to focus convention editions on a particular project and/or restricted to a specific stage and task.

## Writing scripts

* The intent is to finally deploy scripts that offer a good degree of confidence, and control, of the intended host/session interaction.
  But also to write succinct, and idiomatic (Bash 4.3+).
  Pre-processing will be deployed to reach these goals (`us-pp` module and command script).

- Shells have a complex interaction of run-time mode, script and host.
  Scripts should run in strict environments but be lenient depending on context, while functions may demand strict modes/environment/etc.

* For flags, options or any sort of symbol or key we prefer the full or readable form over the flag or mnemonic forms.
  Mnemonics may be appropriate according to context, but never the flag form unless that is the only input.
  We do not want to write code for the initiates only unnecessary, only when context demands it (e.g. regular expressions, file permissions or shell mode and other parsed strings, etc.).

# Project Setup

Goal: clutter free and clear root organisation:

- Source lives in `src/`.

- Local tooling live almost exclusively in ``tool/*/...`` where the asterisk stands-in for a globally defined suite or may be a language like "bash".
  ("tool/local" is a convenient root to tuck away any project specific scripts including Bash but without considering global or shared paths at all.)

- Other resources and dotfiles are configured (as far as possible) to be in etc/, var/, lib/, etc.

- For files that do not check in, use the .local/{etc,var,...} prefix. The .local/user is specifically to keep local user config and state.

- For cache and build, use .local/{cache,build} for local and prefer global paths. For those paths prefer to use additional subdirectories, per script or session or task, to make management easier. Do not put state information in cache, it must be regenerative and safe to be deleted without breaking the current project stage.

- Third party files need to go into ``lib/``, ``usr/`` and others as appropriate, or be kept in other trees that match the required file format and name layout.

## Project flow

- The basic lifecycle is src/ -> pack/ -> dist/, aided by configurable cache, build, config and other lookup/include paths.

- ``redo -k @config all`` "builds" all targets, which is conveniently configured in `.build-select.sh` to `@build @test @pack`.

  NB. special target `@config` needs be called as the very first (and explicitly), so when using parallel runners (-j<N> option) and after touching sources, make sure to run it before.
