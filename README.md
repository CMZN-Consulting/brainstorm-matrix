# Brainstorm Matrix

A seven-seat brainstorming room for Claude Code: one Visionary and six Analysts in a ladder of three rows of two, each a Claude session in its own tmux pane. A question goes in as a brief, the analysts of the first two rows answer it alone through named lenses, the third row checks their citations and their numbers, the Visionary funnels the cards through a ledger into options and a synthesis, and the session or person who asked rules on the findings. The Visionary runs at maximum reasoning effort and each row at its own, with no cap per turn, so the room's rules are about keeping that effort on the question.

## Quickstart

You need Claude Code, tmux, git, bash 4 or later and GNU find (on macOS, install bash and findutils).

1. Clone the repository, `cd` into it and start tmux (`tmux new -s matrix`; from inside tmux, `tmux new-window`). Make seven panes: for example the Visionary in one window, and in a second window six panes laid out three rows by two (`Ctrl-b %` and `Ctrl-b "`, then `tmux select-layout tiled`). In the skills, `$MATRIX_ROOT` is notation for this top directory, not an exported variable.
2. In each pane start `claude` and name the session with `/rename`: `Visionary`, then `Analyst (L0)`, `Analyst (R0)`, `Analyst (L1)`, `Analyst (R1)`, `Analyst (L2)` and `Analyst (R2)`, each a placement, left or right, and a row. A name prefix in front of all seven (`Brainstorm Visionary`, `Brainstorm Analyst (L0)`) names the matrix, so that several can run side by side. The session name is how the Visionary messages an analyst; the pane title, which Claude Code sets from it, is how `matrix.sh` finds the analysts' panes and lets only the Visionary's pane look at its own matrix's. Start all seven in the same permission mode, and set the effort with `/effort`: max for the Visionary, xhigh for row 0, high for row 1 and medium for row 2. `BRIEFING.md` says what the brief carries below max.
3. Load the skills: `/visionary` in the Visionary's pane and `/analyst` in each analyst's. In the Visionary's pane, `.claude/skills/visionary/scripts/matrix.sh roster` should list seven panes with those titles (a leading glyph is normal).
4. Make a place for briefs (`mkdir -p inbox`) and drop one there: a Markdown file with the question, its shape and the files it concerns, for example `inbox/2026-01-15-my-question.md`. Name any repository the question reads by its absolute path; the room reads it, read-only. Tell the Visionary in its pane that the brief is there.
5. The Visionary frames the storm (one run of the room on one brief) under `storms/`, messages the analysts, runs the rounds and writes the synthesis. It runs `matrix.sh status storms/01-ada-SLUG` to see where a round stands and `matrix.sh peek L0` to look at an analyst's pane. `roster` and `status` work from any pane of the tmux session; `peek` only from the Visionary's.

`examples/01-ada-tool-library/` is one storm from brief to synthesis on a made-up question.

## Words

- **Storm:** one run of the room on one brief, kept under `storms/NN-CODENAME-SLUG/`. A **spark**, a **storm** or a **hurricane** is its size, by how many rounds it runs.
- **Brief:** the file that names the question, its shape, the files to read, the **Done-when** (what a complete answer contains) and the **box** (the time for the round).
- **Seat, row:** an analyst's place in the ladder, a placement and a row, as in L0. The row sets its effort and its lenses: row 0 at xhigh with the adversarial and creative lenses, row 1 at high with the structural ones, row 2 at medium with the mechanical ones.
- **Lens:** a vantage dealt to an analyst, such as the Scout or the Saboteur; `lenses.md` is the deck.
- **Card:** one idea on a sheet of rows 0 and 1, in a fixed shape with a path and line behind it. The **wild card** is the idea its analyst would hesitate to say aloud.
- **Check:** row 2's sheet on a sealed round: each finding a citation, a cap or a number that does not hold.
- **Ledger:** the Visionary's list of every card and its fate: alive, floor (carried by every option but the null), folded into one option, or graveyard. **Options** are built from the cards that survive.
- **Grounds, Doubts, Coverage:** the sections every sheet ends with: the states of drift the analyst noticed, what it suspects but could not settle, and what it read and did not read.
- **Board:** `MATRIX.md`, the Visionary's list of storms, rulings, lens log and costs, the tokens per seat and the survival per row among them.
- **Desk lead, directing session:** the person who owns the room, and the session that brings briefs and rules on the findings. The desk lead can be both.

## The seats

| seat                      | effort | skill                               | does                                                                                        |
| ------------------------- | ------ | ----------------------------------- | ------------------------------------------------------------------------------------------- |
| Visionary                 | max    | `.claude/skills/visionary/SKILL.md` | frames the storm, writes the brief, runs the rounds, keeps the ledger, writes the synthesis |
| Analysts L0 and R0, row 0 | xhigh  | `.claude/skills/analyst/SKILL.md`   | answer the brief in an adversarial or creative lens, one sheet per round, and judge duels   |
| Analysts L1 and R1, row 1 | high   | `.claude/skills/analyst/SKILL.md`   | answer the brief in a structural lens, one sheet per round, and judge duels                 |
| Analysts L2 and R2, row 2 | medium | `.claude/skills/analyst/SKILL.md`   | check each sealed round: every citation, every cap, every number                            |

Each seat is a Claude Code session started in its own pane with its skill loaded (`/visionary`, `/analyst`). The Visionary addresses the analysts by session message; the analysts never read a pane and never message one another. Briefs arrive as files under `inbox/`, and everything a storm produces lives under `storms/NN-CODENAME-SLUG/`.

## A storm

1. A brief names the question, its shape (design, draft, census, review or research), the file set, the Done-when and the box.
2. Round 1: each analyst of rows 0 and 1 works alone, five to seven cards and a wild card, each finding at its path and line, then Facts found, Assumptions, Doubts, Grounds and Coverage.
3. Row 2 checks each round once it is sealed: every citation at its pinned line, every cap, every number, the scripts re-run.
4. The ledger: every card takes one of four fates, alive with its reason, floor, folded into an option, or graveyard with an epitaph, and every finding of the checks is re-checked. At most four cards in ten stay alive.
5. Later rounds cross-pollinate and run a tournament between the options when the storm's size calls for them.
6. The synthesis: a TL;DR of at most eight lines, the options and how they fared, the recommendation, the dissent in its author's words, the grounds the storm met and its cost: per round, per seat in tokens, and per row in survival through the ledger.

## Max effort without drift

Both skills carry a section on working at maximum effort. It holds no advice to be careful. It is a set of slots and limits: checks at fixed points, four routes when a line of thought stalls (ask, act, doubt, stop), stopping rules, caps on cards, sheets and syntheses, artifacts in files beside the sheet, helpers with a Done-when and a cap on what they return, and an open list of the states the room has met (`GROUNDS.md`), each with the cap that holds it. Every synthesis ends with a cost table, and the board (`MATRIX.md`, kept out of git) carries the trend across storms.

## Extending the room

A team keeps its own material (its board, grounds and lenses, its names and paths, its extra rules) in a directory of its own beside this repository, and points the sessions at it. The first prompt names it, for example "read `../my-overlay/OVERLAY.md` before anything else", or the instruction file of a parent directory does, with the same line in a `CLAUDE.md` there. Keep the overlay small: one `OVERLAY.md` that says where its board, grounds and lenses are and who the desk lead and the directing session are. Each skill has one paragraph on this, under Overlay; because `matrix.sh` takes its root from its own location, an overlay that moves `storms/` runs a link to the script from its own tree. The overlay adds and narrows; it never lifts a rule of the skills. Without one the room runs on the method alone.

## Files

- `BRIEFING.md`: the briefing rule, the one home of the points both skills cite.
- `GROUNDS.md`: the states the room has met, one line each.
- `.claude/skills/visionary/templates.md`: the brief, ledger, synthesis, ruling and board templates.
- `.claude/skills/visionary/lenses.md`: the lens deck.
- `.claude/skills/visionary/scripts/matrix.sh`: the Visionary's tool for the roster, the peek, the storm directories, the round status and the wait for a round.
- `examples/`: one synthetic storm.

`MATRIX.md`, `inbox/` and `storms/` are the room's working files: the board, the briefs and the storms. They stay out of the repository (see `.gitignore`); it carries the method, not a team's material.

## Credit

Created by A. Arda Uzan, CMZN LTD.

## Licence

MIT, see `LICENSE.md`.
