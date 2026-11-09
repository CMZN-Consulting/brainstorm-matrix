#!/usr/bin/env bash
set -euo pipefail

if [ -z "${BASH_VERSINFO[0]:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  printf '%s\n' "matrix: bash 4 or later is required, and this is bash ${BASH_VERSION:-unknown}; on macOS install a newer bash and run the script with it" >&2
  exit 1
fi
shopt -s inherit_errexit 2>/dev/null || true

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
NAMES=(ada babbage curie dirac euler feynman gauss hopper ising jacobi kolmogorov lamport mandelbrot
  noether ostrom pascal quetelet ramanujan shannon turing ulam volterra wiener xenakis yau zermelo)
LADDER=(L0 R0 L1 R1 L2 R2)
SPARK=(L0 R0)
ROW_EFFORT=(xhigh high medium)
VISIONARY_EFFORT=xhigh
CHECK_ROW=2
CLI_MIN=2.1.236
CLI_MIN_WHY='2.1.236 added notify_when_idle to cross-session SendMessage, which the Visionary subscribes with (CHANGELOG.md of anthropics/claude-code, section 2.1.236)'
TRUST_TEXT='trust this folder'
TITLE_SWITCH=CLAUDE_CODE_DISABLE_TERMINAL_TITLE
CLAUDE_BIN=""
CLI_VER=""

usage() {
  cat <<'EOF'
matrix.sh — the Visionary's tool for the brainstorm matrix, run from the repo root (bash 4 or later)

A matrix's sessions are named "PREFIX Visionary" and "PREFIX Analyst (SEAT)": SEAT is a placement
and a row (L0, R0, L1, R1, L2, R2), and PREFIX names the matrix, or is left out. Without -p,
status and wait take the prefix from the calling Visionary's pane title, and outside one they
take the six seats of the ladder. Outside tmux, -p reads the session up made for PREFIX.
Every failure prints its reason and exits non-zero.

  doctor [-p PREFIX]               one line per check, non-zero exit when one fails: tmux, bash 4,
                                   the claude CLI at 2.1.236 or later, pane titles not switched off,
                                   whether Claude Code trusts this folder (read, never written;
                                   a "step" line says what to do), the matrix's pane titles
                                   unique, the cross-session socket directory while sessions run
  up [-p PREFIX] [--spark] [--model MODEL] [--permission-mode MODE] [--no-web] [--brief PATH]
                                   a new detached tmux session named PREFIX (or matrix): window
                                   Visionary, window Analysts with the six seats in three rows of
                                   two (--spark: row 0 only); each pane starts claude named for its
                                   seat, at its row's effort, in one permission mode (default auto),
                                   with its skill as the first prompt; the analysts start first and
                                   the Visionary last, and --brief adds "The brief is at PATH." to
                                   the Visionary's first prompt; --no-web starts every seat
                                   without web tools, MCP servers or the Chrome integration. When a
                                   pane asks something only a person can answer, up prints the step
                                   and waits MATRIX_UP_WAIT seconds (default 600); if it is not
                                   answered, up stops the session and exits non-zero
  roster [-p PREFIX]               the panes of this tmux session: id, window.pane, title;
                                   with PREFIX, only that matrix's
  peek SEAT [LINES]                the last LINES (default 40) of that seat's pane, in the
                                   caller's own matrix; from a Visionary's pane only
  new SLUG                         make the next storm directory; prints its codename and path
  status [-p PREFIX] STORM_DIR     every round's sheets: sealed, draft, blocked or missing,
                                   with word counts
  wait [-p PREFIX] ROUND_DIR [SEAT ...]
                                   block until those seats' sheets are sealed, or one is blocked,
                                   or MATRIX_WAIT_MINUTES (default 90) pass; run it in the
                                   background. The default is rows 0 and 1, and row 2 as well
                                   once the round holds check.md
EOF
}

die() {
  printf '%s\n' "matrix: $*" >&2
  exit 1
}

SESSION=""

resolve_session() {
  if [ -n "${TMUX_PANE:-}" ]; then
    SESSION="$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}')" ||
      die "tmux cannot name the session of pane $TMUX_PANE"
  elif [ -n "${1:-}" ]; then
    SESSION="$1"
  else
    die "not inside tmux: run this from a pane of the matrix's tmux session"
  fi
  [ -n "$SESSION" ] || die "tmux names no session for pane ${TMUX_PANE:-none}"
}

panes() {
  [ -n "$SESSION" ] || die "no tmux session is resolved"
  tmux list-panes -s -t "=$SESSION" -F '#{pane_id}	#{window_index}.#{pane_index}	#{pane_title}' ||
    die "tmux cannot list the panes of session $SESSION"
}

bare() {
  local t="$1"
  printf '%s' "${t#"${t%%[[:alnum:]]*}"}"
}

own_prefix() {
  local raw t
  [ -n "${TMUX_PANE:-}" ] || return 1
  raw="$(tmux display-message -p -t "$TMUX_PANE" '#{pane_title}')" || die "tmux cannot read the title of pane $TMUX_PANE"
  t="$(bare "$raw")"
  [[ "$t" =~ ^(.+\ )?Visionary$ ]] || return 1
  printf '%s' "${BASH_REMATCH[1]% }"
}

analyst_stem() {
  printf '%s' "${1:+$1 }Analyst ("
}

seat_name() {
  if [ "$2" = V ]; then
    printf '%s' "${1:+$1 }Visionary"
  else
    printf '%s' "${1:+$1 }Analyst ($2)"
  fi
}

in_list() {
  local want="$1" x
  shift
  for x in "$@"; do
    if [ "$x" = "$want" ]; then
      return 0
    fi
  done
  return 1
}

is_matrix_title() {
  local t="$1" prefix="$2" have="$3" stem
  if [ "$have" -eq 1 ]; then
    stem="$(analyst_stem "$prefix")"
    if [ "$t" = "$(seat_name "$prefix" V)" ]; then
      return 0
    fi
    [[ "$t" == "$stem"* && "${t#"$stem"}" =~ ^[LR][0-9]+\)$ ]]
    return
  fi
  [[ "$t" =~ ^(.+\ )?(Visionary|Analyst\ \([LR][0-9]+\))$ ]]
}

prefix_session() {
  if [ -z "${TMUX_PANE:-}" ] && [ "$HAVE_PREFIX" -eq 1 ]; then
    room_session
  fi
}

roster() {
  local id at title
  [ "$#" -eq 0 ] || die "roster takes nothing but -p PREFIX"
  resolve_session "$(prefix_session)"
  if [ "$HAVE_PREFIX" -eq 0 ]; then
    panes
    return 0
  fi
  panes | while IFS=$'\t' read -r id at title; do
    if is_matrix_title "$(bare "$title")" "$PREFIX" 1; then
      printf '%s\t%s\t%s\n' "$id" "$at" "$title"
    fi
  done
}

roster_seats() {
  local stem title t rest
  stem="$(analyst_stem "$1")"
  panes | while IFS=$'\t' read -r _ _ title; do
    t="$(bare "$title")"
    rest="${t#"$stem"}"
    if [[ "$t" == "$stem"* && "$rest" =~ ^([LR][0-9]+)\)$ ]]; then
      printf '%s\n' "${BASH_REMATCH[1]}"
    fi
  done | sort -u -k1.2n -k1.1,1.1
}

SEATS=()

load_seats() {
  local prefix list
  if [ -n "${TMUX_PANE:-}" ]; then
    resolve_session
  fi
  if [ "$HAVE_PREFIX" -eq 1 ]; then
    prefix="$PREFIX"
  elif prefix="$(own_prefix)"; then
    :
  else
    SEATS=("${LADDER[@]}")
    return 0
  fi
  resolve_session "$(prefix_session)"
  list="$(roster_seats "$prefix")"
  [ -n "$list" ] || die "no analyst panes for the prefix '$prefix' in session $SESSION"
  mapfile -t SEATS <<<"$list"
}

seat_pane() {
  local want found count
  want="$(seat_name "$1" "$2")"
  found="$(panes | while IFS=$'\t' read -r id _ title; do
    if [ "$(bare "$title")" = "$want" ]; then
      printf '%s\n' "$id"
    fi
  done)"
  count="$(printf '%s' "$found" | grep -c . || true)"
  [ "$count" -eq 1 ] || die "expected one pane titled '$want' in session $SESSION, found $count"
  printf '%s\n' "$found"
}

peek() {
  local seat="${1:-}" lines="${2:-40}" prefix pane
  [ "$#" -le 2 ] || die "peek takes SEAT and LINES"
  [ -n "${TMUX_PANE:-}" ] || die "peek runs only from a Visionary's pane, and this is not a tmux pane"
  resolve_session
  prefix="$(own_prefix)" || die "peek runs only from a Visionary's pane"
  [[ "$seat" =~ ^[LR][0-9]+$ ]] || die "SEAT is a placement and a row, such as L0 or R2"
  [[ "$lines" =~ ^[0-9]+$ ]] || die "LINES is a number"
  pane="$(seat_pane "$prefix" "$seat")"
  tmux capture-pane -p -J -S "-$lines" -t "$pane" |
    awk '{ sub(/[ \t]+$/, ""); line[NR] = $0 } NF { last = NR } END { for (i = 1; i <= last; i++) print line[i] }' |
    tail -n "$lines"
}

new_storm() {
  local slug="${1:-}" entries entry base last num idx cycle name dir
  [ "$#" -le 1 ] || die "new takes one SLUG"
  [[ "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "SLUG is lowercase words joined by hyphens"
  mkdir -p "$ROOT/storms" || die "cannot make $ROOT/storms"
  entries="$(find "$ROOT/storms" -mindepth 1 -maxdepth 1 -type d)" || die "cannot list $ROOT/storms"
  last=0
  while IFS= read -r entry; do
    base="${entry##*/}"
    if [[ "$base" =~ ^([0-9]+)- ]] && [ "$((10#${BASH_REMATCH[1]}))" -gt "$last" ]; then
      last="$((10#${BASH_REMATCH[1]}))"
    fi
  done <<<"$entries"
  num=$((last + 1))
  idx=$(((num - 1) % ${#NAMES[@]}))
  cycle=$(((num - 1) / ${#NAMES[@]} + 1))
  name="${NAMES[$idx]}"
  if [ "$cycle" -gt 1 ]; then
    name="$name$cycle"
  fi
  dir="$ROOT/storms/$(printf '%02d' "$num")-$name-$slug"
  [ ! -e "$dir" ] || die "$dir exists"
  mkdir "$dir" || die "cannot make $dir"
  printf '%s\t%s\n' "${name^}" "$dir"
}

field() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    $1 == key ":" { $1 = ""; sub(/^ +/, ""); print; exit }
  ' "$1"
}

status() {
  local storm="${1:-}" round seat sheet state words entries entry base rounds=0
  local -a list
  [ "$#" -le 1 ] || die "status takes one STORM_DIR"
  [ -n "$storm" ] || die "status takes a STORM_DIR"
  [ -d "$storm" ] || die "no storm directory: $storm"
  load_seats
  for round in "$storm"/r[0-9]*/; do
    [ -d "$round" ] || continue
    rounds=$((rounds + 1))
    if [ -f "${round}check.md" ]; then
      printf '%s  %s\n' "$(basename "$round")" "(check.md)"
    else
      printf '%s\n' "$(basename "$round")"
    fi
    list=("${SEATS[@]}")
    entries="$(find "$round" -mindepth 1 -maxdepth 1 -type f -name 'analyst-*.md')" || die "cannot list $round"
    entries="$(printf '%s\n' "$entries" | sort)"
    while IFS= read -r entry; do
      base="${entry##*/}"
      if [[ "$base" =~ ^analyst-([^-]+)\.md$ ]] && ! in_list "${BASH_REMATCH[1]}" "${list[@]}"; then
        list+=("${BASH_REMATCH[1]}")
      fi
    done <<<"$entries"
    for seat in "${list[@]}"; do
      sheet="${round}analyst-$seat.md"
      if [ -f "$sheet" ]; then
        state="$(field "$sheet" status)"
        words="$(wc -w <"$sheet")"
        printf '  %-3s %-8s %6s %s\n' "$seat" "${state:-draft}" "${words//[[:space:]]/}" "words"
      else
        printf '  %-3s %s\n' "$seat" "missing"
      fi
    done
  done
  if [ "$rounds" -eq 0 ]; then
    printf '%s\n' "no round directory (r1, r2, ...) in $storm yet"
  fi
}

wait_round() {
  local round="${1:-}" minutes="${MATRIX_WAIT_MINUTES:-90}" deadline seat state sealed blocked
  local -a who
  [ -n "$round" ] || die "wait takes a ROUND_DIR"
  [ -d "$round" ] || die "no round directory: $round"
  [[ "$minutes" =~ ^[0-9]+$ ]] || die "MATRIX_WAIT_MINUTES is a number"
  shift
  who=("$@")
  if [ "${#who[@]}" -eq 0 ]; then
    load_seats
    for seat in "${SEATS[@]}"; do
      if [ "${seat:1}" != "$CHECK_ROW" ] || [ -f "$round/check.md" ]; then
        who+=("$seat")
      fi
    done
  fi
  [ "${#who[@]}" -gt 0 ] || die "no seats to wait for"
  for seat in "${who[@]}"; do
    [[ "$seat" =~ ^[LR][0-9]+$ ]] || die "a SEAT is a placement and a row, such as L0 or R2"
  done
  deadline=$(($(date +%s) + minutes * 60))
  while :; do
    sealed=0
    blocked=""
    for seat in "${who[@]}"; do
      state=""
      if [ -f "$round/analyst-$seat.md" ]; then
        state="$(field "$round/analyst-$seat.md" status)"
      fi
      case "$state" in
        sealed) sealed=$((sealed + 1)) ;;
        blocked) blocked="$blocked $seat" ;;
      esac
    done
    if [ -n "$blocked" ]; then
      printf '%s\n' "blocked:$blocked; $sealed of ${#who[@]} sealed"
      return 0
    fi
    if [ "$sealed" -eq "${#who[@]}" ]; then
      printf '%s\n' "sealed: all $sealed (${who[*]})"
      return 0
    fi
    if [ "$(date +%s)" -ge "$deadline" ]; then
      printf '%s\n' "timeout after $minutes min; $sealed of ${#who[@]} sealed"
      return 0
    fi
    sleep 20
  done
}

version_at_least() {
  local have="$1" want="$2" i a b
  local -a h w
  IFS=. read -r -a h <<<"$have"
  IFS=. read -r -a w <<<"$want"
  for i in 0 1 2; do
    a="${h[$i]:-0}"
    b="${w[$i]:-0}"
    a="${a%%[!0-9]*}"
    b="${b%%[!0-9]*}"
    if [ "$((10#${a:-0}))" -gt "$((10#${b:-0}))" ]; then
      return 0
    fi
    if [ "$((10#${a:-0}))" -lt "$((10#${b:-0}))" ]; then
      return 1
    fi
  done
  return 0
}

cli_version() {
  local out
  CLI_VER=""
  CLAUDE_BIN="$(command -v claude)" || return 1
  case "$CLAUDE_BIN" in
    /*) ;;
    *) CLAUDE_BIN="$(cd "$(dirname "$CLAUDE_BIN")" && pwd)/$(basename "$CLAUDE_BIN")" ;;
  esac
  out="$("$CLAUDE_BIN" --version 2>/dev/null)" || return 1
  out="${out%% *}"
  [[ "$out" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]] || return 1
  CLI_VER="$out"
}

FAILS=0

report() {
  printf '%-5s %s\n' "$1" "$2"
  if [ "$1" = FAIL ]; then
    FAILS=$((FAILS + 1))
  fi
}

room_session() {
  local s="${PREFIX:-matrix}"
  printf '%s' "${s//[.:]/-}"
}

title_session() {
  if [ "$HAVE_PREFIX" -eq 1 ] && tmux has-session -t "=$(room_session)" 2>/dev/null; then
    SESSION="$(room_session)"
    return 0
  fi
  if [ -n "${TMUX_PANE:-}" ]; then
    if SESSION="$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)" && [ -n "$SESSION" ]; then
      return 0
    fi
    report FAIL "pane titles: tmux cannot name the session of pane $TMUX_PANE"
    return 2
  fi
  if tmux has-session -t "=$(room_session)" 2>/dev/null; then
    SESSION="$(room_session)"
    return 0
  fi
  return 1
}

check_titles() {
  local titles dups count
  if ! titles="$(panes | cut -f3 | while IFS= read -r t; do
    t="$(bare "$t")"
    if is_matrix_title "$t" "$PREFIX" "$HAVE_PREFIX"; then
      printf '%s\n' "$t"
    fi
  done)"; then
    report FAIL "pane titles: tmux cannot list the panes of session $SESSION"
    return 0
  fi
  count="$(printf '%s' "$titles" | grep -c . || true)"
  dups="$(printf '%s\n' "$titles" | grep . | sort | uniq -d | paste -sd, - || true)"
  if [ -n "$dups" ]; then
    report FAIL "pane titles in session $SESSION repeat: $dups; matrix.sh finds a seat by its title, so each must be unique"
  elif [ "$count" -eq 0 ] && [ "$HAVE_PREFIX" -eq 1 ]; then
    report FAIL "no pane in session $SESSION is titled for the matrix '$PREFIX'"
  elif [ "$count" -eq 0 ]; then
    report skip "no matrix pane titles in session $SESSION"
  else
    report ok "$count matrix pane titles in session $SESSION, none repeated"
  fi
}

socket_dir() {
  local dir
  local -a dirs=()
  if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    dirs+=("$XDG_RUNTIME_DIR/cc-socks")
  fi
  dirs+=("${CLAUDE_CODE_TMPDIR:-${TMPDIR:-/tmp}}/cc-socks" "/tmp/cc-socks-$(id -u)")
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ] && [ -n "$(find "$dir" -mindepth 1 -maxdepth 1 -name '*.sock' 2>/dev/null)" ]; then
      printf '%s' "$dir"
      return 0
    fi
  done
  return 1
}

title_switch() {
  local g
  if [ -n "${!TITLE_SWITCH:-}" ]; then
    printf '%s' "this shell"
    return 0
  fi
  g="$(tmux show-environment -g "$TITLE_SWITCH" 2>/dev/null || true)"
  if [ -n "$g" ] && [ "${g#-}" = "$g" ]; then
    printf '%s' "tmux's global environment"
    return 0
  fi
  return 1
}

trust_state() {
  local cfg found=""
  for cfg in "${CLAUDE_CONFIG_DIR:+$CLAUDE_CONFIG_DIR/.claude.json}" "$HOME/.claude.json"; do
    if [ -n "$cfg" ] && [ -r "$cfg" ]; then
      found="$cfg"
      break
    fi
  done
  [ -n "$found" ] || return 2
  command -v python3 >/dev/null 2>&1 || return 2
  python3 -I -c '
import json, os, sys
projects = json.load(open(sys.argv[1], encoding="utf-8")).get("projects") or {}
path = sys.argv[2]
while True:
    entry = projects.get(path)
    if isinstance(entry, dict) and entry.get("hasTrustDialogAccepted") is True:
        print(path)
        sys.exit(0)
    parent = os.path.dirname(path)
    if parent == path:
        sys.exit(1)
    path = parent
' "$found" "$ROOT" 2>/dev/null
}

doctor() {
  local dir t where rc by
  FAILS=0
  [ "$#" -eq 0 ] || die "doctor takes nothing but -p PREFIX"
  if ! command -v tmux >/dev/null 2>&1; then
    report FAIL "tmux is not on PATH"
  elif t="$(tmux -V 2>&1)" && [ -n "$t" ]; then
    report ok "$t"
  else
    report FAIL "tmux -V failed: $t"
  fi
  report ok "bash $BASH_VERSION (4 or later)"
  if ! command -v claude >/dev/null 2>&1; then
    report FAIL "the claude CLI is not on PATH"
  elif ! cli_version; then
    report FAIL "claude --version printed no version"
  elif version_at_least "$CLI_VER" "$CLI_MIN"; then
    report ok "claude $CLI_VER at $CLAUDE_BIN (at least $CLI_MIN: $CLI_MIN_WHY)"
  else
    report FAIL "claude $CLI_VER at $CLAUDE_BIN is older than $CLI_MIN: $CLI_MIN_WHY"
  fi
  if where="$(title_switch)"; then
    report FAIL "$TITLE_SWITCH is set in $where, so Claude Code sets no pane title and matrix.sh finds no seat"
  else
    report ok "$TITLE_SWITCH is not set, so Claude Code titles each pane with its session name"
  fi
  rc=0
  by="$(trust_state)" || rc=$?
  case "$rc" in
    0)
      if [ "$by" = "$ROOT" ]; then
        report ok "Claude Code trusts $ROOT"
      else
        report ok "Claude Code trusts $ROOT through $by"
      fi
      ;;
    1) report step "Claude Code does not trust $ROOT yet: run claude there once and answer its trust question before up" ;;
    *) report step "the trust of $ROOT cannot be read here: run claude there once and answer its trust question before up, unless you have" ;;
  esac
  rc=0
  if ! command -v tmux >/dev/null 2>&1; then
    report skip "pane titles: no tmux"
  else
    title_session || rc=$?
    case "$rc" in
      0) check_titles ;;
      1) report skip "pane titles: not inside tmux, and no session named $(room_session) is running" ;;
    esac
  fi
  if ! pgrep -u "$(id -u)" -x claude >/dev/null 2>&1; then
    report skip "cross-session socket directory: no claude session of this user is running"
  elif [ "$(uname -s)" != Linux ]; then
    report skip "cross-session socket directory: unchecked on $(uname -s); /status in a session names it"
  elif dir="$(socket_dir)"; then
    report ok "cross-session socket directory $dir"
  else
    report FAIL "claude sessions run but no cross-session socket directory holds a socket; /status in a session names the directory it tried"
  fi
  if [ "$FAILS" -gt 0 ]; then
    printf '%s\n' "$FAILS check(s) failed"
    return 1
  fi
  return 0
}

UP_MODEL=""
UP_BRIEF=""
UP_MODE=auto
UP_NOWEB=0
UP_SESSION=""

seat_command() {
  local -a argv
  argv=("$CLAUDE_BIN" -n "$1" --effort "$2" --permission-mode "$UP_MODE")
  if [ -n "$UP_MODEL" ]; then
    argv+=(--model "$UP_MODEL")
  fi
  if [ "$UP_NOWEB" -eq 1 ]; then
    argv+=(--disallowedTools=WebSearch,WebFetch --strict-mcp-config --no-chrome)
  fi
  argv+=("$3")
  printf '%q ' "${argv[@]}"
}

quoted_session() {
  printf '%q' "$UP_SESSION"
}

attach_hint() {
  if [ -n "${TMUX:-}" ]; then
    printf '%s' "tmux switch-client -t $(quoted_session)"
  else
    printf '%s' "tmux attach -t $(quoted_session)"
  fi
}

stop_room() {
  trap - INT TERM HUP
  tmux kill-session -t "=$UP_SESSION" 2>/dev/null || true
  die "$1; up stopped the session $(quoted_session), so no partial room is left"
}

wait_ready() {
  local pane="$1" want="$2" limit="${MATRIX_UP_WAIT:-600}" start elapsed dead title screen said_trust=0 said_other=0
  start="$(date +%s)"
  while :; do
    elapsed=$(($(date +%s) - start))
    dead="$(tmux display-message -p -t "$pane" '#{pane_dead}' 2>/dev/null)" || stop_room "pane $pane of '$want' is gone"
    if [ "$dead" = 1 ]; then
      tmux capture-pane -p -t "$pane" | grep . | tail -n 15 >&2 || true
      stop_room "'$want' exited in pane $pane before its prompt came up; its last lines are above"
    fi
    title="$(bare "$(tmux display-message -p -t "$pane" '#{pane_title}')")"
    if [ "$title" = "$want" ]; then
      return 0
    fi
    screen="$(tmux capture-pane -p -t "$pane")"
    if [[ "$screen" == *"$TRUST_TEXT"* ]]; then
      if [ "$said_trust" -eq 0 ]; then
        printf '%s\n' "up: Claude Code asks in pane $pane ('$want') whether you trust $ROOT. Answer it there ($(attach_hint)); up waits up to $limit seconds, then stops the room."
        said_trust=1
      fi
    elif [ "$elapsed" -ge 60 ] && [ "$said_other" -eq 0 ]; then
      printf '%s\n' "up: pane $pane ('$want') has not taken its title after 60 seconds; it shows:"
      printf '%s\n' "$screen" | grep . | tail -n 15 || true
      printf '%s\n' "up: if it asks something, answer it there ($(attach_hint)); if it shows its prompt, Claude Code is not setting the pane title ($TITLE_SWITCH set, or terminalTitleFromRename false in its settings). up waits up to $limit seconds, then stops the room."
      said_other=1
    fi
    if [ "$elapsed" -ge "$limit" ]; then
      stop_room "pane $pane ('$want') did not reach its prompt within $limit seconds"
    fi
    sleep 1
  done
}

start_seat() {
  local pane="$1" seat="$2" effort skill
  if [ "$seat" = V ]; then
    effort="$VISIONARY_EFFORT"
    skill="/visionary${UP_BRIEF:+ The brief is at $UP_BRIEF.}"
  else
    effort="${ROW_EFFORT[${seat:1}]}"
    skill=/analyst
  fi
  tmux respawn-pane -k -t "$pane" "$(seat_command "$(seat_name "$PREFIX" "$seat")" "$effort" "$skill")" ||
    stop_room "tmux cannot start seat $seat in pane $pane"
}

split_off() {
  tmux split-window -d "$1" -P -F '#{pane_id}' -t "$2" -c "$ROOT" || stop_room "tmux cannot split pane $2"
}

up() {
  local spark=0 vis a b c d e f i count where dead
  local -a order panes_of
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -p)
        [ "$#" -ge 2 ] || die "-p takes a PREFIX"
        PREFIX="$2"
        HAVE_PREFIX=1
        shift
        ;;
      --spark) spark=1 ;;
      --no-web) UP_NOWEB=1 ;;
      --brief)
        [ "$#" -ge 2 ] || die "--brief takes a PATH"
        UP_BRIEF="$2"
        shift
        ;;
      --model)
        [ "$#" -ge 2 ] || die "--model takes a MODEL"
        UP_MODEL="$2"
        shift
        ;;
      --permission-mode)
        [ "$#" -ge 2 ] || die "--permission-mode takes a MODE"
        UP_MODE="$2"
        shift
        ;;
      *) die "up takes -p PREFIX, --spark, --model MODEL, --permission-mode MODE, --no-web and --brief PATH, not '$1'" ;;
    esac
    shift
  done
  if [ -n "$PREFIX" ] && ! [[ "$PREFIX" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*(\ [A-Za-z0-9_-]+)*$ ]]; then
    die "PREFIX is letters, digits, hyphens and underscores, in words separated by single spaces"
  fi
  [[ "${MATRIX_UP_WAIT:-600}" =~ ^[0-9]+$ ]] || die "MATRIX_UP_WAIT is a number of seconds"
  if [ -n "$UP_BRIEF" ]; then
    case "$UP_BRIEF" in
      /*) [ -f "$UP_BRIEF" ] || die "no brief at $UP_BRIEF" ;;
      *) [ -f "$ROOT/$UP_BRIEF" ] || die "no brief at $UP_BRIEF under $ROOT" ;;
    esac
    [[ "$UP_BRIEF" =~ ^[A-Za-z0-9_./-]+$ ]] || die "the brief's path is letters, digits, dots, hyphens, underscores and slashes"
  fi
  command -v tmux >/dev/null 2>&1 || die "tmux is not on PATH"
  command -v claude >/dev/null 2>&1 || die "the claude CLI is not on PATH"
  cli_version || die "claude --version printed no version"
  version_at_least "$CLI_VER" "$CLI_MIN" || die "claude $CLI_VER at $CLAUDE_BIN is older than $CLI_MIN: $CLI_MIN_WHY"
  if where="$(title_switch)"; then
    die "$TITLE_SWITCH is set in $where, so Claude Code would set no pane title and matrix.sh would find no seat"
  fi
  UP_SESSION="$(room_session)"
  if tmux has-session -t "=$UP_SESSION" 2>/dev/null; then
    die "a tmux session named $UP_SESSION is running; stop it (tmux kill-session -t $(quoted_session)) or choose another -p PREFIX"
  fi
  vis="$(tmux new-session -d -P -F '#{pane_id}' -s "$UP_SESSION" -n Visionary -x 200 -y 50 -c "$ROOT")" ||
    die "tmux cannot start a session named $UP_SESSION"
  trap 'stop_room "up was interrupted"' INT TERM HUP
  tmux set-window-option -t "$vis" remain-on-exit on >/dev/null || stop_room "tmux cannot keep exited panes in view"
  tmux set-window-option -t "$vis" allow-set-title on >/dev/null 2>&1 || true
  a="$(tmux new-window -d -P -F '#{pane_id}' -t "=$UP_SESSION:" -n Analysts -c "$ROOT")" ||
    stop_room "tmux cannot open the Analysts window"
  tmux set-window-option -t "$a" remain-on-exit on >/dev/null || stop_room "tmux cannot keep exited panes in view"
  tmux set-window-option -t "$a" allow-set-title on >/dev/null 2>&1 || true
  if [ "$spark" -eq 1 ]; then
    b="$(split_off -h "$a")"
    order=("${SPARK[@]}")
    panes_of=("$a" "$b")
  else
    c="$(split_off -v "$a")"
    e="$(split_off -v "$c")"
    tmux select-layout -t "$a" even-vertical >/dev/null || stop_room "tmux cannot lay out the Analysts window"
    b="$(split_off -h "$a")"
    d="$(split_off -h "$c")"
    f="$(split_off -h "$e")"
    order=("${LADDER[@]}")
    panes_of=("$a" "$b" "$c" "$d" "$e" "$f")
  fi
  count="${#order[@]}"
  start_seat "${panes_of[0]}" "${order[0]}"
  wait_ready "${panes_of[0]}" "$(seat_name "$PREFIX" "${order[0]}")"
  for ((i = 1; i < count; i++)); do
    start_seat "${panes_of[$i]}" "${order[$i]}"
  done
  for ((i = 1; i < count; i++)); do
    wait_ready "${panes_of[$i]}" "$(seat_name "$PREFIX" "${order[$i]}")"
  done
  if [ -n "$UP_BRIEF" ]; then
    printf '%s\n' "up: the Visionary starts at $(date -u +%Y-%m-%dT%H:%M:%SZ) with the brief $UP_BRIEF in its first prompt"
  fi
  start_seat "$vis" V
  wait_ready "$vis" "$(seat_name "$PREFIX" V)"
  SESSION="$UP_SESSION"
  HAVE_PREFIX=1
  FAILS=0
  check_titles
  [ "$FAILS" -eq 0 ] || stop_room "the room's pane titles do not hold"
  dead="$(tmux list-panes -s -t "=$UP_SESSION" -F '#{pane_dead}')" || stop_room "tmux cannot list the room's panes"
  if [[ "$dead" == *1* ]]; then
    stop_room "a seat exited after it took its title"
  fi
  trap - INT TERM HUP
  panes
  printf '%s\n' "up: the room is up in tmux session $UP_SESSION ($CLAUDE_BIN $CLI_VER, mode $UP_MODE${UP_MODEL:+, model $UP_MODEL}); attach with: $(attach_hint)"
}

PREFIX=""
HAVE_PREFIX=0
cmd="${1:-help}"
shift || true
case "$cmd" in
  roster | status | wait | doctor | up)
    if [ "${1:-}" = "-p" ]; then
      [ "$#" -ge 2 ] || die "-p takes a PREFIX"
      PREFIX="$2"
      HAVE_PREFIX=1
      shift 2
    fi
    ;;
esac
case "$cmd" in
  doctor) doctor "$@" ;;
  up) up "$@" ;;
  roster) roster "$@" ;;
  peek) peek "$@" ;;
  new) new_storm "$@" ;;
  status) status "$@" ;;
  wait) wait_round "$@" ;;
  help | -h | --help) usage ;;
  *)
    usage >&2
    exit 2
    ;;
esac
