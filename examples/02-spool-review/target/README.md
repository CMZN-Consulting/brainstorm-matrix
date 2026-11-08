# spool

A job spool on the local disk of one POSIX machine. Producers drop jobs in a directory; one run at a time passes them to a handler and files each job as done or failed. Python 3.9 or later, standard library only.

## Layout

`Spool(root, handler, max_attempts=3, base_delay=0.5, max_delay=8.0, sleep=time.sleep)` makes three directories under `root` if they are missing: `incoming/`, `done/` and `failed/`. `root` is made absolute when the spool is built.

A job is one JSON file, `TIME-ID.json`: the submit time in nanoseconds, zero-padded to 20 digits, and a random id. It holds `payload`, `tags` and `created`, the same submit time in seconds.

The lock is the file `spool.lock` in `root`. It holds the process id of the run that took it, and it appears with that id already written.

## Producing

`submit(payload, tags)` writes a new job to `incoming/` and returns its file name. The payload must be JSON-serializable, with finite numbers only; otherwise `submit` raises and writes nothing. `tags` is optional, a list of strings. The job records them followed by `"submitted"`, and the caller's list is left as it was. The job file appears complete or not at all: it is written beside its final name and renamed into place.

`pending()` returns the paths of the jobs in `incoming/`, oldest first by the submit time in their names.

## Running

`run(limit=None)` runs pending jobs and returns a `Result`.

- It runs at most `limit` jobs, all of them when `limit` is `None`, oldest first.
- The `Result` holds the file names in `done` and in `failed`, and `retried`, the number of retries.
- `limit` is `None` or an integer of at least 0; anything else is a `ValueError`, raised before the lock is taken.

- `run` takes the lock first. While another live run holds it, `run` raises `SpoolLocked` and takes nothing.
- A lock whose process no longer runs is taken over.
- A run that took the lock releases it whether it returns or raises.

For each job, `run` calls `handler(payload)`, with the same payload object on every try:

- when it returns, the job moves to `done/`;
- when it raises `RetryableError`, the job is tried again, up to `max_attempts` tries in all. Before try `k + 1` the spool waits `base_delay * 2 ** (k - 1)` seconds, never more than `max_delay`. A job whose last try raises `RetryableError` moves to `failed/`;
- when it raises any other `Exception`, the job moves to `failed/` at once. The exception is not kept.

A `BaseException` that is not an `Exception`, such as `KeyboardInterrupt`, ends the run.

A job file that cannot be read as JSON, or holds no `payload`, moves to `failed/` without a call to the handler. When a run returns, every job it took is in `done/` or `failed/`, and its name is in the `Result`.

`max_attempts` must be an integer of at least 1, and the delays finite numbers that are not negative; otherwise the constructor raises `ValueError`. The `sleep` argument replaces `time.sleep`, for tests.

## Limits

- Delivery is at least once. A run that dies after the handler returns, and before the job is moved, runs that job again next time, so handlers must tolerate a second call.
- Nothing is synced to disk. After a power cut a job may be lost, be empty, or be back in `incoming/`, and the lock may be empty. An empty or unreadable lock is never taken over; remove it by hand.
- Whether a lock's process runs is judged by its process id alone, so a reused id keeps a dead run's lock.
- A process killed while it writes leaves its temporary file behind: a `.json.tmp` in `incoming/` from a producer, a `spool.lock.PID.ID` in `root` from a run taking the lock. No run reads them.
