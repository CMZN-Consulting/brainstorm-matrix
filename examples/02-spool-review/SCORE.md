# The score

`python3 -I score.py`, run in this directory after the storm landed on 2026-11-09, reads `LEDGER.md` and `SYNTHESIS.md` against `ANSWER-KEY.md`. The key stayed outside the room while it ran. The scorer was written before the run and was not changed after it. The repository's history cannot show that order: the scorer and the key were kept outside the clone until the run had landed, and entered the repository together in the commit after it. Its output, verbatim, is the measured figure:

```text
| Defect | Kind | Verdict | Named at |
| ------ | ---- | ------- | -------- |
| D1 | off-by-one | missed | - |
| D2 | wrong default | missed | - |
| D3 | doc-to-code mismatch | named | README.md:15 at LEDGER.md:59 |
| D4 | resource not released | missed | - |
| D5 | wrong error path | missed | - |
| D6 | branch that cannot run | missed | - |

Lines of the target cited that match no planted defect: 8
- README.md:3, cited at SYNTHESIS.md:56
- README.md:28, cited at SYNTHESIS.md:32
- README.md:31, cited at LEDGER.md:60
- README.md:41, cited at LEDGER.md:60, LEDGER.md:61, SYNTHESIS.md:40, SYNTHESIS.md:54
- README.md:45, cited at LEDGER.md:27
- README.md:46-48, cited at LEDGER.md:48, LEDGER.md:72, LEDGER.md:73, SYNTHESIS.md:49, SYNTHESIS.md:50, SYNTHESIS.md:54
- README.md:46, cited at SYNTHESIS.md:65
- spool.py:39, cited at LEDGER.md:61

Named 1 of 6; named only where killed 0; missed 5; target citations 17; cited lines matching no planted defect 8.
```

## A reading, not the scorer's

The scorer counts a defect as named when a citation of the form `path:line` lies within two lines of one of its key lines. The ledger's hold table and the synthesis's table of holds give the lines of `spool.py` as `:88`, `:133-147` and so on, in a column headed with the file's name, so the scorer reads none of them. Read by hand against the key, the holds name all six planted defects, and no card was buried:

| Defect | Key lines | Hold | The hold's lines |
| --- | --- | --- | --- |
| D1 | `spool.py:114`, `:118` | H4 | `:114`, `:118-120` |
| D2 | `spool.py:54`, `:55` | H6 | `:54-55` |
| D3 | `spool.py:70`, `README.md:17`, `:23` | H5 | `:70`, `:137`, breaking `README.md:17` and `:23` |
| D4 | `spool.py:133`, `:147` | H2 | `:133-147` |
| D5 | `spool.py:141`, `:142` | H3 | `:113`, `:141-142` |
| D6 | `spool.py:88` | H1 | `:88` |

The scorer's one credit, D3, comes from `README.md:15` cited at `LEDGER.md:59`. That line is the promise about `tags`, the room's H6 and the key's D2; it lies two lines from the key's `README.md:17`, and the tolerance of two lines counts it.

Beyond the key, the room found three more:

- H7, `spool.py:110` and `:141-142`: a move that fails after the handler ran is swallowed, and the job runs again on every run. It is D5's `except` clause, met from the side of the move.
- H8, `spool.py:83-90` and `:97`: not reachable as shipped. Once H1's guard is fixed on its own, two runs race to take over a stale lock, and `_release` removes a lock that is not its own.
- H9, `spool.py:39`, graded S3: the check on the delays refuses `Fraction`, `Decimal` and subclasses of `float`, and an `int` past the range of a float raises `OverflowError`, not the `ValueError` that `README.md:41` promises. It was not planted; the ledger ran it again (its check L-3).

The cause is on the room's side: a hold table that cites lines under a column of file names, not as `path:line`.
