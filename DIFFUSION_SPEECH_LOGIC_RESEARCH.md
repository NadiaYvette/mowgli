# Diffusion language, speech sidebands, and the logic onion

## Main conclusion

LLaDA is a promising candidate for text-side inference and generation, but it
is not by itself a speech-understanding or prosody model. The right interface
is a typed, uncertainty-preserving intermediate representation:

```text
audio/video/text
  -> modality encoders and aligners
  -> candidate signs, speech acts, and grounded referents
  -> diffusion or other joint hypothesis model
  -> belief state with provenance
  -> ontology + semiotic interpretation
  -> Mercury logic and event calculus
  -> constrained symbolic plan
  -> trajectory/controller
  -> text + prosody + motion/action realization
```

Do not serialize all of this into one prose prompt. Preserve literal content,
prosody, gesture, social context, confidence, and provenance as separate but
aligned channels.

## Why comprehension is harder than generation

The intuition is substantially correct, but the distinction is not simply that
one neural model is larger than the other. Comprehension must solve several
inverse problems simultaneously:

1. segment and recognize signals;
2. identify speakers, objects, and events;
3. align modalities in time;
4. resolve references such as “that one” and “over there”;
5. infer speech act and intended force;
6. distinguish what was said from what the speaker believes or presupposes;
7. infer what each participant can see or know;
8. maintain uncertainty over competing world models;
9. map candidates into ontology and logic;
10. decide whether an action is permitted, safe, and physically feasible.

Generation is also multi-stage, but can begin from a selected proposition and
policy. A robot should therefore generate from a validated communicative plan,
not ask a language model to invent both the action and the report at once.

## Where diffusion models fit

### LLaDA

LLaDA uses forward masking and reverse masked-token prediction in a Transformer
and was introduced as an 8B diffusion language model. Its bidirectional masked
inference and likelihood-based formulation make it interesting for:

- filling missing portions of a structured interpretation;
- proposing multiple compatible parses;
- revising a hypothesis when a late audio/video cue arrives;
- constrained completion around a fixed schema;
- generating several candidate reports or plans for verification.

It does not automatically provide grounding, calibrated probabilities,
prosody understanding, or logical validity. Those must be supplied by the
surrounding architecture.

Earlier work such as Diffusion-LM and DiffuSeq is relevant to controllable and
conditional text generation. LaViDa is particularly relevant to this project
because it combines a vision encoder with a discrete diffusion language model
for multimodal understanding. These are evidence that diffusion can be used
beyond free-form text generation, not evidence that a diffusion backbone alone
solves multimodal comprehension.

## Sideband representation

A single utterance should be represented as a bundle of synchronized channels:

```json
{
  "utterance_id": "u41",
  "interval": [12.40, 13.12],
  "speaker": "alice",
  "lexical": {
    "text": "Give it to Bob",
    "tokens": ["give", "it", "to", "bob"],
    "confidence": 0.93
  },
  "prosody": {
    "pitch_contour": "rising-final",
    "rate": 0.82,
    "intensity": 0.71,
    "prominence": ["Bob"],
    "uncertainty": 0.16,
    "urgency": 0.84,
    "confidence": 0.88
  },
  "pragmatics": [
    {"act": "request", "probability": 0.76},
    {"act": "命令", "probability": 0.18}
  ],
  "grounding": [
    {"referent": "package_7", "probability": 0.81},
    {"referent": "package_8", "probability": 0.12}
  ],
  "provenance": ["mic_2:12.40-13.12", "camera_1:12.40-13.12"]
}
```

The non-English placeholder above should be normalized to a project speech-act
label such as `directive` in an implementation. The important design point is
that prosodic features are not hidden in an opaque text string and are not
converted directly into facts.

A later semiotic projection can classify the evidence separately:

```text
speech words        -> symbolic sign
pointing/gaze       -> indexical sign
facial resemblance  -> iconic evidence
prosodic contour    -> qualifier of speech-act interpretation
social convention   -> symbolic-pragmatic evidence
```

The output should be competing interpretants with confidence and provenance,
not a forced single meaning.

## A practical hybrid architecture

### Perception and alignment

GPU models produce timestamped observations:

- ASR and word timestamps;
- speaker diarization;
- pitch, duration, intensity, and voice-quality features;
- object detection/tracking;
- pointing, gaze, and body-pose estimates;
- scene and sound events.

A lightweight alignment layer places all observations on a common event clock.

### Candidate interpretation

Use a text diffusion model or multimodal diffusion model to propose structured
candidate interpretations, but constrain the output to a schema. The model may
complete:

```text
speech act + arguments + referent + social force + uncertainty
```

For example:

```text
request(alice, bob, deliver(package_7))
```

with alternatives and probabilities rather than only the top string.

### Verification and filtering

A Bayesian filter, particle filter, or factor graph should update beliefs over
persistent hypotheses as new frames arrive. Keep separate distributions for:

- object identity and location;
- speaker intention;
- speech-act type;
- prosodic force;
- visibility and access;
- agent knowledge/belief;
- action success and actuator state.

This is where the current finite Bayesian filter can grow into a controlled HMM
or particle-filter adapter. The filter should not silently turn probability into
truth. The ontology adapter decides when to add a fluent, and records the
threshold and evidence used.

### Logic projection

Project high-confidence or explicitly disjunctive hypotheses into the Mercury
world model:

```text
utterance(alice, bob, deliver(package_7))
points_at(alice, package_7)
urgent(alice, utterance_41)
visible(package_7, bob)
not_visible(package_7, carol)
```

Then query:

```text
K(bob, package_7_location)
B(bob, authorized(alice, bob, deliver(package_7)))
O(bob, deliver(package_7))
not_visible(package_7, carol)
```

A speech-act classifier can suggest a candidate obligation; only the normative
logic and policy layer should determine whether that obligation actually holds.

### Action and report generation

Separate three decisions:

1. **Task policy**: what action should be taken?
2. **World execution**: what action was physically achieved?
3. **Communicative policy**: what must or may be reported to whom?

After execution, construct a report record from verified facts:

```text
completion(task_17)
result(package_7, delivered)
confidence(package_7, 0.94)
exception(no_damage_detected)
```

A diffusion model can produce several report realizations conditioned on this
record. A speech planner then adds explicit prosodic controls such as:

```text
speech_act = report
certainty = high
urgency = low
focus = [package_7, delivered]
addressee = alice
```

A TTS/prosody model realizes the text and controls. It must not be allowed to
change the underlying verified result.

## Research most directly relevant

- Nie et al., “Large Language Diffusion Models,” arXiv:2502.09992 (LLaDA).
- Li et al., “Diffusion-LM Improves Controllable Text Generation,”
  arXiv:2205.14217.
- Gong et al., “DiffuSeq: Sequence to Sequence Text Generation with Diffusion
  Models,” arXiv:2210.08933 / ICLR 2023.
- Li et al., “LaViDa: A Large Diffusion Language Model for Multimodal
  Understanding,” arXiv:2505.16839 / NeurIPS 2025.
- Kim et al., “Paralinguistics-Aware Speech-Empowered Large Language Models for
  Natural Conversation,” NeurIPS 2024; introduces USDM.
- Qian et al., “ProsodyLM: Uncovering the Emerging Prosody Processing
  Capabilities in Speech Language Models,” arXiv:2507.20091.
- Pronina et al., “Bridging the Gap Between Prosody and Pragmatics,” *Frontiers
  in Psychology* 12 (2021), 662124, doi:10.3389/fpsyg.2021.662124.
- Bunt et al., “The ISO Standard for Dialogue Act Annotation, Second
  Edition,” LREC 2020, 549–558,
  https://aclanthology.org/2020.lrec-1.69/
  (doi:10.18653/v1/2020.lrec-1.69); see ISO 24617-2 for multidimensional
  spoken and multimodal dialogue-act annotation.
- Nyga et al., “Grounding Robot Plans from Natural Language Instructions,”
  PMLR 87 (2018).
- Capitanelli et al., “A framework for neurosymbolic robot action planning
  using large language models,” *Frontiers in Neurorobotics* (2024).

## BibTeX

```bibtex
@article{nie2025llada,
  author = {Nie, Shen and Zhu, Fengqi and You, Zebin and Zhang, Xiaolu and
    Ou, Jingyang and Hu, Jun and Zhou, Jun and Lin, Yankai and Wen, Ji-Rong
    and Li, Chongxuan},
  title = {Large Language Diffusion Models},
  journal = {arXiv preprint arXiv:2502.09992},
  year = {2025},
  doi = {10.48550/arXiv.2502.09992}
}
@inproceedings{li2022diffusionlm,
  author = {Li, Xiang Lisa and Thickstun, John and Gulrajani, Ishaan and
    Liang, Percy and Hashimoto, Tatsunori B.},
  title = {Diffusion-LM Improves Controllable Text Generation},
  booktitle = {Advances in Neural Information Processing Systems},
  year = {2022},
  url = {https://arxiv.org/abs/2205.14217}
}
@article{gong2022diffuseq,
  author = {Gong, Shansan and Meng, Giwon and Li, Ye and Wu, Zhaopeng and
    Li, Xiaoni and Wang, Shizhuo and Hovy, Eduard and Huang, Xin},
  title = {DiffuSeq: Sequence to Sequence Text Generation with Diffusion Models},
  journal = {arXiv preprint arXiv:2210.08933 (published at ICLR 2023)},
  year = {2022}
}
@article{li2025lavida,
  author = {Li, Shufan and others},
  title = {LaViDa: A Large Diffusion Language Model for Multimodal Understanding},
  journal = {arXiv preprint arXiv:2505.16839},
  year = {2025},
  doi = {10.48550/arXiv.2505.16839}
}
@inproceedings{bunt2020iso,
  author = {Bunt, Harry and Petukhova, Volha and Gilmartin, Emer and
    Pelachaud, Catherine and Fang, Alex and Keizer, Simon and others},
  title = {The ISO Standard for Dialogue Act Annotation, Second Edition},
  booktitle = {Proceedings of the Twelfth Language Resources and Evaluation
    Conference (LREC)},
  pages = {549--558}, year = {2020},
  doi = {10.18653/v1/2020.lrec-1.69}
}
@article{qian2025prosodylm,
  author = {Qian, Cheng and others},
  title = {ProsodyLM: Uncovering the Emerging Prosody Processing Capabilities
    in Speech Language Models},
  journal = {arXiv preprint arXiv:2507.20091},
  year = {2025},
  doi = {10.48550/arXiv.2507.20091}
}
@inproceedings{kim2024usdm,
  author = {Kim, Hyungjoo and others},
  title = {Paralinguistics-Aware Speech-Empowered Large Language Models for Natural Conversation},
  booktitle = {Advances in Neural Information Processing Systems},
  year = {2024},
  url = {https://arxiv.org/abs/2402.05706}
}
@article{pronina2021prosody,
  author = {Pronina, Mariia and H{\"u}bscher, Iris and Vil{\`a}-Gim{\'e}nez, Ingrid
    and Prieto, Pilar},
  title = {Bridging the Gap Between Prosody and Pragmatics},
  journal = {Frontiers in Psychology},
  volume = {12}, pages = {662124}, year = {2021},
  doi = {10.3389/fpsyg.2021.662124}
}
```

## Prototype status

The repository now contains three dependency-light boundaries:

- `audio_frontend.py` reads PCM WAV and emits duration, RMS, zero-crossing,
  and a deliberately named `pitch_proxy_hz`; it is a baseline measurement,
  not an ASR or prosody classifier.
- `audio_observation.py` packages transcript, timing, prosody, and provenance.
- `llada_interface.py` validates candidate interpretations while keeping
  probability and evidence separate from Mercury truth.
- `llada_backend.py` checks an explicit checkout of the official LLaDA source;
  model loading is intentionally opt-in.

The official LLaDA sampler uses masked-token diffusion rather than a standard
autoregressive generation call. The adapter should therefore pass a structured
prompt/schema to the sampler and parse a candidate list, followed by filtering
and logical validation. It must not treat arbitrary generated prose as an
assertion.

## Recommended experiment

The first useful experiment is not end-to-end robot control. It is a replayable
multimodal episode with injected ambiguity:

1. video shows Alice pointing at one of two packages;
2. speech says “give it to Bob”;
3. prosody varies between request, urgent directive, and uncertain query;
4. Carol can or cannot see the package depending on the episode;
5. the filter maintains candidate referents and speech acts;
6. Mercury evaluates knowledge, obligation, and secrecy constraints;
7. a discrete planner chooses deliver, ask-clarification, or refuse;
8. the robot reports verified outcome facts with controlled prosody.

Measure referent accuracy, speech-act calibration, violation of visibility
constraints, clarification rate, task completion, and report factuality. This
will tell us whether diffusion improves the part we care about instead of
confounding perception, reasoning, and generation in one score.

## Bottom line

The strongest role for diffusion is **parallel, revisable hypothesis formation
and constrained realization**. The strongest role for Mercury is **typed,
provenance-aware social and normative reasoning**. Filtering connects them by
maintaining uncertainty through time. Generation should be downstream of
verified action and communicative policy, with prosody represented as an
explicit control channel rather than discarded by ASR or hallucinated by TTS.
