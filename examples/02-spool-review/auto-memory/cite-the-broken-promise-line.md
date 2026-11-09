---
name: cite-the-broken-promise-line
description: "In matrix review holds, \"breaks README:N\" must name the promise that fails, not the line that makes the triggering input legal"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 84690740-823c-4cbb-bb6a-d57d6999200b
  modified: 2026-11-09T18:15:22.264Z
---

In a review hold's **Where** line, cite as broken only the README lines whose promise the code fails. A line that merely makes the triggering input legal (e.g. "max_attempts must be ≥1", which the code keeps) goes in the Trace as context, not in the "breaks" list.

**Why:** Storm Ada r1 (2026-11-09), hold R1-AL0-H4 cited `README.md:41` as broken; the Visionary flagged that :41 is kept by the constructor and only makes `max_attempts=1` legal; the broken promises were :31 (the handler is called) and :34 (up to max_attempts tries).

**How to apply:** before sealing, for each README line in a "breaks" list, ask "does the code fail what this line says?" If not, move it out of the list.
