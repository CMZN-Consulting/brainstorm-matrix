---
kind: question
storm: 01-ada-spool-review
status: open
date: 2026-11-09
author: visionary
asked-by: desk-lead
size: spark
---

# Storm Ada — review the spool before it ships

## The brief

> **The question.** Review the job spool in `examples/02-spool-review/target/`, the module `spool.py` and its `README.md`, before it ships. What would you hold it back for, and what check clears each hold?
>
> **The decision.** Whether the spool ships as it stands, and what is fixed before it does.
>
> **The shape.** A review.
>
> **The files.** `examples/02-spool-review/target/spool.py` and `examples/02-spool-review/target/README.md` in this repository, at commit `db2820c16fe7e7c58b3e7e50071fe4614e3d6aa2`. The README states what the code promises. Nothing else in the repository bears on the question.
>
> **Done when.** Every hold names its `path:line`, its severity and the check that clears it, and the synthesis says which holds were verified at their line.
>
> **Size.** A spark: two seats, L0 and R0 of row 0 at xhigh, one round, then the synthesis. The room has no row 1 or row 2 seated.
>
> **Web.** None: the seats run without web tools.
>
> **Box.** As `BRIEFING.md` point 8 sets it.

Kept verbatim at `inbox/2026-11-09-spool-review.md`. It reached the Visionary as the first prompt of its pane, so it is the desk lead's.

## The decision

Whether the spool ships as it stands, and what is fixed before it does. The desk lead decides; the room proposes a list of holds, each with its severity and the check that clears it.

## In scope · out of scope

In scope: the two files at `db2820c`, every line of each. The code against what the README promises, and the README against what the code does.

Out of scope: the rest of the repository (the brief says nothing else bears on it); running the module or any test of it (the room runs none of the code it reviews, the visionary skill's Rule 1); the web.

## Settled

No ruling touches the spool. The README is the contract, by the brief's own words.

## Criteria

1. Every promise of the README is kept by a line of the code.
2. No job is lost, stranded in `incoming/`, or run more often than the README's Limits allow, and the spool never stops for want of a hand.
3. The `Result` a run returns is true: its names and its count.
4. The cost of each fix, so the decision can weigh it.

## The null

The spool ships as it stands, with the README as written.

## Assumptions

1. The severity scale is the brief's: S1 blocks the ship, S2 is fixed before the ship, S3 may ship with a README note (the scale is written out in `r1/brief.md`).
2. The README's Limits section (`README.md:43-48`) declares what the spool does not promise. A hold against a declared limit is a Challenge, at most one per sheet; a hold where the code falls short of a limit as written is an ordinary hold.
3. "The check that clears it" is a test or a reading the team can run after a fix. The room writes it and runs none.
4. Both seats read both files, so their coverage is the same file set; the lenses, not the files, keep them apart.
5. No roll call was held as storm 00: both seats had loaded their skill and named their seats in their panes at 17:57Z, before the storm was framed.

## Size

A spark, as the brief sets it: one round, L0 and R0, then the synthesis. No ledger re-check by row 2, since no row 2 is seated; the Visionary opens every hold at its line.
