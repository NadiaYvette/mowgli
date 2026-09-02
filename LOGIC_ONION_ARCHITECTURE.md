# Logic Onion Architecture Overview

The project is best understood as a **typed, uncertainty-preserving world-model stack** rather than one monolithic logic engine.

```text
                         ┌──────────────────────────────┐
                         │  External world / actors      │
                         │  people, objects, institutions│
                         └──────────────┬───────────────┘
                                        │
                         sensors, APIs, human input
                                        │
              ┌─────────────────────────▼─────────────────────────┐
              │  Perception and alignment                          │
              │  video, audio, ASR, diarization, pose, gaze,       │
              │  pointing, object tracking, prosody, timestamps    │
              └─────────────────────────┬─────────────────────────┘
                                        │ uncertain observations
              ┌─────────────────────────▼─────────────────────────┐
              │  Semiotic interpretation                           │
              │  symbolic / indexical / iconic signs, reference,   │
              │  speech acts, prosodic force, provenance            │
              └─────────────────────────┬─────────────────────────┘
                                        │ candidate meanings
              ┌─────────────────────────▼─────────────────────────┐
              │  Filtering and belief state                         │
              │  Bayesian filters, HMMs, particle filters,         │
              │  confidence tracking, multimodal fusion             │
              └─────────────────────────┬─────────────────────────┘
                                        │ belief distributions
              ┌─────────────────────────▼─────────────────────────┐
              │  Dynamic ontology / event calculus                  │
              │  entities, properties, events, fluents, roles,     │
              │  commitments, object identity, temporal updates     │
              └─────────────────────────┬─────────────────────────┘
                                        │ typed possible worlds
              ┌─────────────────────────▼─────────────────────────┐
              │  Formal logic                                       │
              │  alethic possibility, epistemic knowledge,         │
              │  doxastic belief, deontic obligation, temporal      │
              │  logic, probabilistic logic, multimodal relations   │
              └─────────────────────────┬─────────────────────────┘
                                        │ constraints and queries
              ┌─────────────────────────▼─────────────────────────┐
              │  Planning and control                              │
              │  policy selection, MPC, active inference,           │
              │  safety, visibility, feasibility, action recovery   │
              └─────────────────────────┬─────────────────────────┘
                                        │ verified action plan
              ┌─────────────────────────▼─────────────────────────┐
              │  Actuation and communication                        │
              │  motion, manipulation, UI, speech, gesture,        │
              │  report generation, prosody-controlled output       │
              └─────────────────────────┬─────────────────────────┘
                                        │ observed consequences
                                        └───────────────► feedback
```

The feedback arrow is essential: this is intended to become a **closed perception–reasoning–action loop**, not merely a parser.

## 1. Three computational domains

### Numeric/perceptual domain

This is where neural models and numerical algorithms belong.

Potential components:

```text
audio:
  Faster-Whisper
  SpeechBrain
  librosa
  SoundFile
  pitch/intensity/duration analysis

video:
  object detection
  tracking
  pose estimation
  gaze and pointing
  sign-language recognition
  scene understanding

language:
  LLaDA
  other diffusion language models
  ASR transcripts
  reference resolution
  speech-act classification

estimation:
  Bayesian filtering
  Kalman filtering
  particle filtering
  factor graphs
  multimodal temporal alignment
```

This domain works with tensors, embeddings, waveforms, frames, confidence scores, and distributions. It should generally run in Python/PyTorch on CUDA or ROCm, using Kaggle or other GPU infrastructure when appropriate.

### Symbolic/semantic domain

This is where observations become explicit, inspectable propositions.

Examples:

```text
speech(alice, bob, deliver(package_7))
urgent(alice, utterance_41)
points_at(alice, package_7)
visible(package_7, bob)
not_visible(package_7, carol)
member(bob, courier_group)
role(alice, supervisor)
```

The symbolic representation must preserve confidence, timestamp, source sensor, model version, competing interpretations, and whether something is observed, inferred, assumed, or logically entailed.

These are different claims:

```text
observed(points_at(alice, package_7))
likely(request(alice, bob, deliver(package_7)))
entailed(visible(package_7, bob))
obligatory(bob, deliver(package_7))
```

They must not be collapsed into one undifferentiated fact.

### Action/world domain

This is where the system decides and acts. Potential components include discrete planners, motion planning, model-predictive control, actuator interfaces, simulation, task execution, speech and gesture realization, and post-action verification.

The action layer must receive both what is believed about the world and what is permitted, required, and physically feasible. A high-confidence interpretation is not automatically an executable action.

## 2. Current Mercury foundation

The current Mercury project is a collection of small, deliberately inspectable modules in `~/src/logic/`.

### Probabilistic logic

```text
semiring.m
plp.m
plp_demo.m
```

These attach weights to explanations, interpret the same logic program under different algebras, and expose probabilistic assumptions explicitly. The current implementation is primarily a teaching and research scaffold, not a production probabilistic inference engine.

### Temporal logic

```text
ctl.m
ctl_demo.m
```

These model transitions between worlds and query reachability, safety, liveness, and inevitability through CTL-style fixpoints.

### Tabling and negation

```text
tabling.m
tabling_demo.m
plp_naf.m
naf_demo.m
```

These explore memoized recursive derivations and stratified negation-as-failure. They are important for recursive ontology relationships, reachability, common knowledge, and group closure.

### Probabilistic temporal logic

```text
dtmc.m
dtmc_demo.m
```

These combine stochastic transitions with temporal reachability and provide a bridge toward PCTL-style reasoning.

### Multimodal Kripke logic

```text
mm.m
mm_demo.m
mmb.m
mmb_demo.m
mm_multi.m
mm_multi_demo.m
```

These represent indexed accessibility relations, agent-specific beliefs, and multiple modality types.

The current modality vocabulary distinguishes:

```text
K = epistemic knowledge
B = doxastic belief
O = deontic obligation
P = alethic possibility
```

These are not interchangeable:

```text
K(agent, φ) ≠ B(agent, φ)
B(agent, φ) ≠ O(agent, φ)
O(agent, φ) ≠ φ
```

Typical frame profiles are:

| Modality | Intuition | Typical frame |
|---|---|---|
| Epistemic | What an agent knows | S5 / equivalence |
| Doxastic | What an agent believes | S4-like preorder |
| Deontic | What is obligatory | KD / serial relation |
| Alethic | What is possible | configurable modal frame |

### Semiotics

```text
SEMIOTICS_RESEARCH.md
semiotic_demo.m
```

This layer treats meaning as mediated by signs:

```text
icon      resemblance-based evidence
index     pointing, gaze, temporal/spatial linkage
symbol    language and convention
```

Semiotics sits between perception and ontology:

```text
raw signal → sign → interpretant → candidate proposition
```

### Event calculus and grounding

```text
ec.m
grounding_demo.m
```

This is the current closed-loop centerpiece. It models events, initiated and terminated fluents, time-indexed changes, commitments, a dynamically updated world model, and an actuator responding to a deontic goal.

The demonstration includes:

```text
sensor observation
→ Bayesian update
→ ontology update
→ logical query
→ norm evaluation
→ action
→ changed world
→ next observation
```

It distinguishes low belief in a state from violation of a norm. An agent should not act merely because it is uncertain if the world is compliant.

### Social multimodality

```text
social_mm.m
social_mm_demo.m
SOCIAL_MULTIMODAL_RESEARCH.md
```

This models agents, groups, roles, membership, speech, prosodic force, pointing, gaze, observer-relative visibility, common ground, and simple referent resolution.

Raw camera and microphone data are intentionally outside Mercury. External perception systems produce typed observations, and Mercury reasons over the resulting finite model.

## 3. Neural and speech interface

The Python boundary consists of:

```text
audio_frontend.py
audio_observation.py
llada_interface.py
llada_backend.py
```

The intended flow is:

```text
WAV/audio
  ↓
acoustic features
  ↓
ASR transcript + timestamps
  ↓
prosody and speaker features
  ↓
typed audio observation
  ↓
LLaDA candidate interpretation
  ↓
filtering and confidence update
  ↓
social_mm / ontology / Mercury
```

An observation should preserve transcript, speaker, timing, pitch contour, rate/intensity, urgency, uncertainty, focus, and provenance. A candidate interpretation should preserve its speech act, addressee, predicate, arguments, probability, and evidence.

Mercury should not receive an unconditional fact. It should receive a candidate interpretation with evidence and confidence, after which policy decides whether it is sufficiently supported and whether clarification is needed.

## 4. Where LLaDA fits

LLaDA is not intended to replace the logic engine.

Its strongest prospective roles are:

- candidate comprehension;
- filling missing portions of structured interpretations;
- proposing speech-act and referent alternatives;
- revising hypotheses when late evidence arrives;
- constrained report realization after execution.

LLaDA is a masked-diffusion model, not an ordinary autoregressive generator. The official implementation uses a custom sampling loop and an 8B checkpoint. It should therefore remain an explicit GPU-stage dependency.

Generated prose must not be treated as a logical assertion. LLaDA should produce candidate structures, which are then filtered, provenance-checked, and validated against ontology and policy constraints.

## 5. Prosody as a parallel semantic channel

Speech should not be treated only as:

```text
audio → text
```

It should produce:

```text
audio → {
  lexical content,
  speaker identity,
  timing,
  pitch,
  intensity,
  rate,
  pauses,
  prominence,
  voice quality,
  speech-act evidence,
  uncertainty,
  provenance
}
```

Prosody can affect interpretation, but it is evidence rather than a direct logical assertion:

```text
prosody increases probability of urgent_directive
```

is appropriate, while:

```text
urgent prosody entails obligation
```

is not. The transition from speech-act candidate to actual obligation belongs to social and deontic reasoning.

## 6. Dynamic ontology

The ontology layer answers:

```text
What entities exist?
What properties do they have?
What events occurred?
Which properties persist?
What changed?
Which facts are uncertain?
Who knows what?
```

An entity record may include a stable identifier, type hypotheses, spatial state, temporal history, sensor provenance, confidence, relations, permissions, and visibility.

Ontology growth must not silently turn uncertain recognition into certainty:

```text
sensor evidence
→ update belief
→ possibly introduce entity/property
→ record event
→ revise possible worlds
→ preserve historical provenance
```

## 7. Social and collective reasoning

Potential collective operators include:

```text
K(a, φ)       agent a knows φ
B(a, φ)       agent a believes φ
C(G, φ)       φ is common knowledge in group G
D(G, φ)       distributed knowledge of group G
E(G, φ)       everyone in G knows φ
O(a, φ)       a is obligated to φ
O(G, φ)       group G has a collective obligation
```

The architecture distinguishes special obligations, social obligations, collective obligations, and joint commitments. This supports cases where a group has a delivery duty, one member is assigned the action, visibility restrictions apply to another member, and the group shares a policy.

Kantian or universalization-style reasoning should be implemented as an explicit validator over action schemas rather than casually conflated with ordinary deontic logic.

## 8. Filtering, planning, and control

The current filter is a small exact finite Bayesian model:

```text
predict
→ likelihood update
→ normalize
→ select bounded action
```

A staged extension is:

1. finite Bayesian filters for transparent demonstrations;
2. HMMs and factor graphs for temporal dependencies and multimodal fusion;
3. particle filters for nonlinear, multimodal, or continuous state;
4. model-predictive control for replanning under constraints;
5. active inference with an explicit generative model and policy criterion.

The controller should predict candidate action sequences, score them against goals and constraints, reject unsafe or norm-violating sequences, execute only the first action, observe the result, and replan.

## 9. Boundaries that must remain separate

The following distinctions are architectural safety principles:

```text
observation ≠ truth
belief ≠ knowledge
speech-act classification ≠ obligation
plan ≠ execution
generated report ≠ verified fact
probability ≠ logical accessibility
```

For example:

```text
detector says package_7 with confidence 0.81
```

is not identical to:

```text
package_7 exists
```

Likewise:

```text
The language model wrote “delivery succeeded.”
```

is not identical to:

```text
Sensors and the execution trace verified delivery.
```

## 10. Resource requirements

### Immediate local development

The current hardware is sufficient for Mercury modules, symbolic model checking, finite probabilistic demonstrations, JSON contracts, audio preprocessing, small speech models, simulation, replayable datasets, and tests.

### Capable workstation

A 12–24 GB GPU would support faster ASR, prosody models, object detection, tracking, small multimodal models, particle filters, and selected local LLaDA experiments if memory permits.

### Kaggle GPU

Kaggle is well suited for batch video/audio processing, LLaDA inference, model comparisons, multimodal episode replay, adapter experiments, synthetic scenario generation, and evaluation. It is not suited to persistent robot operation, low-latency control, or hardware-in-the-loop action.

### Robotics or lab hardware

Real grounding requires cameras, microphones, calibrated geometry, manipulators or mobile platforms, speech output, tactile feedback, actuator verification, and safety interlocks.

### Data and people

The most important non-compute resource is carefully annotated multimodal episodes labeling what was said, how it was said, who was looking or pointing, what was visible, what was intended, what was permitted, what action occurred, and what outcome was verified.

A serious project also spans formal methods, probabilistic inference, speech and prosody, computer vision, multimodal learning, robotics and control, ontology, semiotics, systems engineering, and evaluation/safety.

## 11. Staged roadmap

### Phase 1 — symbolic foundation

```text
Mercury logic sketches
semiotics
ontology
event calculus
social multimodality
finite Bayesian filtering
```

### Phase 2 — audio and typed observations

```text
audio
→ ASR transcript
→ acoustic/prosodic features
→ typed observation JSON
→ candidate interpretation schema
```

### Phase 3 — Kaggle multimodal experiment

```text
video + audio episode
→ multimodal perception
→ LLaDA candidate generation
→ filtering
→ typed social observations
→ Mercury queries
```

### Phase 4 — simulated action

```text
candidate interpretation
→ deontic/social constraints
→ discrete plan
→ simulated execution
→ verified report
```

### Phase 5 — hardware-in-the-loop

```text
real sensors
→ world model
→ safety-checked action
→ actuator
→ consequence observation
```

### Phase 6 — collective reasoning

```text
multiple agents
→ shared beliefs
→ common knowledge
→ group obligations
→ joint plans
→ conflict resolution
```

## Bottom line

The realistic near-term target is a replayable multimodal episode:

```text
audio/video perception
→ explicit sideband representation
→ diffusion-based candidate interpretation
→ uncertainty filtering
→ semiotic and social projection
→ Mercury logic queries
→ constrained simulated action
→ verified natural-language report
```

This is ambitious but tractable. It demonstrates the full conceptual stack while keeping each layer testable and replaceable.

> Neural models propose interpretations; filters maintain uncertainty; semiotics explains how signals become meaningful signs; ontologies organize entities and events; Mercury checks explicit logical and normative relations; controllers choose feasible actions; verified observations determine what may be reported.
