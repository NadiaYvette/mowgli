#!/usr/bin/env python3
"""Validate the structured contract between audio features and LLaDA.

A future backend can replace ``propose`` with actual LLaDA inference.  The
contract remains JSON so candidate interpretations can be filtered, audited,
and projected into Mercury without treating generated prose as truth.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass, asdict
from typing import Any


@dataclass(frozen=True)
class Candidate:
    speech_act: str
    addressee: str
    predicate: str
    arguments: tuple[str, ...]
    probability: float
    evidence: tuple[str, ...]

    def to_dict(self) -> dict[str, Any]:
        result = asdict(self)
        result["arguments"] = list(self.arguments)
        result["evidence"] = list(self.evidence)
        return result


def validate_candidate(candidate: Candidate) -> None:
    if not candidate.speech_act or not candidate.predicate:
        raise ValueError("speech_act and predicate are required")
    if not 0.0 <= candidate.probability <= 1.0:
        raise ValueError("probability must be between 0 and 1")
    if not candidate.evidence:
        raise ValueError("candidate must retain evidence provenance")


def propose(observation: dict[str, Any]) -> list[Candidate]:
    """Return a deterministic placeholder until a LLaDA backend is selected."""
    text = str(observation.get("text", "")).lower()
    prosody = observation.get("prosody", {})
    urgency = float(prosody.get("urgency", 0.0))
    act = "directive" if urgency >= 0.6 else "request"
    candidate = Candidate(
        speech_act=act,
        addressee="unresolved",
        predicate="unparsed_utterance",
        arguments=(text,),
        probability=0.5,
        evidence=(str(observation.get("observation_id", "unknown")),),
    )
    validate_candidate(candidate)
    return [candidate]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("observation", help="JSON audio observation, or @path.json")
    args = parser.parse_args()
    raw = args.observation
    if raw == "@-":
        import sys
        raw = sys.stdin.read()
    elif raw.startswith("@"):
        with open(raw[1:], encoding="utf-8") as stream:
            raw = stream.read()
    observation = json.loads(raw)
    print(json.dumps([candidate.to_dict() for candidate in propose(observation)], indent=2))


if __name__ == "__main__":
    main()
