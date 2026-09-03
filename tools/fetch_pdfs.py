#!/usr/bin/env python3
"""Fetch open-access PDFs for MOWGLI's verified citations.

Companion to verify_citations.py: downloads the open-access copy of each
cited paper into the gitignored pdfs/ directory, verifies each file is a real
PDF (magic bytes + minimum size), and records file, sha256, source URL, and
fetch date in pdfs/manifest.json. The manifest pins every PDF's bytes so the
reading library is auditable.

Entries without a known open-access copy are recorded as "unavailable-oa"
with a reason; nothing is guessed.

Usage:
    python3 tools/fetch_pdfs.py          # fetch, print summary
    python3 tools/fetch_pdfs.py --json KEY   # show one manifest entry
"""

import hashlib
import json
import sys
import time
import urllib.request
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLAIMS = ROOT / "citation_claims.json"
PDFS = ROOT / "pdfs"
MANIFEST = PDFS / "manifest.json"
PDFS.mkdir(exist_ok=True)

UA = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0",
      "Accept": "application/pdf,*/*"}

# Entries whose canonical PDF is at a non-arXiv, non-DOI location. Everything
# else resolves from its arXiv ID or its DOI (via content negotiation).
HARDCODED = {
    "kayalibay2023": "https://proceedings.mlr.press/v211/kayalibay23a/kayalibay23a.pdf",
    "nyga2018grounding": "https://proceedings.mlr.press/v87/nyga18a/nyga18a.pdf",
    "bunt2020iso": "https://aclanthology.org/2020.lrec-1.69.pdf",
    "kaelbling1998": "https://people.csail.mit.edu/lpk/papers/aij98-pomdp.pdf",
    "pronina2021": "https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2021.662124/pdf",
    "capitanelli2024": "https://www.frontiersin.org/journals/neurorobotics/articles/10.3389/fnbot.2024.1342786/pdf",
}

# Known closed-access or bot-blocked entries: reason recorded, no fetch
# attempted. Bot-blocked OA entries include the manual-download URL.
CLOSED = {
    "kalman1960": "ASME paywall; the famous UNC mirrors (cs.unc.edu/~welch) are dead",
    "aumann1976": "Project Euclid/JSTOR paywall",
    "plaza1989": "original ISMIS proceedings unindexed and not digitized",
    "vanderhoek2003ckt": "Springer Studia Logica paywall",
    "harnad1990": "Elsevier Physica D paywall",
    "halpern1990": "ACM paywall",
    "alur2002": "ACM paywall",
    "fiorini2013": "Elsevier Information Systems paywall",
    "gangemi2002dolce": "Springer LNCS paywall",
    "gerbrandy1997": "Springer JOLLI paywall",
    "milettegagnon2023": "Routledge handbook chapter (paywalled)",
    "friston2010": "Nature Reviews Neuroscience paywall",
    "friston2017": "Elsevier Neuroscience & Biobehavioral Reviews paywall",
    "ramstead2020": "OA on MDPI but bot-blocked; download manually from https://www.mdpi.com/1099-4300/22/8/889",
}


def fetch_pdf(url: str, dest: Path, retries: int = 3) -> bool:
    """Download url to dest, verifying PDF magic bytes and minimum size."""
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=60) as r:
                data = r.read()
            if not data.startswith(b"%PDF") or len(data) < 20_000:
                print(f"    not a real PDF ({len(data)} bytes, magic {data[:5]!r})")
                return False
            dest.write_bytes(data)
            return True
        except Exception as e:  # noqa: BLE001 - report and retry
            if attempt < retries - 1:
                time.sleep(2 ** (attempt + 1))
                continue
            print(f"    fetch failed: {str(e)[:70]}")
            return False
    return False


def oa_url_for(key: str, c: dict) -> str | None:
    """Resolve an OA URL for a claim: hardcoded first, then DOI/arXiv."""
    if key in CLOSED:
        return None
    if key in HARDCODED:
        return HARDCODED[key]
    if c.get("arxiv"):
        return f"https://arxiv.org/pdf/{c['arxiv']}"
    if c.get("doi"):
        return f"https://doi.org/{c['doi']}"
    return None


def doi_pdf_url(doi: str) -> str:
    return f"https://doi.org/{doi}"


def main() -> int:
    claims = json.loads(CLAIMS.read_text())
    keys = [k for k in claims if not k.startswith("_")]
    manifest = {}
    if MANIFEST.exists():
        manifest = json.loads(MANIFEST.read_text())

    ok = err = 0
    for i, key in enumerate(keys, 1):
        c = claims[key]
        entry = manifest.get(key, {})
        status = entry.get("status", "")

        # Skip already-downloaded entries unless explicitly refetching.
        if status == "downloaded" and entry.get("file") and (PDFS / entry["file"]).exists():
            print(f"[{i:>2}/{len(keys)}] SKIP {key} (already have {entry['file']})")
            ok += 1
            continue

        if key in CLOSED:
            manifest[key] = {"status": "unavailable-oa", "file": None,
                             "reason": CLOSED[key], "date": str(date.today())}
            print(f"[{i:>2}/{len(keys)}] CLSD {key} ({CLOSED[key][:50]})")
            err += 1
            continue

        url = oa_url_for(key, c)
        if url is None:
            manifest[key] = {"status": "unavailable-oa", "file": None,
                             "reason": "no known open-access copy", "date": str(date.today())}
            print(f"[{i:>2}/{len(keys)}] CLSD {key} (no known OA copy)")
            err += 1
            continue

        # DOI content negotiation needs redirects; the Frontiers/Mehr or
        # publisher link 302s to the actual PDF. Fake browser UA helps.
        dest = PDFS / f"{key}.pdf"
        if fetch_pdf(url, dest):
            digest = hashlib.sha256(dest.read_bytes()).hexdigest()
            manifest[key] = {"status": "downloaded", "file": dest.name,
                             "sha256": digest, "source": url, "date": str(date.today())}
            print(f"[{i:>2}/{len(keys)}] OK   {key} <- {url[:60]}")
            ok += 1
        else:
            manifest[key] = {"status": "unavailable-oa", "file": None,
                             "reason": f"fetch failed from {url}", "date": str(date.today())}
            print(f"[{i:>2}/{len(keys)}] FAIL {key}")
            err += 1
        time.sleep(1.0)

    MANIFEST.write_text(json.dumps(manifest, indent=2, ensure_ascii=False))

    print(f"\n=== summary ===\n  downloaded: {ok}\n  unavailable/failed: {err}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
