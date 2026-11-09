---
kind: sheet
storm: 01-ada-spool-review
round: r1
analyst: R0
lens: First Principles
status: sealed
date: 2026-11-09
---

# Storm Ada · r1 · R0 — First Principles

I turned every promising sentence of `README.md` into an invariant (39 of them, in `r1/analyst-R0-promises.md`) and traced `spool.py` by hand at each one's boundaries: the smallest legal value, the default, the same call twice, and a refused value. Twelve promises break. **Headline: the spool does not ship as it stands.** Seven holds pass the triage line, all S1 by the brief's scale. The worst two are H1 and H2 together: one Ctrl-C, or any crash of a run, leaves a lock that no later run takes over, so the spool stops until someone deletes `spool.lock` by hand. Each fix is one or two lines plus its test. The wild card is the one Challenge on this sheet: replace the pid lock with `flock`, which retires three declared limits and the race that a naive fix of H1 opens (D1).

## Cards

### R1-AR0-H1 · A dead run's lock is never taken over

- **Severity:** S1: after any death of a run, the spool stops until someone removes `spool.lock` by hand.
- **Defect:** the takeover test requires the dead pid to equal the caller's own pid, which is alive, so the test is never true.
- **Where:** `spool.py:88`; breaks `README.md:28` and the "next time" of `README.md:45`.
- **Trace:** a run dies (SIGKILL, the OOM killer, a deploy, or H2) and leaves `spool.lock` holding pid P. The next run fails the link (78), reads P (83), and finds `_alive(P)` False but `P == os.getpid()` also False, so it raises `SpoolLocked` (91). `os.kill(own pid, 0)` returns (F5), so no pid makes line 88 true. Every later run raises, and `incoming/` only grows.
- **The check that clears it:** `spool.lock` holds a pid no process has (above `/proc/sys/kernel/pid_max`), with one job queued: `run()` returns, the job is in `done/` and `spool.lock` is gone. With a live child's pid in the lock: `SpoolLocked`, and the lock is unchanged. Two processes held at line 89 on one stale lock: exactly one of them runs (D1).
- **Fix:** drop `and pid == os.getpid()`, and make the break safe against a second taker (D1, or the wild card). Cost S.

### R1-AR0-H2 · The lock leaks when a run raises

- **Severity:** S1: a `KeyboardInterrupt`, which `README.md:37` names, leaves the lock. With H1 the spool stops for good; even after H1 is fixed, a long-lived process never runs again.
- **Defect:** `_release` runs only on the normal return, and no `finally` guards lines 134-146.
- **Where:** `spool.py:147`; breaks `README.md:29`.
- **Trace:** the handler raises `KeyboardInterrupt`, or a hand-dropped job nested 200,000 deep raises `RecursionError` (F9). Neither is caught at 141 (F10), so the exception leaves `run` and `spool.lock` keeps this pid. A later `run()` in the same process reads its own live pid and raises `SpoolLocked` forever. A new process meets H1.
- **The check that clears it:** a handler that raises `KeyboardInterrupt`: `run()` raises it, `spool.lock` is absent, and the job is still in `incoming/`. A second `run()` in the same process with a normal handler returns with the job in `done/`.
- **Fix:** wrap 134-146 in `try:`, with `finally: self._release()`. Cost S.

### R1-AR0-H3 · The retry loop makes one try fewer than `max_attempts`

- **Severity:** S1: at the default of 3, a job that would succeed on its third try is failed; at the smallest legal value of 1, every job is failed without a single call.
- **Defect:** `range(1, self.max_attempts)` runs `max_attempts - 1` times, so the guard at 118 is always true.
- **Where:** `spool.py:114` and `:118`; breaks `README.md:34`, `:31` and `:24`.
- **Trace:** at `max_attempts=1`, `range(1, 1)` is empty (F4), so line 127 files the job in `failed/` and the handler is never called. At `max_attempts=3` with a handler that always retries, the spool makes tries 1 and 2 (F4). After each it adds to `retried` and sleeps (0.5 s, then 1.0 s), then files the job in `failed/`. `Result.retried` is 2 for the one retry made, and the last 1.0 s waits for a try that never comes.
- **The check that clears it:** a counting handler with a recording `sleep`. Always `RetryableError`, at `max_attempts` 1 and 3: 1 and 3 calls, `retried` 0 and 2, sleeps `[]` and `[0.5, 1.0]`, job in `failed/`. Retryable twice then a return, at 3: 3 calls, job in `done/`.
- **Fix:** `range(1, self.max_attempts + 1)`; the guard at 118 then does its job. Cost S.

### R1-AR0-H4 · Jobs run newest first, and under a limit the oldest starve

- **Severity:** S1: the README's order breaks on every call, and with `limit` and steady arrivals the oldest jobs stay in `incoming/` for good.
- **Defect:** `pending()` sorts with `reverse=True`, so the newest name comes first (F3).
- **Where:** `spool.py:70`, used at `:135-137`; breaks `README.md:17` and `:23`.
- **Trace:** every name begins with a 20-digit nanosecond time, so name order is time order. Reversed, `jobs[:limit]` (137) takes the `limit` newest jobs. A producer that adds `limit` jobs or more between runs keeps every older job out of every run for as long as it does so.
- **The check that clears it:** submit a, b and c in that order, at distinct times. `pending()` gives `[a, b, c]` by name, and `run(limit=1)` with a recording handler calls it with a's payload alone and returns `Result.done == [a]`.
- **Fix:** drop `reverse=True`. Cost S.

### R1-AR0-H5 · An unreadable job is never filed

- **Severity:** S1: a job that is empty, not UTF-8, not a JSON object, or has no `payload` stays in `incoming/` for good, and every run reads it again.
- **Defect:** `_load` runs outside any `try` in `_process`, and `run` swallows its `ValueError` with `continue` without filing the job.
- **Where:** `spool.py:113` and `:141-142`; breaks both sentences of `README.md:39`.
- **Trace:** an empty file, which the power cut of `README.md:46` can make, raises `JSONDecodeError`, a `ValueError` (F8). It passes out of `_process` to line 141, which continues: the job is not moved and not in the `Result`. `[1]` and `{}` take the same path through line 106. Once H4 is fixed these jobs are the oldest, so they lead every run: `limit` of them stop the spool.
- **The check that clears it:** four files in `incoming/`: empty, `b"\xff"`, `[1]` and `{"tags": []}`. `run()` with a recording handler: all four in `failed/` and in `Result.failed`, no call, and `incoming/` empty.
- **Fix:** catch `ValueError` and `RecursionError` around line 113, file the job in `failed/` and return False. Cost S.

### R1-AR0-H6 · `submit` changes the caller's tags, and the default list grows

- **Severity:** S1: `README.md:15` breaks on every normal `submit`; without tags, the n-th job of a process records n `"submitted"`.
- **Defect:** `tags=[]` is one list shared by every call on every `Spool` in the process, and line 55 appends to whatever list it gets, before the payload is checked.
- **Where:** `spool.py:54-55`; breaks "followed by", "left as it was" and "writes nothing" in `README.md:15`.
- **Trace:** three calls of `submit(p)` record one, then two, then three `"submitted"` (F6). Each extra tag costs 13 bytes (F7). After 100,000 untagged submits in one process the last job is 1.3 MB, the jobs come to about 65 GB in all, and every submit encodes the whole list. `submit(p, T)` with a reused `T` adds one tag per call, and a refused payload still appends.
- **The check that clears it:** three calls of `submit(p)` each record `["submitted"]`. With `t = ["a"]`, `submit(p, t)` leaves `t == ["a"]` and records `["a", "submitted"]`, and `submit(float("nan"), t)` raises `ValueError`, leaves `t == ["a"]`, and adds nothing to `incoming/`.
- **Fix:** `tags=None`, then build `[*(tags or ()), "submitted"]` as a new list. Cost S.

### R1-AR0-H7 · A failed move is swallowed, and the job runs on every run

- **Severity:** S1 by the brief's letter: the job runs more often than `README.md:45` allows, which is only after a death. The trigger is a fault in the layout, not a normal path.
- **Defect:** an `OSError` from `_finish`, after the handler has run, reaches the `continue` at 141, and the job stays in `incoming/`.
- **Where:** `spool.py:110` and `:141-142`; breaks `README.md:39` and `:45`.
- **Trace:** `done/` is removed or made unwritable while a long-lived `Spool` lives, or `done/` is a mount point (`EXDEV`). The handler returns, `os.replace` raises (110), and the run continues. The job is not in the `Result`, and the next run calls the handler again, on every run, for every job.
- **The check that clears it:** remove `done/` after construction, queue one job, and use a counting handler. Two `run()` calls make one handler call at most, the run raises or reports the job, and `spool.lock` is absent afterwards.
- **Fix:** before the first job, check that `done/` and `failed/` are writable directories on the device of `incoming/`, and let a filing error end the run after the release. Cost S to M.

### R1-AR0-W · Challenge to `README.md:46-48`: `flock`, not a pid in a file

- **Severity:** S3: it teaches rather than blocks. It retires the class behind H1, the cross-process half of H2, and D1.
- **Defect:** the lock's liveness is a pid read back from a file, so the spool guesses at deaths the kernel already knows of.
- **Where:** `spool.py:25-32` and `:72-97`. This is a Challenge to the declared limits `README.md:46` (an empty lock, removed by hand), `:47` (pid reuse) and `:48` (`spool.lock.PID.ID` left behind).
- **Trace:** from first principles, one run at a time needs a token that dies with its holder. `fcntl.flock(fd, LOCK_EX | LOCK_NB)` on an open `spool.lock` is released by the kernel on any exit, SIGKILL included. No pid is read, reused or empty, no temporary file exists, and there is no takeover to race. The pid can still be written into the file for people to read. These semantics are recalled, not checked this round (D7).
- **The check that clears it:** a child takes the lock and is SIGKILLed, and a new `run()` takes the lock at once. Two `Spool` objects in one process: the second raises `SpoolLocked`, because `flock` binds the open file, not the process as `lockf` does.
- **Fix:** `fcntl.flock` in `_acquire` and `close` in `_release`; Limits 46-48 shrink to "local filesystems only". Cost M, a two-way door.

## Facts found

1. `pending()` sorts reversed (`spool.py:70`), and on TIME-ID names that is newest first (F3).
2. `range(1, 1)` is `[]` and `range(1, 3)` is `[1, 2]` (F4), so `spool.py:114` makes `max_attempts - 1` tries.
3. `os.kill(os.getpid(), 0)` returns `None` (F5), so `_alive` of the caller's own pid is True and `spool.py:88` can never be true.
4. `spool.py:147` is the only call of `_release`, and `run` (130-148) has no `finally`.
5. Empty content raises `JSONDecodeError` and bytes that are not UTF-8 raise `UnicodeDecodeError`, both `ValueError` (F8). A 200,000-deep array raises `RecursionError`, which is neither `ValueError` nor `OSError` (F9), and `KeyboardInterrupt` is neither (F10).
6. A mutable default accumulates, recording one, two, then three tags over three calls (F6), and each extra `"submitted"` costs 13 bytes of JSON (F7).
7. `Path.glob("*.json")` does not match `X.json.tmp` (F2), so producers' temporary files stay out of `pending()`, as `README.md:48` says.
8. `json.dumps(..., allow_nan=False)` refuses a nested NaN with `ValueError` (F11), so `README.md:15`'s "finite numbers only" holds on disk.
9. The delay check `type(d) in (int, float)` (`spool.py:39`) refuses a `Fraction` (F12), and `os.kill` of a pid of 2^70 raises `OverflowError` (F13), which `spool.py:28` catches.
10. `git log` on the target names one commit, `db2820c`, which adds both files. The falsifier ran on Python 3.15.0 (F1), while `README.md:3` sets the floor at 3.9. I guess, unchecked, that facts 1 to 9 hold on 3.9.

`F` numbers are lines of the output of `r1/analyst-R0-falsifier.py` (40 lines, run with `python3 -I` against the scratchpad in under a second). It never imports or reads `spool.py`.

## Assumptions

1. A "path the README calls normal" includes Ctrl-C (named at `README.md:37`), `max_attempts=1` (legal by `README.md:41`), and `submit` with or without tags. This is what makes H2, H3 and H6 S1 rather than S2.
2. A file a producer drops by hand falls under `README.md:39`, since `README.md:3` says producers drop jobs in a directory.
3. Cost S is a line or two of code plus its test, and M is a changed mechanism plus a README edit.

## Doubts

1. Fixing H1 by dropping the conjunct opens a race between two takers. A and B both read a dead pid (`spool.py:83`). A unlinks the lock (89) and links its own (78), then B unlinks A's lock (89) and links its own. Two runs are now live, jobs run twice, and A's `_release` (97) later removes B's lock. That is S1 once fixed. Confidence: high.
2. A payload that serializes but does not round-trip (a tuple becomes a list, an int key becomes a string) reaches the handler as a different object from the one submitted (`spool.py:57`, `:104`). `README.md:15` promises only "JSON-serializable". S3 as a README note. Confidence: high that it happens, low that it matters.
3. The delay check refuses a `Fraction`, a `Decimal` and float subclasses (F12, `spool.py:39`), though `README.md:41` asks only for "finite numbers". S3. Confidence: high.
4. A run in another pid namespace, such as a container sharing `root`, puts to `_alive` a pid from the wrong namespace (`spool.py:25-32`). A live run can then look dead, so two runs run at once. `README.md:3` and `:47` arguably cover it; S3, or a Limits note. Confidence: medium.
5. `time.time_ns()` (`spool.py:56`) is the wall clock, so a backward step files a later job under an earlier time. `README.md:17` orders by "the submit time in their names", so the promise holds literally. S3. Confidence: high.
6. A `KeyboardInterrupt` between `os.replace` (`spool.py:63`) and the return makes `submit` raise with the job already written. `README.md:15` ties "writes nothing" to a bad payload. S3. Confidence: low that it matters.
7. The `flock` semantics in the wild card come from memory of flock(2); there was no web or man page this round. A handler that forks without exec would hold the lock in its child. Confidence: medium-high.
8. Whether `submit` can write a nesting depth that `_load` cannot read back (`spool.py:57` against `:104`) depends on the encoder and decoder sharing one depth limit, and I did not settle it. That is why H2's and H5's checks use hand-dropped files. Confidence: low.

## Grounds

1. The promise ledger first came out at 9.8 KB against the 8 KB cap (`wc -c`). The table padding, not the content, made the growth. I rewrote it as a one-line-per-promise list at 5.2 KB. This is near G13.

## Coverage

Read to the end, in the procedure, at `db2820c` with `git show`: `examples/02-spool-review/target/README.md` lines 1-48 and `examples/02-spool-review/target/spool.py` lines 1-148. Also read whole: `r1/brief.md`, `QUESTION.md`, `GROUND.md`, `BRIEFING.md`, `GROUNDS.md`, and the analyst skill. Skimmed: none. Not read: none of the file set. I ran `git log` on the target; I did not run `git blame`, because the one commit adds both files whole.
