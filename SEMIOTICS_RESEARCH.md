# Semiotics Meets Modal Logic: A Research Sketch

## The Question

Where does semiotics — the study of signs and meaning-making — fit into
richer logical systems like the multimodal frameworks in `~/src/logic/`?
Can Peircean semiotics be formalized as additional structure within
Kripke models?

**Short answer**: Yes, and there are at least three natural points of
contact, each with different theoretical depth.

---

## 1. Peirce's Sign Classification: The Three Trichotomies

Peirce's standard 10-class system is built from three trichotomies
(Atkin, SEP 2022):

### Trichotomy 1: The Sign in Itself

| Class | Name | Nature |
|-------|------|--------|
| 1 | **Qualisign** | A quality that is a sign (e.g., the redness of a rose) |
| 2 | **Sinsign** | An actual existent thing that is a sign (e.g., *this* rose) |
| 3 | **Legisign** | A law or convention that is a sign (e.g., the word "rose") |

### Trichotomy 2: Sign–Object Relation

| Class | Name | Relation to Object |
|-------|------|-------------------|
| 4 | **Icon** | Resemblance (shared quality) |
| 5 | **Index** | Causal/existential connection |
| 6 | **Symbol** | Convention/law |

### Trichotomy 3: Sign–Interpretant Relation

| Class | Name | How it addresses the interpretant |
|-------|------|----------------------------------|
| 7 | **Rheme** | Represents a possible object (like a term) |
| 8 | **Dicent** | Represents an actual fact (like a proposition) |
| 9 | **Argument** | Represents a necessary law (like a syllogism) |

### The 10 Classes (Combining All Three)

Not all 27 combinations are logically possible. Peirce derived 10 valid
classes by imposing constraints (higher trichotomies subsume lower ones):

```
Class 1:  Qualisign — Icon — Rheme         (pure quality, resemblance, possibility)
Class 2:  Sinsign   — Icon — Rheme         (actual thing, resemblance, possibility)
Class 3:  Sinsign   — Index — Rheme        (actual thing, causal, possibility)
Class 4:  Sinsign   — Index — Dicent       (actual thing, causal, actuality)
Class 5:  Legisign  — Icon — Rheme         (law/convention, resemblance, possibility)
Class 6:  Legisign  — Icon — Dicent        (law/convention, resemblance, actuality)
Class 7:  Legisign  — Symbol — Rheme       (law, convention, possibility)
Class 8:  Legisign  — Symbol — Dicent      (law, convention, actuality)
Class 9:  Legisign  — Symbol — Argument    (law, convention, necessity)
Class 10: Legisign  — Index — Argument     (law, causal, necessity)
```

### The Extended Classifications

Peirce later proposed finer-grained systems:

- **6 trichotomies** → 28 classes (adds: representational relation,
  interpretant type [emotional/energetic/logical], interpretive branch)
- **10 trichotomies** → 66 classes (adds: immediate/dynamic object,
  immediate/dynamic interpretant, interpretant's relation to ground)

The key insight: **the trichotomies are not independent**. They form a
lattice where certain combinations are excluded by Peirce's categories
(Firstness, Secondness, Thirdness). The 66 classes are the consistent
paths through this lattice (Borges 2010; Sanders 1970).

---

## 2. Three Formalization Strategies

### Strategy A: Sign Types as Modality Profiles (Simplest)

Map Peirce's icon/index/symbol trichotomy to modality types on a
shared world set:

| Sign Type | Modal Operator | Axioms | Interpretation |
|-----------|---------------|--------|---------------|
| **Icon**  | ◇ᵢ (diamond_i) | — | "resembles in some respect" |
| **Index** | □ᵢ (box_i) | T (factive) | "is causally connected to" |
| **Symbol**| □ₛ (box_s) | K D 4 (S4) | "conventionally denotes" |

Each agent has three modalities (iconic, indexical, symbolic), and the
interaction axioms encode semiotic relationships:

- **□ᵢ → ◇ᵢ** (every index entails some iconic resemblance)
- **□ₛ → □ᵢ** (every symbol entails some indexical grounding)

This fits directly into our `mm_multi.m` framework — just add three
more modality profiles per agent.

**Pros**: Immediate implementation, uses existing infrastructure.
**Cons**: Loses the triadic structure (sign–object–interpretant).

### Strategy B: Ternary Accessibility (Peirce's Triad)

Peirce's sign relation is irreducibly *triadic*: (Sign, Object,
Interpretant). Binary Kripke relations can't capture this directly.
The fix: use a **ternary accessibility relation**:

```
R(s, o, i)  — sign s denotes object o to interpretant i
```

A "semiotic Kripke structure" would be:

```
W = {worlds}
S = {signs}              — what sign-vehicles exist
O = {objects}            — what objects are denoted
I = {interpretants}      — what meanings are generated
R ⊆ S × O × I           — the sign relation
```

The satisfaction condition becomes:

```
|=(s, o, i, F)  iff  F holds in the "semiotic context" (s, o, i)
```

This is the approach taken by Dau (2003) and connects to
**relation algebra** and **category theory** (see below).

**Pros**: Captures the irreducible triadicity of signs.
**Cons**: Ternary relations are harder to reason about; standard
modal axioms don't apply directly.

### Strategy C: Functors Between Categories (Category-Theoretic)

The deepest formalization uses **category theory** to model semiosis
as a functor between categories:

- Category **Sign**: objects = signs, morphisms = sign transformations
- Category **World**: objects = possible worlds, morphisms = transitions
- Functor **F: Sign → World**: maps signs to the worlds they make
  accessible, preserving composition (the "meaning" of a compound sign
  is the composition of its parts' meanings)

Natural transformations between functors model **interpretation**
— one agent's semiotic functor can be naturally transformed into
another's, capturing the idea that "the same sign means different
things to different interpreters."

This connects to:
- **Châtelet with Peirce** (Queiroz et al. 2023): semiotic
  conception of category theory
- **The Semiotic Machine** (Waythomas, PhilArchive): categorical
  construction of Peirce's triadic sign
- **Existential Graphs as string diagrams**: Peirce's diagrams are
  now recognized as proto-string-diagrams in monoidal categories

**Pros**: Most general, connects to modern mathematical foundations.
**Cons**: Heavy machinery, not yet fully worked out for all of Peirce's
classifications.

---

## 3. Connection to Existential Graphs

Peirce's Existential Graphs (EG) are a diagrammatic logic notation
that already embodies semiotic principles:

- **Alpha graphs**: propositional logic (cuts = negation, juxtaposition = conjunction)
- **Beta graphs**: first-order logic (lines of identity = quantification)
- **Gamma graphs**: **modal logic** (broken cuts = possibility, nested cuts = necessity)

The Gamma graphs are particularly relevant: Peirce invented a
*diagrammatic modal logic* in the 1890s, decades before Kripke
(1959). The "broken cut" (a cut drawn with a dashed line) represents
possibility, and its interaction with ordinary cuts gives the standard
modal axioms (Øhrstrøm 1997; Sowa 2011).

Modern work by Schmidt (2022) and Haydon (2024) has formalized the
Gamma graphs as a complete modal system, with direct connections to
epistemic and temporal logic.

---

## 4. The 10 Sign Classes as Modality Profiles

Here is a concrete proposal: each of Peirce's 10 sign classes defines
a distinct *type of accessibility relation* in a multimodal Kripke
structure. The structural properties of each class determine the
axioms of its modality:

| Class | Name | Reflexive | Transitive | Symmetric | Serial | Modal System |
|-------|------|:---------:|:----------:|:---------:|:------:|:------------:|
| 1 | Qualisign-Icon-Rheme | ✓ | ✗ | ✓ | ✓ | B/D |
| 2 | Sinsign-Icon-Rheme | ✗ | ✗ | ✓ | ✓ | K/D |
| 3 | Sinsign-Index-Rheme | ✓ | ✗ | ✗ | ✓ | T/D |
| 4 | Sinsign-Index-Dicent | ✓ | ✓ | ✗ | ✓ | T/4/D |
| 5 | Legisign-Icon-Rheme | ✓ | ✗ | ✓ | ✓ | B/D |
| 6 | Legisign-Icon-Dicent | ✓ | ✓ | ✓ | ✓ | S5 |
| 7 | Legisign-Symbol-Rheme | ✓ | ✗ | ✗ | ✓ | T/D |
| 8 | Legisign-Symbol-Dicent | ✓ | ✓ | ✗ | ✓ | S4 |
| 9 | Legisign-Symbol-Argument | ✓ | ✓ | ✓ | ✓ | S5 |
| 10 | Legisign-Index-Argument | ✓ | ✓ | ✗ | ✓ | S4 |

(The specific axiom assignments above are a *proposal* — the exact
mapping requires verifying that each sign class's conceptual structure
entails the corresponding relational properties. This is an open
research question.)

---

## 5. Semiotic Modalities in the Existing Framework

To implement this in `~/src/logic/`, the simplest path is Strategy A:
add icon/index/symbol modalities as new modality profiles in `mm_multi.m`.

A "semiotic agent" would have:

```
K_i   — epistemic (what the agent knows)
B_i   — doxastic (what the agent believes)
O_i   — deontic (what the agent ought)
Ic_i  — iconic (what the agent recognizes by resemblance)
Ix_i  — indexical (what the agent infers by causal connection)
Sy_i  — symbolic (what the agent understands by convention)
```

With interaction axioms:
- **Ix → Ic** (indexicality presupposes iconicity)
- **Sy → Ix** (symbolism presupposes indexical grounding)
- **K → B → Ic** (knowledge implies belief implies some iconic recognition)

This gives a 6-modality multimodal system where semiotic and epistemic
operators interleave.

---

## 6. The 66 Classes: A Lattice of Semiotic Modalities

The 66-class system is a **lattice** where:
- Nodes = sign classes
- Edges = subsumption relations (Class A subsumes Class B if B has
  more constraints)
- Paths through the lattice = semiotic "genres" or "modes of meaning"

This lattice could be modeled as a **modal logic of modalities**
(metamodal logic), where:
- Worlds = sign classes
- Accessibility = subsumption (A → B if A subsumes B)
- Modal operators = "in every/more general sign class"

This is genuinely novel territory — I'm not aware of a published
formalization of Peirce's 66-class lattice as a metamodal Kripke
structure. It could be a contribution.

---

## 7. Why the 66-Class System Is Not Popular

Several reasons:

1. **Complexity**: 66 classes with 10 trichotomies creates a
   combinatorial explosion that's hard to work with intuitively.

2. **Peirce's own uncertainty**: The 66-class system was developed
   late (1906-1910) and was never completed. Peirce himself expressed
   uncertainty about some of the later trichotomies.

3. **Lack of formalization**: Unlike the 10-class system (which has
   been formalized in various ways), the 66-class system lacks a
   clean algebraic or logical formalization.

4. **Empirical testing**: The 10-class system maps well to observable
   phenomena (icons look like things, indexes are caused by things,
   symbols are约定俗成). The finer distinctions (immediate vs dynamic
   object) are harder to operationalize.

5. **Community inertia**: Semiotics tends toward humanistic
   methodology; formal logic tends toward mathematical methodology.
   The intersection is small.

The 66-class system remains more of a *philosophical taxonomy* than a
*working tool* — but with modern formal methods (category theory,
modal logic), it could become one.

---

## 8. BibTeX References

```bibtex
@incollection{Atkin2022,
  author    = {Atkin, Albert},
  title     = {Peirce's Theory of Signs},
  booktitle = {Stanford Encyclopedia of Philosophy},
  edition   = {Fall 2022},
  publisher = {Stanford University},
  url       = {https://plato.stanford.edu/entries/peirce-semiotics/},
  year      = {2006/2022}
}

@article{Sanders1970,
  author  = {Sanders, Gary},
  title   = {Peirce's Sixty-Six Signs?},
  journal = {Transactions of the Charles S. Peirce Society},
  volume  = {6},
  number  = {1},
  pages   = {3--16},
  year    = {1970},
  note    = {88 citations. Classic analysis of why 66, not 3^10.}
}

@book{Dau2003,
  author    = {Dau, Frithjof},
  title     = {Mathematical Foundations of Peirce's Semiotics},
  publisher = {College Publications},
  year      = {2003},
  note      = {Formal treatment using relation algebra and diagram logic.}
}

@book{Sowa1984,
  author    = {Sowa, John F.},
  title     = {Conceptual Structures: Information Processing in Mind and Machine},
  publisher = {Addison-Wesley},
  year      = {1984},
  note      = {Introduced Peirce's Existential Graphs to the AI community.}
}

@article{Sowa2006,
  author  = {Sowa, John F.},
  title   = {Worlds, Models and Descriptions},
  journal = {Studia Logica},
  volume  = {84},
  number  = {2-3},
  pages   = {173--192},
  year    = {2006},
  note    = {44 citations. Possible-worlds semantics and conceptual graphs.}
}

@incollection{Queiroz2011,
  author    = {Queiroz, Jo{\~a}o and Elm, Rafael and Rost, Gregor},
  title     = {Introduction: Diagrammatical Reasoning and {P}eircean Logic of Existential Graphs},
  booktitle = {Diagrammatic Representation and Inference},
  publisher = {Springer},
  year      = {2011},
  note      = {21 citations. Existential Graphs as diagrammatic logic.}
}

@article{Borges2010,
  author  = {Borges, Paulo},
  title   = {A Visual Model of {P}eirce's 66 Classes of Signs Unravels His Late Proposal of Enlarging Semiotic Theory},
  journal = {Formal Languages and Analysis},
  year    = {2010},
  publisher = {Springer},
  note    = {27 citations. The lattice structure of the 66 classes.}
}

@book{Champagne2018,
  author    = {Champagne, Marc},
  title     = {Consciousness and the Philosophy of Signs: How {P}eircean Semiotics Combines Phenomenal Qualia and Practical Effects},
  publisher = {Springer},
  year      = {2018},
  note      = {Phenomenological approach to Peircean semiotics.}
}

@incollection{Stalnaker2003,
  author    = {Stalnaker, Robert},
  title     = {Assertion},
  booktitle = {Contexts and Content: Essays on Intensionality in Memory of William L. Parshall},
  publisher = {Oxford University Press},
  year      = {1999/2003},
  note      = {Possible worlds, propositions, and the sign theory.}
}

@article{Schmidt2022,
  author  = {Schmidt, Helge},
  title   = {Enhancing Existential Graphs: {P}eirce's Late Improvements},
  journal = {PhilArchive},
  year    = {2022},
  note    = {Gamma graphs as modal logic: broken cuts for possibility.}
}

@book{Øhrstrøm1997,
  author    = {Øhrstrøm, Peter and Hasle, Per F. V.},
  title     = {Temporal Logic: From Ancient Ideas to Artificial Intelligence},
  publisher = {Kluwer},
  year      = {1997},
  note      = {27 citations. Historical connection between Peirce's EG and temporal/modal logic.}
}

@article{Waythomas2024,
  author  = {Waythomas, Christopher},
  title   = {The Semiotic Machine: A Categorical Construction},
  journal = {PhilArchive},
  year    = {2024},
  note    = {Category-theoretic construction of Peirce's triadic sign.}
}

@incollection{Chatelet2023,
  author    = {Queiroz, Jo{\~a}o and Picasso, Marcos},
  title     = {Ch{\^{a}}telet with {P}eirce. A Semiotic Conception of Category Theory},
  journal   = {European Journal for Philosophy of Science},
  year      = {2023},
  note      = {Semiotic interpretation of category theory through Peirce.}
}
```

---

## 9. Summary: The Three Levels

| Level | What | Formalization | Status |
|-------|------|--------------|--------|
| **Simple** | Icon/Index/Symbol as modality types | `mm_multi.m` profiles | Implementable now |
| **Medium** | Sign–Object–Interpretant as ternary relation | Relation algebra / Kripke³ | Requires new module |
| **Deep** | Semiosis as functor between categories | Category theory | Research frontier |

The simple level is what we can build today. The medium level would
require a new `semiotic.m` module with ternary accessibility relations.
The deep level connects to active research in category-theoretic
semiotics (Queiroz, Waythomas, Châtelet).

For the logic sketches, adding icon/index/symbol modalities to the
cooperate/defect demo would be a clean next step — it demonstrates
the idea without requiring new theoretical machinery.
