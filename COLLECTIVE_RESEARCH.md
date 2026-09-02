# Collective Reasoning: Groups as First-Class Agents

## Companion to SEMIOTICS_RESEARCH.md and ONTOLOGY_RESEARCH.md

## The Question

Our Kripke structures already carry multiple *individual* agents
(epistemic, doxastic, deontic, semiotic modalities). What does it take
to reason about **collectives** — groups, subgroups, institutions — as
subjects in their own right?

- Shared beliefs and knowledge (common knowledge)
- Group obligations vs. the obligations of members (special vs. social)
- Collective moral responsibility; prohibitions binding a group
- Kant's categorical imperative as a constraint on group norms
- Normative institutions that persist over time

This survey maps the formal literature onto the modules we have, and
sketches what `mm_group.m` would add.

---

## 1. The Epistemic Layer: Common Knowledge

The canonical framework (Fagin-Halpern-Moses-Vardi) extends our
per-agent K_i operators with three group operators for a group G:

```
E_G f   "everyone in G knows f"        = conjunction of box_i f
C_G f   "it is COMMON knowledge"       = greatest fixpoint: E f & E E f & ...
D_G f   "distributed knowledge"        = box over INTERSECTION of relations
```

**In our machinery, today:**

| Operator | Recipe with existing modules |
|---|---|
| `E_G f` | `mm.box("K1", f)` conjunct `mm.box("K2", f)` ... |
| `D_G f` | accessibility relation = set intersection of rel_K1 ∩ rel_K2, then one `box` |
| `C_G f` | build modality whose relation is the **transitive closure of the union** rel_K1 ∪ rel_K2, then `box` |

`C_G` needs exactly one new helper (reflexive-transitive closure of a
union of label-indexed maps) plus reusing `mm.box`. Roughly 40 lines.
The classical results this unlocks:

- **Halpern-Moses**: common knowledge is unattainable by message-passing
  without shared clocks/coordinated attack paradox. Direct relevance to
  any multi-LLM routing consensus question (OmniRoute combo strategies!).
- **Aumann's Agreement Theorem** (1976): agents with common priors whose
  posteriors are common knowledge cannot agree to disagree. In our
  grounding_demo terms: two Bayes filters with equal likelihood models,
  whose posteriors become mutually accessible, converge to identical
  beliefs. Testable property — a future demo could verify convergence
  numerically using `mmb.belief`.

---

## 2. Public Announcement: Communication as Model Change

**Plaza (1989)** / **Gerbrandy-Groeneveld (1997)**: announcing f publicly
*transforms* the epistemic model — every world where ¬f is deleted;
agents' accessibilities restricted accordingly; then C_G f holds if it
holds in the transformed model (successful announcement).

We already do model rebuilding per tick in `grounding_demo.m`
(`mk_base`, `apply_labels`, fresh `mk_pmkripke`). A public announcement
is the same operation with deletion instead of growth:

```
announce(K, F) = restrict K to worlds W' = sat(K,F),
                 intersect each relation with W'
```

Three-line filter on states + rels. This gives *communicative acts*
a first-class role between perception and ontology — sign exchange as
model update, matching Sowa's language-game layer.

---

## 3. The Deontic Layer: Individual vs. Group Obligation

### Standard individual deontic operator

We have O_i with serial accessibility (KD) in `mm_multi.m`/`semiotic_demo.m`.

### Group obligation O_G — three published conceptions

1. **Aggregative**: O_G p := some/all members ought p. Trivial to define
   but dies on the Many-Hands problem — everyone thought someone else
   would act.
2. **Distributive**: obligations attach to ROLES (role deontic logic):
   parent-child, employer-employee generate *special* obligations
   distinct from universal social ones.
3. **Emergent / plural-subject** (**Gilbert 1989**, **Tuomela**): a group
   genuinely OUGHT via joint commitment — "we are committed"; violation
   requires rebuke by ANY member. The obligation lives at the collective
   level, irreducible downward. Gilbert's joint commitment has a clean
   Kripke reading: a **shared deontic relation R_{O,G}** such that ideal
   worlds are those where ALL G-role-holders' commitments are kept.

### Special vs. social obligations formally

Model as TWO deontic modalities layered on one structure:

```
O_social : ideal-worlds relation, agent-symmetric, reflexive on norms
O_special_{r} : restricted ideal worlds for role r ∈ subgroup tree
Kantian test (Universalizability) links them:
    O_special_r(p) must be EXHIBITABLE as universalizable:
    no contradiction arises when substituted into O_social for all r'
```

Special obligation passes only if adding its pattern to every member's
relation preserves consistency of O_social — implementable as an
idempotence check under "copy role-pattern across all agents," which
is precisely permutation-invariance below.

### Judgment aggregation limits

**List & Pettit**: for ≥3 propositions, no aggregation of individually
consistent member judgment sets into a collectively consistent one can
satisfy (universal domain + anonymity + independence + unanimity).
Consequence for us: group-level `sat()` cannot be *computed from member
sats by a schema*; it must be evaluated against a genuinely collective
accessibility structure. This justifies treating collectives as NEW
MODALITIES rather than derived formulas — deep design decision, backed
by impossibility.

---

## 4. Kant's Categorical Imperative as Model-Theoretic Constraint

Three operationalizable readings:

### (i) Universalizability = agent-permutation invariance

Formula of Universal Law: act only on maxims you can will as universal
law. Model-theoretically: the normative accessibility relation must be
INVARIANT under permutations σ of agent indices combined with renaming
their private predicates:

```
for all permutable i,j:   R_{O,i}(w,v) = R_{O,j}(σw, σv)
```

This is a **symmetry axiom on the model**, checkable structurally —
exactly the kind of thing `mm_multi.validate` already does for
reflexivity/transitivity/symmetry. Add `universalizable(profile-map)`
verifying isomorphism across agent-family substructures.

Violations = parochial maxims ("everyone else must cooperate, I may
defect") fail invariance → model rejects by construction.

### (ii) Humanity formula = prohibition on world-demotion

Act so as never to treat persons merely as means: each rational agent's
"personhood-preserving" worlds must be accessible in EVERY other
agent's ideal relation — O_j cannot exclude w that are minimal-dignity
worlds for i. Checks are set-inclusion tests across deontic relations.

### (iii) Kingdom-of-Ends = fixed point of mutual legislation

Norm system N is autonomous-coherent iff O-relations coincide with what
all agents jointly LEGISLATE: N = fixpoint of (norm → will-as-universal →
norm'). Formally a gfp over profile-space — same shape as our CTL EG
operator, lifted from worlds to NORM CANDIDATES. Could reuse `ctl`
iterate/gfp machinery with set(string) replaced by map(agent, profile).

---

## 5. Coalitions Over Time: ATL

**Alternating-time Temporal Logic** (Alur-Henzinger-Kupferman 2002,
JACM) is CTL with strategic quantifiers:

```
⟨⟨C⟩⟩ X φ    coalition C can force next state satisfying φ
⟨⟨C⟩⟩ G φ    C can keep φ true forever
⟨⟨C⟩⟩ U φ ψ  C can force φ until ψ, against all outsiders
```

It IS our `ctl.m` architecture with existential path-quantification
relativized to coalition strategy sets. Where EF said "some path",
⟨⟨{a1,a3}⟩⟩F says "the pair (a1,a3) can force reaching" — the *policy*
quantification replaces simple nondeterminism. The natural next module
after mm_group: `atl.m` (~150 lines, fixpoints unchanged, Step function
gains game-tree quantification).

**Normative systems** (van der Hoek-Roberts-Wooldridge 2007): partial
functions restricting every agent's choices; well-behavedness =
stability of sanctions. Institutions = normative systems + count-as
rules (**Searle 2010**: Y counts-as X in context C). Searle's
constitutive rule is directly expressible as a definitional axiom
schema linking raw-situation labels (our ec-fluents!) to institutional
labels (`raw:transfer_deed ⟹ institution:ownership_transfer`).

---

## 6. What `mm_group.m` Would Add (concrete)

1. `closure_union(rels) -> rel` : reflexive-transitive closure enabling C_G
2. `intersect_rels(rels) -> rel` : distributed knowledge D_G
3. `group_type constructors`: group(subgroup_ids), inst(Searle rules)
4. `validate_group`: adds universalizability (permutation) checks atop
   existing validate
5. Reuse everything else — formulas stay `mm.mmf`; operators stay
   string-indexed; the ONLY new object is the relation combinator set.
   ~120 lines estimated. Then `atl.m` separately.

Subgroup trees map naturally: O-relation of parent group must dominate
(serial-superset) child relations — hierarchical KD constraints,
validated recursively like profiles now.

---

## 7. Ties Into Our Existing Loop

| Our component | Collective upgrade |
|---|---|
| ground Bayesian filters | shared prior ⇔ Aumann hypothesis; posteriors exchangeable when announcements make beliefs mutually accessible |
| ec.m fluents | institutional fluents: count-as rule lifts raw→social predicate; sanctions initiate/terminate STATUS fluents |
| deontic O-modalities | split social/special(role); group-level joint-commitment relation added alongside individuals' |
| instability adoption beat | collective analog: norm EMERGES when enough members' anomaly logs cohere (community-based category adoption) |

That last row suggests the deepest unification: ontological growth at
group scale — a shared category enters COMMON ONTOLOGY iff its supporting
sign-evidence is common knowledge among participants. Growth-through-
communication is precisely Halpern-Moses' attainability boundary made
beneficial.

---

## 8. BibTeX References

```bibtex
% ---- group epistemology ----

@article{HalpernMoses1990,
  author  = {Halpern, Joseph Y. and Moses, Yoram},
  title   = {Knowledge and Common Knowledge in a Distributed Environment},
  journal = {Journal of the ACM},
  volume  = {37},
  number  = {3},
  pages   = {549--587},
  year    = {1990},
  doi     = {10.1145/79147.79161}
}

@book{FHMV1995,
  author    = {Fagin, Ronald and Halpern, Joseph Y. and Moses, Yoram and
               Vardi, Moshe Y.},
  title     = {Reasoning About Knowledge},
  publisher = {MIT Press},
  year      = {1995}
}

@article{Aumann1976,
  author  = {Aumann, Robert J.},
  title   = {Agreeing to Disagree},
  journal = {Annals of Statistics},
  volume  = {4},
  number  = {6},
  pages   = {1236--1239},
  year    = {1976}
}

@inproceedings{Plaza1989,
  author    = {Plaza, Jan A.},
  title     = {Logics of Public Communications},
  booktitle = {Proc.\ 4th Int.\ Symp.\ Methodologies for Intelligent Systems},
  pages     = {201--216},
  year      = {1989}
}

@article{GerbrandyGroeneveld1997,
  author  = {Gerbrandy, Jelle and Groeneveld, Willem},
  title   = {Reasoning About Information Change},
  journal = {Journal of Logic, Language and Information},
  volume  = {6},
  number  = {2},
  pages   = {147--169},
  year    = {1997}
}

% ---- coalition power ----

@article{AlurHenzingerKupferman2002,
  author  = {Alur, Rajeev and Henzinger, Thomas A. and Kupferman, Orna},
  title   = {Alternating-Time Temporal Logic},
  journal = {Journal of the ACM},
  volume  = {49},
  number  = {5},
  pages   = {672--713},
  year    = {2002},
  doi     = {10.1145/585265.585270}
}

@incollection{VanderHoekWooldridge2006NPL,
  author    = {van der Hoek, Wiebe and Wooldridge, Michael},
  title     = {Cooperation, Knowledge, and Time:
               Alternating-Time Temporal Epistemic Logic and its Applications},
  booktitle = {Studia Logica},
  volume    = {75},
  number    = {1},
  pages     = {125--157},
  year      = {2007}
}

@inproceedings{RobertsVanderHoekWooldridge2007,
  author    = {Roberts, Mark and van der Hoek, Wiebe and Wooldridge, Michael},
  title     = {On the Complexity of Regulating Multi-Agent Systems},
  booktitle = {AAAI Conference on Artificial Intelligence},
  year      = {2007},
  note      = {Normative systems restricting joint strategies}
}

% ---- collective agency, social ontology ----

@book{ListPettit2011,
  author    = {List, Christian and Pettit, Philip},
  title     = {Group Agency: The Possibility, Design, and Status of
               Corporate Agents},
  publisher = {Oxford University Press},
  year      = {2011}
}

@article{ListPettit2002,
  author  = {List, Christian and Pettit, Philip},
  title   = {Aggregating Sets of Judgments: An Impossibility Result},
  journal = {Economics and Philosophy},
  volume  = {18},
  number  = {1},
  pages   = {89--110},
  year    = {2002}
}

@book{Gilbert1989,
  author    = {Gilbert, Margaret},
  title     = {On Social Facts},
  publisher = {Princeton University Press},
  year      = {1989}
}

@book{Searle2010,
  author    = {Searle, John R.},
  title     = {Making the Social World:
               The Structure of Human Civilization},
  publisher = {Oxford University Press},
  year      = {2010}
}

@book{Tuomela2013,
  author    = {Tuomela, Raimo},
  title     = {Social Ontology: Collective Intentionality and Group Agents},
  publisher = {Oxford University Press},
  year      = {2013}
}

% ---- deontic collectives ----

@book{Horty2001,
  author    = {Horty, John F.},
  title     = {Agency and Deontic Logic},
  publisher = {Oxford University Press},
  year      = {2001},
  note      = {Independence-friendly agency; many hands}
}

@incollection{JonesCarmo2002,
  author    = {Carmo, Jos{\'e} and Jones, Andrew J. I.},
  title     = {Deontic Logic and Contrary-to-Duties},
  booktitle = {Handbook of Philosophical Logic},
  edition   = {2nd},
  volume    = {8},
  publisher = {Springer},
  pages     = {265--343},
  year      = {2002}
}

@proceedings{DEONseries,
  title        = {Deontic Logic in Computer Science (DEON), proceedings series},
  organization = {ELSEvier/Springer LNCS},
  note         = {Biennial; see especially work on normative multi-agent systems}
}

% ---- Kant formalizations ----

@book{Kant1785,
  author    = {Kant, Immanuel},
  title     = {Grundlegung zur Metaphysik der Sitten
               (Groundwork of the Metaphysics of Morals)},
  publisher = {Riga: Hartknoch},
  year      = {1785}
}

@book{ONeill1989,
  author    = {O'Neill, Onora},
  title     = {Constructions of Reason: Explorations of Kant's
               Practical Philosophy},
  publisher = {Cambridge University Press},
  year      = {1989},
  note      = {Consistency-in-willing procedure for FUL}
}

@article{Wood2020KantFormal,
  author  = {Arvan, Marcus},
  title   = {A Formal Approach to {K}ant's Universalizability},
  journal = {Data and Decision Sciences in Action},
  year    = {2020},
  note    = {Computational universalizability testing;
             representative of the small formal-Kant literature}
}
```

---

## 9. One-Paragraph Answer

Collectives enter our stack not as new syntax but as new RELATION
COMBINATORS and MODEL CONSTRAINTS: common knowledge is closure-of-union
(~40 lines over `mm.kripke_m`); distributed knowledge is intersection;
public announcements are world-deletion we nearly already perform;
group obligations survive the List-Pettit impossibility only by being
first-class relations rather than aggregated member formulas; Kant's
categorical imperative becomes a checkable PERMUTATION-INVARIANCE
axiom on deontic accessibility, slotting straight into the validator
we built for profiles; and coalitions over time arrive via ATL, whose
fixpoints are our existing CTL engine with strategy-quantified step
transformers. Searle-style institutions then ride the event calculus:
count-as rules turn raw sensor-grounded fluents into institutional
statuses inside the same `ec`→label pipeline the grounding loop uses —
making social reality simply another tier of dynamic ontology grown
from communicated signs.
