---
kind: board
status: living
date: 2026-11-09
author: visionary
---

# The Matrix

The board of the brainstorm matrix: every storm, its state, and the questions waiting for one. The Visionary keeps it current.

## Storms

| #   | Codename | Question                              | Asked by  | Size  | State      | Synthesis | Ruling |
| --- | -------- | ------------------------------------- | --------- | ----- | ---------- | --------- | ------ |
| 01  | Ada      | Review the spool before it ships      | desk lead | spark | landed     | `storms/01-ada-spool-review/SYNTHESIS.md` | awaiting |

## Proposed

- **The claim step** (noticed by L0, R1-AL0-H7). Moving a job out of `incoming/` before its handler runs would end H7's re-runs by design, but it changes how a crash is recovered. It matters if the spool's handlers are costly to repeat.
- **Splitting a review between seats** (noticed by the Visionary, G18). In storm Ada two lenses found one hold set. Before the next review, decide whether the seats split the defect classes or the files, or whether one seat reviews and one checks.

## Lens log

| Storm | L0           | R0               | L1  | R1  | L2  | R2  |
| ----- | ------------ | ---------------- | --- | --- | --- | --- |
| 01    | The Saboteur | First Principles | —   | —   | —   | —   |

## Cost

The trend across storms, one row per round, from each synthesis's cost table.

| Storm | Round | Minutes | Sheet bytes | Cards | Alive after the ledger | Synthesis bytes |
| ----- | ----- | ------- | ----------- | ----- | ---------------------- | --------------- |
| 01    | r1    | 9       | 31,285 (+8,889 beside) | 16 + V 10 | 1 | 9,814 |

### Tokens

Output tokens per seat, one row per storm and round, from each storm's `COST.md`; the Visionary's share is its part of the storm's output.

| Storm | Round | Turns | V   | L0  | R0  | L1  | R1  | L2  | R2  | All | V share | Input | Cache written | Cache read |
| ----- | ----- | ----- | --- | --- | --- | --- | --- | --- | --- | --- | ------- | ----- | ------------- | ---------- |

### Survival per row

Running totals first, then one row per storm and row.

| Storm | Row | Effort | Cards | Survived | Alive | Findings | Confirmed | Misses |
| ----- | --- | ------ | ----- | -------- | ----- | -------- | --------- | ------ |
| All   | V   | xhigh  | 10    | 10       | 0     | —        | —         | —      |
| All   | 0   | xhigh  | 16    | 16       | 1     | —        | —         | —      |
| All   | 1   | high   | 0     | —        | —     | —        | —         | —      |
| All   | 2   | medium | —     | —        | —     | 0        | —         | —      |
| 01    | V   | xhigh  | 10    | 10       | 0     | —        | —         | —      |
| 01    | 0   | xhigh  | 16    | 16       | 1     | —        | —         | —      |

Storm 01 seated no row 1 or row 2; its six check findings were the ledger's own (`LEDGER.md` § Checks), so no misses are counted.
