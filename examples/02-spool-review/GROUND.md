---
kind: ground
storm: 01-ada-spool-review
status: living
date: 2026-11-09
author: visionary
---

# Storm Ada — ground

## Reading list

Analysts start here, in this order. Read at the pin: `git show db2820c:PATH`.

1. `examples/02-spool-review/target/README.md` — the contract: 48 lines, four sections.
2. `examples/02-spool-review/target/spool.py` — the module: 148 lines, standard library only.

## Facts

Pinned to `db2820c16fe7e7c58b3e7e50071fe4614e3d6aa2` of this repository. Both files are byte-identical at `HEAD` (`6ec3310`), so the line numbers below hold in the working tree too; cite them as `spool.py:N` and `README.md:N`.

1. One commit touches the target: `db2820c`, 2026-11-08, which adds both files whole. There is no earlier version, no test file and no caller anywhere in the repository (`git grep -i spool db2820c`, outside the target, finds nothing).
2. The README's sections: Layout `README.md:5-11`, Producing `README.md:13-17`, Running `README.md:19-41`, Limits `README.md:43-48`. It names Python 3.9 or later and the standard library only (`README.md:3`).
3. The module's surface: exceptions `SpoolLocked` (`spool.py:10`) and `RetryableError` (`spool.py:14`); the dataclass `Result` (`spool.py:18-22`); the helper `_alive` (`spool.py:25-32`); the class `Spool` (`spool.py:35`).
4. `Spool`'s methods: `__init__` `spool.py:36-52`, `submit` `spool.py:54-67`, `pending` `spool.py:69-70`, `_acquire` `spool.py:72-94`, `_release` `spool.py:96-97`, `_delay` `spool.py:99-100`, `_load` `spool.py:102-107`, `_finish` `spool.py:109-110`, `_process` `spool.py:112-128`, `run` `spool.py:130-148`.
5. Public calls the README documents: the constructor (`README.md:7`, `README.md:41`), `submit` (`README.md:15`), `pending` (`README.md:17`), `run` (`README.md:21-39`). The private methods carry no promise of their own; they carry the public ones.
6. The README's Limits (`README.md:45-48`) declare four things the spool does not promise: delivery at least once, no sync to disk, liveness by process id alone, and temporary files left by a killed writer.

## Settled

None. No ruling touches the spool; the README is the contract by the brief's words.

## Unknowns

1. Who calls the spool, with which handlers, and how often: no caller exists in the repository.
2. The filesystem `root` will sit on. The README says local disk on one POSIX machine (`README.md:3`); nothing names one.
3. Whether one process ever holds two `Spool` objects on one `root`, or runs one from two threads. The README says one run at a time (`README.md:3`) and is silent on threads.
4. The Python version the spool will ship on, past "3.9 or later".

## Coverage

Read to the end: `README.md`, `spool.py`, the commit message of `db2820c`. Skimmed: none. Not opened: the rest of the repository, by the brief's scope.
