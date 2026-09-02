#!/usr/bin/env python3
"""Extract conservative acoustic sidebands from a PCM WAV file.

This is a baseline frontend, not speech recognition or prosody interpretation.
It emits measurable features so an ASR/prosody model can later replace it
without changing the observation schema.
"""

from __future__ import annotations

import argparse
import array
import json
import math
import wave
from dataclasses import asdict, dataclass
from pathlib import Path


@dataclass(frozen=True)
class AcousticFeatures:
    sample_rate: int
    duration: float
    rms: float
    zero_crossing_rate: float
    pitch_proxy_hz: float | None
    provenance: str

    def to_dict(self) -> dict[str, object]:
        return asdict(self)


def _samples_from_wav(path: Path) -> tuple[list[float], int]:
    with wave.open(str(path), "rb") as stream:
        channels = stream.getnchannels()
        sample_width = stream.getsampwidth()
        sample_rate = stream.getframerate()
        frame_count = stream.getnframes()
        raw = stream.readframes(frame_count)
    if channels < 1:
        raise ValueError("WAV must contain at least one channel")
    if sample_width not in (1, 2, 4):
        raise ValueError("only 8-, 16-, and 32-bit PCM WAV files are supported")
    typecode = {1: "B", 2: "h", 4: "i"}[sample_width]
    values = array.array(typecode)
    values.frombytes(raw)
    if len(values) % channels != 0:
        raise ValueError("WAV frame data is incomplete")
    scale = {1: 128.0, 2: 32768.0, 4: 2147483648.0}[sample_width]
    samples: list[float] = []
    for frame_start in range(0, len(values), channels):
        frame = values[frame_start:frame_start + channels]
        if sample_width == 1:
            samples.append((sum(frame) / channels - 128.0) / scale)
        else:
            samples.append(sum(frame) / channels / scale)
    return samples, sample_rate


def extract_features(path: str | Path) -> AcousticFeatures:
    wav_path = Path(path)
    samples, sample_rate = _samples_from_wav(wav_path)
    if not samples or sample_rate <= 0:
        raise ValueError("WAV must contain samples and a positive sample rate")
    energy = sum(sample * sample for sample in samples) / len(samples)
    rms = math.sqrt(energy)
    crossings = sum(
        1 for left, right in zip(samples, samples[1:])
        if (left < 0.0 <= right) or (right < 0.0 <= left)
    )
    duration = len(samples) / sample_rate
    zero_crossing_rate = crossings / duration if duration else 0.0
    pitch_proxy = zero_crossing_rate / 2.0 if zero_crossing_rate > 0.0 else None
    return AcousticFeatures(
        sample_rate=sample_rate,
        duration=duration,
        rms=min(1.0, rms),
        zero_crossing_rate=zero_crossing_rate,
        pitch_proxy_hz=pitch_proxy,
        provenance=f"wav:{wav_path}:{0.0:.3f}-{duration:.3f}",
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("wav", help="path to a PCM WAV file")
    args = parser.parse_args()
    print(json.dumps(extract_features(args.wav).to_dict(), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
