---
kind: sheet
storm: 01-ada-tool-library
round: r1
analyst: 2
lens: The Saboteur
status: sealed
date: 2026-01-15
---

# Storm Ada · r1 · Analyst 2 — The Saboteur

I read the question as a Saturday that goes wrong. The sheet already fails twice (the ground's Facts 4 and 5), and any replacement adds failures of its own. My headline: whatever replaces the sheet must still work when the tablet does not, must not shut out the members who gave only a phone number, and must show a reservation where the lending happens.

## Cards

### R1-A2-1 · Saturday without the tablet

- **Pitch:** whatever replaces the sheet falls back to paper in one step when the tablet is down, so that no Saturday has an hour in which no one can see a reservation.
- **How:** on Friday the system prints the next day's reservations for the twelve hot tools as one sheet, kept in a folder at the lending desk. When the tablet loses its connection, the volunteers lend from the sheet and write returns on it; on Monday one volunteer copies it back.
- **Why it could win:** it is the failure that hides every reservation for about an hour of the four, once a page depends on the tablet, and the tablet was down that long on 2 of 9 Saturdays.
- **How it could die:** a sheet printed on Friday is stale as soon as a member reserves on Saturday morning, and the fallback then double-books.
- **Grounding:** `GROUND.md:33`, `GROUND.md:31`.
- **Cost · door:** S · two-way.

### R1-A2-2 · One member holds half the hot tools

- **Pitch:** cap a member at two live reservations, so that no member holds six of the twelve hot tools for a Saturday.
- **How:** the reservation step counts the reservations a member has still to collect and refuses a third. On paper the cap is a volunteer's judgement at the door; in a page it is a line of code.
- **Why it could win:** twelve tools carry 60 percent of the reservations, so a member holding six of them would take half of those tools from everyone else. No fact says it has happened.
- **How it could die:** a cap is a rule the desk must explain at the door, and unexplained it reads as favouritism.
- **Grounding:** `GROUND.md:29`; speculation for the single-member case.
- **Cost · door:** S · two-way.

### R1-A2-3 · The hold that outlasts the member

- **Pitch:** release any reservation not collected 30 minutes after it starts, so that no tool sits idle until closing for a member who never comes.
- **How:** at 10:30 (30 minutes into the morning, or into a reserved slot) every uncollected reservation is struck and its tool goes to the walk-in queue. A member who is late gets the next free tool of the same kind.
- **Why it could win:** 31 of 120 reservations were never collected, and each held its tool until closing; the release turns that hold time back into lending time.
- **How it could die:** a member with a Saturday morning job reserves in good faith, arrives at 11:00 and finds the tool lent. The rule punishes honest lateness.
- **Grounding:** `GROUND.md:28`, `GROUND.md:24`.
- **Cost · door:** S · two-way.

### R1-A2-4 · The reservation for a tool that is not back

- **Pitch:** reserve by two-hour slot and refuse a slot while the tool is still out for the one before, so that no member arrives at 11:00 for a tool lent at 10:00 and not due back until 12:00.
- **How:** a hot tool is lent for two hours, so one lent at 11:00 is out until 13:00. Each reservation names a slot, and the reservation step refuses a slot the tool is still out for. The desk marks a tool in at check-in.
- **Why it could win:** it ends the arrival for a tool that is genuinely out, which neither the sheet nor a release rule can touch.
- **How it could die:** it needs return times at the desk, and slots turn a flexible Saturday into a timetable.
- **Grounding:** `GROUND.md:30`, `GROUND.md:24`.
- **Cost · door:** M · two-way.

### R1-A2-5 · The channel that shuts members out

- **Pitch:** take reservations by text message as well as by page, into the same list, so that the 190 members with only a phone number are not left without a way to reserve.
- **How:** a shared phone number receives "tool, Saturday"; a volunteer enters it on the tablet and texts back a confirmation. A page alone reaches the 70 members who gave an email address; the 190 who gave only a phone number may not own a browser to use it. The 40 with neither are served at the door only.
- **Why it could win:** the criteria ask that a phone-only member be served as well; 190 of 300 members gave only a phone number, and 40 gave neither.
- **How it could die:** a text line adds a second queue for two volunteers on a Saturday, and a phone to keep charged.
- **Grounding:** `GROUND.md:32`, `GROUND.md:31`; speculation for who owns a browser.
- **Cost · door:** M · two-way.

### R1-A2-W · No reservations: draw numbers at the door

- **Pitch:** reservations end; at 10:00 a member who wants one of the twelve hot tools draws a numbered ticket for it, so that no reservation can be forgotten, double-booked or hoarded.
- **How:** twelve tool names on a board and a bag of tickets for each. Ticket order is lending order, and a ticket not claimed within 30 minutes passes to the next. Nothing is booked ahead, so nothing can be forgotten, double-booked or hoarded.
- **Why it could win:** it ends both failures by removing the thing that fails, and it needs no device.
- **How it could die:** it turns a sure thing into a lottery. Members who plan a weekend job will not stand for it, and the crush at 10:00 may be worse than the sheet.
- **Grounding:** `GROUND.md:27`, `GROUND.md:28`; speculation for how members would react.
- **Cost · door:** S · two-way.

## Facts found

1. The tablet lost its connection on 2 of the 9 Saturdays, for about an hour each time (`GROUND.md:33`).
2. 31 of 120 reservations, about a quarter, were never collected, and a reservation holds its tool until closing (`GROUND.md:28`).
3. A hot tool is lent for two hours and the library is open for four, so a hot tool is lent about twice on a Saturday, if each loan runs its full two hours (`GROUND.md:24`, `GROUND.md:30`; derived).
4. 190 of 300 members gave only a phone number and 40 gave neither (`GROUND.md:32`).
5. The lending desk is at the far end of the room from the sheet (`GROUND.md:26`).

## Assumptions

1. The volunteers will follow one rule printed on the desk.
2. A member who reserves a hot tool wants it for the two-hour loan and not for the day.

## Doubts

1. The ground's Facts 4 and 5 may share a cause: the sheet is not where lending happens (`GROUND.md:26`). If so, the 30-minute release (R1-A2-3) mends only the uncollected reservations. Confidence 0.7.
2. R1-A2-4 assumes the volunteers will record when a tool goes out and comes back; no fact says they do (`GROUND.md:31`). Confidence 0.6 that they will not without a prompt.
3. The draw (R1-A2-W) may be fairer than I give it credit for: members already write their names on a shared sheet at the door (`GROUND.md:25`), and a draw asks little more of them. Confidence 0.3.

## Grounds

none.

## Coverage

Read to the end: `QUESTION.md`, `GROUND.md`. Skimmed: none. Not read: none.
