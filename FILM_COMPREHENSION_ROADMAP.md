# Film Comprehension Roadmap

## Goal

Extend the existing logic onion so it can reason about films such as *Eraserhead*
(1977) and *Persona* (1966) without pretending that a thematic interpretation is
a single objectively correct label.

The near-term target is a **replayable, evidence-grounded episode model**:

```text
video/audio/transcript adapters
  -> timestamped observations
  -> semiotic signs and candidate interpretations
  -> filtered belief state
  -> temporal/social/modal reasoning
  -> competing thematic readings
  -> evidence-backed report
```

Mercury should not process raw pixels, waveforms, or neural embeddings directly.
External Python adapters may perform ASR, shot detection, face/object tracking,
prosody analysis, music analysis, and multimodal candidate generation. Mercury
receives typed observations with timestamps, confidence, provenance, and explicit
alternative hypotheses.

## What “comprehension” means here

The system should preserve at least four layers:

1. **Observation** — what is visibly, audibly, or linguistically present.
2. **Formal relation** — recurrence, contrast, framing, montage, sound-image
   alignment, or temporal order.
3. **Semiotic interpretation** — icon, index, symbol, or other sign relation.
4. **Thematic reading** — a defeasible interpretation supported by evidence.

For example:

```text
observation: industrial noise occurs over a confined interior shot
relation: the noise recurs whenever the protagonist is isolated
reading: the film supports a reading involving industrial/social anxiety
```

The first claim may be sensor-verifiable; the last is interpretive. They must
not be stored as the same kind of fact.

## Mapping onto the current codebase

| Film-comprehension need | Existing foundation | Next extension |
|---|---|---|
| timestamped events | `ec.m` | event kinds and intervals |
| competing hypotheses | `mmb.m`, `plp.m` | weighted interpretation candidates |
| temporal structure | `ctl.m`, `dtmc.m` | interval/sequence operators |
| sign relations | `semiotic_demo.m`, `mm.m` | typed sign records |
| viewer/character perspectives | `mm.m`, `mm_multi.m` | audience and character accessibility |
| social identity and speech | `social_mm.m` | dialogue, gaze, silence, address |
| uncertainty fusion | `control_filter.m` | multimodal episode filtering |
| evidence-backed reports | current demos | claim/evidence graph |

## Episode data model

A minimal episode should contain:

```text
Episode
  work identity and source metadata
  ordered observations
  ordered formal relations
  candidate interpretations
  contextual claims
```

Each observation should retain:

```text
interval or timestamp
channel: visual | audio | dialogue | music | editing | context
content and entities
confidence
provenance: file, model, annotator, or source
```

A candidate reading should retain:

```text
claim
supporting observation IDs
counterevidence IDs
alternative readings
confidence
status: proposed | accepted | contested
```

## Film-specific reasoning tasks

### *Eraserhead*

A useful first episode can test:

- industrial sound and visual confinement;
- recurring bodily or reproductive imagery;
- dream/reality ambiguity;
- repetition and duration;
- whether a sound is diegetic, non-diegetic, or uncertain;
- competing psychological, social, and surrealist readings.

The benchmark should not encode “the baby means X.” It should ask whether a
reading cites recurring formal evidence and acknowledges ambiguity.

### *Persona*

A useful first episode can test:

- speech versus silence;
- doubling and identity instability;
- face, gaze, and direct address;
- film-within-film or medium-reflexive interruptions;
- boundary changes between the two central figures;
- competing readings of psychological, theatrical, and cinematic identity.

The essential challenge is cross-modal and temporal: a later shot may alter the
meaning of an earlier silence, look, or utterance.

## Staged implementation

### Stage 1 — deterministic episode replay

Create a small hand-authored episode fixture. Query it for:

- observations inside an interval;
- recurring motifs;
- evidence supporting a claim;
- contradictions and unresolved ambiguity.

This establishes the data contract without requiring a GPU or a full film.

### Stage 2 — semiotic projection

Convert observations into sign records:

```text
visual resemblance -> icon candidate
pointing/gaze/continuity -> index candidate
speech/title/convention -> symbol candidate
```

Keep sign classification probabilistic or defeasible when appropriate.

### Stage 3 — temporal and formal structure

Add shot/scene boundaries, recurrence, contrast, parallel editing, and
sound-image synchronization. Use event calculus for state changes and CTL-like
queries for properties over a finite episode graph.

### Stage 4 — neural adapters

A Python adapter may emit the same fixture schema from:

- ASR with word and speaker timestamps;
- shot and cut detection;
- object/face/pose/gaze tracking;
- audio texture, music, silence, pitch, and intensity features;
- multimodal or diffusion-based candidate interpretations.

Neural output remains a proposal with provenance, never an unconditional fact.

### Stage 5 — evaluation

Score separately:

- perceptual accuracy;
- temporal alignment;
- formal relation detection;
- evidence retrieval;
- cross-modal alignment;
- interpretation plausibility;
- alternative-reading coverage;
- confidence calibration.

Use experts and multiple readings. A defensible minority interpretation should
not be marked wrong merely because it is not the dominant reading.

## Immediate engineering target

The first useful end-to-end demo is not automatic analysis of an entire film. It
is a small episode replay that demonstrates:

```text
observations
  -> interval and recurrence queries
  -> sign candidates
  -> competing thematic readings
  -> evidence/counterevidence report
```

Once that contract is stable, the same episode can be populated by real video,
audio, ASR, and multimodal models without changing the reasoning layer.

## Boundaries

```text
perception != interpretation
interpretation != entailment
historical context != evidence from the audiovisual work
belief != knowledge
plausibility != proof
```

This separation is especially important for ambiguous films. The goal is not to
build a machine that declares the meaning of *Eraserhead* or *Persona*, but one
that can show what it noticed, how it connected those observations, which
readings it supports, what challenges them, and how uncertain it remains.
