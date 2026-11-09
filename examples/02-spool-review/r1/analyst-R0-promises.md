# Storm Ada · r1 · R0 — the promise ledger

Every promising sentence of `README.md` at `db2820c`, as an invariant, with the `spool.py` lines that keep it and the verdict from a hand trace at the boundaries (the smallest legal value, the default, the same call twice, a refused value). One row a promise: `#` · README line · invariant · `spool.py` lines · verdict. Hold and doubt ids are those of `r1/analyst-R0.md`.

- P1 · 3 · At most one run at a time on a `root`. · 72-94 · holds while no lock is ever taken over (H1); D1 for the fixed form.
- P2 · 3 · Every job a run takes is filed as done or failed. · 123, 125, 127, 141 · breaks: H3, H5, H7.
- P3 · 3 · Python 3.9 or later, standard library only. · 1-7, 65, 89, 94, 97 · holds: `missing_ok` is 3.8; imports are stdlib.
- P4 · 7 · The signature and defaults are as written. · 36 · holds.
- P5 · 7 · `incoming/`, `done/`, `failed/` exist after construction. · 51-52 · holds.
- P6 · 7 · `root` is absolute from construction on. · 41 · holds (`resolve` also follows links).
- P7 · 9 · Name = 20-digit ns submit time, `-`, random id, `.json`. · 56, 58 · holds.
- P8 · 9 · The file holds `payload`, `tags`, `created` = that time in seconds. · 57 · holds (`created` is a float of the same ns).
- P9 · 11 · The lock is `root/spool.lock`. · 50 · holds.
- P10 · 11 · The lock holds the taker's pid and never appears without it. · 73-78 · holds: written, then hard-linked into place.
- P11 · 15 · `submit` writes one job to `incoming/` and returns its name. · 59-67 · holds.
- P12 · 15 · Payload not JSON-serializable or not finite: `submit` raises, writes nothing. · 57, 64-65 · holds on disk (F11); the tags list is changed anyway (H6).
- P13 · 15 · The job's tags = the caller's tags + `"submitted"`. · 54-55, 57 · breaks on the default and on a reused list: H6.
- P14 · 15 · The caller's list is unchanged after `submit`, raised or not. · 55 · breaks on every call: H6.
- P15 · 15 · A job file is complete or absent; written beside, renamed into place. · 59-63, 70 · holds: `.json.tmp` is not globbed (F2).
- P16 · 17 · `pending()` is oldest first by the time in the name. · 70 · breaks: newest first (F3), H4.
- P17 · 21 · `run` returns a `Result` when it returns. · 134, 148 · holds.
- P18 · 23 · A run runs at most `limit` jobs, all when `None`. · 135-138 · holds for the count; `limit=0` runs none.
- P19 · 23 · A run takes jobs oldest first. · 70, 135-137 · breaks: H4.
- P20 · 24 · `done`/`failed` hold the names filed; `retried` = retries made. · 119, 143-146 · breaks: H3 (retried one over), H5 and H7 (names missing).
- P21 · 25 · A bad `limit` raises `ValueError` before the lock. · 131-133 · holds (bool refused, `0` legal).
- P22 · 27 · A live holder: `SpoolLocked`, nothing taken. · 80-91, 94 · holds.
- P23 · 28 · A lock whose process is dead is taken over. · 88-90 · breaks: the condition is never true (F5), H1.
- P24 · 29 · The lock is released on every exit after it is taken. · 147 · breaks: no `finally` (F10), H2.
- P25 · 31 · `handler(payload)` is called, the same object on each try. · 113, 116 · holds for the object; never called at `max_attempts=1` (F4), H3.
- P26 · 33 · A handler return files the job in `done/`. · 125 · holds unless the move fails (H7).
- P27 · 34 · `RetryableError`: up to `max_attempts` tries in all. · 114 · breaks: `max_attempts - 1` tries, H3.
- P28 · 34 · Wait before try k+1 = `min(base * 2**(k-1), max_delay)`. · 99-100, 120 · holds for the value; a wait also follows the last try (H3).
- P29 · 34 · Last try `RetryableError`: job to `failed/`. · 127 · holds in shape, one try early (H3).
- P30 · 35 · Any other `Exception`: `failed/` at once, not kept. · 122-124 · holds.
- P31 · 37 · A non-`Exception` `BaseException` ends the run. · 138-146 · holds; the lock stays (H2).
- P32 · 39 · Unreadable JSON or no `payload`: `failed/`, handler not called. · 102-107, 113, 141-142 · breaks: left in `incoming/` for good (F8), H5.
- P33 · 39 · On return, every job taken is in `done/` or `failed/` and in the `Result`. · 138-146 · breaks: H5, H7.
- P34 · 41 · Bad `max_attempts` or delays: `ValueError` from the constructor. · 37-40 · holds; stricter than written for delays (F12, D3).
- P35 · 41 · `sleep` replaces `time.sleep`. · 36, 46, 120 · holds.
- P36 · 45 · A run that dies before the move runs the job again next time. · 88, 133 · breaks: no later run takes the dead run's lock, H1.
- P37 · 46 · An empty or unreadable lock is never taken over. · 83-88 · holds (`pid` 0 is never taken).
- P38 · 47 · Liveness is judged by pid alone. · 25-32 · holds; a pid from another namespace is D4.
- P39 · 48 · A killed writer leaves only `.json.tmp` or `spool.lock.PID.ID`; no run reads them. · 59, 70, 73, 94 · holds.

Tally: 39 promises; 27 hold, 12 break (P2, P13, P14, P16, P19, P20, P23, P24, P27, P32, P33, P36). P1 holds today only because H1 keeps every lock forever; it is at risk in the fixed form (D1). The `F` numbers are lines of `r1/analyst-R0-falsifier.py`'s output, quoted in the sheet's Facts found.
