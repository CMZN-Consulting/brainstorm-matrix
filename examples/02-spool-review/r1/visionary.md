---
kind: sheet
storm: 01-ada-spool-review
round: r1
analyst: V
lens: none
status: sealed
date: 2026-11-09
---

# Storm Ada · r1 · V — the Visionary's own reading

Drafted in the Visionary's scratchpad at 18:02Z, from the two files at `db2820c`, before either sheet of r1 was opened. It was copied here after both sheets were sealed at 18:10Z, with only the ids and the format changed. A spark has no r2, so these holds enter at the ledger and carry no more weight than any other card.

| Card    | Sev | Where                       | Defect                                                                                                                                                | README          |
| ------- | --- | --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| R1-V-1  | S1  | `spool.py:133-147`          | No `try`/`finally`: any exception that leaves the loop (a `BaseException`, a `RecursionError` from `_load`, anything from `pending`) skips `_release`. | `:29`           |
| R1-V-2  | S1  | `spool.py:88`               | `not _alive(pid) and pid == os.getpid()` is never true, so no stale lock is ever taken over.                                                           | `:28`           |
| R1-V-3  | S1  | `spool.py:70`, `:137`       | `reverse=True` is newest first, and `jobs[:limit]` takes the newest.                                                                                   | `:17`, `:23`    |
| R1-V-4  | S1  | `spool.py:114`, `:127`      | `range(1, max_attempts)` makes `max_attempts - 1` tries; at 1 the handler is never called.                                                             | `:34`, `:41`    |
| R1-V-5  | S2  | `spool.py:118-120`          | The guard is always true inside the loop: a sleep after the last try, and `retried` counts tries that raised.                                          | `:24`, `:34`    |
| R1-V-6  | S1  | `spool.py:113`, `:141-142`  | A `_load` error is swallowed by `continue`: the job stays in `incoming/` and is missing from the `Result`.                                              | `:39`, `:46`    |
| R1-V-7  | S1  | `spool.py:54-55`            | The mutable default `tags=[]` is appended to, and so is the caller's list.                                                                             | `:15`           |
| R1-V-8  | S2  | `spool.py:110`, `:141`      | An `OSError` from `_finish` is swallowed: the job ran, but is missing from the `Result` and may stay in `incoming/`.                                    | `:39`           |
| R1-V-9  | S2  | `spool.py:83-89`, `:97`     | Latent: the takeover's read, check and unlink are not atomic, and `_release` unlinks whatever lock is there. It goes live once V-2 is fixed.             | `:3`, `:27`     |
| R1-V-10 | S3  | `spool.py:39`               | `type(d) in (int, float)` refuses float subclasses, `Fraction` and `Decimal`.                                                                         | `:41`           |

Doubts at drafting: deep nesting in `json.load` raises `RecursionError`, which `:141` does not catch (checked at 18:04Z on Python 3.15.0: depth 100,000 raises it); `_load` accepts `NaN` from a hand-placed file, while the README promises finiteness only for `submit`; `created` is a float, which is not a hold.
