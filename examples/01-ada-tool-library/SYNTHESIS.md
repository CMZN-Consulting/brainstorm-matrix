---
kind: synthesis
storm: 01-ada-tool-library
status: landed
date: 2026-01-15
author: visionary
asked-by: desk-lead
---

# Storm Ada — how should a tool library take reservations? — synthesis

## TL;DR

Recommend O1: a paper sheet for the twelve hot tools at the lending desk, where members write their names and a volunteer copies it clean on Fridays, with a release 30 minutes after a reservation starts.
Why: the sheet hangs where nobody lends from (Fact 3), a reservation holds its tool until closing (Fact 5), and twelve tools carry 60 percent of the reservations (Fact 6).
How sure: medium. The ground does not separate the causes of the four bad Saturdays, and L0 suspects they share one cause (Doubt 1).
Cost: S, a two-way door; paper stays possible.
Measure four Saturdays against the thresholds below. O2, a page with text confirmations, is the next step if the first or third threshold is missed; a miss on the second moves the release time instead.

## The question

How should the library take reservations once the paper sheet goes? `QUESTION.md`.

## Options and how they fared

A spark runs no tournament, so the record is the ledger's: the cards each option is built from, and how many of them are alive.

| Option                                      | In one line                                                                                     | Record                                     | Strongest at                                                                       | Weakest at                                                                                      | Cost · door |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | ----------- |
| O1 · Tightened paper                        | The sheet at the lending desk, the twelve hot tools only, copied clean on Fridays, with release | 2 cards, none alive: it rests on the floor | Cost, and a Saturday nobody has to learn                                           | A name dropped in Friday's copy; the other 388 tools cannot be reserved at all                  | S · two-way |
| O2 · A booking page with text confirmations | A page and a shared phone number feed one list on the tablet, with cap, slots and tool status   | 5 cards, 3 alive                           | Reaching the 190 members with only a phone number; slots refuse a tool that is out | The tablet outage; a build kept by one volunteer; a phone line and a page need money or a donor | M · two-way |
| O3 · A draw at the door                     | No reservations; numbered tickets for the twelve hot tools at 10:00                             | 1 card, 1 alive                            | No device, no hoarding, no no-shows                                                | Fairness, and the crush at 10:00                                                                | S · two-way |
| Null · keep the sheet                       | The sheet by the door, as it is                                                                 | none                                       | Nothing to build                                                                   | Facts 4 and 5 stay as they are                                                                  | none        |

All three options carry the floor: only the twelve hot tools are reserved or drawn (R1-AL1-2), and a reservation not collected 30 minutes after it starts is released (R1-AL1-3; 10:30 for a reservation for the morning, 30 minutes into the slot for a slotted one). No duel split, because no duel was run.

## Recommendation

O1, for the spring term. A sheet at the desk answers the cause that Fact 3 points at, the sheet far from the desk, at the price of a pegboard or folder and a Friday task. We would pick O2 instead if the first or third threshold below is missed in the four Saturdays, or if the committee finds a volunteer who will keep a page and a phone line, both donated. We would pick O3 only if members ask for it; nothing in the ground says they will.

## Dissent

The best case for the runner-up, O2, in L0's own words (R1-AL0-5): "the criteria ask that a phone-only member be served as well; 190 of 300 members gave only a phone number, and 40 gave neither." A sheet at the desk serves them only when they come to the door.

## Risks and first measurements

Registered before the data, for the first four Saturdays of O1.

| Risk                                                                         | Metric                                                                                                          | Null                                                    | Threshold                          | Window         |
| ---------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ---------------------------------- | -------------- |
| Facts 4 and 5 share no cause the desk-side sheet reaches                     | Saturdays with an arrival for a lent reserved tool (a reservation already struck by the release is not counted) | 4 of 9, as last term                                    | at most 1 of 4                     | four Saturdays |
| The release punishes honest lateness (R1-AL0-3)                              | Members who arrive more than 30 minutes after their reservation starts and find the tool lent                   | not counted last term                                   | fewer than 3 in the four Saturdays | four Saturdays |
| A clean copy drops a name (R1-AL1-5)                                         | Reservations on the old sheet that are missing from the clean copy, checked on Saturday                         | not counted last term                                   | none                               | four Saturdays |
| The floor turns away the 40 percent of reservations for other tools (Fact 6) | Requests at the door to reserve a tool outside the twelve                                                       | 40 percent of last term's reservations, about 48 of 120 | fewer than 1 a Saturday            | four Saturdays |

A miss on the fourth row widens the twelve to the next most reserved tools; it does not point at O2.

## Open questions

For the committee: how many members would reserve by text message (`GROUND.md:42`); whether the volunteers will keep a paper fallback if asked; whether they would record when a tool goes out and comes back (L0, Doubt 2). For anyone with the log: the nine Saturdays one by one, to see whether Facts 4 and 5 share a cause.

## Provenance

O1 is built from R1-AL1-1 and R1-AL1-5, over the floor. O2 from R1-AL1-4, R1-AL0-1, R1-AL0-2, R1-AL0-4 and R1-AL0-5. O3 from R1-AL0-W. The sources are the ten Facts of `GROUND.md`; nothing came from outside them. L0's sheet is `r1/analyst-L0.md`; L1's is not reproduced in this example.

## Kudos

L1, the Minimalist: R1-AL1-3, the release, the shortest statement of a rule that two cards made, and carried by every option. L0, the Saboteur: R1-AL0-1, the only card that asked what a Saturday looks like when the tablet is down.

## The graveyard

- **R1-AL1-W · A Friday-night lottery.** Killed by an evening that asks members and volunteers to be present together. It may rise again with a volunteer who wants the job.
- **R1-AL0-3 · The hold that outlasts the member.** Killed by R1-AL1-3, which says the same in fewer words. Its objection, honest lateness, is a risk above.

## Disclosures

The ground did not separate the causes of Facts 4 and 5, and I dealt the lenses without asking the committee for the Saturday-by-Saturday log. It would have made the first risk above a question instead of a measurement.

## Grounds

none.

## Cost

No minutes and no tokens: this example was written by hand, and no room ran it. Survival per row, from the ledger; row 2 did not check this example's round.

| Row | Seats | Cards | Survived | Alive  | Findings | Confirmed | Misses |
| --- | ----- | ----- | -------- | ------ | -------- | --------- | ------ |
| 0   | L0    | 6     | 5 of 6   | 4 of 6 | —        | —         | —      |
| 1   | L1    | 6     | 5 of 6   | 0 of 6 | —        | —         | —      |
