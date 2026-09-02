# Film annotation JSONL format

The film-comprehension prototype uses newline-delimited JSON as the boundary
between audiovisual adapters and the Mercury episode model. Each non-empty,
non-comment line is one observation or relation.

## Observations

```json
{
  "kind": "observation",
  "id": "shot-001-audio",
  "start_ms": 12000,
  "end_ms": 18500,
  "channel": "audio",
  "content": "continuous industrial drone",
  "confidence": 0.87,
  "provenance": "whisper:large-v3; annotator:nyc"
}
```

`kind` may be omitted for backward compatibility and defaults to
`observation`. Required observation fields are `id`, `start_ms`, `end_ms`,
`channel`, `content`, `confidence`, and `provenance`.

## Relations

```json
{
  "kind": "relation",
  "source": "shot-001-audio",
  "relation": "synchronized_with",
  "target": "shot-001-visual",
  "confidence": 0.91,
  "provenance": "annotator:nyc"
}
```

Valid relation kinds are:

```text
before, after, overlaps, during, synchronized_with,
contrasts_with, recurs_after
```

Relation endpoints must refer to observation IDs in the same input stream.
Self-relations are rejected. Relation confidence is also in `[0, 1]`.

Semantic validation applies these rules:

- `before`: source ends strictly before target starts;
- `after` and `recurs_after`: source starts strictly after target ends;
- `overlaps` and `synchronized_with`: intervals intersect;
- `during`: source is contained by target;
- `contrasts_with`: no temporal constraint; it may describe a formal or semantic
  contrast across separated times.

`overlaps`, `synchronized_with`, and `contrasts_with` are symmetric for
duplicate detection. `before` and `after` are inverse directions, so a pair
cannot be redundantly asserted in both directions.

Observation intervals are inclusive and must satisfy
`0 <= start_ms <= end_ms`. Valid channels are `visual`, `audio`, `dialogue`,
`music`, `editing`, and `context`. IDs must be unique within one input stream.
Lines beginning with `#` are ignored.

## Generate Mercury

Validate and generate a typed Mercury module with:

```bash
python3 film_annotations.py film_annotations.jsonl \
  --mercury film_annotation_fixture.m
mmc --make film_annotation_fixture_test
./film_annotation_fixture_test
```

The generated module exports both:

```mercury
observations = list(film_episode.observation)
relations = list(film_episode.observation_relation)
```

The typed episode model exposes:

- `relation_is_valid/2`: checks endpoint existence and temporal semantics;
- `all_relations_are_valid/1`: checks every relation in an episode;
- `relations_for_observation/2`: all relations where an ID is either endpoint;
- `related_observations/3`: observations connected by a selected relation kind;
- `cross_modal_relations/1`: relations whose endpoints have different channels.

The generated module is a build artifact and should normally be regenerated,
not hand-edited. Raw JSON parsing remains outside the logical rules so model
adapters cannot bypass schema, confidence, or provenance validation.
