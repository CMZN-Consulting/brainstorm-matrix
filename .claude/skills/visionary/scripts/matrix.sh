#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
NAMES=(ada babbage curie dirac euler feynman gauss hopper ising jacobi kolmogorov lamport mandelbrot
  noether ostrom pascal quetelet ramanujan shannon turing ulam volterra wiener xenakis yau zermelo)

usage() {
  cat <<'EOF'
matrix.sh — the Visionary's tool for the brainstorm matrix, run from the repo root

  roster                  the panes of this tmux session: id, window.pane, title
  peek N [LINES]          the last LINES (default 40) of Analyst N's pane; Visionary's pane only
  new SLUG                make the next storm directory; prints its codename and path
  status STORM_DIR        every round's sheets: sealed, draft, blocked or missing, with word counts
  wait ROUND_DIR [N ...]  block until those analysts' sheets (default all four) are sealed, or one
                          is blocked, or MATRIX_WAIT_MINUTES (default 90) pass; run it in the background
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

roster() {
  tmux list-panes -s -t "$(session)" -F '#{pane_id}	#{window_index}.#{pane_index}	#{pane_title}'
}

analyst_pane() {
  local n="${1:-}" panes count
  [[ "$n" =~ ^[1-4]$ ]] || die "the analyst is a number from 1 to 4"
  panes="$(roster | awk -F '\t' -v want="Analyst $n" '{ t = $3; sub(/^[^A-Za-z]+/, "", t); if (t == want) print $1 }')"
  count="$(printf '%s' "$panes" | grep -c . || true)"
  [ "$count" -eq 1 ] || die "expected one pane titled Analyst $n in session $(session), found $count"
  printf '%s\n' "$panes"
}

peek() {
  local n="${1:-}" lines="${2:-40}" pane
  [[ "$(tmux display-message -p -t "${TMUX_PANE:-}" '#{pane_title}')" =~ Visionary$ ]] ||
    die "peek runs only from the Visionary's pane"
  [[ "$lines" =~ ^[0-9]+$ ]] || die "LINES is a number"
  pane="$(analyst_pane "$n")"
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
  local storm="${1:-}" round n sheet state words
  [ -d "$storm" ] || die "no storm directory: $storm"
  for round in "$storm"/r[0-9]*/; do
    [ -d "$round" ] || continue
    printf '%s\n' "$(basename "$round")"
    for n in 1 2 3 4; do
      sheet="${round}analyst-$n.md"
      if [ -f "$sheet" ]; then
        state="$(field "$sheet" status)"
        words="$(wc -w <"$sheet")"
        printf '  Analyst %s  %-8s %6s words\n' "$n" "${state:-draft}" "$words"
      else
        printf '  Analyst %s  missing\n' "$n"
      fi
    done
  done
}

wait_round() {
  local round="${1:-}" minutes="${MATRIX_WAIT_MINUTES:-90}" deadline n state sealed blocked
  [ -d "$round" ] || die "no round directory: $round"
  [[ "$minutes" =~ ^[0-9]+$ ]] || die "MATRIX_WAIT_MINUTES is a number"
  shift
  local who=("$@")
  if [ "${#who[@]}" -eq 0 ]; then
    who=(1 2 3 4)
  fi
  deadline=$(($(date +%s) + minutes * 60))
  while :; do
    sealed=0
    blocked=""
    for n in "${who[@]}"; do
      state=""
      if [ -f "$round/analyst-$n.md" ]; then
        state="$(field "$round/analyst-$n.md" status)"
      fi
      case "$state" in
        sealed) sealed=$((sealed + 1)) ;;
        blocked) blocked="$blocked $n" ;;
      esac
    done
    if [ -n "$blocked" ]; then
      printf 'blocked:%s; %s of %s sealed\n' "$blocked" "$sealed" "${#who[@]}"
      return 0
    fi
    if [ "$sealed" -eq "${#who[@]}" ]; then
      printf 'sealed: all %s\n' "$sealed"
      return 0
    fi
    if [ "$(date +%s)" -ge "$deadline" ]; then
      printf 'timeout after %s min; %s of %s sealed\n' "$minutes" "$sealed" "${#who[@]}"
      return 0
    fi
    sleep 20
  done
}

cmd="${1:-help}"
shift || true
case "$cmd" in
  roster) roster ;;
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
