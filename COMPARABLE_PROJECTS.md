# Comparable Projects and Research Ecosystems

## Overview

The complete logic-onion architecture is unusual. Existing projects usually cover one or two layers rather than the entire stack:

```text
audio/video perception
→ semiotic evidence
→ probabilistic candidate meanings
→ dynamic ontology
→ agent-indexed knowledge/belief
→ group/common knowledge
→ deontic obligations and privacy
→ temporal reasoning
→ constrained planning/control
→ verified action and communication
```

The most practical strategy is composition rather than replacement: use established robotics, perception, planning, ontology, and probabilistic systems while retaining Mercury as a transparent formal reference and integration laboratory.

## Closest overall relatives

| Project | Strongest overlap | Main difference |
|---|---|---|
| **ROS 2 + Nav2/MoveIt** | Sensors → world state → planning → action | Robotics middleware, not a semantic logic architecture |
| **KnowRob / RoboSherlock** | Robot knowledge representation, perception, ontology, reasoning | More robotics-specific and generally not centered on diffusion models or Peircean semiotics |
| **VirtualHome** | Language → symbolic world model → household actions | Simulated environments; limited social epistemic/deontic depth |
| **BEHAVIOR-1K / OmniGibson** | Multimodal perception, language instructions, embodied task planning | Primarily benchmark and simulation ecosystems |
| **SayCan** | Language model + affordance/value grounding + robot actions | LLM selects feasible skills; not a general epistemic/deontic world logic |
| **PaLM-E** | Vision/language/state inputs → embodied decisions | End-to-end embodied multimodal model rather than a transparent logic-centered stack |
| **RT-2 / OpenVLA** | Vision-language-action modeling | Action policy learning, not explicit ontology, semiotics, or modal logic |
| **Inner Monologue** | Language feedback, environment state, replanning, robot execution | Focused on language-mediated robot control, not group knowledge or formal obligations |
| **LTLf2DFA / LTLMoP / ROSPlan** | Temporal logic and planning constraints | Formal planning/control, generally weaker multimodal/social interpretation |

## Symbolic robotics

### KnowRob

KnowRob is one of the most relevant robotics precedents. It combines robot knowledge representation, OWL/RDF-style ontologies, spatial and temporal reasoning, perception results, action models, Prolog-based reasoning, and ROS links.

Conceptually:

```text
robot sensors
→ semantic knowledge base
→ entities, properties, events
→ reasoning
→ robot actions
```

This is close to the ontology/event-calculus direction. The intended architecture differs by emphasizing multimodal signs, explicit uncertainty, Peircean semiotics, epistemic/doxastic/deontic modalities, collective agents, diffusion-based candidate interpretations, and Mercury experiments.

### RoboSherlock

RoboSherlock focuses on perception-driven knowledge processing:

- combining multiple perception algorithms;
- representing object hypotheses;
- semantic scene interpretation;
- integrating perception with a knowledge base.

It addresses how several imperfect perceptual components can contribute evidence about the same object or scene. Its emphasis is perception orchestration rather than social normative reasoning.

### Scene-graph systems

Modern scene-graph systems perform:

```text
image/video
→ objects
→ relations
→ structured scene graph
```

They are useful predecessors to the ontology adapter. Ordinary scene graphs, however, usually do not represent who knows what, what someone intends, whether an action is permitted, whether information should be concealed, or what a group jointly commits to.

## Embodied language and action

### SayCan

SayCan combines language-model suggestions with robot skill affordances:

```text
language model:
  what action sounds relevant?

robot value/affordance model:
  what action is feasible?

combined score:
  choose an action
```

This is highly relevant to the distinction between interpreted command and physically executable plan. The intended architecture adds explicit speech-act, social, normative, and visibility constraints before feasibility scoring.

### PaLM-E

PaLM-E injects continuous observations such as images, robot state, visual features, and text instructions into an embodied language model. It demonstrates that language models can consume heterogeneous embodied state, but its internal representation is largely neural and opaque.

The proposed architecture uses neural models as proposal mechanisms and projects results into typed observations, belief states, ontologies, and explicit logic.

### RT-2 and OpenVLA

These models learn vision-language-action behavior directly or nearly directly. They are useful references for generalization, visual grounding, instruction following, and action policies.

They are less suited as direct references for proof-producing reasoning, deontic constraints, explicit uncertainty, common knowledge, information-flow restrictions, and auditable social interpretation.

### Inner Monologue

Inner Monologue uses language feedback from the environment to support replanning:

```text
instruction
→ proposed action
→ environmental feedback
→ language-mediated reassessment
→ revised action
```

This resembles the closed-loop grounding architecture. The intended system adds explicit separation between observations, beliefs, logical facts, obligations, plans, and verified outcomes.

## Formal planning and temporal logic

### ROSPlan

ROSPlan bridges symbolic planning and ROS. It is relevant to action schemas, predicates, planning domains, execution monitoring, and replanning.

A possible integration is:

```text
Mercury social/deontic reasoning
→ validated action schema
→ ROSPlan/PDDL-compatible task plan
→ Nav2/MoveIt execution
→ event-calculus outcome update
```

### Temporal-logic robotics

Temporal-logic planners compile goals and constraints into executable plans. They are useful for requirements such as:

```text
always avoid unsafe regions
eventually deliver the object
never expose the package to Carol
after receiving confirmation, report completion
```

Temporal logic is best used for invariants and sequencing; deontic logic alone should not control continuous motion.

### PDDL and contingent planning

PDDL provides action preconditions and effects. Conformant and contingent planning extend this to uncertainty, sensing actions, and partial observability. Mercury can evaluate social and normative conditions and translate approved actions into PDDL-like structures.

## Ontology and knowledge representation

### Semantic Web, OWL, and RDF

Protégé, Apache Jena, RDF4J, HermiT, Pellet, and ELK provide mature tools for classes, properties, identity, inheritance, constraints, and linked data.

They are suitable for relatively stable domain knowledge:

```text
package ⊆ object
courier ⊆ agent
supervisor ⊆ role
delivery ⊆ event
```

They do not directly solve rapidly changing beliefs, probabilistic sensor evidence, conflicting possible worlds, agent-indexed knowledge, action control loops, or richly contextual semiotic interpretation.

A hybrid is more realistic:

```text
OWL/RDF:
  stable domain ontology

probabilistic state:
  uncertain current observations

Mercury:
  finite modal/probabilistic/temporal experiments and policy checks

database/event store:
  history, provenance, replay
```

### DOLCE, BFO, and foundational ontologies

These provide disciplined concepts for objects, events, processes, qualities, roles, dispositions, agents, and time. BFO is common in scientific and biomedical settings; DOLCE often supports ordinary conceptual distinctions.

The immediate priority is not choosing one ontology but avoiding an ad hoc ontology that later conflicts with established standards.

### Event calculus and situation calculus

The `ec.m` work belongs to the established traditions of Kowalski and Sergot’s event calculus, Shanahan’s event calculus, Reiter’s situation calculus, fluent calculus, and action languages such as C+ and BC.

These provide foundations for:

```text
events
→ initiated/terminated fluents
→ temporal persistence
→ action effects
→ reasoning about change
```

## Probabilistic and neuro-symbolic systems

### DeepProbLog and ProbLog

DeepProbLog combines probabilistic logic programming with neural predicates. ProbLog provides weighted facts, uncertain derivations, query probabilities, and probabilistic explanations.

A related interface for the project could be:

```text
neural_points_at(frame, Agent, Object, Confidence)
→ social_mm facts
→ visibility/knowledge reasoning
→ deontic action policy
```

The Mercury work differs by emphasizing typed finite models, explicit modal distinctions, temporal updates, and inspectable demonstrations.

### Logic Tensor Networks

Logic Tensor Networks combine fuzzy logic with neural representations. They are relevant to graded interpretations such as object similarity, speech-act likelihood, and visibility confidence.

Their soft/fuzzy semantics should be treated as a numerical front end rather than a replacement for explicit possible-world and modal semantics.

### Markov Logic Networks and Probabilistic Soft Logic

These combine weighted logical formulas with probabilistic inference and are useful for uncertain relational reasoning, social relations, and soft constraints. They could help resolve references by jointly weighting pointing, proximity, and language evidence.

Modal and normative distinctions would still need explicit treatment.

## Grounded and multimodal language

### Grounded language learning

Grounded-language research studies language ↔ perception ↔ action, including referring expressions, situated dialogue, visual grounding, instruction following, object-centric representations, spatial language, and interactive clarification.

The intended extension adds pointing, gaze, prosody, speaker identity, social roles, visibility, intentional concealment, and uncertainty over reference.

### Referring-expression comprehension

These systems map language to objects, such as “the red cup next to the book.” The proposed system extends this with multimodal evidence and social information-state reasoning.

### Situated dialogue and clarification

Clarification should be selected when:

```text
top interpretation probability is low
```

or:

```text
candidate interpretations produce materially different plans
```

or:

```text
action would violate a norm under plausible alternatives
```

This is stronger than ordinary language-model confidence.

## Social, epistemic, and multi-agent reasoning

### Epistemic planning

Epistemic planning reasons about what agents know, do not know, learn after an action, or can observe. It applies to information-gathering actions, security protocols, privacy, communication, and secrets.

An action can change the physical world and the information state:

```text
deliver(package_7)
```

may also cause:

```text
Carol observes the delivery
Bob learns the location
Alice learns that Bob received it
```

### Dynamic Epistemic Logic

Dynamic epistemic logic models knowledge updates after public announcements, private announcements, observation events, misinformation, and information hiding.

A possible extension is:

```text
utterance or gesture
→ dynamic epistemic update
→ revised Kripke model
→ deontic evaluation
```

### Multi-agent epistemic planning

This provides a strong reference for joint actions, distributed knowledge, communication actions, coordination, nested beliefs, and partial observability.

### Multi-agent reinforcement learning

MARL addresses coordination, communication, shared tasks, emergent conventions, group rewards, and decentralized policies. It is useful for action learning but does not automatically provide interpretable obligations, privacy proofs, explicit common knowledge, or moral reasoning.

## Normative and ethical systems

### Deontic planners and artificial institutions

Normative systems model obligations, prohibitions, permissions, violations, reparations, norms, sanctions, roles, powers, and institutional rules.

They are relevant to:

```text
O(bob, deliver(package_7))
F(bob, expose(package_7, carol))
P(alice, authorize_delivery)
```

Conflicting obligations require priorities, exceptions, reparations, clarification, refusal, or safe fallback.

### Computational ethics

Approaches include rule-based ethical reasoning, value-sensitive design, preference aggregation, consequence-based evaluation, deontological constraints, and hybrid ethical governors.

A practical ethical governor could sit between planner and actuator:

```text
candidate action
→ safety check
→ legal/normative check
→ privacy check
→ execution authorization
```

## Semiotics and multimodal meaning

This is the least integrated area in existing embodied-AI stacks. Related fields include semiotic robotics, cognitive robotics, grounded language, pragmatics, multimodal discourse analysis, human–robot interaction, ecological psychology, and affordance research.

A semiotic layer can distinguish:

| Evidence | Possible semiotic role |
|---|---|
| Image resemblance | Iconic evidence |
| Pointing/gaze | Indexical evidence |
| Spoken words | Symbolic evidence |
| Prosody | Pragmatic or qualifying evidence |
| Social convention | Symbolic-institutional evidence |
| Repeated successful interaction | Learned interpretant convention |

There is no obvious dominant open-source framework that unifies these with formal multimodal epistemic and deontic logic.

## Comparison with the intended architecture

| Layer | Existing precedents | Intended emphasis |
|---|---|---|
| Sensors | ROS, OpenCV, audio frameworks | Typed timestamped evidence |
| Perception | Foundation models, tracking, ASR | Competing hypotheses and provenance |
| Prosody | SpeechBrain, OpenSMILE, speech-language models | Explicit sideband semantics |
| Diffusion NLP | LLaDA, DiffuSeq, LaViDa | Revisable structured interpretation |
| Scene/world model | KnowRob, RoboSherlock, scene graphs | Dynamic ontology with uncertainty |
| Semiotics | Semiotic robotics, pragmatics | Explicit icon/index/symbol layer |
| Belief | POMDPs, Bayesian filters, epistemic planning | Belief distributions plus logical worlds |
| Logic | ProbLog, DeepProbLog, DEL, temporal logic | Mercury modal/probabilistic/temporal substrate |
| Norms | Deontic planners, artificial institutions | Individual and collective obligations |
| Planning | PDDL, ROSPlan, SayCan | Logic-constrained feasible planning |
| Control | MPC, active inference, RL | Filter-aware closed-loop control |
| Action | ROS 2, MoveIt, Nav2, robot policies | Verified event-calculus consequences |
| Communication | Dialogue systems, TTS, HRI | Truth-constrained text, prosody, and gesture |

## What may be distinctive

The individual components are established:

```text
neural perception
Bayesian filtering
ontology
modal logic
temporal logic
planning
control
robotics
```

The potentially unusual contribution is the composition:

```text
multimodal perception
→ semiotic evidence
→ probabilistic candidate meanings
→ dynamic ontology
→ agent-indexed knowledge/belief
→ group/common knowledge
→ deontic obligations and privacy
→ temporal reasoning
→ constrained planning/control
→ verified action and communication
```

Especially unusual is treating prosody, gesture, visibility, and social role as first-class evidence in a formal world model rather than flattening them into text.

The central boundary is:

```text
neural models propose
filters estimate
logic validates
controllers act
sensors verify
```

## Strong ecosystems to study

1. **ROS 2 + Nav2 + MoveIt** — physical middleware, navigation, manipulation, sensors, and execution.
2. **KnowRob / RoboSherlock** — ontology, robot knowledge, and perception-to-symbolic integration.
3. **ProbLog / DeepProbLog** — neural predicates and probabilistic symbolic reasoning.
4. **Dynamic Epistemic Logic and epistemic planning** — visibility, communication, common knowledge, secrets, and information-changing actions.
5. **PDDL/ROSPlan plus temporal logic** — task planning, temporal constraints, execution monitoring, and safety.
6. **SayCan / PaLM-E / Inner Monologue / OpenVLA** — language-to-action grounding and embodied multimodal control.
7. **LLaDA and related diffusion-language models** — revisable text hypotheses, structured completion, and constrained reporting.

No single project supplies the full architecture. The appropriate strategy is to compose these ecosystems.

## Practical interoperability architecture

```text
ROS 2 messages
  sensors and actuators

JSON / Protocol Buffers
  neural-to-symbolic observations

RDF/OWL
  relatively stable domain ontology

ProbLog-like weighted facts
  uncertain relational evidence

PDDL or behavior-tree actions
  task plans

LTL/CTL/PCTL
  temporal and probabilistic properties

Dynamic epistemic updates
  communication and observation effects

Mercury
  typed experimental logic, validators, and finite model checking
```

Mercury need not replace mature robotics infrastructure. It can serve as a formal reference implementation, policy checker, model-construction laboratory, test oracle, and educational substrate. A Python or ROS prototype can exchange serialized facts with it.

## Bottom line

There are many close neighbors, but no obvious dominant project combining all of the following:

```text
audio/video perception
prosody and gesture
Peircean semiotics
dynamic ontology
probabilistic filtering
epistemic and doxastic logic
collective knowledge
deontic and privacy constraints
temporal reasoning
optimal control
motion/action planning
verified communication
```

The credible resource strategy is to recruit or collaborate by layer, define stable interchange formats, and use the Mercury project as the transparent semantic and logical integration laboratory rather than reimplementing all robotics infrastructure from scratch.
