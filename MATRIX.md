---
kind: board
status: living
date: 2026-10-22
author: visionary
---

# The Matrix

The board of the brainstorm matrix: every storm, its state, and the questions waiting for one. The Visionary keeps it current. Briefs come from Arda or the Directing Advisor; findings go to the DA, who rules on them and records the ruling in the desk's ledger.

The room, at roll call (2026-10-22): the Visionary, and four analysts, every one of them Claude Sonnet 5.5 at max effort. One model in four seats: the lenses carry the diversity.

From 2026-10-23 the analysts run at xhigh effort (Arda, through the DA). From storm 04 on, every brief follows the room's briefing rule, `BRIEFING.md`, so the brief carries what effort used to. The DA now addresses the Visionary alone, and the analysts' findings reach it through the Visionary.

From the afternoon of 2026-10-23 every seat runs at max, with no cap on reasoning per turn (Arda, through the DA). The DA's rule for it (`inbox/2026-10-23-max-effort-rule.md`), amended by its v3 (`inbox/2026-10-23-max-effort-rule-v3.md`), is installed in both skills, § Max effort, with `GROUNDS.md` as the room's list of the states it has met. It governs every round from Dirac r1b and Euler r1 on, the whole of v3 from the round after them.

## Storms

| #   | Codename | Question                                                                                               | Asked by  | Size      | State                                                                                                                                                                        | Synthesis                                                       | Ruling                               |
| --- | -------- | ------------------------------------------------------------------------------------------------------ | --------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------------------------------ |
| 00  | —        | roll call                                                                                              | visionary | —         | done, 4 of 4 sealed                                                                                                                                                          | —                                                               | —                                    |
| 01  | Ada      | the selection method of the brain's rule search                                                        | da        | hurricane | ruled: the floor for every search; the tree's guarantee as the search bullet; mechanism by the registered comparison                                                         | `storms/01-ada-selection-method/SYNTHESIS.md`                   | ruled 2026-10-22T17:4xZ, `RULING.md` |
| 02  | Babbage  | the specification chain before it deploys the fleet                                                    | da        | spark     | acted on: #1265 carries H3 to H6 and half of H2; H1 with Arda; production held                                                                                               | `storms/02-babbage-spec-chain-review/SYNTHESIS.md`              | `OUTCOME.md`                         |
| 03  | Curie    | what every test file in the monorepo is trying to test                                                 | da        | spark     | ruled: census accepted whole as the file of record; 4 corrections accepted; 3 items held for Arda. Scale: 683 rows, the largest read so far                                  | `storms/03-curie-test-intent-census/SYNTHESIS.md`, `LEDGER.tsv` | ruled 04:3xZ, `OUTCOME.md`           |
| 04  | Dirac    | the platform manifests of storage, engine, brain and terminal, with the neighbours and the tape's road | da        | spark     | ruled: S1 to S8, with integration suites under the platform; O2 for the neighbours; O4 for the tape's road; both Challenges accepted; END#1-B's volume, dev's dashboard home and three credentials held for Arda. Landed 13:08Z on four sheets (r1, and r1b for Analyst 3's lost sheet) | `storms/04-dirac-platform-manifests/SYNTHESIS.md`, `LEDGER.md`, `drafts/` | ruled 13:14Z, `RULING.md` |
| 05  | Euler    | the engine's package shape under the SPEC laws, and the fate of today's code                           | da        | hurricane | r1 re-issued under the max-effort rule 12:31Z: shape pair to 13:31Z, census to 13:46Z (Analyst 4) and after Dirac r1b (Analyst 3); synthesis due 19:00Z, the OC red-teams it | —                                                               | —                                    |

## Proposed

Questions the matrix noticed that nobody asked, each with who noticed it and why it matters before the fleet goes up.

- **The engine's neighbours on Execution.** With storage and terminal moved onto the engine's node and the data volume attached there, what keeps a slow chain write, a heavy terminal query or a store that only grows (the public tape, the λ-cache) from costing the engine a cycle? The engine places no order while it cannot read its book or write its chain (`endurance/SPEC.md:59`), and the old map kept the engine alone for exactly this reason (`endurance/deploy/SETUP.md:18`; the move, `endurance-desk-docs/rulings/rulings-2026-10.md:4697`, `:4699`). Analysts 1 and 2, roll call.
- **The tape's road to the brain.** With `/db` on Execution and the brain alone on Intelligence, how does the public tape reach the lattice and the lab, and what does each side do while the other is down (`endurance/SPEC.md:83`, `:92`)? Analyst 3, roll call.
- **What the router refuses.** What must a write through the router prove before it is sent, and what must the router refuse whoever asks, so that no single compromised node, tool or session can trade the account at will? Its authorization line is still open (`rulings-2026-10.md:4704`). Analyst 4, roll call.

Not a storm, passed on: all four analysts found the map files (`deploy/SETUP.md`, the root `CLAUDE.md`, `source/BLUEPRINT.md`, the engine's `PLATFORM.md`) still describing the fleet and the `asset` package as they were before the 10-21 ruling; the rewrite's documentation pass owns that.

## Lens log

| Storm   | Analyst 1                | Analyst 2         | Analyst 3         | Analyst 4                |
| ------- | ------------------------ | ----------------- | ----------------- | ------------------------ |
| 00      | none                     | none              | none              | none                     |
| 01, r1  | The Archaeologist        | The Scout         | The Scientist     | The Saboteur             |
| 01, r3  | judge                    | judge             | judge             | judge                    |
| 01, r4  | build: comparison        | build: O4         | measure: fork     | red team                 |
| 02, r1  | The Contradiction Hunter | The Newcomer      | The Operator      | The Saboteur             |
| 03, r1  | The Integrator           | The Newcomer      | The Archaeologist | The Operator             |
| 04, r1  | The Saboteur             | The Scientist     | The Scout         | The Contradiction Hunter |
| 04, r1b | —                        | —                 | The Scout         | —                        |
| 05, r1  | First Principles         | The Archaeologist | The Integrator    | The Minimalist           |

## Cost

The trend across storms, one row per round, from each synthesis's cost table (`.claude/skills/visionary/SKILL.md` § Max effort and the room, 4). The rows before Dirac are back-filled from the files: minutes run from the brief's last write to the last sheet's, sheet bytes sum the round's sheets, and cards count the analysts' card headings.

| Storm      | Round | Minutes                    | Sheet bytes                  | Cards                        | Alive after the ledger                                            | Synthesis bytes |
| ---------- | ----- | -------------------------- | ---------------------------- | ---------------------------- | ----------------------------------------------------------------- | --------------- |
| 01 Ada     | r1    | 165                        | 133,660                      | 29, and 7 of the Visionary's | 29 of 36 in the ledger                                            | 41,371          |
| 01 Ada     | r3    | 12                         | 47,998                       | duels                        | —                                                                 |                 |
| 01 Ada     | r4    | 16                         | 93,091                       | build and red team           | —                                                                 |                 |
| 02 Babbage | r1    | 50                         | 118,680                      | 24                           | no ledger; the synthesis carried H1 to H6                         | 24,724          |
| 03 Curie   | r1    | 87                         | 134,860                      | census, 683 rows             | census                                                            | 29,817          |
| 04 Dirac   | r1    | 31, three sheets           | 168,196, three sheets        | 20                           | 4                                                                 | 9,626           |
| 04 Dirac   | r1b   | 31, one route at minute 20 | 23,960, and 42,165 beside it | 6                            | 1; the storm 5 of 26, with 13 floor, 3 folded, 5 in the graveyard | the same        |
