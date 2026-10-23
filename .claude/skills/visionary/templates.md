# Templates

Shapes for every file the Visionary writes in a storm. Placeholders are in capitals. The analyst's sheet shapes live in the analyst skill, `.claude/skills/analyst/SKILL.md`.

## QUESTION.md

```markdown
---
kind: question
storm: NN-CODENAME-SLUG
status: open
date: YYYY-MM-DD
author: visionary
asked-by: da | arda
size: spark | storm | hurricane
---

# Storm CODENAME — THE QUESTION IN A FEW WORDS

## The brief

> The brief verbatim, or its opening lines and the path `inbox/YYYY-MM-DD-SLUG.md`.

## The decision

What will be decided, by whom, and what it feeds: a SPEC section, a deploy step, a ruling.

## In scope · out of scope

## Settled

Rulings and SETTLED lines in force, each with its block or `path:line`. Not re-opened unless the brief invites challenges.

## Criteria

What "better" means here, most important first, from the brief and the desk's doctrine.

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

Pinned to endurance `SHA` and desk-docs `SHA`; read moving files with `git show SHA:PATH`.

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

**The shape.** DESIGN: CARDS, LEDGER, OPTIONS, TOURNAMENT · CENSUS: ROWS AND A LEDGER, NO CARDS · REVIEW: HOLDS H1 TO HN, EACH WITH A SEVERITY AND THE CHECK THAT CLEARS IT · RESEARCH: ONE MEASUREMENT, ITS NULL, THRESHOLD AND WINDOW WRITTEN BEFORE THE DATA · DRAFT: THE ARTIFACT IN A FILE BESIDE THE SHEET, A SOURCES AND DECISIONS TABLE, AT MOST FOUR BOUNDARY-CONTRACT CARDS AND THE WILD CARD. The stopping rule that follows from it.

**Your lens, your question, your files.**

| Analyst | Lens | Your question | Your files | Procedure |
| ------- | ---- | ------------- | ---------- | --------- |
| 1       | LENS | ONE QUESTION  | NAMED SET  | THE CHECK |
| 2       | LENS | ONE QUESTION  | NAMED SET  | THE CHECK |
| 3       | LENS | ONE QUESTION  | NAMED SET  | THE CHECK |
| 4       | LENS | ONE QUESTION  | NAMED SET  | THE CHECK |

THE FOUR LENS DESCRIPTIONS FROM lenses.md, WHOLE.

**Look for.** THE DEFECT CLASSES, EACH WITH THE CHECK THAT FINDS IT.

**Done when.** WHAT A COMPLETE ANSWER CONTAINS. Every card passes one triage line first: does it change THE DECISION THIS STORM FEEDS (for a deploy storm, tonight's deploy)? A card that does not becomes a doubt or is not written. Your Coverage section equals your file set, file for file (RULES 6b). A doubt is welcome even when it proves wrong: raise it with your confidence and its `path:line`.

**Deliver.** `storms/NN-CODENAME-SLUG/r1/analyst-N.md`: five to seven cards and a wild card, each finding at its `path:line`; facts found; assumptions; Doubts; Grounds; Coverage, with Not read. Write "none" rather than leave out a section. An artifact past 20 lines or a table past 15 rows goes beside the sheet as `r1/analyst-N-NAME.EXT`. The caps, the checks and the routes are the analyst skill's § Max effort and the thread: 24 KB a sheet with its Coverage, 14 non-blank lines and 1.8 KB a card, the sheet on disk with its Coverage skeleton before the first card. Read the pinned commits of GROUND.md. Box: 45 TO 60 MINUTES, ending at HH:MMZ; at its end, seal.

**This round.** Alone: open no other sheet of r1. Challenges to settled rulings: ALLOWED, AT MOST ONE, OR NOT INVITED. The allowlist, which is the law for this round: THE COMMANDS; ONE FALSIFIER SCRIPT OR NONE; HELPERS AND THEIR NUMBER. ANYTHING SPECIAL.
```

## r2/brief.md — cross-pollinate

```markdown
# Storm CODENAME · r2 · cross-pollinate

Weather: ONE LINE.

**Your hand.** Read your hand and nothing else of r1.

| Analyst | Hand              |
| ------- | ----------------- |
| 1       | `r1/analyst-2.md` |
| 2       | `r1/analyst-3.md` |
| 3       | `r1/analyst-4.md` |
| 4       | `r1/analyst-1.md` |

**Deliver.** `storms/NN-CODENAME-SLUG/r2/analyst-N.md`: steelman the two strongest cards in your hand; graft two or three hybrids with your own r1 cards; write the pre-mortem of the card most likely to win; end with one question nobody has asked.
```

For a cluster each, the hand column names the cards of the theme instead of a sheet.

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

**Deliver.** `storms/NN-CODENAME-SLUG/r3/analyst-N.md`: per duel the winner, the margin (slight, clear, decisive), the deciding criterion, and what would flip it; then your ranking of every option, the first thing you would measure, and the options your own cards built.
```

### Duel tables

**Two options.** Everyone judges O1 v O2. Analysts 1 and 3 read O1 first; Analysts 2 and 4 read O2 first.

**Three options.** Everyone judges all three pairs. Analysts 1 and 3: O1 v O2 · O1 v O3 · O2 v O3. Analysts 2 and 4: O2 v O1 · O3 v O1 · O3 v O2.

**Four options.** Three duels each; every pair is judged by a different pair of analysts, and every option is read first three times and second three times.

| Analyst | Duels, in this order        |
| ------- | --------------------------- |
| 1       | O1 v O2 · O3 v O2 · O2 v O4 |
| 2       | O2 v O1 · O1 v O4 · O3 v O4 |
| 3       | O1 v O3 · O4 v O1 · O4 v O2 |
| 4       | O3 v O1 · O2 v O3 · O4 v O3 |

**Five options.** Five duels each; every option is read first four times and second four times.

| Analyst | Duels, in this order                            |
| ------- | ----------------------------------------------- |
| 1       | O1 v O2 · O4 v O1 · O2 v O3 · O5 v O2 · O3 v O5 |
| 2       | O2 v O1 · O5 v O1 · O2 v O4 · O2 v O5 · O4 v O5 |
| 3       | O1 v O3 · O1 v O4 · O4 v O2 · O4 v O3 · O5 v O3 |
| 4       | O3 v O1 · O1 v O5 · O3 v O2 · O3 v O4 · O5 v O4 |

**The tally.** Per option, wins minus losses over every judgment (a Copeland score). Ties are broken by margins, slight 1, clear 2, decisive 3, won minus lost. A split is a pair whose judges did not agree; the synthesis quotes both reasons.

## r4/brief.md — deep dive and red team

```markdown
# Storm CODENAME · r4 · deep dive and red team

| Analyst | Option | Role     |
| ------- | ------ | -------- |
| 1       | ON     | build    |
| 2       | ON     | red team |
| 3       | OM     | build    |
| 4       | OM     | red team |

**Build** to spec level: what it is in the SPEC's own voice; components and interfaces; state; failure modes and what the system does in each; the measurement that proves it (metric, null, threshold, window, written before the data); migration and rollback; cost; open questions.

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

| Card    | Title | By  | Fate           |
| ------- | ----- | --- | -------------- |
| R1-A1-1 | TITLE | A1  | alive: WHY     |
| R1-A2-3 | TITLE | A2  | floor          |
| R2-V-1  | TITLE | V   | folded into O2 |
| R1-A3-4 | TITLE | A3  | graveyard      |

## Options

- **Floor**, carried by every option but the null ← CARD IDS.
- **O1 · NAME** ← CARD IDS.

## The graveyard

- **R1-A3-4 · TITLE.** Here lies AN IDEA, killed by A REASON (A CITATION). It may rise again only with NEW EVIDENCE.
```

## SYNTHESIS.md

```markdown
---
kind: synthesis
storm: NN-CODENAME-SLUG
status: landed
date: YYYY-MM-DD
author: visionary
asked-by: da | arda
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

For the DA, for Arda, or for data nobody has yet.

## SPEC-ready fragment

Spec questions only: sentences in the SPEC's own voice, ready to paste.

## Provenance

The cards behind each option, and the key sources.

## Kudos

Each analyst's best contribution, by name.

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
```

## RULING.md

```markdown
---
kind: ruling
storm: NN-CODENAME-SLUG
status: ruled
date: YYYY-MM-DD
author: da | arda
---

# Storm CODENAME — ruling

> The ruling, verbatim.

Ledger: `endurance-desk-docs/rulings/rulings-YYYY-MM.md`, block TITLE.
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

Questions the matrix noticed that nobody asked, each with who noticed it and why it matters before the fleet goes up.

## Lens log

| Storm | Analyst 1 | Analyst 2 | Analyst 3 | Analyst 4 |
| ----- | --------- | --------- | --------- | --------- |

## Cost

The trend across storms, one row per round, from each synthesis's cost table.

| Storm | Round | Minutes | Sheet bytes | Cards | Alive after the ledger | Synthesis bytes |
| ----- | ----- | ------- | ----------- | ----- | ---------------------- | --------------- |
```
