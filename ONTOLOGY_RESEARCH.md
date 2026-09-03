# The Onion: Logic → Semiotics → Ontology → Sensors

## Companion to SEMIOTICS_RESEARCH.md

## The Question

Can the logics we built — probabilistic, temporal, multimodal — *grasp
the external world*? Is there a coherent chain:

```
logic ⊃ semiotics ⊃ ontology ⊃ sensors ⊃ world
```

perhaps with dynamic ontologies continuously updated by camera,
microphone, and other sensor streams?

**Short answer**: yes, and each arrow of that chain has a distinct
research literature behind it. The onion has four rings, and — the key
finding of this survey — the outermost ring does not just feed inward:
it *closes the loop* through action, exactly as Friston's active
inference predicts.

---

## The Four Rings

```
      ┌─────────────────────────────────────────────┐
      │  Ring 1: LOGIC                              │
      │  modal operators, Kripke frames, fixpoints  │
      │  (mm.m, ctl.m, dtmc.m, mmb.m ...)           │
      │                                             │
      │   ┌─────────────────────────────────────┐   │
      │   │  Ring 2: SEMIOTICS                  │   │
      │   │  sign → object → interpretant       │   │
      │   │  how formulas MEAN                  │   │
      │   │                                     │   │
      │   │   ┌─────────────────────────────┐   │   │
      │   │   │  Ring 3: ONTOLOGY           │   │   │
      │   │   │  what EXISTS: objects,      │   │   │
      │   │   │  processes, events          │   │   │
      │   │   │                             │   │   │
      │   │   │   ┌─────────────────────┐   │   │   │
      │   │   │   │  Ring 4: WORLD      │   │   │   │
      │   │   │   │  physical reality,  │   │   │   │
      │   │   │   │  accessed via       │   │   │   │
      │   │   │   │  sensors & actuators│   │   │   │
      │   │   │   └─────────────────────┘   │   │   │
      │   │   └─────────────────────────────┘   │   │
      │   └─────────────────────────────────────┘   │
      └─────────────────────────────────────────────┘
```

Each ring is where one discipline's "primitive" becomes the next ring's
"derived". What logic calls an *atomic proposition*, semiotics calls a
*symbol*; what semiotics calls an *object*, ontology calls an
*individual or process*; what ontology calls a *state of affairs*, a
sensor produces as *data*.

---

## Ring 3 → Ring 4: How Ontology Touches the World

This is the hardest arrow, and it has two rival formalizations that are
directly relevant to our sketches.

### Possible Worlds vs Situations (Barwise–Perry)

Standard Kripke semantics quantifies over **total possible worlds** —
maximal, mutually inconsistent states of the entire universe. For a
sensor, this is wildly wrong: a camera frame does not capture the whole
world; it captures a **scene** with a boundary.

**Situation semantics** (Barwise & Perry 1983) replaces total worlds
with **partial situations** — small chunks of reality supporting only
the facts they contain. Crucially:

- A situation `s` supports a fact `⟨⟨R, a, b, T⟩⟩` without deciding
  everything else
- Infons (basic facts) can carry polarity (true or false in s)
- Meaning of an utterance/sign = relation between described situation
  and described-by situation

This is the natural ontological layer for sensors: **each observation
is a partial situation**, and the accessibility structure between
situations replaces worlds. Our Kripke models survive this change —
`ctl.m`'s fixpoints work unchanged on situations, but the model is now
*growable*: novel observations introduce new situations (dynamic
ontology).

### The Symbol Grounding Problem (Harnad)

If every symbol's meaning comes from other symbols, meaning is circular.
Harnad (1990): somewhere, symbols must ground out in **non-symbolic
representation** — sensorimotor categorization. Iconic representations
(analog images of rose-shapes) plus indexical representations (causal
links from actual roses to tokened features) combine into symbols.

Note the exact correspondence to Peirce's second trichotomy (icon →
index → symbol). Harnad's grounding ladder *is* Peirce's trichotomy,
arrived at independently through cognitive science. That convergence is
the strongest argument that the icon/index/symbol modalities we built in
`semiotic_demo.m` are the right vocabulary for the grounding arrow.

---

## Ring 2 → Ring 3: From Signs to an Ontology

John Sowa's program (`Signs, Processes, and Language Games`, 2015) is
the clearest published bridge. He synthesizes three logicians into a
foundation for ontology:

| Thinker | Contribution | Role in the onion |
|---|---|---|
| **Whitehead** | Process philosophy | Theory of the **flux** — events/processes are primary |
| **Peirce** | Semiotics + Existential Graphs | Theory of the **logos** — signs carve patterns out of flux |
| **Wittgenstein** | Language games | Theory of semantic **adaptability** — categories shift with use |

Sowa's point: any static ontology (Cyc's 600k concepts, WordNet,
EDR) inherits Aristotle's genus/differentia method, which assumes
discrete stable objects. But sensors deliver continuous **process**
(Whitehead), meaning arises by interpretation (**Peirce**), and category
boundaries drift as communities use them (**Wittgenstein**). A dynamic
ontology must therefore be:

1. **Process-based** — the world is a stream of events, objects are
   stable patterns within it (Whitehead)
2. **Interpreted** — its elements are sign-vehicles awaiting
   interpretants, not self-interpreting atoms (Peirce)
3. **Revisable** — belief revision on new evidence is normal, not an
   error state (Wittgenstein/AGM)

### Formal Foundational Ontologies

Two mature systems supply Ring 3's internal structure:

- **BFO (Basic Formal Ontology)** — Barry Smith's *realist* ontology:
  categories exist independently of observers. Continuants (objects,
  enduring) vs occurrents (processes, unfolding). ISO-standardized,
  used across biomedical sciences via the OBO Foundry.
- **DOLCE** — Guarino & Masolo's *descriptive/cognitive* ontology:
  categories reflect human linguistic-conceptual organization
  (endurants, perdurants, qualities, abstracta).

For a sensing system, BFO's realist stance maps naturally onto sensor
grounding (occurrents = what instruments register); DOLCE maps onto the
interpretive side. Sowa's process-flux position sits between them.

---

## Ring 1 ↔ Ring 4 closed by ACTION: Active Inference

Here is the deepest recent development. Friston's **free energy
principle** states that anything persisting in exchange with its
environment maintains a generative model minimizing variational free
energy — surprise w.r.t. sensory input. Perception = belief update;
action = expected free energy minimization (sampling the world you expect).

Ramstead et al. (2020, *Entropy*) ask directly: *Is the Free-Energy
Principle a Formal Theory of Semantics?* Their answer: yes in embryo —
Markov blankets partition external states from internal model states,
and the blanket states function as **sign vehicles**: they stand for
external causes while being physically independent of them.

**Milette-Gagnon, Veissière, Friston & Ramstead (2023)** then make the
convergence explicit: *"An active inference approach to semiotics: A
variational theory of signs."* Their mapping:

```
Peircean term              Variational / mathematical term
─────────────────────     ─────────────────────────────────
sign vehicle               Markov blanket state (sensory)
object                     hidden external state
dynamical interpretant     posterior belief update q(s | o)
habit                      learned generative model prior
semiosis                   recursive variational inference
```

In other words: **an interpretant is literally a Bayesian posterior
update**. And that is precisely what our `mmb.m` already computes —

```
belief(PK, Agent, F, ActualWorld)
    = Σ prior(v)·[v ⊨ F]   restricted to agent-accessible v
      ─────────────────────────────────────────── normalized
        Σ prior(v)             restricted to agent-accessible v
```

— conditioning a prior over worlds on an observation set (the
accessible ones). It is a discrete, hand-computable special case of
variational message passing. The onion's innermost computational step
and its outermost physical principle are the same operation.

### Dynamic Ontologies via Event Calculus

How do ontologies *change*? The classic machinery is temporal action
formalism:

- **Situation calculus** (McCarthy 1963): fluents hold in situations;
  actions map situations to situations
- **Event calculus** (Kowalski & Sergot 1986): events *initiate* and
  *terminate* fluents over time:
    ```
    initiated_at(F, T)  :- happens(E, T), initiates(E, F, T).
    holds_at(F, T2)     :- initiated_at(F, T1), T1 < T2,
                           not clipped_between(T1, T2, F).
    ```
- Modern form: epistemic event calculi add **knows whether/that**
  operators — knowledge itself becomes a fluent that sensors initiate
  and terminate (Lee & Palla; ASReasoner variants)

A sensor stream is then just: `happens(observation(camera, o_t), t)` —
each frame is an event initiating/terminating fluents ("sees red", "door
open"). The Kripke model's label map `labels :: map(string, list(string))`
is a minimal fluent store; adding/removing labels on evidence *is*
event-calculus updating in miniature. Combined with `mmb.m`'s
threshold-conditioned beliefs, you get exactly Ramstead-style belief
revision driving ontology growth.

---

## Implementation Sketches (all buildable from existing modules)

| Step | Modules needed | Status |
|---|---|---|
| Sensor reading as evidence set restricting accessible worlds | `mmb.belief/4` | exists |
| Threshold crossing → assert/remove atomic labels (fluent update) | `map.set/map.delete` on `kripke_m.labels` | trivial addition |
| Event log with initiation/termination of fluents | new `ec.m` (~100 lines) | easy |
| Situation vs world check: does `sat()` care about totality? | it doesn't — fixpoints only need monotone ops | observation: `ctl.m` already runs on partial models |
| Per-agent belief divergence tracking over time | fold over time steps using `mmb` | easy |
| Novel-sign detection (label never seen before) → grow States | membership test + set insert | trivial |

The genuinely new module would be ~150 lines: `ec.m` (event calculus
over discrete ticks feeding `mm.kripke_m`) and `grounding_demo.m`
running a simulated light/noise sensor through ten ticks, showing
beliefs diverging per modality type and the ontology gaining a new
predicate when observations fall outside all existing classes.

---

## Why This Is Not Mainstream Yet

Same diagnosis as for Peircean formalization generally (see
SEMIOTICS_RESEARCH.md §7): the layers live in different academic tribes.

- BFO/DOLCE people = philosophers + biologists (ICBO conference)
- Event calculus people = logic programmers (KR, ICLP)
- Active inference people = neuroscientists + physicists (ENTROPY,
  Biological Theory)
- Semioticians = humanities departments

Very few people read all four literatures. Sowa, Ramstead, and
Friston's group are the exceptions proving the rule — and notably,
both Sowa and Ramstead cite Peirce as their common ancestor. The
onion diagram above is essentially the citation graph collapsed.

There is also a genuine technical obstacle: composing a **modal model
checker** with a **Bayesian filter** requires the algebra of belief
states to be compatible with the lattice over which CTL fixpoints run.
Our `dtmc.m` solved exactly this problem once already (booleans →
probability vectors for reachability) — probability-vector-valued
fluents in event calculus is the same move again, and there is no
published treatment connecting those two literatures specifically.

---

## BibTeX References

```bibtex
% ---- Ring 4 -> 3: situational/embodied grounding ----

@article{Harnad1990,
  author  = {Harnad, Stevan},
  title   = {The Symbol Grounding Problem},
  journal = {Physica D: Nonlinear Phenomena},
  volume  = {42},
  number  = {1--3},
  pages   = {335--346},
  year    = {1990},
  doi     = {10.1016/0167-2789(90)90087-6}
}

@book{BarwisePerry1983,
  author    = {Barwise, Jon and Perry, John},
  title     = {Situations and Attitudes},
  publisher = {MIT Press},
  address   = {Cambridge, MA},
  year      = {1983}
}

@incollection{Kratzer2007,
  author    = {Kratzer, Angelika},
  title     = {Situations in Natural Language Semantics},
  booktitle = {Stanford Encyclopedia of Philosophy},
  publisher = {Stanford University},
  url       = {https://plato.stanford.edu/entries/situations-semantics/},
  year      = {2007/2018}
}

@article{Fiorini2013GroundOnto,
  author  = {Fiorini, Sergio and Abel, Mark and Scherer, Stefano},
  title   = {An approach for grounding ontologies in raw data using
             foundational ontologies},
  journal = {Information Systems},
  volume  = {38}, number = {5}, pages = {784--799},
  year    = {2013},
  doi     = {10.1016/j.is.2012.11.013},
  note    = {Survey of raw-data-to-BFO grounding pipelines}
}

% ---- Ring 3: foundational ontologies ----

@book{SmithBFO2020,
  author    = {Smith, Barry},
  title     = {Basic Formal Ontology: A Guided Tour},
  edition   = {2nd},
  publisher = {OBO Foundry / University at Buffalo},
  year      = {2020}
}

@inproceedings{GangemiMasolo2002DOLCE,
  author    = {Gangemi, Aldo and Guarino, Nicola and Masolo, Claudio and
               Oltramari, Alessandro and Schneider, Luc},
  title     = {Sweetening Ontologies with {DOLCE}},
  booktitle = {Knowledge Engineering and Knowledge Management: Ontologies
               and the Semantic Web (EKAW 2002), Lecture Notes in Computer
               Science 2473},
  publisher = {Springer},
  pages     = {166--181},
  year      = {2002},
  doi       = {10.1007/3-540-45810-7_18}
}

@book{Rescher1996Process,
  author    = {Rescher, Nicholas},
  title     = {Process Metaphysics: An Introduction to Process Philosophy},
  publisher = {SUNY Press},
  year      = {1996},
  note      = {Modern exposition of Whiteheadian flux-primacy}
}

% ---- Ring 2 -> 3: semiotic foundations of ontology ----

@misc{Sowa2015SignProc,
  author = {Sowa, John F.},
  title  = {Signs, Processes, and Language Games: Foundations for Ontology},
  url    = {https://www.jfsowa.com/pubs/signproc.htm},
  year   = {2015},
  note   = {Extended version of invited lecture, Nijmegen 1999;
            explicitly proposes Whitehead+Peirce+Wittgenstein synthesis}
}

@book{Sowa1984CG,
  author    = {Sowa, John F.},
  title     = {Conceptual Structures: Information Processing in Mind
               and Machine},
  publisher = {Addison-Wesley},
  year      = {1984}
}

% ---- Ring 1 <-> 4: action closing the loop ----

@article{Friston2010FEF,
  author  = {Friston, Karl J.},
  title   = {The Free-Energy Principle: A Unified Brain Theory?},
  journal = {Nature Reviews Neuroscience},
  volume  = {11},
  pages   = {127--138},
  year    = {2010},
  doi     = {10.1038/nrn2787}
}

@article{Ramstead2020Semantics,
  author  = {Ramstead, Maxwell J. D. and Badcock, Paul B. and Friston, Karl J.},
  title   = {Is the Free-Energy Principle a Formal Theory of Semantics?
             From Variational Density Dynamics to Attractive Discrete States},
  journal = {Entropy},
  volume  = {22},
  number  = {8},
  pages   = {889},
  year    = {2020},
  doi     = {10.3390/e22080889}
}

@incollection{MiletteGagnon2023,
  author    = {Milette-Gagnon, Antoine and Veissi{\`e}re, Samuel P. L. and
               Friston, Karl J. and Ramstead, Maxwell J. D.},
  title     = {An Active Inference Approach to Semiotics:
               A Variational Theory of Signs},
  booktitle = {The Routledge Handbook of Semiosis and the Brain},
  publisher = {Routledge},
  year      = {2023},
  note      = {Peircean trichotomies as Markov blankets and variational updates}
}

@article{Bruineberg2016,
  author  = {Bruineberg, Jelle and Rietveld, Erik},
  title   = {The Anticipating Brain Is Not a Scientist:
             The Free-Energy Principle from an Ecological-Enactive Perspective},
  journal = {Frontiers in Human Neuroscience},
  volume  = {10},
  year    = {2016},
  note    = {554 citations; ecological alternative framing}
}

@article{Clark2013WhateverNext,
  author  = {Clark, Andy},
  title   = {Whatever Next? Predictive Brains, Situated Agents, and the
             Future of Cognitive Science},
  journal = {Behavioral and Brain Sciences},
  volume  = {36},
  number  = {3},
  pages   = {181--204},
  year    = {2013}
}

% ---- Dynamic ontology: event/situation calculus ----

@article{KowalskiSergot1986,
  author  = {Kowalski, Robert and Sergot, Marek},
  title   = {A Logic-Based Calculus of Events},
  journal = {New Generation Computing},
  volume  = {4},
  number  = {1},
  pages   = {67--95},
  year    = {1986}
}

@article{McCarthy1963,
  author  = {McCarthy, John},
  title   = {Situations, Actions, and Causal Laws},
  journal = {Stanford AI Project Memo 2},
  year    = {1963},
  note    = {Origin of situation calculus}
}

@article{LeePallaReformulating,
  author  = {Lee, Joohyung and Palla, Ravi},
  title   = {Reformulating the Situation Calculus and the Event Calculus
             in the General Theory of Stable Models and in Answer Set
             Programming},
  journal = {Journal of Artificial Intelligence Research},
  year    = {2012}
}

@article{EpistemicEC2018,
  author  = {{Various ASP-based authors}},
  title   = {An Epistemic Event Calculus for {ASP}-based Reasoning About
             Knowledge of the Past, Present, and Future},
  journal = {Theory and Practice of Logic Programming},
  year    = {2018},
  note    = {knows_whether/holds_at fusion — knowledge as fluent}
}
```

---

## One-Paragraph Answer

Yes — there is a coherent onion, and its modern form closes a loop:
**logic** provides the invariant reasoning skeleton (Kripke frames,
fixpoints); **semiotics** supplies the syntax-meaning link whose
icon/index/symbol stratification matches the sensorimotor grounding
ladder Harnad independently derived; **ontology** organizes the flux
into process-friendly categorical schemes (BFO/DOLCE/Sowa-process);
**sensors** inject *partial situations* — Barwise–Perry's correction to
total possible worlds — as fresh evidence sets; and **active inference**
turns evidence update into Bayesian belief revision whose mathematics,
per Milette-Gagnon/Friston/Ramstead 2023, *is* Peircean interpretation.
Every arrow has working computational machinery in our sketch set except
the last mile, which needs one new ~150-line module: a discrete event
calculus that grows `mm.kripke_m` label sets under threshold-crossed
BeliefUpdates from `mmb.belief/4`. The loop being open rather than
one-way is not decoration — without the action-perception cycle, the
innermost ring is a beautiful proof system about nothing in particular.
