---
kind: ledger
storm: 01-ada-spool-review
status: landed
date: 2026-11-09
author: visionary
---

# Storm Ada — ledger

A review, so each card is a hold. The storm's holds, H1 to H9, merge the cards that name one defect. A card's fate follows the four of the visionary skill. **Floor** means the hold is fixed under every option except the null. **Alive** means a mechanism that tells the fix options apart. Every hold below was opened at its line at `db2820c` and traced by hand. None of `spool.py` was run. Both falsifiers were re-run on Python 3.15.0 and their output matches the sheets.

## The storm's holds

| Hold | Sev | Where (`spool.py`) | Breaks (`README.md`) | Defect | Cards |
| ---- | --- | ------------------ | -------------------- | ------ | ----- |
| H1 | S1 | `:88` | `:28`, `:45` | The takeover test needs the dead pid to equal the caller's own, which is alive, so a dead run's lock is never taken over. | AL0-H1, AR0-H1, V-2 |
| H2 | S1 | `:133-147` | `:29` | `_release` runs only on a normal return; `KeyboardInterrupt`, `SystemExit` or a `RecursionError` from `:104` leaves the lock. | AL0-H2, AR0-H2, V-1 |
| H3 | S1 | `:113`, `:141-142` | `:39`, `:46` | A job that is empty, not UTF-8, not an object, or without `payload` is skipped, not filed: it stays in `incoming/` for good and is missing from the `Result`. | AL0-H3, AR0-H5, V-6 |
| H4 | S1 | `:114`, `:118-120` | `:24`, `:31`, `:34` | `max_attempts - 1` tries: none at 1, two at the default. `retried` is one over, and a sleep follows the last try. | AL0-H4, AR0-H3, V-4, V-5 |
| H5 | S1 | `:70`, `:137` | `:17`, `:23` | `reverse=True` runs newest first; with a `limit` and steady arrivals, the oldest never run. | AL0-H5, AR0-H4, V-3 |
| H6 | S1 | `:54-55` | `:15` | The default `tags=[]` is shared and appended to, and so is the caller's list: the n-th untagged job records n tags. | AL0-H6, AR0-H6, V-7 |
| H7 | S1 | `:110`, `:141-142` | `:39`, `:45` | An `OSError` from a move, after the handler ran, is swallowed: the job is re-run on every run while the fault lasts, and missing from the `Result`. | AL0-H7, AR0-H7, V-8 |
| H8 | S1 | `:83-90`, `:97` | `:3`, `:27` | Unreachable as shipped, live as soon as H1's guard is fixed alone: two takers race on a stale lock, and `_release` unlinks a lock that is not its own. | AL0-W, V-9, AR0 doubt 1 |
| H9 | S3 | `:39` | `:41` | The delay check refuses `Fraction`, `Decimal` and float subclasses, and an `int` past float range raises `OverflowError`, not `ValueError`. | V-10, AL0 doubt 6, AR0 doubt 3 |

H7 is S1 by the scale's letter, since the job runs more often than `README.md:45` allows; its trigger is a fault in `done/` or `failed/` (removed, unwritable, full, or on another device), not a normal path. R0 said so in its hold, and my draft graded it S2. H8 is graded on the code with H1's guard fixed alone. My draft graded it S2 as latent; both seats graded it S1 conditionally, and the ledger follows them, since a fix of H1 that ignores H8 lets two runs in at once.

## Cards

| Card | Title | By | Fate |
| ---- | ----- | -- | ---- |
| R1-AL0-H1 | A dead run's lock is never taken over | AL0 | floor: H1 |
| R1-AL0-H2 | `run` releases the lock only when it returns | AL0 | floor: H2 |
| R1-AL0-H3 | An unreadable job stays in `incoming/` | AL0 | floor: H3 |
| R1-AL0-H4 | One try fewer than `max_attempts` | AL0 | floor: H4 |
| R1-AL0-H5 | `pending` and `run` go newest first | AL0 | floor: H5 |
| R1-AL0-H6 | The shared default `tags` grows | AL0 | floor: H6 |
| R1-AL0-H7 | A failed move re-runs the job | AL0 | floor: H7 |
| R1-AL0-W | The obvious fix for H1 lets two runs in | AL0 | floor: H8 (its race); its fix is AR0-W's |
| R1-AR0-H1 | A dead run's lock is never taken over | AR0 | floor: H1, found independently |
| R1-AR0-H2 | The lock leaks when a run raises | AR0 | floor: H2, found independently |
| R1-AR0-H3 | One try fewer than `max_attempts` | AR0 | floor: H4, found independently |
| R1-AR0-H4 | Newest first; the oldest starve | AR0 | floor: H5, found independently |
| R1-AR0-H5 | An unreadable job is never filed | AR0 | floor: H3, found independently |
| R1-AR0-H6 | `submit` changes the caller's tags | AR0 | floor: H6, found independently |
| R1-AR0-H7 | A failed move is swallowed | AR0 | floor: H7, found independently |
| R1-AR0-W | Challenge to `README.md:46-48`: `flock` | AR0 | alive: the one mechanism that separates O1 from O2 |
| R1-V-1 to R1-V-10 | The Visionary's ten (`r1/visionary.md`) | V | floor: V-1 to V-8 in H1 to H7; V-9 in H8; V-10 in H9 |

1 of 26 cards is alive. 25 are floor. None goes to the graveyard: every card names a defect that holds at its line.

## Checks

No row 2 was seated. The ledger did the checks itself: every `path:line` on the sixteen cards and in both Facts lists, every cap, and both falsifiers re-run.

| Finding | On | Re-check |
| ------- | -- | -------- |
| L-1 | R1-AR0-H6 | Not confirmed in one clause. The hold says "writes nothing" of `README.md:15` breaks, but on disk it holds, as R0's own ledger row P12 says. What breaks is "left as it was". The hold stands. |
| L-2 | R1-AL0-H4 | Not confirmed in one citation. `README.md:41` holds: it is the line that makes `max_attempts=1` legal. The promise that breaks at 1 is `README.md:31` and `:34`, as AR0-H3 cites. The hold stands. |
| L-3 | AL0 doubt 6 | Confirmed: `math.isfinite(10**400)` raises `OverflowError` on 3.15.0, so `spool.py:39` breaks `README.md:41` at that edge. It is now H9. |
| L-4 | both sheets | Confirmed: both falsifiers re-ran in under a second, and their output matches F1-F5 (L0) and F1-F13 (R0). |
| L-5 | both sheets | Caps hold: 16,106 B and 15,179 B against 24 KB; every hold has 6 non-blank lines and is at most 1,288 B; the promise ledger is 5,176 B against 8 KB; the falsifiers are 40 lines each. |
| L-6 | both sheets | Seat slips, the allowlist's gap, not the seats'. L0 ran `python3 --version`, `wc` and `awk`, and disclosed it; R0 ran `wc -c` (its Grounds). The skill needs the caps measured, and the brief's allowlist did not name that step: G14 again. |

Every other cited line holds. Misses: not counted, since no check row was seated.

## Options

- **Floor**, carried by every option but the null: H2 to H7 fixed as the cards' Fix lines give, each with its card's check as a test; H9 fixed or noted in the README.
- **O0 · Ship as it stands** (the null): 12 of 39 README promises break (R0's ledger, `r1/analyst-R0-promises.md`).
- **O1 · Fix in place, keep the pid lock**: the floor, plus H1's guard fixed together with a takeover that a second taker cannot race (H8). `README.md:46-48` stay as written. ← AL0-H1, AR0-H1, AL0-W.
- **O2 · Fix in place, lock with `flock`**: the floor, plus `fcntl.flock(LOCK_EX | LOCK_NB)` on `spool.lock`, held for the run. That retires H1 and H8 together, and `README.md:46-48` are rewritten. ← AR0-W, AL0-W's Fix.

## The graveyard

Empty. No card died: the module is small, and both seats grounded every hold in the code.
