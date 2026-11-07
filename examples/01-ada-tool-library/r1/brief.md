---
kind: brief
storm: 01-ada-tool-library
round: r1
status: open
date: 2026-01-15
author: visionary
---

# Storm Ada · r1 · diverge

Weather: a calm morning, with a few clouds over the Saturday desk.

**The question.** The library lends 400 tools to 300 members on Saturdays and takes reservations on a paper sheet by the door. On four Saturdays out of nine a member arrived for a reserved tool that had been lent to someone else, and 31 of 120 reservations were never collected. How should the library take reservations? Read `QUESTION.md` and `GROUND.md` before anything else.

**What this storm is for.** The committee's choice for the spring term, and the first thing its one builder is asked to build.

**The shape.** DESIGN: cards, a ledger, options. A spark runs no tournament, so the stopping rule is the ledger: at most four cards in ten stay alive.

**Your seat, your lens, your question, your files.**

| Seat | Row · effort | Lens           | Your question                                                                             | Your files                 | Procedure                                                                                                                         |
| ---- | ------------ | -------------- | ----------------------------------------------------------------------------------------- | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| L0   | 0 · xhigh    | The Saboteur   | What breaks first in any replacement for the sheet, and what must the design do about it? | `QUESTION.md`, `GROUND.md` | For each Saturday task a volunteer or a member performs under a replacement, name the event that breaks it, at the Fact it meets. |
| L1   | 1 · high     | The Minimalist | What is the smallest change to the sheet that ends both failures?                         | `QUESTION.md`, `GROUND.md` | For Facts 4 and 5, name the smallest change that makes each impossible, and what it costs a volunteer on a Saturday.              |

**The Saboteur.** _Stance:_ the pre-mortem. It is ninety days after launch and it failed, lost money, or woke someone at three in the morning: write the incident. _Asks:_ what breaks first: a race, a restart, stale data, an outage of something we depend on, a start in the wrong order, a human under stress? _Cards:_ designs driven by failure, each naming the incident it makes impossible.

**The Minimalist.** _Stance:_ the smallest thing that could work. Delete, merge, defer; every part must earn its place. _Asks:_ what if we built a third of it, and what would we never miss? _Cards:_ designs with less in them, each listing what was cut and why the cut is safe.

**Look for.** A hold with no release (check: what ends it, and when?). A channel that shuts a group of members out (check: count the members it reaches, Fact 9). A single device that Saturday depends on (check: Fact 10). A rule the desk cannot see (check: where the rule is shown, against where lending happens, Fact 3).

**Done when.** L0: five cards and the wild card, each naming the incident it makes impossible. L1: five cards and the wild card, each with what it cuts. Every card passes one triage line first: does it change what the committee adopts for the spring term? A card that does not becomes a doubt or is not written. Your Coverage section equals your file set, file for file. A doubt is welcome even when it proves wrong: raise it with your confidence and its `path:line`.

**Deliver.** `examples/01-ada-tool-library/r1/analyst-SEAT.md` (in a live room, `storms/NN-CODENAME-SLUG/r1/analyst-SEAT.md`): five to seven cards and a wild card, each finding at its `path:line`; facts found; assumptions; Doubts; Grounds; Coverage, with Not read. Write "none" rather than leave out a section. An artifact past 20 lines or a table past 15 rows goes beside the sheet. The caps, the checks and the routes are the analyst skill's § Max effort and the thread: 24 KB a sheet with its Coverage, 14 non-blank lines and 1.8 KB a card, the sheet on disk with its Coverage skeleton before the first card. Read the pinned facts of `GROUND.md`. Box: 45 minutes, ending at 11:05Z; at its end, seal.

**This round.** Alone: open no other sheet of r1. Challenges to settled rulings: not invited. The allowlist, which is the law for this round: read the two files; no web, no scripts, no helpers.
