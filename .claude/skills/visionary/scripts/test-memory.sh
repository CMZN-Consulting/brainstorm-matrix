#!/usr/bin/env bash
set -euo pipefail

if [ -z "${BASH_VERSINFO[0]:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  printf '%s\n' "test-memory: bash 4 or later is required, and this is bash ${BASH_VERSION:-unknown}" >&2
  exit 1
fi
shopt -s inherit_errexit 2>/dev/null || true
unset TMUX TMUX_PANE CLAUDE_CODE_DISABLE_TERMINAL_TITLE

HERE="$(CDPATH='' cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATRIX="$HERE/matrix.sh"
ROOT="$(CDPATH='' cd -- "$HERE/../../../.." && pwd)"
command -v tmux >/dev/null 2>&1 || {
  printf '%s\n' "test-memory: tmux is not on PATH" >&2
  exit 1
}
WORK="$(mktemp -d /tmp/test-memory.XXXXXX)" || exit 1
SOCK="$WORK/t/tmux-$(id -u)/default"
trap 'tmux -S "$SOCK" kill-server >/dev/null 2>&1 || true; rm -rf "$WORK"' EXIT
mkdir "$WORK/t" "$WORK/cfg" "$WORK/bin" "$WORK/01-ada-memory" "$WORK/notes"
printf '%s\n' '#!/bin/sh' 'printf "%s\n" "2.1.400 (Claude Code)"' >"$WORK/bin/claude"
chmod +x "$WORK/bin/claude"
export CLAUDE_CONFIG_DIR="$WORK/cfg" TMUX_TMPDIR="$WORK/t" PATH="$WORK/bin:$PATH"
SESSION=TestMemory
FAILS=0

report() {
  printf '%-5s %s\n' "$1" "$2"
  if [ "$1" = FAIL ]; then
    FAILS=$((FAILS + 1))
  fi
}

holds() {
  local what="$1"
  shift
  if "$@"; then
    report ok "$what"
  else
    report FAIL "$what"
  fi
}

run() {
  local rc=0
  "$MATRIX" "$@" >"$WORK/out" 2>&1 || rc=$?
  printf '%s' "$rc"
}

no_session() {
  ! tmux -S "$SOCK" has-session -t "=$SESSION" 2>/dev/null
}

said() {
  grep -q -- "$1" "$WORK/out"
}

failed_saying() {
  [ "$rc" -ne 0 ] && said "$1"
}

ascii_short() {
  [ "$(LC_ALL=C printf '%s' "$ROOT" | LC_ALL=C tr -d '\000-\177' | wc -c)" -eq 0 ] && [ "${#slug}" -le 200 ]
}

both_left() {
  [ "$rc" -ne 0 ] && [ -f "$mem/MEMORY.md" ] && [ -f "$mem/a note.md" ]
}

both_left_running() {
  both_left && said "the room was not stopped" && session_runs
}

both_moved() {
  cmp -s "$WORK/one" "$WORK/01-ada-memory/auto-memory/MEMORY.md" && cmp -s "$WORK/two" "$WORK/01-ada-memory/auto-memory/a note.md"
}

memory_empty() {
  [ -z "$(find "$mem" -mindepth 1 -maxdepth 1 -print)" ]
}

kept_both() {
  [ "$rc" -ne 0 ] && grep -qx "a later note" "$mem/MEMORY.md" && [ -f "$mem/b note.md" ] && [ ! -e "$WORK/01-ada-memory/auto-memory/b note.md" ] && cmp -s "$WORK/one" "$WORK/01-ada-memory/auto-memory/MEMORY.md"
}

session_runs() {
  tmux -S "$SOCK" has-session -t "=$SESSION" 2>/dev/null
}

refused_not_storm() {
  [ "$rc" -ne 0 ] && said "not a storm directory" && session_runs && [ -f "$mem/MEMORY.md" ] && [ ! -e "$WORK/notes/auto-memory" ]
}

rc="$(run doctor)"
mem="$(sed -n "s/^ok    this folder's Claude Code project memory is empty (\(.*\))\$/\1/p" "$WORK/out")"
holds "doctor names this folder's project memory, empty, under the fake CLAUDE_CONFIG_DIR" [ -n "$mem" ]
if [ -z "$mem" ]; then
  cat "$WORK/out" >&2
  printf '%s\n' "$FAILS check(s) failed"
  exit 1
fi
slug="$(LC_ALL=C printf '%s' "$ROOT" | LC_ALL=C tr -c 'a-zA-Z0-9' '-')"
if ascii_short; then
  holds "the memory is projects/$slug/memory, the folder's path with each character but a-z, A-Z and 0-9 made a hyphen" [ "$mem" = "$CLAUDE_CONFIG_DIR/projects/$slug/memory" ]
else
  report skip "the folder's path is not plain ASCII of at most 200 characters, so its name is not computed here"
fi

mkdir -p "$mem"
printf '%s\n' "a note a seat kept" >"$mem/MEMORY.md"
printf '%s\n' "a second note" >"$mem/a note.md"
cp "$mem/MEMORY.md" "$WORK/one"
cp "$mem/a note.md" "$WORK/two"

rc="$(run doctor)"
holds "doctor fails while the memory holds two files" failed_saying "^FAIL  this folder's Claude Code project memory holds 2 file(s)"

rc="$(run up -p "$SESSION")"
holds "up refuses to start while the memory holds a file" failed_saying "project memory holds files"
holds "up makes no tmux session when it refuses" no_session

rc="$(run down -p "$SESSION")"
holds "down with no STORM_DIR refuses and leaves both files where they are" both_left

tmux -S "$SOCK" new-session -d -s "$SESSION" -x 80 -y 24 "sleep 600"
rc="$(run down -p "$SESSION")"
holds "down with no STORM_DIR, while the room runs, refuses before it stops the room" both_left_running
rc="$(run down -p "$SESSION" "$WORK/notes")"
holds "down refuses a STORM_DIR that is not a storm's, before it stops the room" refused_not_storm

rc="$(run down -p "$SESSION" "$WORK/01-ada-memory")"
holds "down exits 0" [ "$rc" -eq 0 ]
holds "down stops the room's tmux session" no_session
holds "down moves both files, unchanged, into STORM_DIR/auto-memory" both_moved
holds "down leaves the memory empty" memory_empty

printf '%s\n' "a later note" >"$mem/MEMORY.md"
printf '%s\n' "a third note" >"$mem/b note.md"
rc="$(run down -p "$SESSION" "$WORK/01-ada-memory")"
holds "down refuses to overwrite a file the storm's record holds, and moves nothing" kept_both
rm "$mem/MEMORY.md" "$mem/b note.md"

rc="$(run doctor)"
holds "doctor finds the memory empty again" said "^ok    this folder's Claude Code project memory is empty"

if [ "$FAILS" -gt 0 ]; then
  printf '%s\n' "$FAILS check(s) failed"
  exit 1
fi
printf '%s\n' "every check held"
