#!/usr/bin/env python3
"""Validate film observations and relations, then generate Mercury fixtures."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from typing import Any, Iterable, TextIO

CHANNELS = {"visual", "audio", "dialogue", "music", "editing", "context"}
RELATIONS = {
    "before",
    "after",
    "overlaps",
    "during",
    "synchronized_with",
    "contrasts_with",
    "recurs_after",
}


@dataclass(frozen=True)
class FilmObservation:
    observation_id: str
    start_ms: int
    end_ms: int
    channel: str
    content: str
    confidence: float
    provenance: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "kind": "observation",
            "id": self.observation_id,
            "start_ms": self.start_ms,
            "end_ms": self.end_ms,
            "channel": self.channel,
            "content": self.content,
            "confidence": self.confidence,
            "provenance": self.provenance,
        }


@dataclass(frozen=True)
class FilmRelation:
    source_id: str
    relation: str
    target_id: str
    confidence: float
    provenance: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "kind": "relation",
            "source": self.source_id,
            "relation": self.relation,
            "target": self.target_id,
            "confidence": self.confidence,
            "provenance": self.provenance,
        }


def _number(value: Any, field: str) -> int:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError(f"{field} must be a number")
    if int(value) != value:
        raise ValueError(f"{field} must be an integer")
    return int(value)


def _confidence(value: Any) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError("confidence must be a number")
    result = float(value)
    if not 0.0 <= result <= 1.0:
        raise ValueError("confidence must be between 0 and 1")
    return result


def _text(record: dict[str, Any], field: str, non_empty: bool = True) -> str:
    value = record.get(field)
    if not isinstance(value, str) or (non_empty and not value):
        suffix = "non-empty " if non_empty else ""
        raise ValueError(f"{field} must be a {suffix}string")
    return value


def normalize_observation(record: dict[str, Any]) -> FilmObservation:
    required = {"id", "start_ms", "end_ms", "channel", "content", "confidence", "provenance"}
    missing = required - record.keys()
    if missing:
        raise ValueError(f"missing fields: {', '.join(sorted(missing))}")
    observation_id = _text(record, "id")
    channel = record["channel"]
    if channel not in CHANNELS:
        raise ValueError(f"channel must be one of: {', '.join(sorted(CHANNELS))}")
    content = _text(record, "content", non_empty=False)
    provenance = _text(record, "provenance")
    start_ms = _number(record["start_ms"], "start_ms")
    end_ms = _number(record["end_ms"], "end_ms")
    if start_ms < 0 or end_ms < start_ms:
        raise ValueError("interval must satisfy 0 <= start_ms <= end_ms")
    return FilmObservation(
        observation_id, start_ms, end_ms, channel, content,
        _confidence(record["confidence"]), provenance,
    )


def normalize_relation(record: dict[str, Any]) -> FilmRelation:
    required = {"source", "relation", "target", "confidence", "provenance"}
    missing = required - record.keys()
    if missing:
        raise ValueError(f"missing relation fields: {', '.join(sorted(missing))}")
    source_id = _text(record, "source")
    relation = record["relation"]
    if relation not in RELATIONS:
        raise ValueError(f"relation must be one of: {', '.join(sorted(RELATIONS))}")
    target_id = _text(record, "target")
    if source_id == target_id:
        raise ValueError("relation endpoints must have different IDs")
    return FilmRelation(
        source_id, relation, target_id,
        _confidence(record["confidence"]), _text(record, "provenance"),
    )


def read_annotations(stream: Iterable[str]) -> tuple[list[FilmObservation], list[FilmRelation]]:
    observations: list[FilmObservation] = []
    relations: list[FilmRelation] = []
    seen_ids: set[str] = set()
    for line_number, line in enumerate(stream, 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        try:
            record = json.loads(line)
            if not isinstance(record, dict):
                raise ValueError("record must be a JSON object")
            kind = record.get("kind", "observation")
            if kind == "observation":
                observation = normalize_observation(record)
                if observation.observation_id in seen_ids:
                    raise ValueError(f"duplicate id: {observation.observation_id}")
                seen_ids.add(observation.observation_id)
                observations.append(observation)
            elif kind == "relation":
                relations.append(normalize_relation(record))
            else:
                raise ValueError("kind must be observation or relation")
        except (json.JSONDecodeError, ValueError) as error:
            raise ValueError(f"line {line_number}: {error}") from error
    known_ids = {observation.observation_id for observation in observations}
    for relation in relations:
        missing = {relation.source_id, relation.target_id} - known_ids
        if missing:
            raise ValueError(
                f"relation references unknown observation IDs: {', '.join(sorted(missing))}"
            )
    return observations, relations


def read_jsonl(stream: Iterable[str]) -> list[FilmObservation]:
    """Backward-compatible observation-only view of a JSONL stream."""
    observations, relations = read_annotations(stream)
    if relations:
        raise ValueError("relation records require read_annotations")
    return observations


def _mercury_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def generate_mercury_module(
    observations: list[FilmObservation],
    module_name: str = "film_annotation_fixture",
    relations: list[FilmRelation] | None = None,
) -> str:
    if not module_name.replace("_", "a").isalnum() or not module_name[0].islower():
        raise ValueError("module_name must be a lowercase Mercury identifier")
    relations = [] if relations is None else relations
    lines = [
        "% Generated by film_annotations.py; do not edit by hand.",
        f":- module {module_name}.",
        "",
        ":- interface.",
        "",
        ":- import_module film_episode.",
        ":- import_module list.",
        "",
        ":- func observations = list(film_episode.observation).",
        ":- func relations = list(film_episode.observation_relation).",
        "",
        ":- implementation.",
        "",
        "observations = [",
    ]
    rendered_observations = [
        "    film_episode.observation(%s, %d, %d, %s, %s, %.17g, %s)"
        % (
            _mercury_string(observation.observation_id),
            observation.start_ms,
            observation.end_ms,
            observation.channel,
            _mercury_string(observation.content),
            observation.confidence,
            _mercury_string(observation.provenance),
        )
        for observation in observations
    ]
    lines.append(",\n".join(rendered_observations))
    lines.extend(["].", "", "relations = ["])
    rendered_relations = [
        "    film_episode.observation_relation(%s, %s, %s, %.17g, %s)"
        % (
            _mercury_string(relation.source_id),
            relation.relation,
            _mercury_string(relation.target_id),
            relation.confidence,
            _mercury_string(relation.provenance),
        )
        for relation in relations
    ]
    lines.append(",\n".join(rendered_relations))
    lines.extend(["] .".replace("] ", "]"), "", f":- end_module {module_name}.", ""])
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", nargs="?", help="JSONL file; stdin if omitted")
    parser.add_argument("--mercury", metavar="PATH", help="write a Mercury fixture module")
    parser.add_argument("--module", default="film_annotation_fixture")
    args = parser.parse_args()
    stream: TextIO
    with open(args.path, encoding="utf-8") if args.path else sys.stdin as stream:
        observations, relations = read_annotations(stream)
    if args.mercury:
        with open(args.mercury, "w", encoding="utf-8") as output:
            output.write(generate_mercury_module(
                observations, module_name=args.module, relations=relations))
    else:
        for record in [*observations, *relations]:
            print(json.dumps(record.to_dict(), sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
