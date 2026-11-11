# Templates

Shapes for every file the Visionary writes in a storm. Placeholders are in capitals. The analyst's sheet shapes live in the analyst skill, `.claude/skills/analyst/SKILL.md`.

## The roll call: storms/00-roll-call/r1/brief.md

Storm 00 is made by hand before the first storm, because `matrix.sh new` numbers from 01; a seat that joins a running room gets a roll call of its own, `storms/00-roll-call-SLUG/`. It has no QUESTION, GROUND or ledger. Its sheets go in `r1/`, so that `matrix.sh status` and `wait` read them.

```markdown
---
kind: brief
storm: 00-roll-call
round: r1
status: open
date: YYYY-MM-DD
author: visionary
---

# Roll call

Weather: ONE LINE.

**What this is for.** The room learns that each seat is here, has its skill loaded, and has read the same files.

**Boot.** Load your skill, `/analyst`, if it is not in your context; then the overlay, THE OVERLAY'S PATH OR "none"; then read these files whole: `BRIEFING.md`, `GROUNDS.md`, THE FILES EVERY STORM WILL NEED.

| Seat | Row · effort | Your sheet                             |
| ---- | ------------ | -------------------------------------- |
| L0   | 0 · xhigh    | `storms/00-roll-call/r1/analyst-L0.md` |
| R0   | 0 · xhigh    | `storms/00-roll-call/r1/analyst-R0.md` |
| L1   | 1 · high     | `storms/00-roll-call/r1/analyst-L1.md` |
| R1   | 1 · high     | `storms/00-roll-call/r1/analyst-R1.md` |
| L2   | 2 · medium   | `storms/00-roll-call/r1/analyst-L2.md` |
| R2   | 2 · medium   | `storms/00-roll-call/r1/analyst-R2.md` |

**Deliver.** A short sheet with the front matter of the analyst skill's sheet, with no cards: one paragraph naming your seat, your row and your effort as your session name and this brief give them; a map of what you read, one line a file; then Doubts, Grounds and Coverage, with Not read. Write "none" rather than leave out a section. Box: THE BOX, ending at HH:MMZ; at its end, seal.

**This round.** The allowlist: reading the files above, reading your own pane title, listing a directory inside this folder, the clock, your scratchpad, and writing your sheet. No helpers.
```

## QUESTION.md

```markdown
---
kind: question
storm: NN-CODENAME-SLUG
status: open
date: YYYY-MM-DD
author: visionary
asked-by: directing-session | desk-lead
size: spark | storm | hurricane
---

# Storm CODENAME — THE QUESTION IN A FEW WORDS

## The brief

> The brief verbatim, or its opening lines and the path `inbox/YYYY-MM-DD-SLUG.md`.

## The decision

What will be decided, by whom, and what it feeds: a section of a specification, a release step, a ruling.

## In scope · out of scope

## Settled

Rulings and settled decisions in force, each with its record or `path:line`. Not re-opened unless the brief invites challenges.

## Criteria

What "better" means here, most important first, from the brief and the team's stated principles.

## The null

What happens if nothing changes. It enters the tournament when there is something to keep.

## Assumptions

## Size

Spark, storm or hurricane, and why.
```

## GROUND.md

```markdown
---
kind: ground
storm: NN-CODENAME-SLUG
status: living
date: YYYY-MM-DD
author: visionary
---

# Storm CODENAME — ground

## Reading list

Analysts start here, in this order.

1. `PATH` — why it matters.

## Facts

Pinned to `SHA` of each repository the question reads; read moving files with `git show SHA:PATH`.

1. A fact, with `path:line` or a URL.

## Settled

## Unknowns

What the Visionary looked for and did not find, so no analyst has to stumble on it.

## Coverage

Read to the end: … Skimmed: … Not opened: …
```

## r1/brief.md — diverge

```markdown
---
kind: brief
storm: NN-CODENAME-SLUG
round: r1
status: open
date: YYYY-MM-DD
author: visionary
---

# Storm CODENAME · r1 · diverge

Weather: ONE LINE.

**The question.** One neutral paragraph. Read `QUESTION.md` and `GROUND.md` before anything else.

**What this storm is for.** One line: the decision it feeds.

**The shape.** DESIGN: CARDS, LEDGER, OPTIONS, TOURNAMENT · CENSUS: ROWS AND A LEDGER, NO CARDS · REVIEW: HOLDS H1 TO HN, EACH WITH A SEVERITY AND THE CHECK THAT CLEARS IT · RESEARCH: ONE MEASUREMENT, ITS NULL, THRESHOLD AND WINDOW WRITTEN BEFORE THE DATA · DRAFT: THE ARTIFACT IN A FILE BESIDE THE SHEET, A SOURCES AND DECISIONS TABLE, AT MOST FOUR INTERFACE CARDS AND THE WILD CARD. The stopping rule that follows from it.

**Your seat, your lens, your question, your files.**

| Seat | Row · effort | Lens | Your question | Your files | Procedure |
| ---- | ------------ | ---- | ------------- | ---------- | --------- |
| L0   | 0 · xhigh    | LENS | ONE QUESTION  | NAMED SET  | THE CHECK |
| R0   | 0 · xhigh    | LENS | ONE QUESTION  | NAMED SET  | THE CHECK |
| L1   | 1 · high     | LENS | ONE QUESTION  | NAMED SET  | THE CHECK |
| R1   | 1 · high     | LENS | ONE QUESTION  | NAMED SET  | THE CHECK |

THE DEALT LENS DESCRIPTIONS FROM lenses.md, WHOLE, AND ONE TABLE ROW PER SEAT IN THE ROUND. Row 2 checks this round once it is sealed, under its own brief, `check.md`.

**Look for.** THE DEFECT CLASSES, EACH WITH THE CHECK THAT FINDS IT.

**Done when.** WHAT A COMPLETE ANSWER CONTAINS. Every card passes one triage line first: does it change THE DECISION THIS STORM FEEDS (for a storm that feeds a release, that release)? A card that does not becomes a doubt or is not written. Your Coverage section equals your file set, file for file. A doubt is welcome even when it proves wrong: raise it with your confidence and its `path:line`.

**Deliver.** `storms/NN-CODENAME-SLUG/r1/analyst-SEAT.md`: five to seven cards and a wild card, each finding at its `path:line`; facts found; assumptions; Doubts; Grounds; Coverage, with Not read. Write "none" rather than leave out a section. An artifact past 20 lines or a table past 15 rows goes beside the sheet as `r1/analyst-SEAT-NAME.EXT`. The caps, the checks and the routes are the analyst skill's § Max effort and the thread: 24 KB a sheet with its Coverage, 14 non-blank lines and 1.8 KB a card, the sheet on disk with its Coverage skeleton before the first card. Read the pinned commits of GROUND.md. Box: 45 TO 60 MINUTES, ending at HH:MMZ; at its end, seal.

**This round.** Alone: open no other sheet of r1. Challenges to settled rulings: ALLOWED, AT MOST ONE, OR NOT INVITED. The allowlist, which is the law for this round: THE COMMANDS; ONE FALSIFIER SCRIPT OR NONE; HELPERS AND THEIR NUMBER. ANYTHING SPECIAL.
```

## r2/brief.md — cross-pollinate

```markdown
# Storm CODENAME · r2 · cross-pollinate

Weather: ONE LINE.

**Your hand.** Read your hand and nothing else of r1. Each hand comes from the other row.

| Seat | Hand               |
| ---- | ------------------ |
| L0   | `r1/analyst-L1.md` |
| R0   | `r1/analyst-R1.md` |
| L1   | `r1/analyst-R0.md` |
| R1   | `r1/analyst-L0.md` |

**Deliver.** `storms/NN-CODENAME-SLUG/r2/analyst-SEAT.md`: steelman the two strongest cards in your hand; graft two or three hybrids with your own r1 cards; write the pre-mortem of the card most likely to win; end with one question nobody has asked.
```

For a cluster each, the hand column names the cards of the theme instead of a sheet.

## rK/check.md — row 2's check

Written when round K is sealed, and dispatched to row 2 while the next step runs.

```markdown
---
kind: brief
storm: NN-CODENAME-SLUG
round: rK
status: open
date: YYYY-MM-DD
author: visionary
---

# Storm CODENAME · the check of rK

Weather: ONE LINE.

**What you check.** The sealed sheets of rK: THE SHEETS BY NAME, WITH r2/visionary.md IN r2 AND THE DUEL TABLES IN r3. Open these and no other sheet. Read the commits GROUND.md pins, with `git show SHA:PATH`.

| Seat | Row · effort | Lens        | Your items                                                                          |
| ---- | ------------ | ----------- | ----------------------------------------------------------------------------------- |
| L2   | 2 · medium   | The Notary  | every `path:line` a card, a fact or a doubt cites; every card that restates another |
| R2   | 2 · medium   | The Auditor | every cap; every number a sheet states; every script beside a sheet, re-run         |

THE TWO LENS DESCRIPTIONS FROM lenses.md, WHOLE.

**Done when.** Every item of your column has a row in your ledger beside the sheet, `rK/analyst-SEAT-checks.tsv`: the card, the item, and holds, fails or unrun. Every failure is a finding in your sheet, with what the sheet states and what the source shows. A doubt is welcome even when it proves wrong: raise it with your confidence and its `path:line`.

**Deliver.** `storms/NN-CODENAME-SLUG/rK/analyst-SEAT.md`, in the check shape of the analyst skill: at most 12 KB, a finding at most six lines, then Unrun, Doubts, Grounds and Coverage. Box: 20 TO 30 MINUTES, ending at HH:MMZ; at its end, seal.

**This check.** The allowlist, which is the law for this check: THE COMMANDS, WITH THE SKILL'S OWN STEPS (THE SCRATCHPAD, THE CLOCK, LISTING A DIRECTORY); THE SCRIPTS BESIDE THE SHEETS, EACH READ WHOLE FIRST; HELPERS AND THEIR NUMBER, OR NONE.
```

## r3/brief.md — the tournament

```markdown
# Storm CODENAME · r3 · the tournament

Weather: ONE LINE.

**The options.** Each a complete answer to the question, in one shape, no authors.

### O1 · NAME

- **In one line:**
- **How it works:** three to six lines.
- **What it gives up:**
- **Cost · door:** S, M or L · one-way or two-way.

**Your duels**, in this order; the option named first is the one you read first.

THE DUEL TABLE FOR THIS NUMBER OF OPTIONS.

**Deliver.** `storms/NN-CODENAME-SLUG/r3/analyst-SEAT.md`: per duel the winner, the margin (slight, clear, decisive), the deciding criterion, and what would flip it; then your ranking of every option, the first thing you would measure, and the options your own cards built.
```

### Duel tables

Rows 0 and 1 judge. Every pair is judged in both orders, with a seat of each row on it, and every seat carries the same load.

**Two options.** All four seats judge O1 v O2. L0 and L1 read O1 first; R0 and R1 read O2 first.

**Three options.** All four seats judge all three pairs, in a cycle that has each seat read every option first once. L0 and L1: O1 v O2 · O2 v O3 · O3 v O1. R0 and R1: O2 v O1 · O3 v O2 · O1 v O3.

**Four options.** Three duels each; every pair is judged by one seat of row 0 and one of row 1, in opposite orders, and every option is read first three times and second three times. The old table gave every pair its own pair of judges; with a judge from each row on every pair, four pairs of judges serve six pairs of options, so some pairs share their judges.

| Seat | Duels, in this order        |
| ---- | --------------------------- |
| L0   | O1 v O2 · O4 v O3 · O3 v O1 |
| R0   | O2 v O3 · O1 v O4 · O4 v O2 |
| L1   | O4 v O1 · O3 v O2 · O2 v O1 |
| R1   | O1 v O3 · O2 v O4 · O3 v O4 |

**Five options.** Five duels each; every pair is judged by one seat of row 0 and one of row 1, in opposite orders, and every seat reads every option first once and second once.

| Seat | Duels, in this order                            |
| ---- | ----------------------------------------------- |
| L0   | O1 v O2 · O3 v O4 · O5 v O1 · O2 v O3 · O4 v O5 |
| R0   | O1 v O3 · O2 v O4 · O3 v O5 · O4 v O1 · O5 v O2 |
| L1   | O5 v O3 · O1 v O4 · O2 v O5 · O3 v O1 · O4 v O2 |
| R1   | O4 v O3 · O1 v O5 · O3 v O2 · O5 v O4 · O2 v O1 |

**The tally.** Per option, wins minus losses over every judgment (a Copeland score). Ties are broken by margins, slight 1, clear 2, decisive 3, won minus lost. A split is a pair whose judges did not agree; the synthesis quotes both reasons.

## r4/brief.md — deep dive and red team

```markdown
# Storm CODENAME · r4 · deep dive and red team

| Seat | Option | Role     |
| ---- | ------ | -------- |
| L1   | ON     | build    |
| L0   | ON     | red team |
| R1   | OM     | build    |
| R0   | OM     | red team |

Row 2 checks the four sheets once they are sealed.

**Build** to spec level: what it is in the voice of the specification the brief names; components and interfaces; state; failure modes and what the system does in each; the measurement that proves it (metric, null, threshold, window, written before the data); migration and rollback; cost; open questions.

**Red team**: the five ways it fails, each with likelihood, impact, and the cheapest test that would show it before go-live.
```

## LEDGER.md

```markdown
---
kind: ledger
storm: NN-CODENAME-SLUG
status: living
date: YYYY-MM-DD
author: visionary
---

# Storm CODENAME — ledger

| Card     | Title | By  | Fate           |
| -------- | ----- | --- | -------------- |
| R1-AL0-1 | TITLE | AL0 | alive: WHY     |
| R1-AR0-3 | TITLE | AR0 | floor          |
| R2-V-1   | TITLE | V   | folded into O2 |
| R1-AL1-4 | TITLE | AL1 | graveyard      |

One row per card, under its own id: never a range such as `R1-V-1 to R1-V-10`. A table of holds, in a review, cites every line as `path:line`, as in `src/spool.py:88`, and never as a bare `:88` under a column named for the file.

## Checks

Every finding of row 2, re-checked at its line or its number.

| Finding  | By  | On       | Re-check                 |
| -------- | --- | -------- | ------------------------ |
| R1-AL2-1 | AL2 | R1-AL0-1 | confirmed: WHAT IT SHOWS |
| R1-AR2-2 | AR2 | R1-AR1-W | not confirmed: WHY       |

Misses: EACH DEFECT THE LEDGER FOUND THAT NO CHECK RAISED, WITH ITS CARD AND ITS LINE, OR "none".

## Options

- **Floor**, carried by every option but the null ← CARD IDS.
- **O1 · NAME** ← CARD IDS.

## The graveyard

- **R1-AL1-4 · TITLE.** Here lies AN IDEA, killed by A REASON (A CITATION). It may rise again only with NEW EVIDENCE.
```

## SYNTHESIS.md

```markdown
---
kind: synthesis
storm: NN-CODENAME-SLUG
status: landed
date: YYYY-MM-DD
author: visionary
asked-by: directing-session | desk-lead
---

# Storm CODENAME — THE QUESTION — synthesis

## TL;DR

At most eight lines: what we recommend, why, how sure, and what it costs. The whole synthesis is at most 10 KB for a spark, 14 KB for a storm, 18 KB for a hurricane; past the TL;DR, the options and the recommendation, point into the storm's files.

## The question

One line, and `QUESTION.md`.

## Options and how they fared

| Option | In one line | Record | Strongest at | Weakest at | Cost · door |
| ------ | ----------- | ------ | ------------ | ---------- | ----------- |

The split duels, with the reason on each side.

## Recommendation

What, why, and the conditions under which we would pick another option.

## Dissent

The best case for the runner-up, in the dissenter's own words, credited.

## Risks and first measurements

Each risk with the cheapest measurement that would show it, written so it can be registered before the data.

## Open questions

For the directing session, for the desk lead, or for data nobody has yet.

## Specification-ready fragment

Specification questions only: sentences in the voice of the specification the brief names, ready to paste.

## Provenance

The cards behind each option, and the key sources.

## Kudos

Each seat's best contribution, by seat, row 2's checks included.

## The graveyard

The two or three epitaphs worth reading; the rest are in `LEDGER.md`.

## Disclosures

The Visionary's own slips in this storm, or "none".

## Grounds

The states this storm met, each filed in `GROUNDS.md` with its number, or "none".

## Cost

| Round | Minutes | Sheet bytes | Cards | Alive after the ledger |
| ----- | ------- | ----------- | ----- | ---------------------- |
| r1    |         |             |       |                        |

Tokens, from the count of the seats' transcripts that the directing session supplies after the storm (`COST.md`): output tokens per seat and round, then the storm's totals. Filled when the count comes.

| Seat | Model  | Effort | r1  | r2  | r3  | Output | Share | Input | Cache written | Cache read | Turns |
| ---- | ------ | ------ | --- | --- | --- | ------ | ----- | ----- | ------------- | ---------- | ----- |
| V    | opus   | xhigh  |     |     |     |        |       |       |               |            |       |
| L0   | sonnet | xhigh  |     |     |     |        |       |       |               |            |       |
| All  |        |        |     |     |     |        | 100%  |       |               |            |       |

Survival per row, from the ledger: a card survives as alive, floor or folded; a finding survives when the re-check confirms it.

| Row | Seats  | Cards | Survived | Alive | Findings | Confirmed | Misses |
| --- | ------ | ----- | -------- | ----- | -------- | --------- | ------ |
| V   | V      |       |          |       | —        | —         | —      |
| 0   | L0, R0 |       |          |       | —        | —         | —      |
| 1   | L1, R1 |       |          |       | —        | —         | —      |
| 2   | L2, R2 | —     | —        | —     |          |           |        |
```

## RULING.md

```markdown
---
kind: ruling
storm: NN-CODENAME-SLUG
status: ruled
date: YYYY-MM-DD
author: directing-session | desk-lead
---

# Storm CODENAME — ruling

> The ruling, verbatim.

Recorded in: WHERE THE TEAM KEEPS ITS RULINGS, with the date or heading.
```

## MATRIX.md

```markdown
---
kind: board
status: living
date: YYYY-MM-DD
author: visionary
---

# The Matrix

The board of the brainstorm matrix: every storm, its state, and the questions waiting for one. The Visionary keeps it current.

## Storms

| #   | Codename | Question | Asked by | Size | State | Synthesis | Ruling |
| --- | -------- | -------- | -------- | ---- | ----- | --------- | ------ |

## Proposed

Questions the matrix noticed that nobody asked, each with who noticed it and why it matters before a decision falls.

## Lens log

| Storm | L0  | R0  | L1  | R1  | L2  | R2  |
| ----- | --- | --- | --- | --- | --- | --- |

## Cost

The trend across storms, one row per round, from each synthesis's cost table.

| Storm | Round | Minutes | Sheet bytes | Cards | Alive after the ledger | Synthesis bytes |
| ----- | ----- | ------- | ----------- | ----- | ---------------------- | --------------- |

### Tokens

Output tokens per seat, one row per storm and round, from each storm's `COST.md`; the Visionary's share is its part of the storm's output.

| Storm | Round | Turns | V   | L0  | R0  | L1  | R1  | L2  | R2  | All | V share | Input | Cache written | Cache read |
| ----- | ----- | ----- | --- | --- | --- | --- | --- | --- | --- | --- | ------- | ----- | ------------- | ---------- |

### Survival per row

Running totals first, then one row per storm and row.

| Storm | Row | Model  | Effort | Cards | Survived | Alive | Findings | Confirmed | Misses |
| ----- | --- | ------ | ------ | ----- | -------- | ----- | -------- | --------- | ------ |
| All   | V   | opus   | xhigh  |       |          |       | —        | —         | —      |
| All   | 0   | sonnet | xhigh  |       |          |       | —        | —         | —      |
| All   | 1   | sonnet | high   |       |          |       | —        | —         | —      |
| All   | 2   | sonnet | medium | —     | —        | —     |          |           |        |
```
