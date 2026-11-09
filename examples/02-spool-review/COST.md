---
kind: cost
storm: 01-ada-spool-review
date: 2026-11-09
author: operator
---

# Storm Ada — cost

Filled in by the operator after the storm landed, from the seats' own transcripts; the room wrote none of it. The synthesis's cost section points here for its tokens.

## The run

- A spark: the Visionary and the analysts L0 and R0, one round, with no row 1 and no row 2. Every seat ran `claude-opus-5-5` at xhigh effort under Claude Code 2.1.319, in permission mode auto, without web tools, MCP servers or the Chrome integration: `matrix.sh up --spark -p Clean --model claude-opus-5-5 --no-web --brief inbox/2026-11-09-spool-review.md`.
- It ran on Linux from a fresh clone of this repository at `6ec3310`, in a folder trusted by hand before the run. No instruction file sat above the clone. The seats ran under the operator's user settings (permission rules, Remote Control at startup), with no hooks and no plugins.
- No seat made a web call or started a helper. Each seat took three turns.

## Time, by the wall clock

All on 2026-11-09.

| Window | From | To | Minutes |
| --- | --- | --- | --- |
| The whole run | 17:56:46Z, the Visionary's start | 18:15:26Z, the end of its closing turn | 18 min 40 s |
| To the synthesis | 17:56:46Z | 18:14:37Z, `SYNTHESIS.md` landed | 17 min 51 s |
| Round 1 | 18:01:35Z, the briefs sent | 18:10:04Z, the last seal | 8 min 29 s |

## Tokens

Counted from every seat's transcript and its helpers', each message once by its id. The token windows open at 17:56:44Z, the launch, since the analysts start two seconds before the Visionary.

| Window | Output | Cache writes | Cache reads | Input | Messages | The Visionary's share of output |
| --- | --- | --- | --- | --- | --- | --- |
| The whole run, to 18:15:45Z | 174,691 | 356,875 | 7,840,054 | 180 | 80 | 39.3 percent |
| To the synthesis, to 18:14:37Z | 166,815 | 341,144 | 6,506,225 | 158 | 71 | 37.6 percent |

By seat, over the whole run:

| Seat | Output | Cache writes | Cache reads | Input | Messages | Turns |
| --- | --- | --- | --- | --- | --- | --- |
| Visionary | 68,570 | 147,274 | 4,141,827 | 80 | 36 | 3 |
| L0 | 50,492 | 119,717 | 1,962,428 | 52 | 23 | 3 |
| R0 | 55,629 | 89,884 | 1,735,799 | 48 | 21 | 3 |

Counting each line of a transcript instead of each message, an earlier method, gives 435,051 output tokens for the whole run, 2.49 times the figure above.

## Price

At the list price for Opus 5.5, in USD per million tokens (output 20; cache writes 5 to 8, by the cache's lifetime; cache reads 0.20), the whole run comes to 6.85 to 7.92 USD:

| Tokens | Count | Price | USD |
| --- | --- | --- | --- |
| Output | 174,691 | 20 | 3.49 |
| Cache writes | 356,875 | 5 to 8 | 1.78 to 2.86 |
| Cache reads | 7,840,054 | 0.20 | 1.57 |

The 180 input tokens are left out.
