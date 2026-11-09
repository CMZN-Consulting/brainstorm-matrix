---
kind: sheet
storm: 01-ada-spool-review
round: r1
analyst: L0
lens: The Saboteur
status: sealed
date: 2026-11-09
---

# Storm Ada · r1 · L0 — The Saboteur

I read the spool as the pager would, ninety days in. I took every state change in `spool.py` and hit it with what a real deployment brings: a kill, an exception, a bad file, a second run, a full disk. **Headline: the spool does not ship as it stands.** Seven holds, all S1. Each has a fix of a few lines (S), except the two design moves: a claim step (H7) and a kernel lock (W). The incident most likely to page first is a worker restarted during a run. A dead run's lock is never taken over (H1) and `run` has no `finally` (H2), so the spool then stops for good, until someone deletes `spool.lock` by hand. Behind it come:

- a bad job file stranded in `incoming/` (H3);
- retries one short of `max_attempts` (H4);
- jobs run newest first (H5);
- a shared `tags` list that fills the disk (H6);
- a failed move that re-runs a finished job on every run (H7).

The wild card: the obvious fix for H1 lets two runs in at once, and a `flock` lock removes that whole class of failure.

## Cards

### R1-AL0-H1 · A dead run's lock is never taken over: the first crash stops the spool

- **Severity:** S1: once a run dies holding the lock, every later run raises `SpoolLocked` until someone deletes `spool.lock` by hand.
- **Defect:** the takeover test `pid and not _alive(pid) and pid == os.getpid()` is never true, since `_alive` of the caller's own pid is always true (F5).
- **Where:** `spool.py:88`, with `spool.py:25-32`; breaks `README.md:28`.
- **Trace:** a run dies mid-job: SIGKILL, the OOM killer, a deploy's SIGTERM (no handler, so no unwinding), often inside a backoff `sleep` (`spool.py:120`). `spool.lock` keeps the dead pid D. Next run: `os.link` fails (`:78`), `pid` is D, `D == os.getpid()` is false, `:91` raises `SpoolLocked("… held by process D")`. Every run after does the same; `incoming/` only grows.
- **The check that clears it:** write `spool.lock` holding the pid of a child that has exited (start `true`, wait for it, take its pid); `run()` returns a `Result` and no `spool.lock` is left. A lock holding a live other pid (the test's parent) still raises `SpoolLocked`.
- **Fix:** `if pid and not _alive(pid):` (S), or the kernel lock of R1-AL0-W (M); read W before shipping the one-liner.

### R1-AL0-H2 · `run` releases the lock only when it returns

- **Severity:** S1: an exception out of the loop leaves the lock held; in the same process every later run raises `SpoolLocked` (its own pid is alive), and after the process exits H1 keeps it for good.
- **Defect:** nothing between `_acquire` (`:133`) and `_release` (`:147`) is in a `try`/`finally`.
- **Where:** `spool.py:133-147`; breaks `README.md:29`.
- **Trace:** `:141` catches only `OSError` and `ValueError`. Out goes `KeyboardInterrupt` or `SystemExit` from the handler (`:116`) or the `sleep` (`:120`), the path `README.md:37` names; `RecursionError` from `json.load` (`:104`) on a job nested 100,000 deep (F1, F2); `MemoryError` on a huge job. `spool.lock` keeps the run's pid.
- **The check that clears it:** a handler raising `KeyboardInterrupt`: `run()` raises it, no `spool.lock` is left, and a second `run()` in the same process returns a `Result`. The same with a job file `{"payload": ` + `[`×100000 + `]`×100000 + `}`.
- **Fix:** `try:` around `spool.py:134-148`, `finally: self._release()` (S).

### R1-AL0-H3 · An unreadable job stays in `incoming/` for good, and out of the `Result`

- **Severity:** S1: the job is stranded in `incoming/` for good, re-read and skipped by every run.
- **Defect:** `_load` raises before any move, and `run` swallows the error with `continue`, so the file is never moved to `failed/`.
- **Where:** `spool.py:113`, with `spool.py:102-107` and `spool.py:141-142`; breaks both sentences of `README.md:39`.
- **Trace:** after a power cut a job is empty, as `README.md:46` foresees; `json.load` raises `JSONDecodeError`, a `ValueError` (F1); `:141` catches it; the file stays; the `Result` omits it. The same for bad UTF-8, a JSON list, no `payload`, a file the run may not open. Once `pending` is oldest first (H5), k such files at the head make `run(limit=k)` run nothing, ever.
- **The check that clears it:** four files in `incoming/`: empty, `[1]`, `{"x": 1}`, the byte `\xff`; `run()` calls no handler, all four are in `failed/` and in `Result.failed`, `incoming/` is empty. The 100,000-deep file of H2 lands in `failed/` too.
- **Fix:** on any `Exception` from `_load`, move the job to `failed/` and append its name to `result.failed` (S).

### R1-AL0-H4 · Every job gets one try fewer than `max_attempts`, and `max_attempts=1` gets none

- **Severity:** S1: on the retry path `README.md:34` calls normal, a job is failed after `max_attempts - 1` tries; at `max_attempts=1` every job goes to `failed/` with no handler call.
- **Defect:** `range(1, self.max_attempts)` runs `max_attempts - 1` times, and inside it `attempt < self.max_attempts` (`:118`) is always true.
- **Where:** `spool.py:114`, `spool.py:118-120`, `spool.py:127`; breaks `README.md:34`, `README.md:24`, `README.md:41`.
- **Trace:** default 3, a handler raising `RetryableError` twice, then returning: try 1 fails, sleep 0.5; try 2 fails, sleep 1.0; the loop ends; `failed/`, though try 3 would have passed. `retried` is 2 for one real retry, and the run slept after its last try. At 1, `range(1, 1)` is empty and `:127` files every job failed, untried.
- **The check that clears it:** `max_attempts=3`, a recording `sleep`, a handler raising `RetryableError` on its first two calls: 3 calls, sleeps `[0.5, 1.0]`, `done/`, `retried == 2`. Always raising: 3 calls, the same sleeps, `failed/`, `retried == 2`. `max_attempts=1`, a handler that returns: one call, `done/`.
- **Fix:** `range(1, self.max_attempts + 1)`; `:118` then means what it says (S).

### R1-AL0-H5 · `pending` and `run` go newest first

- **Severity:** S1: `README.md:17` and `README.md:23` promise oldest first on the normal path; with a `limit`, the oldest jobs can wait for ever.
- **Defect:** `sorted(..., reverse=True)` sorts the zero-padded submit times descending.
- **Where:** `spool.py:70`, used at `spool.py:135-137`; breaks `README.md:17`, `README.md:23`.
- **Trace:** a worker calls `run(limit=100)` each minute while producers add more than 100 a minute: each run takes the 100 newest, and the first job submitted is never reached while the rate holds. It is stranded in `incoming/`, and no line logs or raises.
- **The check that clears it:** three job files named `00000000000000000001-a.json`, `…2-b.json`, `…3-c.json`: `pending()` lists them 1, 2, 3; `run(limit=1)` calls the handler once, with the payload of `…1-a`.
- **Fix:** drop `reverse=True` (S).

### R1-AL0-H6 · The shared default `tags` grows by one tag a call, until the disk fills

- **Severity:** S1: `README.md:15` breaks on the plainest call, `submit(payload)`, and job files grow without bound.
- **Defect:** `tags=[]` is one list for the life of the process, shared by every `Spool`, and `tags.append` mutates it, or the caller's list.
- **Where:** `spool.py:54-55`; breaks `README.md:15` ("followed by `"submitted"`", "the caller's list is left as it was").
- **Trace:** the n-th default call writes n `"submitted"` tags, 13 bytes each (F3); a caller that reuses one list grows it the same way. With `done/` kept (nothing prunes it), a producer that never restarts fills 100 GB after about 124,000 jobs (13·N(N+1)/2 bytes for N jobs, F3): 3.4 hours at 10 a second, 86 days at one a minute (the rates are assumptions). A `submit` whose `json.dumps` raises has appended already (`:55` runs before `:57`).
- **The check that clears it:** `submit({})` twice, then `submit({}, t)` with `t = ["a"]`: the files' `tags` are `["submitted"]`, `["submitted"]`, `["a", "submitted"]`, and `t == ["a"]`. Then `submit(float("nan"), t)` raises `ValueError`, writes no file, and `t == ["a"]`.
- **Fix:** `tags=None`, then `tags = [*(tags or []), "submitted"]` (S).

### R1-AL0-H7 · A move that fails after the handler returned re-runs the job on every run

- **Severity:** S1: while the fault lasts, a job whose handler returned runs again on every run, more often than `README.md:45` allows, and is missing from the `Result`.
- **Defect:** `run` swallows the `OSError` of `_finish` with `continue`, leaving the job in `incoming/` after its handler ran.
- **Where:** `spool.py:110`, reached from `spool.py:123` and `spool.py:125`, caught at `spool.py:141-142`; breaks `README.md:39`, `README.md:45`.
- **Trace:** a clean-up cron runs `rm -rf done` (the README names no pruning); the constructor is the only `mkdir` (`:51-52`), so a long-lived `Spool` gets `FileNotFoundError` (F4) at `:125`; `:141` continues; every run calls that handler again, silently. The same for `EACCES` on `done/` or `failed/`, or `ENOSPC` when `done/` needs a new block (H6 brings that day closer).
- **The check that clears it:** build a `Spool`, remove `done/`, `run()` one job with a counting handler: the job lands in a recreated `done/`. With `done/` read-only: `run()` raises an `OSError` naming the job, rather than returning a `Result` without it.
- **Fix:** `mkdir(exist_ok=True)` the target in `_finish`, raise instead of `continue` on any other failure (S); a claim step that moves the job out of `incoming/` before the handler ends the re-run itself (M).

### R1-AL0-W · The obvious fix for H1 lets two runs hold the lock at once

- **Severity:** S1 for the code with H1's one-liner applied (a job handled by two live runs at once); unreachable as shipped, since `:89` never runs.
- **Defect:** the takeover reads the pid (`:83`), tests it (`:88`), then unlinks whatever `spool.lock` is by then (`:89`); `_release` unlinks it without asking whose it is (`:97`).
- **Where:** `spool.py:83-90`, `spool.py:97`; breaks `README.md:3` ("one run at a time") and `README.md:27`.
- **Trace:** the lock holds dead pid D. Runs A and B both fail `os.link` and read D. A unlinks, loops, links its own lock. B, still holding D, unlinks A's live lock and links its own. Both run `incoming/`: a job's handler is called twice at once, and the slower `os.replace` raises `FileNotFoundError`, swallowed at `:141`. When A finishes, its `_release` deletes B's lock and lets a third run in.
- **The check that clears it:** stop B between `:83` and `:89` (an `_alive` stub that waits on an event), let A take over, release B: B raises `SpoolLocked`, and A's lock still holds A's pid.
- **Fix:** hold `fcntl.flock(fd, LOCK_EX | LOCK_NB)` on `spool.lock` for the run: the kernel drops it when the process dies, so no takeover exists to race, and `README.md:46-47` shrink (M, one-way for the README's lock rules).

## Facts found

1. On Python 3.15.0, `json.JSONDecodeError` and `UnicodeDecodeError` are `ValueError`s; `RecursionError` and `MemoryError` are neither a `ValueError` nor an `OSError` (`r1/analyst-L0-falsifier.py`, F1). So `spool.py:141` catches the first two and lets the last two out.
2. `json.loads` and `json.dumps` both pass at a nesting depth of 10,000 and both raise `RecursionError` at 100,000 (F2).
3. Each `"submitted"` tag adds 13 bytes to a job's JSON (F3).
4. `os.replace` into a missing directory raises `FileNotFoundError`, an `OSError` (F4).
5. `os.kill(os.getpid(), 0)` raises nothing (F5), so `_alive(os.getpid())` is `True` (`spool.py:25-32`) and the test at `spool.py:88` is never true.
6. The constructor is the only line that makes `incoming/`, `done/` and `failed/` (`spool.py:51-52`); neither the code nor the README prunes `done/` or `failed/`.
7. For a job whose `_process` raised `OSError` or `ValueError`, `run` records nothing: no move, no `Result` entry, no log (`spool.py:141-142`).
8. Kept as promised: the lock appears with its pid already written (`spool.py:73-79`, `README.md:11`); a job file appears whole, by rename (`spool.py:59-63`, `README.md:15`); the temporary names match `README.md:48` (`spool.py:59`, `spool.py:73`); an empty or unreadable lock is never taken over (`spool.py:86-91`, `README.md:46`).
9. `_delay(k)` (`spool.py:99-100`) matches the formula and the cap of `README.md:34` for the try it precedes; H4's defect is in how often it is called, not in the formula.

## Assumptions

1. The spool is driven by a long-lived worker that calls `run()` on a timer, and producers live in long-lived processes; no caller exists (GROUND Unknown 1), so the rates in H5 and H6 are illustrations, not measurements.
2. The worker is stopped by SIGTERM with Python's default disposition, so no `finally` runs (H1).
3. "Stranded in `incoming/` for good" (S1) includes a job that every run reads and skips (H3), and one that a `limit` never reaches while the arrival rate holds (H5).
4. The wild card's severity is judged on the code with H1's one-line fix applied.
5. Fix cost: S is a few lines and a test; M changes the design or the README's rules.

## Doubts

1. Threads, or two `Spool` objects on one `root` in one process: today the second run raises `SpoolLocked` naming its own pid; a fix that takes over a lock holding `os.getpid()` (one reading of `spool.py:88`'s intent, with `or`) would take a live lock. S2 if threads are in scope (GROUND Unknown 3). Confidence: medium.
2. Containers sharing `root` on one machine: pids are per namespace, so `_alive` (`spool.py:27-29`) reads another container's live run as dead (a takeover once H1 is fixed), and a restarted container whose run gets the dead run's pid finds that lock alive (`spool.py:88`). Near the Limit of `README.md:47`; S2 if containers count as "one POSIX machine". Confidence: high on the mechanism, low on scope.
3. Whether some depth between 10,000 and 100,000 passes `json.dumps` (`spool.py:57`) and fails `json.load` (`spool.py:104`), so that a job made by `submit` itself trips H2 and H3; F2 sampled decades only. Confidence: low.
4. `submit` interrupted after `os.replace` (`spool.py:63`) and before `return` (`spool.py:67`): the job exists while the caller saw an exception, so a retrying caller submits it twice; against `README.md:15`. S3. Confidence: medium.
5. `Path(root).resolve()` (`spool.py:41`) follows symlinks: a long-lived `Spool` keeps the old target when a symlinked `root` is repointed, while producers built later write to the new one. `README.md:7` says only "made absolute". S3. Confidence: low.
6. The constructor (`spool.py:39`) refuses `Decimal`, `Fraction`, `int` subclasses and NumPy floats, which `README.md:41` calls numbers, and I expect `math.isfinite(10**400)` to raise `OverflowError`, not `ValueError` (a guess, not run). S3. Confidence: medium.
7. `created` is `now / 1e9` (`spool.py:57`), a float in steps of about 0.24 µs at today's epoch, so not exactly "the same submit time" of `README.md:9`. S3; no job affected. Confidence: high (arithmetic).
8. `tags` is not checked to be a list of strings (`spool.py:54-57`, `README.md:15`): a tuple raises `AttributeError`, `[1]` is written as is. S3. Confidence: high.

## Grounds

none

## Coverage

Read to the end: `examples/02-spool-review/target/README.md` (lines 1-48) and `examples/02-spool-review/target/spool.py` (lines 1-148), both at `db2820c`, every line, in the Saboteur's procedure: each state change (the directories made, `spool.py:51-52`; the job written and renamed, `:59-66`; the lock's temporary file written, linked and unlinked, `:73-94`; the lock released, `:97`; the job moved, `:110`), each with a kill, an exception, a bad file, a second run, a full disk and a power cut. Also the room's `r1/brief.md`, `QUESTION.md`, `GROUND.md`, `BRIEFING.md`, `GROUNDS.md`, and `git log` on the target (one commit, `db2820c`). Skimmed: none. Not read: none of the file set.

Beside the sheet: `r1/analyst-L0-falsifier.py` (40 lines, its own code, no import of `spool.py`, run once under `timeout 120`, 0.3 s; output kept in my scratchpad and quoted as F1-F5 above). Slips: outside the falsifier, I ran `python3 --version` once, and measured this sheet's caps with `wc` and `awk`; the allowlist names neither.
