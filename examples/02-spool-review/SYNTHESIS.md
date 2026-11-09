---
kind: synthesis
storm: 01-ada-spool-review
status: landed
date: 2026-11-09
author: visionary
asked-by: desk-lead
---

# Storm Ada — review the spool before it ships — synthesis

## TL;DR

- **Hold the ship.** Eight S1 holds (H1–H8) and one S3 (H9), each verified at its line; 12 of the README's 39 promises break.
- Two seats found the same seven S1 holds independently, and the Visionary's draft, written before reading them, matched.
- Worst: one Ctrl-C or crash in a run stops the spool for good. The lock is never released (H2) or taken over (H1).
- Also: newest first (H5), one try too few (H4), unreadable jobs stranded (H3), re-runs after a failed move (H7), tags that grow (H6).
- Recommended, O2: fix H2–H7 in place (a line or two each, plus a test), and replace the pid lock with `flock` (M), retiring H1 and H8.
- O1, keeping the pid lock, needs a race-free takeover that nobody has designed. O0, shipping as it stands, is not supported.
- Confidence high. Nothing was executed: each hold's check is a test the team runs after the fix.

## The question

Whether the spool ships as it stands, and what is fixed before it does (`QUESTION.md`).

## The holds

All nine are verified at their line at `db2820c`, by reading and tracing by hand; none was shown by running `spool.py` (the room runs none of it). The full table, with every card behind each hold, is in `LEDGER.md`; the trace and the check that clears each hold are in the cards named.

| Hold | Sev | `spool.py` | Defect, in one line | Check that clears it (card) |
| ---- | --- | ---------- | ------------------- | --------------------------- |
| H1 | S1 | `:88` | Never takes over a dead run's lock (`README.md:28`). | AR0-H1: a lock holding a pid that is not in use → the run proceeds; a live other pid → `SpoolLocked`. |
| H2 | S1 | `:133-147` | No `finally`: an exception that escapes `run` leaves the lock (`:29`). | AL0-H2: a handler raises `KeyboardInterrupt` → no lock left; a second `run()` in the same process works. |
| H3 | S1 | `:113`, `:141` | An unreadable job is skipped, not filed (`:39`). | AL0-H3: empty, `[1]`, `{"x":1}`, `\xff` → all four in `failed/` and in `Result.failed`, with no handler call. |
| H4 | S1 | `:114` | `max_attempts - 1` tries, and none at 1 (`:31`, `:34`, `:24`). | AR0-H3: always retryable at 1 and 3 → 1 and 3 calls, sleeps `[]` and `[0.5, 1.0]`. |
| H5 | S1 | `:70` | Newest first; under a `limit`, the oldest starve (`:17`, `:23`). | AL0-H5: names 1, 2, 3 → `pending()` gives 1, 2, 3, and `run(limit=1)` runs 1. |
| H6 | S1 | `:54-55` | A shared mutable default; the caller's list is changed (`:15`). | AL0-H6: two untagged submits each record `["submitted"]`, and the caller's `t` is unchanged, even when `submit` raises. |
| H7 | S1 | `:110`, `:141` | A failed move is swallowed, and the job re-runs every run (`:39`, `:45`). | AL0-H7: `done/` removed after construction → the job is filed, or the run raises and names it. |
| H8 | S1* | `:83-90`, `:97` | *Live once H1's guard is fixed alone: two takers race, and `_release` unlinks a lock that is not its own (`:3`, `:27`). | AL0-W: a taker paused between `:83` and `:89` → it raises `SpoolLocked`, and the other's lock survives. |
| H9 | S3 | `:39` | Refuses `Fraction` and float subclasses; an `int` past float range raises `OverflowError`, not `ValueError` (`:41`). | `Spool(r, h, base_delay=10**400)` raises `ValueError`, or `README.md:41` says what is refused. |

## Options and how they fared

A review runs no tournament. The options are the complete answers to "what is fixed before it ships".

| Option | In one line | Strongest at | Weakest at | Cost · door |
| ------ | ----------- | ------------ | ---------- | ----------- |
| O0 · ship as it stands | the null | nothing to do | 8 S1 holds; the first crash stops the spool | — |
| O1 · fix in place, keep the pid lock | H2–H7, plus H1 with a takeover that cannot race (H8) | `README.md:46-48` stay as they are | no seat specified a race-free takeover on a pid file, and pid namespaces stay a doubt (AL0 doubt 2, AR0 doubt 4) | S for H2–H7, M and unspecified for H1+H8 · two-way |
| O2 · fix in place, lock with `flock` | H2–H7, plus `fcntl.flock` held for the run | the kernel drops the lock when its holder dies, so neither H1 nor H8 can occur; works across pid namespaces | `README.md:46-48` are rewritten; a handler that forks without exec keeps the lock (AR0 doubt 7) | S + M · see Dissent |

## Recommendation

**O2.** Fix H2–H7 as the cards' Fix lines give, and land each card's check as the module's first test file (no test exists, GROUND fact 1). Replace `_acquire` and `_release` with `flock` on `spool.lock`; rewrite `README.md:46-48`; fix H9 or say in `README.md:41` what it refuses. O2 beats O1 because O1's hard part, a pid-file takeover that two takers cannot race, has no design on the table, and `flock` makes the takeover unnecessary.

Pick O1 instead if `root` may sit on a filesystem where `flock` is not honoured (the README says local disk, `README.md:3`), or if something outside the spool reads the pid in `spool.lock` as the lock itself. O0 is not supported: its S1 holds sit on paths the README calls normal.

## Dissent

The seats agree on every hold and on its severity. They differ on the door of `flock`:

- **L0:** "M, one-way for the README's lock rules."
- **R0:** "Cost M, a two-way door."

The Visionary's reading: both are right, at different times. Before the ship nobody depends on the README's lock rules, so the door is two-way today. Once operators learn "remove it by hand" (`README.md:46`), it becomes one-way. That is an argument for choosing now.

## Risks and first measurements

1. **A `flock` fix that also unlinks `spool.lock` brings H8 back.** Run B opens the old file; A releases and unlinks it; C creates a new file and locks it; B then locks the unlinked one. Now two runs hold "the lock". Rule: never unlink, and the README says never remove it by hand. Test: script that interleaving; at most one run proceeds. (The Visionary's addition; no seat raised it.)
2. **A handler that forks without exec holds the lock in its child** (AR0 doubt 7). Test: a handler forks a sleeper; the next `run()` raises `SpoolLocked` until the child exits. Then document it, or close the fd in the child.
3. **The Python facts were checked on 3.15.0 only**, and the README's floor is 3.9 (AR0 fact 10). Test: run the nine checks under 3.9.
4. **Can `submit` write a nesting depth that `_load` cannot read?** (AL0 doubt 3, AR0 doubt 8.) Bisect the depth on 3.9 and on 3.15. Under O2 it matters less, because H2's and H3's fixes file the job either way.

## Open questions

1. For the desk lead: will two containers ever share `root`? Under O1 a pid from another namespace makes a live run look dead; under O2 it does not matter.
2. For the desk lead: does any runbook or habit depend on "remove `spool.lock` by hand"? Under O2 that becomes the one way to let two runs in.
3. Proposed: L0-H7's claim step, which moves a job out of `incoming/` before the handler, would end the re-run of H7 by design but changes crash recovery. It is a design question for another storm, if handlers are costly to repeat.

## Provenance

Holds: `LEDGER.md` § The storm's holds, card by card. Promises: `r1/analyst-R0-promises.md`, 39 rows. Python facts: `r1/analyst-L0-falsifier.py` and `r1/analyst-R0-falsifier.py`, both re-run by the ledger on 3.15.0. `flock` semantics, checked by the Visionary's own script on this machine: a SIGKILLed holder's lock is free at once, and a second open in the same process is refused. The script is in the scratchpad and is not part of the storm.

## Kudos

- **L0, the Saboteur**, for its wild card: the obvious fix for H1 lets two runs in at once. That turned a one-line fix into a design choice. Also for the disk arithmetic that gave H6 its weight.
- **R0, First Principles**, for the 39-row promise ledger behind the "12 of 39" measure, and for the `flock` Challenge, with its check that two `Spool` objects in one process still exclude each other because `flock` binds the open file.
- Both seats sealed early, and every citation held.

## The graveyard

Empty: no card died.

## Disclosures

1. My allowlist did not name measuring the sheet against its caps, which the skill requires. Both seats ran `wc` outside it, and L0 also ran `awk` and `python3 --version`. The gap was the brief's (G14).
2. My own draft graded H7 and H8 S2. The ledger follows the scale's letter and both seats, at S1.
3. No roll call was held as storm 00, and my holds entered at the ledger, not in an r2, because a spark has none (QUESTION assumption 5, `r1/visionary.md`).

## Grounds

- G13 again: R0's promise ledger came out at 9.8 KB against its 8 KB cap and was rewritten to 5.2 KB. The cap held it.
- G14 again: Disclosure 1.
- **G18, new: two lenses, one hold set.** In a review of a small closed file set, the Saboteur and First Principles found the same seven holds and the same wild-card mechanism. The lenses changed the route, not the findings. Filed in `GROUNDS.md`.

## Cost

| Round | Minutes | Sheet bytes | Cards | Alive after the ledger |
| ----- | ------- | ----------- | ----- | ---------------------- |
| r1 | 9 (18:01Z dispatch to 18:10Z, the last seal) | 31,285, plus 8,889 beside | 16, plus V's 10 | 1 |

Tokens: pending. They go in `COST.md` once the count of the seats' transcripts comes.

| Row | Seats | Cards | Survived | Alive | Findings | Confirmed | Misses |
| --- | ----- | ----- | -------- | ----- | -------- | --------- | ------ |
| V | V | 10 | 10 | 0 | — | — | — |
| 0 | L0, R0 | 16 | 16 | 1 | — | — | — |
| 1 | not seated | — | — | — | — | — | — |
| 2 | not seated | — | — | — | 6, by the ledger | 4 in full, 2 in part | not counted |
