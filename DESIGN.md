# Sike Society — Design Document

> _"Një shoqëri sekrete që punon në hije për të mbajtur paqen në glob."_

**Author:** Alban Tahiri
**Course:** Functional Programming · 2025/2026
**Last updated:** April 2026

---

## 1. Vision

Sike Society is a functional simulation of a secret guardian society that
defends the planet from external threats. It is **not** a conflict-driven
system, nor an economic one. The seven members work **collectively**, each
specialized in their own domain, under the unified command of Sike.

The simulation models how a disciplined, hierarchical, altruistic group
responds to unpredictable global threats. The emergent behavior of interest
is **not** interpersonal rivalry, but **collective resilience** — how the
society maintains equilibrium as threats appear, are neutralized, and fade.

This project is a work of functional art expressed in Haskell. Every design
decision prioritizes **clarity**, **type safety**, and **narrative fidelity**
to the original Sike Society concept.

---

## 2. The World

### 2.1 Domains

The world is partitioned into three physical domains plus a symbolic one:

| Domain   | Description                                        |
| -------- | -------------------------------------------------- |
| `Earth`  | The surface world — cities, forests, land.         |
| `Ocean`  | The seas and unexplored deep waters.               |
| `Sky`    | The aerial domain — clouds, atmosphere.            |
| `Hidden` | The symbolic / unseen layer (memory, information). |

Each member operates in one or more domains. Threats appear in specific
domains, and only members with access to that domain can respond directly.

### 2.2 Time

Time advances in discrete steps. Each step represents one "tick" of global
activity. At every step:

1. Continuous rules fire (healing, intelligence gathering, command flow).
2. Scheduled external events may trigger (new threats, alien incursions).
3. Members respond to active threats based on domain and command.
4. The world state updates. Nothing is mutated — each step returns a new `World`.

---

## 3. The Members of Sike Society

All seven members are **united**, **loyal**, and **cooperative**. There is no
internal rivalry. Each has a bounded, specialized capability. Only Sike has
unbounded oversight.

### 3.1 Sike — The Head

- **Domain:** All
- **Role:** Commander. Sees one step into the future. Reads the minds of
  all entities (members and external).
- **Bounded?** No — Sike's perception and authority are unlimited within
  the society.
- **Core function in simulation:** Issues commands, prioritizes threats,
  assigns members to respond.

### 3.2 Tobi — Guardian of the Waters

- **Domain:** Ocean (primary), Earth (can visit)
- **Role:** Maintains order and peace in the oceans. Holds a safe haven
  in the deep waters.
- **Bounded?** Yes — can only act in Ocean and Earth.
- **Core function:** Defends ocean peace; stabilizes aquatic threats.

### 3.3 Travis — Enforcer of the Waters

- **Domain:** Ocean
- **Role:** Targets and dismantles illegal businesses operating in the
  deep waters — creatures running underwater bars, smuggling dens, or
  unlicensed operations in unexplored ocean zones. He imposes the
  "ocean coin" toll on these illicit enterprises as a corrective measure,
  not a general tax on honest sea life.
- **Bounded?** Yes — Ocean only.
- **Core function:** Detects and neutralizes illegal aquatic businesses.

### 3.4 Skye — Guardian of the Sky

- **Domain:** Sky
- **Role:** Monitors and intercepts illegal aerial movement. Arrests
  criminal flights (e.g., spy pigeons).
- **Bounded?** Yes — Sky only.
- **Core function:** Defends aerial domain from smugglers and spies.

### 3.5 Leyton — Keeper of Ancient Knowledge

- **Domain:** Hidden (memory), Earth
- **Role:** The first inhabitant. A dino-snake hybrid. Remembers the
  deep history of the planet and knows what truly controls it.
- **Bounded?** Yes — acts through knowledge, not force.
- **Core function:** Provides historical context; identifies ancient
  threats that others cannot recognize.

### 3.6 Terry100 — The Listener

- **Domain:** Hidden (information), all physical domains
- **Role:** The only woman of the group. Leyton's partner. Met Sike
  through Leyton. Her gift is hearing the conversations and secrets of
  external creatures. Because Sike cannot be everywhere, he appointed
  Terry100 as the society's intelligence officer.
- **Bounded?** Yes — her **primary mission** is information gathering.
  However, she **can fight** when the situation demands it. Combat is
  not her purpose, but she is not helpless.
- **Core function:**
  1. `listen` — collects intelligence on external entities, increasing
     society awareness and helping detect threats earlier.
  2. `engage` (secondary) — can participate in combat when assigned by
     Sike, though at reduced effectiveness compared to specialized members.

### 3.7 DrLeyton — The Healer and Keeper of Immortality

- **Domain:** Hidden (internal to society)
- **Role:** A secret clone of Leyton, created by Leyton himself. Because
  Leyton — the first inhabitant of the planet — already held the full
  ancient knowledge of existence, including the lost medical arts, he
  cloned himself into a second form specialized as an omniscient doctor.
  DrLeyton therefore is not an ordinary healer: he is the guardian of the
  **secret of immortality** that keeps the whole society alive across time.
- **Hidden fact:** DrLeyton is a clone of Leyton. This is a secret even
  within the society — modeled in the data as `isClone :: Bool` and
  `originatedFrom :: MemberId`.
- **Chain of command:** Reports to Leyton (his origin), serves Sike Society
  (his purpose), commanded by Sike (his authority).
- **Bounded?** Yes — acts only within the society, never against external
  threats directly.
- **Core functions:**
  1. `heal` — restores energy to _any_ member who has lost it through
     engagement. Not limited to Leyton.
  2. `preserve` — applies the immortality principle: members under
     DrLeyton's care do not decay over time. Their base capacity is
     maintained regardless of how many steps have passed.

---

## 4. External Entities (The Threats)

External entities are **not** members of Sike Society. They are the "evil"
that the society works to contain. Examples from the canon:

| Threat              | Domain | Description                                 |
| ------------------- | ------ | ------------------------------------------- |
| Ocean Abusers       | Ocean  | Creatures that exploit the seas unlawfully. |
| Rogue Pilots        | Sky    | Pilots transporting illegal cargo.          |
| Spy Pigeons         | Sky    | Birds used by criminals for surveillance.   |
| Aliens              | All    | Historic major threat — can return.         |
| Ancient Disturbance | Hidden | Old evils known only to Leyton.             |

Threats have their own energy and hostility levels. They appear at scheduled
or random intervals and persist until neutralized by the appropriate member.

---

## 5. Interaction Rules

Interactions are **asymmetric** and **domain-aware**. A member can only act
on a threat that shares one of their domains. Sike can act on anything.

### 5.1 Continuous Rules (fire every step)

These rules run every tick, giving the world constant life. Even during
peaceful steps, the society is active:

1. **Healing rule:** `DrLeyton` restores `+3 energy` to _every_ member
   below maximum, each step. All seven are under his care.
2. **Immortality rule:** While `DrLeyton` is `Active`, no member suffers
   time-based decay. The society's base capacity is preserved indefinitely.
3. **Intelligence rule:** `Terry100` listens. Each step, she gathers a
   small amount of intelligence from the external world, raising the
   society's awareness level (capped).
4. **Enforcement rule:** `Travis` patrols the ocean. Each step, he has a
   chance to detect and collect the `ocean coin` toll from illegal
   underwater businesses — even when no major threat is active. This is
   ambient income for the society.
5. **Sky watch rule:** `Skye` monitors the atmosphere. Each step, he may
   raise a low-level alarm about suspicious aerial movement — early
   warnings that may or may not escalate into full threats.
6. **Command rule:** `Sike` scans the world, detects active threats, and
   assigns them to members based on domain match. He does not rest.
7. **Recovery rule:** Any member in `Dormant` state regains `+1 energy`
   per step until they return to `Active`.

The simulation is alive every step — threats only add **escalation** on
top of this baseline activity.

### 5.2 Engagement Rules (fire when a threat is active)

8. **Domain match:** Only a member whose domain includes the threat's
   domain can engage it.
9. **Engagement cost:** Engaging costs the member energy proportional to
   the threat's hostility.
10. **Neutralization:** When a threat's energy drops to zero, it is removed
    from the world and the engaging member gains `+influence`.
11. **Overwhelm:** If a threat's hostility exceeds a single member's
    capacity, Sike may assign a second member (if domains allow).

### 5.3 State Transitions

A member's state evolves based on their energy:

- `energy >= 60` → `Active`
- `20 <= energy < 60` → `Strained`
- `energy < 20` → `Dormant` (cannot engage, only recover)
- `engaged in combat` → `Vigilant`
- `post-engagement, fully healed` → `Harmonized`

---

## 6. Scheduled Historical Events

Beyond the continuous activity of section 5.1, the simulation honors the
canonical history of Sike Society through **scheduled events** — major
moments that occur at specific steps and disrupt the baseline rhythm:

| Step | Event                  | Effect                                           |
| ---- | ---------------------- | ------------------------------------------------ |
| 0    | Society awakens        | All members set to `Active`.                     |
| 10   | Spy pigeon incursion   | A `SpyPigeons` threat appears in Sky.            |
| 25   | Illegal ocean business | An `OceanAbuser` threat appears in Ocean.        |
| 50   | **Alien incursion**    | A high-hostility `Aliens` threat appears in All. |
| 75   | Ancient disturbance    | A `Hidden` threat only Leyton can identify.      |

**Important distinction:** The rules in 5.1 describe what the society
_always does_ — healing, listening, patrolling, commanding. The table
above describes _what happens to the society_ from the outside world at
specific moments in its history. Together they produce the dramatic
pedagogical rhythm of the simulation:

1. **Peace** (steps 1–9): baseline activity hums along.
2. **First minor threat** (step 10): Skye handles the spy pigeons.
3. **Peace resumes** (steps 11–24): recovery, healing, patrols continue.
4. **Second minor threat** (step 25): Travis handles the illegal business.
5. **Long peace** (steps 26–49): the society reaches a high harmony.
6. **Major threat** (step 50): the aliens arrive. Full mobilization.
7. **Recovery and healing** (steps 51–74): DrLeyton works hard.
8. **Ancient threat** (step 75): only Leyton can interpret it.
9. **Final equilibrium** (steps 76–100): does the society harmonize?

Multiple runs with the same schedule but different initial conditions will
produce different outcomes — this is the emergent behavior.

---

## 7. Architecture

The project is organized into five Haskell modules, each with a single,
well-defined responsibility:

```
src/
├── Types.hs         -- All algebraic data types and type classes
├── Characters.hs    -- Initial definitions of the seven members
├── Threats.hs       -- Definitions of external threats
├── Interaction.hs   -- Continuous and engagement rules
└── Simulation.hs    -- step :: World -> World and simulate :: Int -> World -> World

app/
└── Main.hs          -- Entry point; runs demonstration scenarios

test/
└── Spec.hs          -- QuickCheck properties and unit tests
```

### 7.1 Type Classes

Two custom type classes provide polymorphic abstraction:

- `class Engageable a` — things that can engage with threats (members).
- `class Threatening a` — things that can threaten (external entities).

### 7.2 Purity

All transformations are pure functions. Side effects (IO, printing) are
confined to `Main.hs`. The simulation is **deterministic**: given the same
initial world and event schedule, the output is always identical.

### 7.3 Error Handling

No runtime exceptions. Partial operations return `Maybe` or `Either` and
are handled explicitly at every call site.

---

## 8. Testing Strategy

Testing is done with **QuickCheck** (property-based) and **HUnit** (unit).

### 8.1 Properties to Verify

1. **Conservation of members:** `length (members w) == length (members (step w))`
2. **Energy non-negativity:** No member ever has negative energy.
3. **Domain safety:** A member never engages a threat outside their domain.
4. **Simulation composition:** `simulate n . simulate m == simulate (n + m)`
5. **DrLeyton invariant:** While `DrLeyton` is `Active`, no member
   remains at zero energy for more than `k` consecutive steps (for some
   small `k` representing healing delay).
6. **Clone invariant:** `DrLeyton.originatedFrom == Leyton.id` at all
   times — the origin relationship is immutable.

---

## 9. Out of Scope

The following are intentionally excluded from this project:

- Internal conflict among members.
- An economic system or currency mechanics.
- Graphical rendering (terminal output is sufficient).
- Networked or concurrent simulation.
- Machine learning or adaptive agent behavior.

---

_End of design document. Implementation follows._
