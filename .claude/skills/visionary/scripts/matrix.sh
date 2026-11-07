#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
NAMES=(ada babbage curie dirac euler feynman gauss hopper ising jacobi kolmogorov lamport mandelbrot
  noether ostrom pascal quetelet ramanujan shannon turing ulam volterra wiener xenakis yau zermelo)
LADDER=(L0 R0 L1 R1 L2 R2)
CHECK_ROW=2

usage() {
  cat <<'EOF'
matrix.sh — the Visionary's tool for the brainstorm matrix, run from the repo root

A matrix's sessions are named "PREFIX Visionary" and "PREFIX Analyst (SEAT)": SEAT is a placement
and a row (L0, R0, L1, R1, L2, R2), and PREFIX names the matrix, or is left out. Without -p,
status and wait take the prefix from the calling Visionary's pane title, and outside one they
take the six seats of the ladder.

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
  printf 'matrix: %s\n' "$*" >&2
  exit 1
}

session() {
  [ -n "${TMUX_PANE:-}" ] || die "not inside tmux"
  tmux display-message -p -t "$TMUX_PANE" '#{session_name}'
}

panes() {
  tmux list-panes -s -t "$(session)" -F '#{pane_id}	#{window_index}.#{pane_index}	#{pane_title}'
}

bare() {
  local t="$1"
  printf '%s' "${t#"${t%%[[:alnum:]]*}"}"
}

own_prefix() {
  local t
  [ -n "${TMUX_PANE:-}" ] || return 1
  t="$(bare "$(tmux display-message -p -t "$TMUX_PANE" '#{pane_title}')")"
  [[ "$t" =~ ^(.+\ )?Visionary$ ]] || return 1
  printf '%s' "${BASH_REMATCH[1]% }"
}

analyst_stem() {
  if [ -n "$1" ]; then
    printf '%s Analyst (' "$1"
  else
    printf 'Analyst ('
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

roster() {
  local stem vis id at title t
  [ "$#" -eq 0 ] || die "roster takes nothing but -p PREFIX"
  if [ "$HAVE_PREFIX" -eq 0 ]; then
    panes
    return
  fi
  stem="$(analyst_stem "$PREFIX")"
  vis="${PREFIX:+$PREFIX }Visionary"
  panes | while IFS=$'\t' read -r id at title; do
    t="$(bare "$title")"
    if [ "$t" = "$vis" ] || [[ "$t" == "$stem"* && "${t#"$stem"}" =~ ^[LR][0-9]+\)$ ]]; then
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

matrix_seats() {
  local prefix list
  if [ "$HAVE_PREFIX" -eq 1 ]; then
    prefix="$PREFIX"
  elif prefix="$(own_prefix)"; then
    :
  else
    printf '%s\n' "${LADDER[@]}"
    return
  fi
  list="$(roster_seats "$prefix")"
  [ -n "$list" ] || die "no analyst panes for the prefix '$prefix' in session $(session)"
  printf '%s\n' "$list"
}

seat_pane() {
  local want found count
  want="$(analyst_stem "$1")$2)"
  found="$(panes | while IFS=$'\t' read -r id _ title; do
    if [ "$(bare "$title")" = "$want" ]; then
      printf '%s\n' "$id"
    fi
  done)"
  count="$(printf '%s' "$found" | grep -c . || true)"
  [ "$count" -eq 1 ] || die "expected one pane titled '$want' in session $(session), found $count"
  printf '%s\n' "$found"
}

peek() {
  local seat="${1:-}" lines="${2:-40}" prefix pane
  prefix="$(own_prefix)" || die "peek runs only from a Visionary's pane"
  [[ "$seat" =~ ^[LR][0-9]+$ ]] || die "SEAT is a placement and a row, such as L0 or R2"
  [[ "$lines" =~ ^[0-9]+$ ]] || die "LINES is a number"
  pane="$(seat_pane "$prefix" "$seat")"
  tmux capture-pane -p -J -S "-$lines" -t "$pane" |
    awk '{ sub(/[ \t]+$/, ""); line[NR] = $0 } NF { last = NR } END { for (i = 1; i <= last; i++) print line[i] }' |
    tail -n "$lines"
}

new_storm() {
  local slug="${1:-}" last num idx cycle name dir
  [[ "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "SLUG is lowercase words joined by hyphens"
  mkdir -p "$ROOT/storms"
  last="$(find "$ROOT/storms" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
    sed -n 's/^\([0-9][0-9]*\)-.*/\1/p' | sort -n | tail -n 1)"
  num=$((10#${last:-0} + 1))
  idx=$(((num - 1) % ${#NAMES[@]}))
  cycle=$(((num - 1) / ${#NAMES[@]} + 1))
  name="${NAMES[$idx]}"
  if [ "$cycle" -gt 1 ]; then
    name="$name$cycle"
  fi
  dir="$ROOT/storms/$(printf '%02d' "$num")-$name-$slug"
  mkdir "$dir"
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
  local storm="${1:-}" seats_text round extra seat sheet state words
  local -a seats list
  [ -d "$storm" ] || die "no storm directory: $storm"
  seats_text="$(matrix_seats)"
  mapfile -t seats <<<"$seats_text"
  for round in "$storm"/r[0-9]*/; do
    [ -d "$round" ] || continue
    if [ -f "${round}check.md" ]; then
      printf '%s  (check.md)\n' "$(basename "$round")"
    else
      printf '%s\n' "$(basename "$round")"
    fi
    list=("${seats[@]}")
    extra="$(find "$round" -maxdepth 1 -type f -name 'analyst-*.md' -printf '%f\n' |
      sed -n 's/^analyst-\([^-]*\)\.md$/\1/p' | sort)"
    while IFS= read -r seat; do
      if [ -n "$seat" ] && ! in_list "$seat" "${list[@]}"; then
        list+=("$seat")
      fi
    done <<<"$extra"
    for seat in "${list[@]}"; do
      sheet="${round}analyst-$seat.md"
      if [ -f "$sheet" ]; then
        state="$(field "$sheet" status)"
        words="$(wc -w <"$sheet")"
        printf '  %-3s %-8s %6s words\n' "$seat" "${state:-draft}" "$words"
      else
        printf '  %-3s missing\n' "$seat"
      fi
    done
  done
}

wait_round() {
  local round="${1:-}" minutes="${MATRIX_WAIT_MINUTES:-90}" seats_text deadline seat state sealed blocked
  local -a all who
  [ -d "$round" ] || die "no round directory: $round"
  [[ "$minutes" =~ ^[0-9]+$ ]] || die "MATRIX_WAIT_MINUTES is a number"
  shift
  who=("$@")
  if [ "${#who[@]}" -eq 0 ]; then
    seats_text="$(matrix_seats)"
    mapfile -t all <<<"$seats_text"
    for seat in "${all[@]}"; do
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
      printf 'blocked:%s; %s of %s sealed\n' "$blocked" "$sealed" "${#who[@]}"
      return 0
    fi
    if [ "$sealed" -eq "${#who[@]}" ]; then
      printf 'sealed: all %s (%s)\n' "$sealed" "${who[*]}"
      return 0
    fi
    if [ "$(date +%s)" -ge "$deadline" ]; then
      printf 'timeout after %s min; %s of %s sealed\n' "$minutes" "$sealed" "${#who[@]}"
      return 0
    fi
    sleep 20
  done
}

PREFIX=""
HAVE_PREFIX=0
cmd="${1:-help}"
shift || true
case "$cmd" in
  roster | status | wait)
    if [ "${1:-}" = "-p" ]; then
      [ "$#" -ge 2 ] || die "-p takes a PREFIX"
      PREFIX="$2"
      HAVE_PREFIX=1
      shift 2
    fi
    ;;
esac
case "$cmd" in
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
