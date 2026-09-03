# Logic Sketches in Mercury

Ten modules exploring logic through Mercury's type system and determinism checker.

## Modules

| Module | What it does | Key idea |
|--------|-------------|----------|
| `semiring.m` | Semiring typeclass with 4 instances | One interpreter, four algebras |
| `plp.m` | Probabilistic logic programming (Sato semantics) | Weighted proof search over semirings |
| `ctl.m` | CTL model checker (Clarke-Emerson-Sistla) | Formulas as data, fixpoint iteration |
| `tabling.m` | Memoization via `pragma memo` | Shared subcomputations, exponential to linear |
| `plp_naf.m` | PLP with stratified negation-as-failure | Bottom-up over SCCs, correct NAF |
| `dtmc.m` | PCTL reachability on DTMCs (value iteration) | CTL's EF generalized from bools to floats |
| `mm.m` | Multimodal Kripke structures (indexed accessibility) | Multiple modalities, S5 semantics |
| `mmb.m` | Probabilistic multimodal reasoning | Per-agent Bayesian belief conditioning |
| `mm_multi.m` | Modality type profiles with structural validation | K/B/O/P with S5/S4/KD axioms |
| `ec.m` | Discrete event calculus (Kowalski-Sergot miniature) | Fluent initiation/termination -> Kripke labels |
| `mm_multi_demo.m` | Grand unified multimodal logic | 3 modality types x 2 agents, cross-modal formulas |

## Demos

| Demo | Axes combined | Example |
|------|--------------|---------|
| `plp_demo` | Probabilistic | Rain/sprinkler + graph reachability |
| `ctl_demo` | Temporal | 3-state Kripke (reachability, liveness) |
| `tabling_demo` | Probabilistic + tabling | Diamond DAG path counting |
| `naf_demo` | Probabilistic + negation | Stratified NAF, cycle rejection |
| `dtmc_demo` | Probabilistic + temporal | Machine reliability PCTL |
| `mm_demo` | Multimodal | Die game: exact vs partial observation |
| `mmb_demo` | Multimodal + probabilistic | Skewed die, agent belief computation |
| `mm_multi_demo` | Multimodal (multi-type) | Game theory: K, B, O across agents |
| `semiotic_demo` | Semiotic modalities | Icon/index/symbol agents on the game |
| `grounding_demo` | FULL LOOP (all axes) | Sensors -> Bayes -> EC fluents -> Kripke beliefs -> ontology growth |
| `social_mm_demo` | Social multimodal | Speech + prosody + pointing + visibility + common ground |
| `control_filter_demo` | Filtering + control | Predict/update belief, then choose a bounded actuator action |

## Social Multimodality

`social_mm.m` is a boundary layer for situated interaction. It keeps
speech content, prosodic force, pointing, gaze, visibility, roles, group
membership, and common-ground accommodation as typed facts rather than
collapsing them into one proposition. `social_mm_demo` models Alice
pointing at a package while urgently asking Bob to deliver it; Bob's
visibility, Carol's visibility, and the group's accommodated proposition
remain separately queryable.

Raw camera and microphone data should be interpreted by external adapters;
Mercury receives provenance-preserving observations and reasons over the
resulting finite model. See `SOCIAL_MULTIMODAL_RESEARCH.md`.

## Diffusion and Speech Prototype

The dependency-light Python boundary is split across `audio_frontend.py`,
`audio_observation.py`, `llada_interface.py`, and `llada_backend.py`. It keeps
transcript, timing, acoustic/prosodic sidebands, confidence, and provenance
separate before any candidate is projected into Mercury. The official LLaDA
checkout is detected at `~/src/LLaDA`; its masked-diffusion sampler remains an
explicit GPU-stage dependency. See `LOCAL_DIFFUSION_SETUP.md`.

## Filtering and Control

`control_filter.m` adds an intentionally small finite-state layer between
sensor signs and logical world updates. It performs controlled prediction,
likelihood updates, normalization, and a threshold policy. This is an exact
Bayesian filter for the two-state demo, not a Kalman filter or a claim of
continuous optimal control. See `CONTROL_FILTER_RESEARCH.md` for the proposed
extension to particle filters, MPC, and active inference.

The recommended production boundary is: numeric filters estimate; ontology
adapters preserve confidence and provenance; Mercury reasons over typed
hypotheses and constraints; controllers emit event-calculus actions.

## The Axes

```
              Probabilistic
              (weights on worlds)
                    |
                    |
  Multimodal -------+------- Temporal
  (indexed           |       (paths over
   relations)        |        worlds)
```

**Probabilistic** (PLP): semiring-parameterized CLP. The program stays
fixed; the algebra changes (float, maxplus, minplus, bool).

**Temporal** (CTL): formulas evaluated as fixpoints over the state
lattice. EF/EG/AF/AG are least/greatest fixpoints of monotone operators.

**Multimodal** (mm): multiple indexed accessibility relations on the
same world set. Box_i/Dia_i evaluate under relation R_i.

**Multi-type multimodal** (mm_multi): each modality carries a
*structural profile* (reflexivity, transitivity, symmetry) that
constrains its accessibility relation:

| Type | Axioms | Accessibility |
|------|--------|--------------|
| Epistemic (K) | K T 4 5 (S5) | Equivalence relation |
| Doxastic (B) | K 4 (S4) | Preorder |
| Deontic (O) | K D (KD) | Serial |
| Alethic (P) | K T 4 5 (S5) | Equivalence relation |

Cross-modality interaction axioms:
- **K -> B** (knowledge implies belief)
- **O -> P** (ought implies can)
- **B -> P** (belief in possibility)

**Combining axes**:
- Probabilistic + Temporal = PCTL/DTMC (`dtmc.m`)
- Multimodal + Probabilistic = Agent belief computation (`mmb.m`)
- Multi-type Multimodal = Grand unified epistemic/doxastic/deontic (`mm_multi.m`)

## The Grounding Loop

`grounding_demo` closes the onion from ONTOLOGY_RESEARCH.md:

```
photons --(sensor)--> signs --(likelihood x prior)--> posterior
   ^                                                    |
   |                                             ec.m fluents
 action                                        (commitments)
   |                                                    v
 world <--(actuation)-- reason over grown ontology = relabelled
                                          kripke_m queried by
                                          mmb.prob / mmb.belief
```

Novel signs (observations no hypothesis explains) grow the sign
vocabulary and can adopt new cross-cutting predicates ("unstable")
that become visible to every downstream query on the next tick.

The loop is genuinely CLOSED: an operator agent pursues the deontic
goal `O(lamp_on)`. Actuation triggers on **norm violation** (the
physical truth is off), not on low posterior — a disliked world may
still satisfy the norm. The corrective request travels as a pending
status (`want-on`) consumed by next tick's planner, so restoration is
a one-shot mechanical event that exogenous faults can override again.
Watch the agent fire once at each fault tick (4 and 9) and recover
next tick, while staying silent through the t6 belief crash it did
not need to act on.

## Film relation fixtures

`meshes_gold_scene.jsonl` is a candidate, manually reviewable annotation set
for the locally supplied *Meshes of the Afternoon* encode. It contains no
media. The accompanying manifest pins the source filename, duration, and
SHA-256 hash, while `MESHES_GOLD_SCENE_REVIEW.md` records the checklist for
promoting the candidate to reviewed gold data.

Generate and validate the typed fixture with:

```bash
python3 film_annotations.py meshes_gold_scene.jsonl \\
  --mercury meshes_gold_scene_fixture.m \\
  --module meshes_gold_scene_fixture
make meshes_gold_scene_demo meshes_gold_scene_test
./meshes_gold_scene_demo
./meshes_gold_scene_test
```

Do not treat the candidate timestamps or interpretations as ground truth until
they have been checked against the exact local encode. Keep the source media
outside Git; only the provenance-bearing annotations and manifest belong in
the repository.

## Building

```bash
make              # Build all 8 demos
make run          # Build and run all
make clean        # Remove all build artifacts
make mm_demo      # Build just the multimodal demo
make mm_multi_demo  # Build the grand unified demo
```

Requires: Mercury rotd-2024 or later, `mmc` in PATH.

## What's Honest

- The PLP fold gives an **upper bound** for overlapping explanations.
  The honest overcount is visible in the output (1.3 vs exact 0.88).
- Tabling is demonstrated on a counting predicate (diamond DAG), not
  cyclic graphs this grade's `pragma memo` doesn't support.
- Negation uses stratified evaluation (correct for stratified programs).
- Multimodal uses S5 (equivalence relations) for epistemic operators.
- The multi-type demo's structural validator catches real violations:
  doxastic relations are NOT reflexive (belief need not be factive),
  deontic relations are NOT reflexive (obligations can conflict with
  reality). These are *features*, not bugs.

## Mercury Quirks

1. **No list comprehensions.** `[X || X <- L, Cond]` doesn't parse.
   Use `list.filter_map` or recursive helpers instead.
2. **`list.foldl` is a predicate, not a function.** Can't use
   `X = list.foldl(...)`. Must call it as a 4-arg predicate.
3. **`list.filter_map` with `func` lambdas must be det.** For
   `semidet` filtering, use the `pred` form or recursive helpers.
4. **`io.write_string` needs `!IO` threading** even for non-mutating
   output.
5. **`map.init` needs type annotation** when used as a fold accumulator.
