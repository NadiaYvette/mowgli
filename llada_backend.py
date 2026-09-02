#!/usr/bin/env python3
"""Optional adapter boundary for the official LLaDA implementation.

The repository's official sampler is intentionally not copied here.  This
wrapper checks a user-provided checkout and prints the invocation contract;
actual model loading remains an explicit operation because the checkpoint is
large and requires a compatible PyTorch/Transformers environment.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


REQUIRED_FILES = ("generate.py", "chat.py")


def inspect_checkout(path: str | Path) -> dict[str, object]:
    root = Path(path).expanduser()
    present = [name for name in REQUIRED_FILES if (root / name).is_file()]
    return {
        "path": str(root),
        "official_layout_detected": len(present) == len(REQUIRED_FILES),
        "present_files": present,
        "missing_files": [name for name in REQUIRED_FILES if name not in present],
        "model": "GSAI-ML/LLaDA-8B-Instruct",
        "transformers": "4.38.2",
        "mask_sampler": "official generate.py; not autoregressive generate()",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("checkout", help="path to an official LLaDA checkout")
    args = parser.parse_args()
    print(json.dumps(inspect_checkout(args.checkout), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
