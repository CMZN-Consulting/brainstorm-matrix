---
kind: brief
storm: 01-ada-spool-review
round: r1
status: open
date: 2026-11-09
author: visionary
---

# Storm Ada · r1 · review

Weather: a dry front over a small module; two seats, one round, light winds.

**The question.** A job spool, `examples/02-spool-review/target/spool.py`, and its `README.md`, which states what the code promises, are about to ship. What would you hold the spool back for, and what check clears each hold? Read `QUESTION.md` and `GROUND.md` before anything else; then both target files whole, at the pin, `git show db2820c:PATH`.

**What this storm is for.** The desk lead's decision: whether the spool ships as it stands, and what is fixed before it does.

**The shape.** A review: holds, each with its `path:line`, its severity and the check that clears it, and no tournament. The stopping rule: your sheet is done when every line of both files has been read in your procedure and every defect that passes the triage line is a hold or a doubt.

**Your seat, your lens, your question, your files.**

| Seat | Row · effort | Lens             | Your question                                                                         | Your files                                       | Procedure                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ---- | ------------ | ---------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| L0   | 0 · xhigh    | The Saboteur     | What incident does this spool cause in its first ninety days, and which line causes it? | `spool.py`, `README.md` at `db2820c`, both whole | Walk every state change in `spool.py`: a file written, renamed, linked or unlinked; the lock taken or released; a job moved. For each, name the event that breaks it: a kill or a crash at that line, an exception out of the handler, the disk or the parser, a second run or a producer at the same moment, a power cut. Write what it leaves on disk and what the next run does with that; then the `README.md` line it breaks, or "no promise". |
| R0   | 0 · xhigh    | First Principles | Which promise of the README does the code not keep, and where?                          | `README.md`, `spool.py` at `db2820c`, both whole | Turn every sentence of `README.md` that promises something into a numbered invariant, in a ledger beside your sheet, `r1/analyst-R0-promises.md`: one row a promise, with its `README.md` line, the invariant, the `spool.py` lines that keep it, and holds or breaks. Check each by tracing the code by hand at the boundaries of every input the promise names: the smallest legal value, the default, the same call made twice, and a value the README says is refused. |

**The Saboteur.** _Stance:_ the pre-mortem. It is ninety days after launch and it failed, lost money, or woke someone at three in the morning: write the incident. _Asks:_ what breaks first: a race, a restart, stale data, an outage of something we depend on, a start in the wrong order, a human under stress? _Cards:_ designs driven by failure, each naming the incident it makes impossible.

**First Principles.** _Stance:_ start from what must be true (the rules of the domain, the mathematics, the physics of the machine, the cost) and rebuild from there; compare with today only at the end. _Asks:_ what is the irreducible job, and what would a clean sheet look like? _Cards:_ designs derived from named invariants, each invariant stated.

In this review, a lens's cards are holds. No row 1 or row 2 is seated: the Visionary opens every hold at its line in the ledger.

**Severity.** One of three, with its reason in one line.

- **S1 · blocks the ship.** A README promise breaks on a path the README calls normal; or a job is lost, stranded in `incoming/` for good, or run more often than the Limits (`README.md:45-48`) allow; or the spool stops running jobs until someone acts by hand.
- **S2 · fixed before the ship.** A promise breaks on an error or an edge path, or a `Result` is wrong, and no job is lost or stranded.
- **S3 · may ship with a README note.** The code is stricter or looser than the README says with no job affected, or the README is wrong where the code is sound.

**Look for.** Each class with the check that finds it.

1. A promise with no line that keeps it. Check: name the line for each promising sentence of the README.
2. A loop or a range off by one. Check: count its iterations by hand at the smallest legal bound and at the default.
3. A condition that can never be true, or never false. Check: evaluate it for every combination its inputs can take.
4. A resource taken and not released on every exit. Check: list each exit of the function (a return, a raised `Exception`, a raised `BaseException`) and what each leaves behind.
5. An `except` too wide or too narrow. Check: for each call inside its `try`, the exceptions that call can raise, and where each one lands.
6. An order or a direction opposite to the promise. Check: the sort key and its direction against the README's words.
7. State shared across calls, or with the caller. Check: every default argument, and every argument the function mutates.
8. A race between two processes. Check: interleave two of them line by line where they touch the same file.
9. A value read from disk and trusted. Check: the worst content that file can hold, followed through the code.
10. A count or a name in the `Result` that disagrees with what happened. Check: tally it by hand for one job that succeeds, one that retries and then succeeds, and one that fails.

**The hold's shape.** Ids are `R1-AL0-H1`, `R1-AR0-H1` and on, most severe first; the wild card is `R1-AL0-W` or `R1-AR0-W`, the hold you would hesitate to raise, judged on what it teaches rather than on whether it blocks. Each hold is at most 14 non-blank lines and 1.8 KB:

```markdown
### R1-AL0-H1 · TITLE

- **Severity:** S1, S2 or S3, and the reason in one line.
- **Defect:** one sentence.
- **Where:** `spool.py:N`, and the `README.md:N` it breaks, or "no promise".
- **Trace:** two to five lines: the input or the event, the lines it passes, what is left on disk or returned.
- **The check that clears it:** a test or a reading the team can run after the fix: its inputs, and the result that passes.
- **Fix:** one line, or "none obvious".
```

**Done when.** Your holds, as many as the code gives up to seven, and the wild card; a defect past the seventh goes under Doubts in one line, with its severity and its `path:line`. Every hold passes one triage line first: does it change whether the spool ships, or what is fixed before it does? A defect that does not becomes a doubt or is not written. Every hold names its `path:line`, its severity and its check. Your Coverage equals your file set, file for file, every line of both. R0's promise ledger has a row for every promising sentence of the README. A doubt is welcome even when it proves wrong: raise it with your confidence and its `path:line`.

**Deliver.** `storms/01-ada-spool-review/r1/analyst-SEAT.md`, in the sheet shape of the analyst skill with holds for cards: one opening paragraph, with your headline on whether the spool ships as it stands; the holds and the wild card; Facts found (at most ten); Assumptions; Doubts; Grounds; Coverage, with Not read. Write "none" rather than leave out a section. An artifact past 20 lines or a table past 15 rows goes beside the sheet as `r1/analyst-SEAT-NAME.EXT` (R0's promise ledger is one), at most 8 KB. The caps, the checks and the routes are the analyst skill's § Max effort and the thread: 24 KB a sheet with its Coverage, 14 non-blank lines and 1.8 KB a hold, the sheet on disk with its Coverage skeleton and `status: draft` before the first hold. Box: 50 minutes, ending at 18:55Z; at its end, seal.

**This round.** Alone: open no other sheet of r1. Challenges: at most one, and a hold against a limit the README declares (`README.md:45-48`) is one; a hold where the code falls short of a limit as written is an ordinary hold. The allowlist, which is the law for this round:

- read the room's files (this brief, `QUESTION.md`, `GROUND.md`, `BRIEFING.md`, `GROUNDS.md`, your skill) and the two target files, with `git show db2820c:PATH`, `git log` and `git blame` on them, and `cat -n`, `sed -n` and `grep -n` on those files;
- list a directory, read the clock, use your scratchpad, write your sheet and the files beside it;
- one falsifier script, as the skill allows: your own code, at most 40 lines and two minutes, beside your sheet as `r1/analyst-SEAT-falsifier.py`, to settle a fact about Python or the operating system that a hold turns on. It never imports, runs or pastes `spool.py`, since none of the reviewed code runs; it opens no network and writes only to your scratchpad;
- no helpers, no web.
