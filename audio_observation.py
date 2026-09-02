#!/usr/bin/env python3
"""Create a typed audio observation record for the logic onion.

This intentionally does not run ASR.  It accepts transcript text and optional
prosodic measurements from any audio frontend, then emits a stable JSON record
that a later LLaDA adapter can turn into interpretation candidates.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class Prosody:
    pitch_contour: str = "unknown"
    rate: float | None = None
    intensity: float | None = None
    urgency: float = 0.0
    uncertainty: float = 0.0
    focus: tuple[str, ...] = ()
    confidence: float = 0.0


@dataclass(frozen=True)
class AudioObservation:
    observation_id: str
    speaker: str
    text: str
    start: float
    end: float
    prosody: Prosody
    provenance: tuple[str, ...]

    def to_dict(self) -> dict[str, Any]:
        result = asdict(self)
        result["prosody"]["focus"] = list(self.prosody.focus)
        result["provenance"] = list(self.provenance)
        return result


def clamp(value: float) -> float:
    return max(0.0, min(1.0, value))


def make_observation(
    observation_id: str,
    speaker: str,
    text: str,
    start: float,
    end: float,
    pitch_contour: str,
    rate: float | None,
    intensity: float | None,
    urgency: float,
    uncertainty: float,
    focus: tuple[str, ...],
    confidence: float,
    provenance: tuple[str, ...],
) -> AudioObservation:
    if end < start:
        raise ValueError("end must be greater than or equal to start")
    return AudioObservation(
        observation_id=observation_id,
        speaker=speaker,
        text=text,
        start=start,
        end=end,
        prosody=Prosody(
            pitch_contour=pitch_contour,
            rate=None if rate is None else clamp(rate),
            intensity=None if intensity is None else clamp(intensity),
            urgency=clamp(urgency),
            uncertainty=clamp(uncertainty),
            focus=focus,
            confidence=clamp(confidence),
        ),
        provenance=provenance,
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--id", default="u1", dest="observation_id")
    parser.add_argument("--speaker", default="unknown")
    parser.add_argument("--text", required=True)
    parser.add_argument("--start", type=float, default=0.0)
    parser.add_argument("--end", type=float, default=0.0)
    parser.add_argument("--pitch-contour", default="unknown")
    parser.add_argument("--rate", type=float)
    parser.add_argument("--intensity", type=float)
    parser.add_argument("--urgency", type=float, default=0.0)
    parser.add_argument("--uncertainty", type=float, default=0.0)
    parser.add_argument("--focus", action="append", default=[])
    parser.add_argument("--confidence", type=float, default=0.0)
    parser.add_argument("--source", action="append", default=[])
    args = parser.parse_args()
    observation = make_observation(
        args.observation_id,
        args.speaker,
        args.text,
        args.start,
        args.end,
        args.pitch_contour,
        args.rate,
        args.intensity,
        args.urgency,
        args.uncertainty,
        tuple(args.focus),
        args.confidence,
        tuple(args.source),
    )
    print(json.dumps(observation.to_dict(), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
