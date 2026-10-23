# Brainstorm Matrix

A five-seat brainstorming room for Claude Code: one Visionary and four Analysts, each a Claude session in its own tmux pane. A question goes in as a brief, each analyst answers it alone through a named lens, the Visionary funnels the cards through a ledger into options and a synthesis, and the person who asked rules. The room was built for an engineering desk's decisions and runs at maximum reasoning effort with no cap per turn, so its rules are about keeping that effort on the question.

## The seats

| seat           | skill                               | does                                                                                        |
| -------------- | ----------------------------------- | ------------------------------------------------------------------------------------------- |
| Visionary      | `.claude/skills/visionary/SKILL.md` | frames the storm, writes the brief, runs the rounds, keeps the ledger, writes the synthesis |
| Analyst 1 to 4 | `.claude/skills/analyst/SKILL.md`   | answers the brief in its lens, writes one sheet per round and the artifacts beside it       |

Each seat is a Claude Code session started in its own pane with its skill loaded (`/visionary`, `/analyst`). The Visionary addresses the analysts by session message; the analysts never read a pane and never message one another. Briefs arrive as files under `inbox/`, and everything a storm produces lives under `storms/NN-CODENAME-SLUG/`.

## A storm

1. A brief names the question, its shape (design, draft, census, review or research), the file set, the Done-when and the box.
2. Round 1: each analyst works alone, five to seven cards and a wild card, each finding at its path and line, then Facts found, Assumptions, Doubts, Grounds and Coverage.
3. The ledger: every card takes one of four fates, alive with its reason, floor, folded into an option, or graveyard with an epitaph. At most four cards in ten stay alive.
4. Later rounds cross-pollinate and run a tournament between the options when the storm's size calls for them.
5. The synthesis: a TL;DR of at most eight lines, the options and how they fared, the recommendation, the dissent in its author's words, the grounds the storm met and its cost table.

## Max effort without drift

Both skills carry a section on working at maximum effort. It holds no advice to be careful. It is a set of slots and limits: checks at fixed points, four routes when a line of thought stalls (ask, act, doubt, stop), stopping rules, caps on cards, sheets and syntheses, artifacts in files beside the sheet, helpers with a Done-when and a cap on what they return, and an open list of the states the room has met (`GROUNDS.md`), each with the cap that holds it. Every synthesis ends with a cost table, and `MATRIX.md` carries the trend across storms.

## Files

- `BRIEFING.md`: the briefing rule, the one home of the points both skills cite.
- `GROUNDS.md`: the states the room has met, one line each.
- `MATRIX.md`: the board, with the storms, their states, the rulings, the lens log and the cost table.
- `.claude/skills/visionary/templates.md`: the brief, ledger, synthesis and ruling templates.

`storms/` and `inbox/` are the room's working directories and stay out of the repository; it carries the method, not the desk's material.

## Licence

MIT, see `LICENSE.md`.
