#!/usr/bin/env bash
set -euo pipefail

if [ -z "${BASH_VERSINFO[0]:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  printf '%s\n' "matrix: bash 4 or later is required, and this is bash ${BASH_VERSION:-unknown}; on macOS install a newer bash and run the script with it" >&2
  exit 1
fi
shopt -s inherit_errexit 2>/dev/null || true

ROOT="$(CDPATH='' cd -- "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
NAMES=(ada babbage curie dirac euler feynman gauss hopper ising jacobi kolmogorov lamport mandelbrot
  noether ostrom pascal quetelet ramanujan shannon turing ulam volterra wiener xenakis yau zermelo)
LADDER=(L0 R0 L1 R1 L2 R2)
SPARK=(L0 R0)
ROW_EFFORT=(xhigh high medium)
VISIONARY_EFFORT=xhigh
VISIONARY_MODEL=opus
ANALYST_MODEL=sonnet
CHECK_ROW=2
CLI_MIN=2.1.236
CLI_MIN_WHY='2.1.236 added notify_when_idle to cross-session SendMessage, which the Visionary subscribes with (CHANGELOG.md of anthropics/claude-code, section 2.1.236)'
TRUST_TEXT='trust this folder'
TITLE_SWITCH=CLAUDE_CODE_DISABLE_TERMINAL_TITLE
EFFORT_SWITCH=CLAUDE_CODE_EFFORT_LEVEL
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
                                   CLAUDE_CODE_EFFORT_LEVEL unset (a "step" line names it when set),
                                   a running tmux server that stops when no client is attached
                                   (a "step" line when exit-unattached is on),
                                   whether Claude Code trusts this folder (read, never written;
                                   a "step" line says what to do), the matrix's pane titles
                                   unique, the cross-session socket directory while sessions run,
                                   and this folder's Claude Code project memory empty
  up [-p PREFIX] [--spark] [--model MODEL] [--permission-mode MODE] [--no-web] [--brief PATH]
     [--director NAME]
                                   a new detached tmux session named PREFIX (or matrix): window
                                   Visionary, window Analysts with the six seats in three rows of
                                   two (--spark: row 0 only); each pane starts claude named for its
                                   seat, the Visionary on opus at xhigh and the analysts on sonnet,
                                   row 0 at xhigh, row 1 at high and row 2 at medium (--model MODEL
                                   puts all seven on MODEL), in one permission mode (default auto),
                                   with its skill as the first prompt; the analysts start first and
                                   the Visionary last; --brief adds "The brief is at PATH." to the
                                   Visionary's first prompt, and --director adds "The directing
                                   session is NAME." after it, NAME written as PREFIX is, for the
                                   session that brings the room its briefs; --no-web starts every
                                   seat without web tools, MCP servers or the Chrome integration.
                                   When a pane asks something only a person can answer, up prints
                                   the step and waits MATRIX_UP_WAIT seconds (default 600); if it is
                                   not answered, up stops the session and exits non-zero
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
  check STORM_DIR                  a storm's files against the room's rules, with no session, no
                                   network and no tokens: LEDGER.md has a card table, with Card and
                                   Fate columns, each card on a row of its own, named for its
                                   round, with one fate of four (alive, floor, folded, graveyard);
                                   at most four cards in ten of each round stay alive; every card
                                   headed ### under a Cards or Holds heading of a sheet is in the
                                   ledger; every path:line a card cites, under its ### heading or
                                   on a table row whose first cell is its id (a path with a slash
                                   or an extension; a bare name such as Makefile:40 is not read,
                                   and a name that ends like a host, such as db.local:5432, only
                                   when it is a file) resolves, in the storm, at the commit
                                   GROUND.md pins or in the working tree, to a line in range, and a
                                   quote after it holds within two lines, blanks collapsed; outside
                                   its graveyard SYNTHESIS.md names only cards that survived the
                                   ledger, except in its risks a buried card whose epitaph in the
                                   ledger says its objection is carried as a risk, and a card an
                                   epitaph names after the buried one is a reference; it names no
                                   card the ledger lacks, and no finding of row 2 that no other
                                   file of the storm names; no table of the ledger or the synthesis
                                   cites a line without its path; the synthesis has a cost table
                                   with a Minutes column, a Recommendation and a Dissent. Prints
                                   the ledger's four counts and the memo's head, times itself, and
                                   exits non-zero when a check fails
  down [-p PREFIX] [STORM_DIR]     stops the room's tmux session, then moves every file of this
                                   folder's Claude Code project memory, where a seat's auto-memory
                                   lands, into STORM_DIR/auto-memory/ and leaves it empty; a git
                                   reset does not touch that directory, and up refuses to start
                                   while it holds a file, or while another room of this folder
                                   runs. down stops nothing and moves nothing when STORM_DIR is not
                                   a storm's, or is left out while the memory holds a file; it
                                   moves nothing when the record already holds a file of the same
                                   name, or while another room of this folder runs
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

effort_switch() {
  local g
  if [ -n "${!EFFORT_SWITCH:-}" ]; then
    printf '%s\037%s' "${!EFFORT_SWITCH}" "this shell"
    return 0
  fi
  g="$(tmux show-environment -g "$EFFORT_SWITCH" 2>/dev/null || true)"
  if [ -n "$g" ] && [ "${g#-}" = "$g" ]; then
    printf '%s\037%s' "${g#*=}" "tmux's global environment"
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
  local dir t where rc by mem entries level
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
  if [ "$(tmux show-options -sv exit-unattached 2>/dev/null || true)" = on ]; then
    report step "the running tmux server stops when no client is attached (exit-unattached on), and a room on it stops with it: keep a client attached while the room runs, or set exit-unattached off"
  fi
  if level="$(effort_switch)"; then
    report step "$EFFORT_SWITCH is ${level%%"$CHECK_SEP"*} in ${level#*"$CHECK_SEP"}, and it overrides --effort: every seat would run at that level whatever its row; unset it there for the ladder"
  else
    report ok "$EFFORT_SWITCH is not set, so each seat runs at its row's effort"
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
    *) report step "the trust of $ROOT cannot be read here: run claude there once and answer its trust question before up, unless you already have" ;;
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
  if ! mem="$(memory_dir 2>&1)"; then
    report FAIL "${mem#matrix: }"
  elif ! entries="$(memory_files "$mem" 2>/dev/null)"; then
    report FAIL "this folder's Claude Code project memory $mem cannot be listed"
  elif [ -z "$entries" ]; then
    report ok "this folder's Claude Code project memory is empty ($mem)"
  else
    report FAIL "this folder's Claude Code project memory holds $(wc -l <<<"$entries" | tr -d ' ') file(s) from earlier sessions in this folder ($mem): move them into a storm's record with matrix.sh down STORM_DIR, or aside by hand; up refuses to start until it is empty"
  fi
  if [ "$FAILS" -gt 0 ]; then
    printf '%s\n' "$FAILS check(s) failed"
    return 1
  fi
  return 0
}

UP_MODEL=""
UP_BRIEF=""
UP_DIRECTOR=""
UP_MODE=auto
UP_NOWEB=0
UP_SESSION=""

seat_command() {
  local -a argv
  if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
    argv=(env "CLAUDE_CONFIG_DIR=$CLAUDE_CONFIG_DIR")
  else
    argv=(env -u CLAUDE_CONFIG_DIR)
  fi
  argv+=("$CLAUDE_BIN" -n "$1" --model "$2" --effort "$3" --permission-mode "$UP_MODE")
  if [ "$UP_NOWEB" -eq 1 ]; then
    argv+=(--disallowedTools=WebSearch,WebFetch --strict-mcp-config --no-chrome)
  fi
  argv+=("$4")
  printf '%q ' "${argv[@]}"
}

seat_models() {
  if [ -n "$UP_MODEL" ]; then
    printf '%s' "every seat on $UP_MODEL"
  else
    printf '%s' "the Visionary on $VISIONARY_MODEL and the analysts on $ANALYST_MODEL"
  fi
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
  local pane="$1" seat="$2" model effort skill
  if [ "$seat" = V ]; then
    model="${UP_MODEL:-$VISIONARY_MODEL}"
    effort="$VISIONARY_EFFORT"
    skill="/visionary${UP_BRIEF:+ The brief is at $UP_BRIEF.}${UP_DIRECTOR:+ The directing session is $UP_DIRECTOR.}"
  else
    model="${UP_MODEL:-$ANALYST_MODEL}"
    effort="${ROW_EFFORT[${seat:1}]}"
    skill=/analyst
  fi
  tmux respawn-pane -k -t "$pane" "$(seat_command "$(seat_name "$PREFIX" "$seat")" "$model" "$effort" "$skill")" ||
    stop_room "tmux cannot start seat $seat in pane $pane"
}

session_kept() {
  tmux has-session -t "=$UP_SESSION" 2>/dev/null && return 0
  if tmux list-sessions >/dev/null 2>&1; then
    die "tmux ended the session $(quoted_session) as soon as up made it, and its server runs on: a hook or a setting of that server ends new sessions"
  fi
  die "tmux ended the session $(quoted_session) as soon as up made it: this server stops when no client is attached (exit-unattached on); run up from a pane of a tmux client attached to it, or set exit-unattached off"
}

split_off() {
  tmux split-window -d "$1" -P -F '#{pane_id}' -t "$2" -c "$ROOT" || stop_room "tmux cannot split pane $2"
}

up() {
  local spark=0 vis a b c d e f i count where dead mem entries here
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
      --director)
        [ "$#" -ge 2 ] || die "--director takes a NAME"
        UP_DIRECTOR="$2"
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
      *) die "up takes -p PREFIX, --spark, --model MODEL, --permission-mode MODE, --no-web, --brief PATH and --director NAME, not '$1'" ;;
    esac
    shift
  done
  if [ -n "$PREFIX" ] && ! [[ "$PREFIX" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*(\ [A-Za-z0-9_-]+)*$ ]]; then
    die "PREFIX is letters, digits, hyphens and underscores, in words separated by single spaces"
  fi
  if [ -n "$UP_DIRECTOR" ] && ! [[ "$UP_DIRECTOR" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*(\ [A-Za-z0-9_-]+)*$ ]]; then
    die "the director's NAME is written as PREFIX is: letters, digits, hyphens and underscores, in words separated by single spaces"
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
  mem="$(memory_dir)"
  entries="$(memory_files "$mem")"
  [ -z "$entries" ] || die "this folder's Claude Code project memory holds files from earlier sessions in this folder ($mem): move them into a storm's record with matrix.sh down STORM_DIR, or aside by hand, so that the room starts clean"
  here="$(rooms_here)"
  [ -z "$here" ] || die "a room of this folder already runs in tmux session(s) $here, and a second room's seats would share this folder's Claude Code project memory with it: start the second room from a clone of its own"
  UP_SESSION="$(room_session)"
  if tmux has-session -t "=$UP_SESSION" 2>/dev/null; then
    die "a tmux session named $UP_SESSION is running; stop it (tmux kill-session -t $(quoted_session)) or choose another -p PREFIX"
  fi
  vis="$(tmux new-session -d -P -F '#{pane_id}' -s "$UP_SESSION" -n Visionary -x 200 -y 50 -c "$ROOT" \; set-option -t "=$UP_SESSION:" destroy-unattached off)" ||
    die "tmux cannot start a session named $UP_SESSION"
  session_kept
  trap 'stop_room "up was interrupted"' INT TERM HUP
  tmux set-window-option -t "$vis" remain-on-exit on >/dev/null || { session_kept; stop_room "tmux cannot keep exited panes in view"; }
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
  printf '%s\n' "up: the room is up in tmux session $UP_SESSION ($CLAUDE_BIN $CLI_VER, mode $UP_MODE, $(seat_models)); attach with: $(attach_hint)"
}

CHECK_FAILS=0
CHECK_WORK=""
CHECK_PIN=""
CHECK_PIN_GIT=""
CHECK_STORM=""
CHECK_EN=$'\xe2\x80\x93'
CHECK_EM=$'\xe2\x80\x94'
CHECK_SEP=$'\037'
CHECK_UTF8=""

check_line() {
  printf '%-5s %s\n' "$1" "$2"
  if [ "$1" = FAIL ]; then
    CHECK_FAILS=$((CHECK_FAILS + 1))
  fi
}

check_ledger() {
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    function bare(s) { s = tolower(s); gsub(/[`*_~]/, "", s); return trim(s) }
    function isfate(w) { return w == "alive" || w == "floor" || w == "folded" || w == "graveyard" }
    function fate(cell,   c, k, w, s, first, prev) {
      c = cell
      gsub(/~~[^~]*~~/, "", c)
      c = bare(c)
      k = index(c, ":")
      if (k > 0) c = substr(c, 1, k - 1)
      first = ""
      prev = ""
      while (match(c, /[a-z]+(-[a-z]+)*/)) {
        s = substr(c, 1, RSTART - 1)
        w = substr(c, RSTART, RLENGTH)
        c = substr(c, RSTART + RLENGTH)
        if (first == "") {
          if (!isfate(w)) return "invalid"
          first = w
        } else if (isfate(w) && w != first && (isfate(prev) || prev == "or" || prev == "and" || prev == "then" || prev == "now" || prev == "later" || s ~ /[,;\/|+&]/)) {
          return "invalid"
        }
        prev = w
      }
      if (first == "") return "invalid"
      return first
    }
    BEGIN { OFS = "\037" }
    /^\|/ {
      row = $0
      gsub(/\\\|/, "\001", row)
      n = split(row, cell, "|")
      if (!intable) {
        fc = 0
        ic = 0
        for (i = 2; i < n; i++) {
          x = bare(cell[i])
          if (x == "fate") fc = i
          if (x == "card") ic = i
        }
        if (fc && ic) { intable = 1; skip = 1 }
        next
      }
      if (skip) { skip = 0; next }
      id = cell[ic]
      gsub(/[`*_~]/, "", id)
      id = trim(id)
      k = index(id, "](")
      if (substr(id, 1, 1) == "[" && k > 0 && substr(id, length(id)) == ")") id = substr(id, 2, k - 2)
      if (id == "") id = "-"
      raw = trim(cell[fc])
      gsub(/\001/, "|", raw)
      print id, fate(cell[fc]), FNR, raw
      next
    }
    { intable = 0; skip = 0 }
  ' "$1"
}

check_findings() {
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^\|/ {
      row = $0
      gsub(/\\\|/, "\001", row)
      n = split(row, cell, "|")
      if (!intable) {
        fc = 0
        for (i = 2; i < n; i++) {
          x = tolower(cell[i])
          gsub(/[`*_~]/, "", x)
          if (trim(x) == "finding") fc = i
        }
        if (fc) { intable = 1; skip = 1 }
        next
      }
      if (skip) { skip = 0; next }
      id = cell[fc]
      gsub(/[`*~]/, "", id)
      id = trim(id)
      if (id != "") print id
      next
    }
    { intable = 0; skip = 0 }
  ' "$1"
}

check_cards() {
  env ${CHECK_UTF8:+"LC_ALL=$CHECK_UTF8"} awk -v en="$CHECK_EN" -v em="$CHECK_EM" '
    BEGIN {
      OFS = "\037"
      cre = "[[:alnum:]_./~-]*[[:alnum:]_~-]([.][A-Za-z][A-Za-z0-9]*)?:[0-9]+((-|" en "|" em ")[0-9]+)?"
    }
    FNR == 1 { insection = 0; card = ""; kind = ""; front = 0; intab = 0; outer = "" }
    FNR == 1 && $0 == "---" { front = 1; next }
    front && $0 == "---" { front = 0; next }
    front { if ($1 == "kind:") kind = $2; next }
    kind == "check" { next }
    /^## / { s = tolower($0); insection = (s ~ /(^|[^a-z])(cards|holds)([^a-z]|$)/); card = ""; intab = 0; next }
    !/^\|/ && intab { intab = 0; card = outer }
    /^\|/ {
      c1 = $0
      sub(/^\|[ \t]*/, "", c1)
      sub(/[ \t]*\|.*$/, "", c1)
      gsub(/[`*~]/, "", c1)
      if (c1 ~ /^[Rr][0-9]+-(A[LR][01]|V)-[A-Za-z0-9]+$/) {
        if (!intab) outer = card
        intab = 1
        card = c1
      } else if (intab) {
        card = outer
      }
    }
    /^### / {
      h = substr($0, 5)
      gsub(/[`*~]/, "", h)
      sub(/^[ \t]*\[?/, "", h)
      id = (match(h, /^[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]/) ? substr(h, RSTART, RLENGTH) : "")
      card = ""
      if (insection || id ~ /^[Rr][0-9]+-(A[LR][0-9]+|V)-[A-Za-z0-9]+$/) {
        if (id == "") {
          k = index(h, " ")
          id = (k ? substr(h, 1, k - 1) : h)
        }
        card = id
        print "C", FILENAME, FNR, card
      }
    }
    card != "" {
      rest = $0
      while (match(rest, cre)) {
        cite = substr(rest, RSTART, RLENGTH)
        pre = (RSTART > 1 ? substr(rest, RSTART - 1, 1) : "")
        rest = substr(rest, RSTART + RLENGTH)
        gsub(en, "-", cite)
        gsub(em, "-", cite)
        k = index(cite, ":")
        path = substr(cite, 1, k - 1)
        span = substr(cite, k + 1)
        if (pre == ":" || pre == "@") continue
        if (path ~ /^[0-9.]+$/) continue
        host = 0
        if (path !~ /\//) {
          if (path !~ /[.][A-Za-z][A-Za-z0-9]*$/) continue
          if (path ~ /[.](com|org|net|io|dev|app|ai|cloud|internal|local|lan|svc|cluster|uk|eu|us|de|jp)$/) host = 1
        }
        after = rest
        if (pre == "`" && substr(after, 1, 1) == "`") after = substr(after, 2)
        quote = ""
        if ($0 !~ /^#/ && match(after, "^ *([:(-]|" en "|" em ")? *`[^`]+`")) {
          q = substr(after, RSTART, RLENGTH)
          tail = substr(after, RSTART + RLENGTH)
          sub("^ *([:(-]|" en "|" em ")? *`", "", q)
          sub(/`$/, "", q)
          if (!match(q, "^" cre "$")) {
            quote = q
            rest = tail
          }
        }
        a = span
        b = span
        if (index(span, "-")) {
          a = substr(span, 1, index(span, "-") - 1)
          b = substr(span, index(span, "-") + 1)
        }
        print "Q", FILENAME, FNR, card, path, a, b, host, quote
      }
    }
  ' "$@"
}

check_synthesis_ids() {
  CHECK_IDS="$2" CHECK_KNOWN="$3" awk '
    BEGIN {
      OFS = "\037"
      n = split(ENVIRON["CHECK_IDS"], list, "\n")
      for (i = 1; i <= n; i++) if (list[i] != "") want[list[i]] = 1
      n = split(ENVIRON["CHECK_KNOWN"], list, "\n")
      for (i = 1; i <= n; i++) if (list[i] != "") known[list[i]] = 1
    }
    /^[ \t]*(```|~~~)/ { fence = !fence }
    !fence && /^# / { grave = 0; risks = 0; next }
    !fence && /^## / {
      h = tolower($0)
      grave = (h ~ /^##[ \t]+(the[ \t]+)?graveyard/)
      risks = (!grave && h ~ /(^|[^a-z])risks?([^a-z]|$)/)
      first = 1
      byhead = 0
      next
    }
    grave && !fence && /^###/ { first = 1; byhead = 0 }
    grave && (/^[ \t]*([-*+]|[0-9]+[.])[ \t]/ || /^\|/) { first = 1; byhead = 0 }
    grave && /^[ \t]*$/ && !byhead { first = 1 }
    {
      line = $0
      while (match(line, /[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]/)) {
        tok = substr(line, RSTART, RLENGTH)
        line = substr(line, RSTART + RLENGTH)
        if (tok in want) {
          print tok, FNR, (grave ? (first ? "graveyard" : "reference") : (risks ? "risks" : "body"))
          if (grave) { first = 0; if (/^###/) byhead = 1 }
        } else if (!(tok in known) && tok ~ /^[Rr][0-9]+-(A[LR][0-9]+|V)-[A-Za-z0-9]+$/) {
          print tok, FNR, "unknown"
        }
      }
    }
  ' "$1"
}

check_carried() {
  CHECK_IDS="$2" awk '
    function flush(   b) {
      if (id != "") {
        b = tolower(text)
        sub(/^[ \t]*([-*+]|[0-9]+[.])?[ \t]*[*][*][^*]*[*][*]/, "", b)
        ns = split(b, sent, /[.;!?][ \t]/)
        for (k = 1; k <= ns; k++) if (sent[k] ~ /(^|[^a-z])carried([^a-z]|$)/ && sent[k] ~ /(^|[^a-z])risks?([^a-z]|$)/ && sent[k] !~ /(not|never|n\047t|no longer|neither)[ \t]+([a-z]+[ \t]+)?carried|carried[ \t]+nowhere/) { o = sent[k]; gsub(tolower(id), "", o); if (o !~ /r[0-9]+-(a[lr][0-9]+|v)-[a-z0-9]+/) { print id; break } }
      }
      id = ""
      text = ""
    }
    BEGIN {
      n = split(ENVIRON["CHECK_IDS"], list, "\n")
      for (i = 1; i <= n; i++) if (list[i] != "") want[list[i]] = 1
    }
    /^[ \t]*(```|~~~)/ { fence = !fence }
    !fence && /^##? / { flush(); grave = (tolower($0) ~ /^##[ \t]+(the[ \t]+)?graveyard/); byhead = 0; next }
    !grave { next }
    !fence && /^###/ { flush(); byhead = 0 }
    /^[ \t]*([-*+]|[0-9]+[.])[ \t]/ || /^\|/ { flush(); byhead = 0 }
    /^[ \t]*$/ && !byhead { flush(); next }
    {
      if (id == "") {
        line = $0
        while (match(line, /[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]/)) {
          tok = substr(line, RSTART, RLENGTH)
          line = substr(line, RSTART + RLENGTH)
          if (tok in want) { id = tok; if (/^###/) byhead = 1; break }
        }
      }
      if (!/^###/) text = text " " $0
    }
    END { flush() }
  ' "$1"
}

check_bare() {
  awk '
    BEGIN { OFS = "\037" }
    FNR == 1 { if (fname != "") print fname, rows, firstline, firstref; fname = FILENAME; rows = 0; firstline = ""; firstref = ""; intab = 0 }
    !/^\|/ { intab = 0; next }
    /^\|[ \t:|-]+$/ { next }
    {
      row = $0
      gsub(/\\\|/, "\001", row)
      n = split(row, cell, "|")
      if (!intab) {
        intab = 1
        split("", filecol)
        for (i = 2; i <= n; i++) filecol[i] = (cell[i] ~ /[A-Za-z0-9_-][.][A-Za-z][A-Za-z0-9]*|[\/]/)
        next
      }
      for (i = 2; i <= n; i++) {
        if (!match(cell[i], /(^|[^A-Za-z0-9_.\/~-])`?:[0-9]+(-[0-9]+)?/)) continue
        r = substr(cell[i], RSTART, RLENGTH)
        if (!filecol[i] && cell[i] !~ /[A-Za-z0-9_-][.][A-Za-z][A-Za-z0-9]*:[0-9]/) continue
        sub(/^[^`:]*/, "", r)
        gsub(/`/, "", r)
        rows++
        if (firstline == "") { firstline = FNR; firstref = r }
        break
      }
    }
    END { if (fname != "") print fname, rows, firstline, firstref }
  ' "$@"
}

check_resolve() {
  local p="$1" rest cand obj dir hits=0 found=""
  case "$p" in
    /*)
      if [ -f "$p" ]; then
        printf '%s' "file:$p"
        return 0
      fi
      ;;
  esac
  if [[ "$p" != */* ]] && [ ! -f "$CHECK_STORM/$p" ]; then
    while IFS= read -r cand; do
      if [ "${cand##*/}" = "$p" ] && [ "$cand" != "$p" ]; then
        hits=$((hits + 1))
        found="$cand"
      fi
    done <"$CHECK_WORK/ground-paths"
    if [ "$hits" -eq 1 ] && check_resolve "$found"; then
      return 0
    fi
    hits=0
    found=""
  fi
  rest="$p"
  while [ -n "$rest" ]; do
    if [ -f "$CHECK_STORM/$rest" ]; then
      printf '%s' "file:$CHECK_STORM/$rest"
      return 0
    fi
    if [ -n "$CHECK_PIN" ]; then
      obj="$(printf '%s\n' "$CHECK_PIN:./$rest" | GIT_NO_LAZY_FETCH=1 git -C "$CHECK_PIN_GIT" cat-file --batch-check='%(objecttype) %(objectname)' --follow-symlinks 2>/dev/null || true)"
      obj="${obj%%$'\n'*}"
      if [[ "$obj" =~ ^blob\ ([0-9a-f]+)$ ]]; then
        printf '%s' "git:${BASH_REMATCH[1]}"
        return 0
      fi
    fi
    while IFS= read -r dir; do
      if [ -f "$dir/$rest" ]; then
        printf '%s' "file:$dir/$rest"
        return 0
      fi
    done <"$CHECK_WORK/roots"
    if [ -f "$ROOT/$rest" ]; then
      printf '%s' "file:$ROOT/$rest"
      return 0
    fi
    case "$rest" in
      */*) rest="${rest#*/}" ;;
      *) rest="" ;;
    esac
  done
  if [ -f "$CHECK_STORM/GROUND.md" ]; then
    while IFS= read -r cand; do
      if [ "$cand" != "$p" ] && [[ "$cand" == */"$p" ]]; then
        hits=$((hits + 1))
        found="$cand"
      fi
    done <"$CHECK_WORK/ground-paths"
    if [ "$hits" -eq 1 ]; then
      check_resolve "$found"
      return
    fi
  fi
  return 1
}

check_text() {
  local where="$1" key
  key="$(printf '%s' "$where" | cksum | cut -d' ' -f1)"
  if [ ! -f "$CHECK_WORK/$key" ]; then
    case "$where" in
      git:*) GIT_NO_LAZY_FETCH=1 git -C "$CHECK_PIN_GIT" cat-file blob "${where#git:}" >"$CHECK_WORK/$key" 2>/dev/null || return 1 ;;
      file:*) cp "${where#file:}" "$CHECK_WORK/$key" 2>/dev/null || return 1 ;;
    esac
  fi
  printf '%s' "$CHECK_WORK/$key"
}

collapse() {
  LC_ALL=C tr -s ' \t' '  ' | LC_ALL=C sed 's/^ //; s/ $//'
}

check_storm() {
  local storm="${1:-}" t0 t1 ledger synth ids known id fate line raw total alive floor folded grave
  local r n a sheet citations=0 resolved=0 quotes=0 held=0 where text lines lo hi window q
  local tag file fline card path qa qb host quote syn_ids tok sline secfate carried
  local named=0 head bfile brows bline bref
  local -a sheets bare_files
  local -A fate_of=() round_n=() round_a=() seen_id=()
  [ "$#" -eq 1 ] || die "check takes one STORM_DIR"
  [ -d "$storm" ] || die "no storm directory: $storm"
  CHECK_STORM="$(CDPATH='' cd -- "$storm" && pwd)" || die "cannot enter $storm"
  t0="${EPOCHREALTIME:-$(date +%s)}"
  t0="${t0/,/.}"
  CHECK_WORK="$(mktemp -d)" || die "cannot make a scratch directory"
  trap 'rm -rf "$CHECK_WORK"' EXIT
  CHECK_FAILS=0
  CHECK_PIN=""
  ledger="$CHECK_STORM/LEDGER.md"
  synth="$CHECK_STORM/SYNTHESIS.md"
  printf '%s\n' "check $CHECK_STORM"
  : >"$CHECK_WORK/ground-paths"
  : >"$CHECK_WORK/roots"
  CHECK_PIN_GIT="$ROOT"
  if [ -f "$CHECK_STORM/GROUND.md" ]; then
    { grep -o '`/[^`]*`' "$CHECK_STORM/GROUND.md" || true; } | tr -d '`' | sort -u | while IFS= read -r dir; do
      dir="${dir%/}"
      if [ -n "$dir" ] && [ -d "$dir" ]; then
        printf '%s\n' "$dir"
      fi
    done >"$CHECK_WORK/roots"
    CHECK_PIN="$(grep -i -o 'pinned to `[0-9a-f]\{7,40\}`' "$CHECK_STORM/GROUND.md" | head -n 1 | tr 'A-F' 'a-f' | grep -o '[0-9a-f]\{7,40\}' || true)"
    if [ -n "$CHECK_PIN" ] && ! GIT_NO_LAZY_FETCH=1 git -C "$ROOT" cat-file -e "$CHECK_PIN^{commit}" 2>/dev/null; then
      while IFS= read -r dir; do
        if GIT_NO_LAZY_FETCH=1 git -C "$dir" cat-file -e "$CHECK_PIN^{commit}" 2>/dev/null; then
          CHECK_PIN_GIT="$dir"
          break
        fi
      done <"$CHECK_WORK/roots"
    fi
    if [ -n "$CHECK_PIN" ] && ! GIT_NO_LAZY_FETCH=1 git -C "$CHECK_PIN_GIT" cat-file -e "$CHECK_PIN^{commit}" 2>/dev/null; then
      check_line note "GROUND.md pins $CHECK_PIN, which neither this repository nor a directory GROUND.md names holds; citations are read from the working tree"
      CHECK_PIN=""
    fi
    if [ -n "$CHECK_PIN" ] && [ -n "$(git -C "$CHECK_PIN_GIT" config --get-regexp '^(remote\..*\.promisor|extensions\.partialclone)$' 2>/dev/null || true)" ]; then
      check_line note "this clone is partial: a file whose content at $CHECK_PIN is not here is read from the working tree, where its lines may differ"
    fi
    { grep -o '`[^`]*/[^`]*`' "$CHECK_STORM/GROUND.md" || true; } | tr -d '`' | sed 's/:[0-9-]*$//' | sort -u >"$CHECK_WORK/ground-paths" || die "cannot read $CHECK_STORM/GROUND.md"
  fi
  : >"$CHECK_WORK/rows"
  if [ ! -f "$ledger" ]; then
    check_line FAIL "no LEDGER.md"
  else
    check_ledger "$ledger" >"$CHECK_WORK/rows" || die "cannot read $ledger"
    [ -s "$CHECK_WORK/rows" ] || check_line FAIL "LEDGER.md has no card table with a Card and a Fate column"
  fi
  total=0 alive=0 floor=0 folded=0 grave=0
  ids=""
  while IFS="$CHECK_SEP" read -r id fate line raw; do
    if [ "$id" = - ]; then
      check_line FAIL "LEDGER.md:$line: a row of the card table names no card"
      continue
    fi
    if ! [[ "$id" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
      check_line FAIL "LEDGER.md:$line: the row names '$id', not one card; a card takes a row of its own"
      continue
    fi
    total=$((total + 1))
    if [ -n "${seen_id[$id]-}" ]; then
      check_line FAIL "LEDGER.md:$line: card $id is listed twice"
    fi
    seen_id[$id]=1
    ids="$ids$id"$'\n'
    fate_of[$id]="$fate"
    case "$fate" in
      alive) alive=$((alive + 1)) ;;
      floor) floor=$((floor + 1)) ;;
      folded) folded=$((folded + 1)) ;;
      graveyard) grave=$((grave + 1)) ;;
      *) check_line FAIL "LEDGER.md:$line: card $id has no single fate of the four: '$raw'" ;;
    esac
    if [[ "$id" =~ ^[Rr]([0-9]+)- ]]; then
      r=$((10#${BASH_REMATCH[1]}))
      round_n[$r]=$((${round_n[$r]-0} + 1))
      if [ "$fate" = alive ]; then
        round_a[$r]=$((${round_a[$r]-0} + 1))
      fi
    else
      check_line FAIL "LEDGER.md:$line: card $id names no round"
    fi
  done <"$CHECK_WORK/rows"
  if [ -f "$ledger" ]; then
    check_line ok "the ledger's four counts: alive $alive, floor $floor, folded $folded, graveyard $grave, of $total cards"
  fi
  for r in $(if [ "${#round_n[@]}" -gt 0 ]; then printf '%s\n' "${!round_n[@]}" | sort -n; fi); do
    n="${round_n[$r]}"
    a="${round_a[$r]-0}"
    if [ $((a * 10)) -le $((n * 4)) ]; then
      check_line ok "round r$r: $a of $n cards alive, within four in ten"
    else
      check_line FAIL "round r$r: $a of $n cards alive, over four in ten"
    fi
  done
  sheets=()
  find -L "$CHECK_STORM" -mindepth 2 -maxdepth 2 -type f \( -name 'analyst-[LR][0-9].md' -o -name 'visionary.md' \) >"$CHECK_WORK/sheets" || check_line FAIL "the storm's round directories cannot all be listed"
  while IFS= read -r sheet; do
    case "${sheet#"$CHECK_STORM"/}" in
      r[0-9]*/*) sheets+=("$sheet") ;;
    esac
  done < <(sort "$CHECK_WORK/sheets")
  : >"$CHECK_WORK/cards"
  CHECK_UTF8="$(locale -a 2>/dev/null | grep -m 1 -ixE 'c[.]utf-?8|en_US[.]utf-?8' || true)"
  if [ "${#sheets[@]}" -gt 0 ]; then
    check_cards "${sheets[@]}" >"$CHECK_WORK/cards" || check_line FAIL "a sheet of the storm cannot be read"
  fi
  while IFS="$CHECK_SEP" read -r tag file fline card path qa qb host quote; do
    case "$tag" in
      C)
        if [ -z "$card" ] || [ -z "${seen_id[$card]-}" ]; then
          check_line FAIL "${file#"$CHECK_STORM"/}:$fline: card $card is on a sheet and not in the ledger"
        fi
        ;;
      Q)
        if ! where="$(check_resolve "$path")"; then
          where=""
        fi
        if [ -z "$where" ] && [ "$host" = 1 ]; then
          continue
        fi
        citations=$((citations + 1))
        if ! [[ "$qa" =~ ^[0-9]{1,9}$ && "$qb" =~ ^[0-9]{1,9}$ ]]; then
          check_line FAIL "${file#"$CHECK_STORM"/}:$fline: card $card cites $path:$qa-$qb, which is no line number"
          continue
        fi
        qa=$((10#$qa))
        qb=$((10#$qb))
        if [ -z "$where" ]; then
          check_line FAIL "${file#"$CHECK_STORM"/}:$fline: card $card cites $path:$qa, which resolves to no file"
          continue
        fi
        if ! text="$(check_text "$where")"; then
          check_line FAIL "${file#"$CHECK_STORM"/}:$fline: card $card cites $path, which cannot be read"
          continue
        fi
        lines="$(awk 'END { print NR }' "$text")"
        if [ "$qa" -lt 1 ] || [ "$qb" -gt "$lines" ] || [ "$qa" -gt "$qb" ]; then
          check_line FAIL "${file#"$CHECK_STORM"/}:$fline: card $card cites $path:$qa-$qb, past the file's $lines lines"
          continue
        fi
        resolved=$((resolved + 1))
        if [ -n "$quote" ]; then
          quotes=$((quotes + 1))
          lo=$((qa - 2))
          hi=$((qb + 2))
          [ "$lo" -ge 1 ] || lo=1
          window="$(LC_ALL=C sed -n "${lo},${hi}p" "$text" | LC_ALL=C tr '\n' ' ' | collapse)"
          q="$(printf '%s' "$quote" | collapse)"
          if [[ "$window" == *"$q"* ]]; then
            held=$((held + 1))
          else
            check_line FAIL "${file#"$CHECK_STORM"/}:$fline: card $card quotes '$quote', which is not at $path:$qa within two lines"
          fi
        fi
        ;;
    esac
  done <"$CHECK_WORK/cards"
  check_line ok "citations: $resolved of $citations in the cards on file resolve at their lines; $held of $quotes quotes hold within two lines"
  if [ ! -f "$synth" ]; then
    check_line FAIL "no SYNTHESIS.md"
  else
    known="$ids"
    if [ -f "$ledger" ]; then
      known="$known$(check_findings "$ledger")" || die "cannot read $ledger"
    fi
    known="$known"$'\n'"$(find -L "$CHECK_STORM" -maxdepth 2 -type f -name '*.md' ! -name SYNTHESIS.md -exec grep -ohE '[Rr][0-9]+-A[LR]2-[A-Za-z0-9]+' {} + 2>/dev/null || true)"
    syn_ids="$(check_synthesis_ids "$synth" "$ids" "$known")" || die "cannot read $synth"
    carried=""
    if [ -f "$ledger" ]; then
      carried="$(check_carried "$ledger" "$ids")" || die "cannot read $ledger"
    fi
    while IFS="$CHECK_SEP" read -r tok sline secfate; do
      [ -n "$tok" ] || continue
      fate="${fate_of[$tok]-}"
      named=$((named + 1))
      if [ "$secfate" = unknown ]; then
        check_line FAIL "SYNTHESIS.md:$sline: names $tok, which is not in the ledger"
      elif [ "$secfate" = graveyard ] && [ "$fate" != graveyard ]; then
        check_line FAIL "SYNTHESIS.md:$sline: its graveyard cites $tok, whose fate is $fate"
      elif [ "$secfate" = body ] && [ "$fate" = graveyard ]; then
        check_line FAIL "SYNTHESIS.md:$sline: cites $tok, which the ledger buried, outside its graveyard and its risks"
      elif [ "$secfate" = risks ] && [ "$fate" = graveyard ] && ! grep -qxF -- "$tok" <<<"$carried"; then
        check_line FAIL "SYNTHESIS.md:$sline: its risks cite $tok, which the ledger buried without carrying its objection as a risk"
      fi
    done <<<"$syn_ids"
    check_line ok "the synthesis names cards $named time(s): outside its graveyard only cards that survived the ledger may stand, except in its risks a buried card whose epitaph carries its objection as a risk; each graveyard entry's first card is a buried one, and a card an epitaph names after it is a reference"
    if awk '/^## / { c = (tolower($0) ~ /^##[ \t]+(the[ \t]+)?cost/); t = 0; next } !/^\|/ { t = 0; next } c && !t { n = split(tolower($0), h, "|"); for (i = 2; i <= n; i++) { x = h[i]; gsub(/^[ \t]+|[ \t]+$/, "", x); if (x == "minutes") f = 1 } } { t = 1 } END { exit !f }' "$synth"; then
      check_line ok "the synthesis has a cost table with a Minutes column"
    else
      check_line FAIL "the synthesis has no cost table with a Minutes column"
    fi
  fi
  bare_files=()
  if [ -f "$ledger" ]; then
    bare_files+=("$ledger")
  fi
  if [ -f "$synth" ]; then
    bare_files+=("$synth")
  fi
  : >"$CHECK_WORK/bare"
  if [ "${#bare_files[@]}" -gt 0 ]; then
    check_bare "${bare_files[@]}" >"$CHECK_WORK/bare" || die "cannot read the ledger or the synthesis"
  fi
  while IFS="$CHECK_SEP" read -r bfile brows bline bref; do
    [ -n "$bfile" ] || continue
    if [ "$brows" -gt 0 ]; then
      check_line FAIL "${bfile#"$CHECK_STORM"/}:$bline: $brows table row(s) cite a line with no path, such as $bref; write path:line"
    fi
  done <"$CHECK_WORK/bare"
  if [ -f "$synth" ]; then
    head="$(awk '/^## / { s = tolower($0); sub(/^##[ \t]+/, "", s); sub(/^the[ \t]+/, "", s); s = (s ~ /^recommendation/ ? "r" : (s ~ /^dissent/ ? "d" : (s ~ /^cost/ ? "c" : ""))); shown = 0; next } (s == "r" || s == "d") && NF && !shown { print (s == "r" ? "Recommendation" : "Dissent") ": " $0; shown = 1 } s == "c" && /^\|/ { print }' "$synth")" || die "cannot read $synth"
    grep -q '^Recommendation: ' <<<"$head" || check_line FAIL "SYNTHESIS.md has no Recommendation section for the memo's head"
    grep -q '^Dissent: ' <<<"$head" || check_line FAIL "SYNTHESIS.md has no Dissent section for the memo's head"
    printf '%s\n' "--- the memo's head" "$head"
  fi
  t1="${EPOCHREALTIME:-$(date +%s)}"
  t1="${t1/,/.}"
  printf '%s\n' "--- check ran in $(awk -v a="$t0" -v b="$t1" 'BEGIN { printf "%.3f", b - a }') s; $CHECK_FAILS check(s) failed"
  [ "$CHECK_FAILS" -eq 0 ]
}

memory_dir() {
  local cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}" out rc=0
  command -v python3 >/dev/null 2>&1 || die "python3 is needed to name this folder's Claude Code project memory"
  out="$(python3 -I -X utf8 -c '
import json, os, sys
cfg, root = sys.argv[1], os.path.realpath(sys.argv[2])
if os.environ.get("CLAUDE_COWORK_MEMORY_PATH_OVERRIDE"):
    print("CLAUDE_COWORK_MEMORY_PATH_OVERRIDE sends every seat\x27s auto-memory to one directory that matrix.sh cannot keep apart by room; unset it for the room")
    sys.exit(2)
for src in ("/etc/claude-code/managed-settings.json", "/Library/Application Support/ClaudeCode/managed-settings.json", os.path.join(root, ".claude", "settings.local.json"), os.path.join(root, ".claude", "settings.json"), os.path.join(cfg, "settings.json")):
    try:
        with open(src, encoding="utf-8") as f:
            v = json.load(f)
    except (OSError, ValueError):
        continue
    if isinstance(v, dict) and v.get("autoMemoryDirectory") is not None:
        print("autoMemoryDirectory in " + src + " sends every session\x27s auto-memory to one directory that matrix.sh cannot keep apart by room; remove it for the room")
        sys.exit(2)
base, d = root, root
while True:
    if os.path.exists(os.path.join(d, ".git")):
        base = d
        break
    if os.path.dirname(d) == d:
        break
    d = os.path.dirname(d)
try:
    with open(os.path.join(base, ".git"), encoding="utf-8") as f:
        t = f.read().strip()
    if t.startswith("gitdir:"):
        g = os.path.normpath(os.path.join(base, t[7:].strip()))
        with open(os.path.join(g, "commondir"), encoding="utf-8") as f:
            c = os.path.normpath(os.path.join(g, f.read().strip()))
        if os.path.dirname(g) == os.path.join(c, "worktrees"):
            if os.path.basename(c) == ".git":
                base = os.path.dirname(c)
            elif not os.path.exists(os.path.join(c, ".git")):
                base = c
except OSError:
    pass
b = base.encode("utf-16-le", "surrogatepass")
units = [int.from_bytes(b[i:i + 2], "little") for i in range(0, len(b), 2)]
slug = "".join(chr(u) if u < 128 and chr(u).isalnum() else "-" for u in units)
if len(slug) > 200:
    h = 0
    for u in units:
        h = (h * 31 + u) & 0xFFFFFFFF
    h = abs(h - (1 << 32) if h >= 1 << 31 else h)
    digits = ""
    while True:
        h, r = divmod(h, 36)
        digits = "0123456789abcdefghijklmnopqrstuvwxyz"[r] + digits
        if h == 0:
            break
    slug = slug[:200] + "-" + digits
print(os.path.join(cfg, "projects", slug, "memory"))
' "$cfg" "$ROOT")" || rc=$?
  [ "$rc" -eq 0 ] || die "${out:-cannot name the Claude Code project memory of this folder under $cfg/projects}"
  printf '%s\n' "$out"
}

memory_files() {
  local mem="$1"
  [ -d "$mem" ] || return 0
  find -H "$mem" -mindepth 1 -maxdepth 1 -print || die "cannot list $mem"
}

rooms_here() {
  local phys sname path title
  phys="$(CDPATH='' cd -- "$ROOT" && pwd -P)"
  { tmux list-panes -a -F "#{session_name}$CHECK_SEP#{pane_current_path}$CHECK_SEP#{pane_title}" 2>/dev/null || true; } |
    while IFS="$CHECK_SEP" read -r sname path title; do
      if { [ "$path" = "$ROOT" ] || [ "$path" = "$phys" ]; } && is_matrix_title "$(bare "$title")" "" 0; then
        printf '%s\n' "$sname"
      fi
    done | sort -u | paste -sd, -
}

down() {
  local storm="" base mem entry name dest session here list moved=0
  local -a items=()
  [ "$#" -le 1 ] || die "down takes at most one STORM_DIR"
  storm="${1:-}"
  session="$(room_session)"
  if [ -n "$storm" ]; then
    [ -d "$storm" ] || die "no storm directory: $storm"
    base="$(CDPATH='' cd -- "$storm" && pwd)" || die "cannot enter $storm"
    base="${base##*/}"
    [[ "$base" =~ ^[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "$storm is not a storm directory, named NN-CODENAME-SLUG as matrix.sh new names it"
  fi
  mem="$(memory_dir)"
  if [ -z "$storm" ] && [ -n "$(memory_files "$mem")" ]; then
    die "this folder's Claude Code project memory holds files from earlier sessions in this folder ($mem): move them into a storm's record with matrix.sh down STORM_DIR, or aside by hand (the room was not stopped)"
  fi
  if [ -n "${TMUX_PANE:-}" ] && [ "$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null || true)" = "$session" ]; then
    die "down stops the tmux session $session, which runs this pane, so it would end before the move: run it from outside the room"
  fi
  if tmux has-session -t "=$session" 2>/dev/null; then
    tmux kill-session -t "=$session" || die "tmux cannot stop the session $session"
    printf '%s\n' "down: stopped the tmux session $session"
  else
    printf '%s\n' "down: no tmux session named $session is running"
  fi
  here="$(rooms_here)"
  [ -z "$here" ] || die "a room of this folder still runs in tmux session(s) $here, and its seats share this folder's Claude Code project memory: stop it with matrix.sh down -p PREFIX, then move the memory"
  list="$(mktemp)" || die "cannot make a scratch file"
  if [ -d "$mem" ]; then
    find -H "$mem" -mindepth 1 -maxdepth 1 -print0 >"$list" || {
      rm -f "$list"
      die "cannot list $mem"
    }
  fi
  while IFS= read -r -d '' entry; do
    items+=("$entry")
  done <"$list"
  rm -f "$list"
  if [ "${#items[@]}" -eq 0 ]; then
    printf '%s\n' "down: this folder's Claude Code project memory is empty ($mem)"
    return 0
  fi
  [ -n "$storm" ] || die "this folder's Claude Code project memory holds files from earlier sessions in this folder ($mem): move them into a storm's record with matrix.sh down STORM_DIR, or aside by hand"
  dest="$storm/auto-memory"
  for entry in "${items[@]}"; do
    name="${entry##*/}"
    if [ -e "$dest/$name" ] || [ -L "$dest/$name" ]; then
      die "$dest/$name exists; move it aside first (nothing was moved)"
    fi
  done
  mkdir -p "$dest" || die "cannot make $dest"
  for entry in "${items[@]}"; do
    mv -- "$entry" "$dest/" || die "cannot move $entry into $dest"
    printf '%s\n' "down: moved ${entry##*/} into $dest"
    moved=$((moved + 1))
  done
  [ -z "$(memory_files "$mem")" ] || die "this folder's Claude Code project memory $mem is still not empty"
  printf '%s\n' "down: moved $moved file(s); this folder's Claude Code project memory is empty ($mem)"
}

PREFIX=""
HAVE_PREFIX=0
cmd="${1:-help}"
shift || true
case "$cmd" in
  roster | status | wait | doctor | up | down)
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
  check) check_storm "$@" ;;
  down) down "$@" ;;
  help | -h | --help) usage ;;
  *)
    usage >&2
    exit 2
    ;;
esac
