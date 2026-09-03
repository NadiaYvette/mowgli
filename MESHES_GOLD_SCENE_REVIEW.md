# Meshes of the Afternoon gold-scene review

## Scope

This package is a candidate annotation set for the opening motif sequence. It
uses the local encode identified in `meshes_gold_scene_manifest.json` but does
not include or redistribute that media.

The JSONL timestamps are relative to the manifest's `scene_start_ms`. The
manifest currently marks the package `candidate_pending_manual_review`.

## Review procedure

1. Open the local source encode and identify the first frame of the scene
   window. Do not assume another copy has the same introduction, restoration,
   soundtrack, or frame rate.
2. Check each observation's start and end boundaries. Adjust the JSONL record if
   the event begins or ends elsewhere; preserve a useful confidence value.
3. Check that the content describes an observable event rather than an
   interpretation. Move claims about symbolism into a later sign or reading
   layer.
4. Check every relation against the reviewed intervals and the semantic rules
   in `FILM_ANNOTATION_FORMAT.md`.
5. Record reviewer identity and date in the provenance field, for example:
   `annotator:nyc;reviewed:2026-09-03;review:confirmed`.
6. Change the manifest status to `gold_reviewed` only after all records have
   been checked and the generated Mercury fixture has been regenerated.

## Observation checklist

| ID | Check |
|---|---|
| `m01` | Figure/path/house event and interval |
| `m02` | Flower visibility and interval |
| `m03` | Key/hand/entrance event and interval |
| `m04` | Interior movement and stair event |
| `m05` | Obscured or mirror-faced figure event |
| `m06` | Score presence and interval |
| `m07` | Editing transition boundary |
| `m08` | Scene-window context bounds |

## Relation checklist

| Relation | Check |
|---|---|
| `m01 overlaps m02` | Both events visibly coexist |
| `m02 before m03` | The flower event ends before the key event begins |
| `m03 before m04` | The key event ends before interior movement begins |
| `m04 overlaps m05` | The encounter occurs during the interior movement |
| `m05 synchronized_with m06` | Score and encounter overlap in the reviewed encode |
| `m07 after m05` | The transition follows the encounter |
| `m03 during m08` | The key event lies inside the scene window |
| `m02 contrasts_with m06` | Reviewer agrees this is a defensible formal/semantic contrast |

`contrasts_with` is intentionally the least objective relation here. It may
be removed if the reviewer cannot state what evidence makes the contrast
meaningful without importing a thematic interpretation.
