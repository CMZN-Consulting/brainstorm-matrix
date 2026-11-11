#!/usr/bin/env bash
set -euo pipefail

if [ -z "${BASH_VERSINFO[0]:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  printf '%s\n' "test-room: bash 4 or later is required, and this is bash ${BASH_VERSION:-unknown}" >&2
  exit 1
fi
shopt -s inherit_errexit 2>/dev/null || true
unset TMUX TMUX_PANE CLAUDE_CODE_DISABLE_TERMINAL_TITLE CLAUDE_CODE_EFFORT_LEVEL

HERE="$(CDPATH='' cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATRIX="$HERE/matrix.sh"
command -v tmux >/dev/null 2>&1 || {
  printf '%s\n' "test-room: tmux is not on PATH" >&2
  exit 1
}
WORK="$(mktemp -d /tmp/test-room.XXXXXX)" || exit 1
SOCK="$WORK/t/tmux-$(id -u)/default"
cleanup() {
  exec 3>&- 2>/dev/null || true
  tmux -S "$SOCK" kill-server >/dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap cleanup EXIT
mkdir -p "$WORK/t" "$WORK/cfg" "$WORK/bin" "$WORK/home/.config"
cat >"$WORK/bin/claude" <<'STUB'
#!/bin/sh
if [ "${1:-}" = --version ]; then
  printf '%s\n' "2.1.400 (Claude Code)"
  exit 0
fi
name=""
prev=""
for a in "$@"; do
  if [ "$prev" = -n ]; then
    name="$a"
  fi
  prev="$a"
done
{
  for a in "$@"; do
    printf '%s\037' "$a"
  done
  printf '\n'
} >>"$TEST_ROOM_LOG"
printf '\033]2;%s\033\\' "$name"
exec sleep 600
STUB
chmod +x "$WORK/bin/claude"
export CLAUDE_CONFIG_DIR="$WORK/cfg" TMUX_TMPDIR="$WORK/t" PATH="$WORK/bin:$PATH" HOME="$WORK/home" \
  XDG_CONFIG_HOME="$WORK/home/.config" MATRIX_UP_WAIT=20 TEST_ROOM_LOG="$WORK/argv"
SESSION=TestRoom
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
    sed 's/^/      /' "$WORK/out" >&2
  fi
}

run() {
  local rc=0
  "$MATRIX" "$@" >"$WORK/out" 2>&1 || rc=$?
  printf '%s' "$rc"
}

said() {
  grep -q -- "$1" "$WORK/out"
}

user_conf() {
  printf '%s\n' "$@" >"$WORK/home/.tmux.conf"
}

fresh() {
  exec 3>&- 2>/dev/null || true
  tmux -S "$SOCK" kill-server >/dev/null 2>&1 || true
  : >"$TEST_ROOM_LOG"
  user_conf "$@"
}

room_up() {
  [ "$rc" -eq 0 ] && [ "$(tmux -S "$SOCK" list-panes -s -t "=$SESSION" -F '#{pane_dead}' 2>/dev/null | grep -c '^0$')" -eq 7 ]
}

room_gone() {
  ! tmux -S "$SOCK" has-session -t "=$SESSION" 2>/dev/null
}

down_stops_it() {
  [ "$(run down -p "$SESSION")" -eq 0 ] && room_gone
}

failed_saying() {
  [ "$rc" -ne 0 ] && said "$1"
}

no_server() {
  ! tmux -S "$SOCK" list-sessions >/dev/null 2>&1
}

attach_control_client() {
  tmux -S "$SOCK" -f "$WORK/home/.tmux.conf" new-session -d -s keep -x 80 -y 24 "sleep 600"
  mkfifo "$WORK/ctl"
  tmux -S "$SOCK" -C attach -t =keep <"$WORK/ctl" >/dev/null 2>&1 &
  exec 3>"$WORK/ctl"
  local i
  for ((i = 0; i < 50; i++)); do
    if [ -n "$(tmux -S "$SOCK" list-clients 2>/dev/null)" ]; then
      return 0
    fi
    sleep 0.1
  done
  return 1
}

fresh
rc="$(run up -p "$SESSION")"
holds "with no setting of the user's, up builds the room of seven" room_up
holds "down stops it" down_stops_it

fresh 'set -g destroy-unattached on'
rc="$(run up -p "$SESSION")"
holds "under destroy-unattached on, up keeps its own session and builds the room" room_up
holds "the room's session has destroy-unattached off, and the user's global setting is left on" \
  [ "$(tmux -S "$SOCK" show-options -t "=$SESSION:" -v destroy-unattached 2>/dev/null)/$(tmux -S "$SOCK" show-options -gv destroy-unattached 2>/dev/null)" = off/on ]
holds "down stops it" down_stops_it

fresh 'set -g exit-unattached on'
rc="$(run up -p "$SESSION")"
holds "under exit-unattached on with no client attached, up fails and names exit-unattached" failed_saying "exit-unattached on"
holds "and no tmux server is left running" no_server

fresh 'set -g exit-unattached off'
holds "a control-mode client attaches to a private server" attach_control_client
tmux -S "$SOCK" set-option -s exit-unattached on
rc="$(run doctor)"
holds "doctor names exit-unattached on in a step line while the server runs with it" said "^step  the running tmux server stops when no client is attached (exit-unattached on)"
rc="$(run up -p "$SESSION")"
holds "with a client attached, up builds the room under exit-unattached on" room_up
holds "down stops it" down_stops_it

if [ "$FAILS" -gt 0 ]; then
  printf '%s\n' "$FAILS check(s) failed"
  exit 1
fi
printf '%s\n' "every check held"
