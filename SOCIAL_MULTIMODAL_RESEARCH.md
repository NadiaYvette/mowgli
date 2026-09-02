# Social Multimodal Logic: Research and Design Sketch

## Scope

The existing project models propositions, indexed accessibility relations,
probability, temporal change, semiotic modalities, and event-calculus
updates. Realistic interaction adds a situated social layer: speech,
prosody, gesture, gaze, spatial reference, visibility, roles, group
membership, and common ground.

This document deliberately separates **perception** from **formal reasoning**.
Camera/audio systems should emit typed observations; Mercury should reason over
those observations rather than over raw pixels or waveforms.

## Proposed onion

```text
sensor streams
  -> perceptual observations
  -> multimodal signs
  -> situated utterances and gestures
  -> common ground and social context
  -> epistemic / doxastic / deontic / temporal formulas
  -> action and new observations
```

A useful event vocabulary is:

```text
point(agent, object, spatial_region)
gaze(agent, object)
say(agent, addressee, proposition, prosody)
prosody(utterance, pitch_contour, intensity, tempo, affect)
visible(object, observer)
role(agent, role_name, group)
member(agent, group)
commit(agent, proposition)
```

These are **observations**, not automatically true facts. A pointing gesture
may be ambiguous; prosody may alter pragmatic force without changing literal
truth conditions; visibility is observer-relative; and social role claims may
be uncertain. The probabilistic layer should therefore be able to attach
confidence or competing interpretations before an ontology update commits a
fact.

## Formal layers

### 1. Situated reference

Add an interpretation context containing a discourse center, participants,
objects, spatial coordinates, and attention. A deictic expression such as
“that one” is evaluated relative to a gesture, gaze direction, and shared
scene, not only to a world label.

### 2. Multimodal fusion

Multiple signs can jointly support one proposition:

```text
say(A, B, deliver(X), urgent)
point(A, X, left_of_A)
visible(X, B)
```

Fusion should preserve provenance. The system should be able to distinguish
“the speech asserted X” from “gesture and gaze made X the likely referent.”

### 3. Social epistemics

Use one accessibility relation per agent for private information and group
operators for collective information:

```text
K(A, φ)          A knows φ
E(G, φ)          everyone in G knows φ
C(G, φ)          φ is common knowledge in G
D(G, φ)          distributed knowledge of G entails φ
```

Common ground is dynamic: assertions, questions, corrections, and accepted
commands update what participants publicly accommodate. A future module
should represent this as an event-calculus state rather than treating common
ground as a static label.

### 4. Norms, secrecy, and visibility

The motivating example can be represented as a conditional norm:

```text
O(A, deliver(X))
O(A, not_visible(X, observer_C))
```

The controller must check both the action and its observability. This is a
social-deontic constraint, not merely a physical one. Whether `not_visible`
holds depends on the observer's viewpoint and on uncertainty in the scene.

### 5. Action

Actions should carry intended audience, expected effects, and observability:

```text
action(A, deliver(A, X, B),
       achieves(delivered(X, B)),
       preserves(not_visible(X, C)))
```

The action layer should report norm violations and failed assumptions rather
than silently changing the world model.

## Peircean interpretation

Peirce is particularly useful here because the modalities are not just data
channels. A pointing gesture is often indexical, visual resemblance can be
iconic, and speech conventions are symbolic. Prosody can function as a sign
of affect, stance, urgency, or illocutionary force. The interpretant is the
contextual update produced by combining these signs with prior common ground.

This suggests retaining sign provenance:

```text
sign(vehicle, object, interpretant, sign_class, source_modality)
```

The existing `semiotic_demo.m` uses relations as a first approximation. A
social extension should avoid collapsing the irreducible sign/object/
interpretant triad into a single Boolean label too early.

## Recommended Mercury boundary

Create a new `social_mm.m` rather than modifying `mm.m` initially. It should
provide a small typed representation of:

- agents and groups;
- social roles;
- observations with provenance;
- speech acts and prosodic features;
- gestures and referents;
- visibility relations;
- common-ground propositions;
- conversion into an `mm.kripke_m` snapshot for existing model checking.

A focused demo should simulate two agents, three objects, a pointing gesture,
an urgent utterance, an observer with a different line of sight, and a secret
handoff obligation. It should show that literal content, pragmatic force,
knowledge, and deontic compliance remain separately queryable.

## Research references

- Brown, L. & Prieto, P. (2021). “Gesture and Prosody in Multimodal
  Communication.” *Oxford Research Encyclopedia of Linguistics*.
- Gibbon, D. (2009). “Gesture Theory is Linguistics: On Modelling
  Multimodality as Prosody.” *Proceedings of the 10th Annual Conference of
  the International Speech Communication Association*.
- Lo Re, L. et al. (2021). “Prosody and gestures to modelling multimodal
  interaction: Constructing a multimodal corpus.” *International Journal of
  Corpus Linguistics*.
- Geurts, B. (2024). “Common Ground in Pragmatics.” *Stanford Encyclopedia
  of Philosophy*.
- Rasenberg, M. et al. (2022). “The multimodal nature of communicative
  efficiency in social interaction.” *Philosophical Transactions of the Royal
  Society B*.
- Bateman, J. A. (2018). “Peircean Semiotics and Multimodality: Towards a
  New Synthesis.”
- Zlatev, J. et al. (2019). “Peirce’s universal categories: On their potential
  for gesture theory and multimodal analysis.”

These references support the design direction but do not imply that one
published calculus already solves the entire logic-to-sensor-to-social loop.
The proposed module is an engineering synthesis, not a claim of an
established unified theory.

## Staging

1. Typed observations and provenance, with no automatic truth commitment.
2. Reference resolution over a finite simulated scene.
3. Common-ground update events.
4. Group knowledge and social-deontic checks.
5. Probabilistic interpretation and conflicting cues.
6. Sensor adapters and action execution outside the Mercury core.
