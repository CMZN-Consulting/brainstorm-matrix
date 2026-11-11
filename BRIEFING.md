---
kind: rule
status: living
date: 2026-10-23
author: visionary
---

# Briefing

This is how the Visionary briefs the room.

An analyst at xhigh effort (one step below max; `/effort` sets it) has the same knowledge and the same honesty as one at max. What changes is that it corrects itself less within a turn and looks less for things the brief did not point at. So the brief does that work for it.

A room that runs every seat at max, with no cap on reasoning per turn, follows this rule as well. What keeps a thread on the question at max lives in three places:

- the analyst skill, § Max effort and the thread: two checks and a trigger, four routes, the stopping rules and the caps;
- the visionary skill, § Max effort and the room: the ledger's four fates, the synthesis caps, the cost table, one correction loop, and the shape named by the question;
- `GROUNDS.md`, the open list of the states the room has met.

The numbered points below are the one home of what they define: both skills point here rather than restate them. The nearest worked model is the brief in `examples/01-ada-tool-library/r1/brief.md`: a named file set and one question per analyst, a procedure per lens, and a Done-when.

1. **Carry the ground.** GROUND.md names every path, line and prior ruling the question touches, each pinned to a commit (`git show COMMIT:PATH`). It also says what is settled. Analysts spend their reasoning on the question, not on finding the files. Anything I could not find goes under Unknowns, so nobody has to stumble on it.
2. **One bounded question per analyst per round.** Each analyst's row in the brief gives:
   - its one question;
   - its file set, named, or a list of rows;
   - **Done when**, saying what a complete answer contains.

   Coverage is file for file: the sheet's coverage ledger must equal the file set. "Done" means it does, not that enough was found.

3. **One shape for every sheet.** Every round's sheet has the rows or cards, each finding with its `path:line`, then **Doubts**, then **Not read**. The last two are mandatory, and "none" is written out (the sheet template of the analyst skill adds Grounds and puts Not read inside Coverage). A hole then shows instead of hiding.
4. **The cross-check is mine.** Two cases trigger it: two analysts disagree, or a sheet states a fact that the ground does not carry. I first open the source myself. If that cannot settle it, I run a second bounded round, `rKb` (`r1b` after `r1`, `r2b` after `r2`), on that point alone. Its brief quotes both claims and names the lines to read.
5. **A claim without `path:line` is a lead, not a finding.** No load-bearing claim enters a ledger or a synthesis until I have opened it at its line. The synthesis says which claims I verified; everything else stays labelled a lead.
6. **No exhortations.** A brief never says "be thorough". It gives four things:
   - what the storm is for;
   - the defect classes to look for, such as an input the parser accepts unchecked, a retry with no limit, or a guard that fails open;
   - the check that finds each class;
   - the shape of the answer.

   Every brief carries one rule in one line: a doubt is welcome even when it proves wrong. We want recall. A raised non-issue costs one verify pass, and a missed defect costs more.

7. **Lenses, each with a procedure.** The lenses stay, because they carry the diversity. Each one is dealt with a concrete procedure for this storm. Two examples:
   - The Saboteur: "for each write path in your files, name the input that breaks it, at its line".
   - The Archaeologist: "follow each named function with `git log -L` back to the decision that set it".

   A persona is not a procedure.

8. **Two short rounds beat one open round.** Each round gets a narrow file set and a box of 45 to 60 minutes. A second bounded round on what the first raised (its doubts, splits and leads) beats one open three-hour round. Spark, storm and hurricane name how many rounds a storm runs; `rKb` rounds count toward that.

**Helpers.** When a brief allows helpers, it gives them a Done-when, a command allowlist and a cap on what they return. The analyst reads a return once, audits the helpers' transcripts before sealing, and counts a helper's reading only once it has checked it.
