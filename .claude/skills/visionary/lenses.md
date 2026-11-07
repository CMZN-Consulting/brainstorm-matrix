# The lens deck

A lens is a vantage: it decides where an analyst looks and what it dares. Deal one lens per analyst for a diverging round, four different lenses for a storm or a hurricane, and paste each dealt lens into the brief whole, so the brief stands alone. When a question needs a lens the deck lacks, invent one in the same three parts and add it here after the storm. An overlay may word a lens for its own team; where it does, deal its wording.

**First Principles.** _Stance:_ start from what must be true (the rules of the domain, the mathematics, the physics of the machine, the cost) and rebuild from there; compare with today only at the end. _Asks:_ what is the irreducible job, and what would a clean sheet look like? _Cards:_ designs derived from named invariants, each invariant stated.

**The Archaeologist.** _Stance:_ the team has already paid for many lessons; dig them up. Decisions, deferred decisions, incidents, post-mortems, audits, the project's notes, version history. _Asks:_ what did we try, what broke, what was ruled and why, what was deferred and is now due? _Cards:_ what to keep, what never to repeat, what to finally do, each citing the record. Never re-proposes a buried idea without new evidence.

**The Scout.** _Stance:_ the outside view. Other teams and products in the field, open-source projects, papers, the latest releases. _Asks:_ who solved this, how well, at what cost, and what changed in the last year? _Cards:_ prior art with URLs and dates, each with the difference between their setting and ours spelled out.

**The Saboteur.** _Stance:_ the pre-mortem. It is ninety days after launch and it failed, lost money, or woke someone at three in the morning: write the incident. _Asks:_ what breaks first: a race, a restart, stale data, an outage of something we depend on, a start in the wrong order, a human under stress? _Cards:_ designs driven by failure, each naming the incident it makes impossible.

**The Adversary.** _Stance:_ someone wants to hurt us: an attacker at the boundary, a competitor or a customer reading what we publish, a poisoned input, a compromised dependency. _Asks:_ what do they see, and what do they try first? _Cards:_ designs that hold under attack, each with the cheap test that proves it.

**The Minimalist.** _Stance:_ the smallest thing that could work. Delete, merge, defer; every part must earn its place. _Asks:_ what if we built a third of it, and what would we never miss? _Cards:_ designs with less in them, each listing what was cut and why the cut is safe.

**The Moonshot.** _Stance:_ budget, headcount and time are no object; what would the best team in the world build? Then walk it back to the first rung reachable now. _Asks:_ what is the ceiling, and which step toward it is cheap today? _Cards:_ an ambitious design and its first rung, the rung costed.

**The Inverter.** _Stance:_ take the question's central assumption and flip it. _Asks:_ what if the thing we protect is the liability, the slow path is the fast one, the part we centralise should be spread, or the reverse? _Cards:_ inverted designs, each naming the assumption flipped and what survives the flip.

**The Analogist.** _Stance:_ borrow from a distant field: biology, ecology, physics, aviation, distributed systems, games, markets of another century. _Asks:_ where has nature or another discipline already solved this shape of problem? _Cards:_ transplanted mechanisms, each with the mapping spelled out and the place where the analogy breaks.

**The Contradiction Hunter.** _Stance:_ name the trade-off that blocks the design (improve A and B gets worse), then dissolve it instead of splitting the difference, separating the two demands in time, in space, by condition or by scale (TRIZ). _Asks:_ which contradiction is everyone compromising on? _Cards:_ designs that remove a trade-off, each naming the contradiction.

**The Operator.** _Stance:_ day two, and every day after. Deploy, observe, recover, rotate, upgrade, one machine at a time. _Asks:_ what does the operator see, what do they type, and what happens while they sleep? _Cards:_ operable designs, each with its signals, its runbook steps and its failure behaviour.

**The Scientist.** _Stance:_ how will we know? Every claim becomes a measurement: the metric, the null, the threshold and the window, registered before the data. _Asks:_ which experiment decides this, how cheap can it be, and what result would kill the idea? _Cards:_ designs with their falsifiers built in.

**The Economist.** _Stance:_ every choice spends something: money, compute, operator attention, tokens. _Asks:_ what does it cost, what does it earn, what does its spread of outcomes look like, and what is the cheapest experiment? _Cards:_ priced designs, the price of doing nothing included.

**The Newcomer.** _Stance:_ arrive tomorrow knowing nothing. _Asks:_ what is confusing, what would a newcomer break first, and what should be one concept instead of three? _Cards:_ designs easy to hold in the head, with the names that make them so.

**The Integrator.** _Stance:_ everything touches something. Contracts upstream and downstream, the direction a dependency may point, the order in which things arrive. _Asks:_ what does this change around it, and in what order can it land? _Cards:_ designs with their interfaces, their dependencies and their arrival order.
