# Film annotation JSONL format

The film-comprehension prototype uses newline-delimited JSON as the boundary
between audiovisual adapters and the Mercury episode model. Each non-empty,
non-comment line is one observation:

```json
{
  "id": "shot-001-audio",
  "start_ms": 12000,
  "end_ms": 18500,
  "channel": "audio",
  "content": "continuous industrial drone",
  "confidence": 0.87,
  "provenance": "whisper:large-v3; annotator:nyc"
}
```

Required fields are `id`, `start_ms`, `end_ms`, `channel`, `content`,
`confidence`, and `provenance`. Valid channels are:

```text
visual, audio, dialogue, music, editing, context
```

Intervals are inclusive and must satisfy `0 <= start_ms <= end_ms`.
Confidence is a number in `[0, 1]`. IDs must be unique within one input
stream. Lines beginning with `#` are ignored.

Validate or normalize a file with:

```bash
python3 film_annotations.py film_annotations.jsonl
```

The validator is deliberately independent of model inference. Vision, ASR,
prosody, shot detection, music analysis, and human annotation tools can all
produce this same boundary format. `provenance` identifies the source, while
`confidence` records uncertainty; neither is treated as truth by the logic
layer.

The current bridge generates a Mercury module after validation:

```bash
python3 film_annotations.py film_annotations.jsonl \
  --mercury film_annotation_fixture.m
mmc --make film_annotation_fixture_test
./film_annotation_fixture_test
```

The generated module contains typed `film_episode.observation` constructors.
It is a build artifact and should normally be regenerated, not hand-edited.
Raw JSON parsing remains outside the logical rules until the schema and
provenance requirements have stabilized.
