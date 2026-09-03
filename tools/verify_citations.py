#!/usr/bin/env python3
"""Verify MOWGLI's citation claims against public bibliographic indexes.

Reads citation_claims.json (extracted from the research docs) and checks each
claim against the Crossref REST API (by DOI and by bibliographic search), the
arXiv API, and DBLP. Writes citation_verification.json and prints a human
summary. All HTTP responses are cached under /tmp/mowgli_cite_cache so reruns
are cheap and rate-limit friendly.

Usage:
    python3 tools/verify_citations.py            # verify, print summary
    python3 tools/verify_citations.py --json KEY # print one entry's report
"""

import hashlib
import json
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from difflib import SequenceMatcher
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLAIMS = ROOT / "citation_claims.json"
REPORT = ROOT / "citation_verification.json"
CACHE = Path("/tmp/mowgli_cite_cache")
CACHE.mkdir(exist_ok=True)

MAILTO = "citation-check%40example.org"
PAUSE = 1.5          # polite pacing between API calls
TITLE_OK = 0.75      # similarity threshold for a match
YEAR_SLACK = 1       # allow conference-year vs journal-year off-by-one


def fetch(url: str, retries: int = 3) -> str | None:
    """GET with disk cache, backoff on 429/5xx, None on hard failure."""
    key = hashlib.md5(url.encode()).hexdigest()
    cache_file = CACHE / key
    if cache_file.exists():
        return cache_file.read_text(errors="replace")
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": f"mowgli-cite-check/1.0 (mailto:{MAILTO.replace('%40','@')})"})
            with urllib.request.urlopen(req, timeout=30) as r:
                body = r.read().decode("utf-8", errors="replace")
            cache_file.write_text(body)
            time.sleep(PAUSE)
            return body
        except urllib.error.HTTPError as e:
            if e.code in (429, 502, 503) and attempt < retries - 1:
                time.sleep(2 ** (attempt + 2))
                continue
            return None
        except (urllib.error.URLError, TimeoutError, OSError):
            if attempt < retries - 1:
                time.sleep(2)
                continue
            return None
    return None


def norm_title(s: str) -> str:
    s = unicodedata.normalize("NFKD", s)
    s = re.sub(r"[^a-z0-9 ]+", " ", s.lower())
    return re.sub(r"\s+", " ", s).strip()


def title_sim(a: str, b: str) -> float:
    """Symmetric title similarity: max of char ratio and token containment."""
    a, b = norm_title(a), norm_title(b)
    if not a or not b:
        return 0.0
    ratio = SequenceMatcher(None, a, b).ratio()
    ta, tb = set(a.split()), set(b.split())
    lo = min(len(ta), len(tb))
    contain = len(ta & tb) / lo if lo else 0.0
    return max(ratio, contain if contain > 0.6 else 0.0)


def first_surname(authors) -> str:
    for a in authors or []:
        m = re.search(r"[A-Za-zÀ-ž'’-]+", str(a))
        if m:
            return m.group(0).lower()
    return ""


# ---------- Crossref ----------

def crossref_doi(doi: str) -> dict | None:
    body = fetch(f"https://api.crossref.org/works/{urllib.parse.quote(doi)}")
    if not body:
        return None
    try:
        return json.loads(body)["message"]
    except (json.JSONDecodeError, KeyError):
        return None


def crossref_search(title: str) -> dict | None:
    q = urllib.parse.quote(title)
    body = fetch(f"https://api.crossref.org/works?query.bibliographic={q}&rows=3&mailto={MAILTO}")
    if not body:
        return None
    try:
        items = json.loads(body)["message"]["items"]
    except (json.JSONDecodeError, KeyError):
        return None
    best, best_s = None, 0.0
    for it in items:
        t = " ".join(it.get("title") or [])
        s = title_sim(title, t)
        if s > best_s:
            best, best_s = it, s
    return best if best_s >= TITLE_OK else None


def cr_year(msg: dict):
    for k in ("published-print", "published-online", "issued", "created"):
        dp = msg.get(k) or {}
        parts = dp.get("date-parts") or []
        if parts and parts[0] and parts[0][0]:
            return int(parts[0][0])
    return None


def cr_title(msg: dict) -> str:
    t = msg.get("title") or []
    return t[0] if t else ""


def cr_authors(msg: dict) -> list[str]:
    return [a.get("family", "") for a in msg.get("author", []) if isinstance(a, dict)]


# ---------- arXiv ----------

def arxiv_meta(arxiv_id: str) -> dict | None:
    body = fetch(f"http://export.arxiv.org/api/query?id_list={arxiv_id}&max_results=1")
    if not body or "<entry>" not in body:
        return None
    ns = {"a": "http://www.w3.org/2005/Atom"}
    try:
        root = ET.fromstring(body)
        entry = root.find("a:entry", ns)
        if entry is None:
            return None
        title = (entry.findtext("a:title", "", ns) or "").strip()
        authors = [e.findtext("a:name", "", ns) for e in entry.findall("a:author", ns)]
        year = (entry.findtext("a:published", "", ns) or "")[:4]
        return {"title": title, "authors": authors, "year": int(year) if year.isdigit() else None}
    except ET.ParseError:
        return None


# ---------- DBLP ----------

def dblp_search(title: str) -> list[dict]:
    body = fetch("https://dblp.org/search/publ/api?format=json&h=5&q=" + urllib.parse.quote(title))
    if not body:
        return []
    try:
        hits = json.loads(body)["result"]["hits"].get("hit", [])
    except (json.JSONDecodeError, KeyError):
        return []
    out = []
    for h in hits:
        info = h.get("info", {})
        authors = info.get("authors", {}).get("author", [])
        if isinstance(authors, dict):
            authors = [authors]
        out.append({
            "title": info.get("title", ""),
            "year": int(info["year"]) if str(info.get("year", "")).isdigit() else None,
            "authors": [a.get("text", "") for a in authors],
            "venue": info.get("venue", ""),
            "volume": info.get("volume", ""),
            "pages": info.get("pages", ""),
            "doi": info.get("doi", ""),
            "url": info.get("url", ""),
        })
    return out


# ---------- verification ----------

def check_year(claimed: int, actual) -> bool:
    return actual is not None and abs(int(claimed) - int(actual)) <= YEAR_SLACK


def check_authors(claimed: list[str], actual: list[str]) -> bool:
    if not claimed or not actual:
        return True  # nothing to contradict
    joined = " | ".join(a.lower() for a in actual)
    return first_surname(claimed[:1]) in joined if claimed else True


def verify(key: str, c: dict) -> dict:
    rec = {"key": key, "doc": c["doc"], "status": "unverified",
           "claimed_title": c["title"], "claimed_year": c.get("year"),
           "claimed_id": c.get("doi") or c.get("arxiv"), "notes": []}

    # 1. DOI path
    if c.get("doi"):
        msg = crossref_doi(c["doi"])
        if msg is None:
            rec["status"], rec["notes"] = "error", ["crossref unreachable for DOI"]
            return rec
        t, y, au = cr_title(msg), cr_year(msg), cr_authors(msg)
        rec["found_title"], rec["found_year"], rec["found_authors"] = t, y, au
        rec["sim"] = round(title_sim(c["title"], t), 3)
        ok_t = rec["sim"] >= TITLE_OK
        ok_y = check_year(c["year"], y)
        ok_a = check_authors(c.get("authors", []), au)
        rec["status"] = "verified-doi" if (ok_t and ok_y and ok_a) else "mismatch"
        if not ok_t:
            rec["notes"].append(f"title similarity {rec['sim']} below {TITLE_OK}")
        if not ok_y:
            rec["notes"].append(f"year claimed {c['year']}, crossref says {y}")
        if not ok_a:
            rec["notes"].append(f"author mismatch: claimed {c.get('authors')}, found {au}")
        return rec

    # 2. arXiv path
    if c.get("arxiv"):
        meta = arxiv_meta(c["arxiv"])
        if meta is None:
            rec["status"], rec["notes"] = "error", ["arxiv unreachable or no entry"]
            return rec
        rec["found_title"], rec["found_year"] = meta["title"], meta["year"]
        rec["found_authors"] = meta["authors"]
        rec["sim"] = round(title_sim(c["title"], meta["title"]), 3)
        ok_t = rec["sim"] >= TITLE_OK
        ok_y = check_year(c["year"], meta["year"])
        ok_a = check_authors(c.get("authors", []), meta["authors"])
        rec["status"] = "verified-arxiv" if (ok_t and ok_y and ok_a) else "mismatch"
        if not ok_t:
            rec["notes"].append(f"title similarity {rec['sim']} below {TITLE_OK}")
        if not ok_y:
            rec["notes"].append(f"year claimed {c['year']}, arxiv says {meta['year']}")
        if not ok_a:
            rec["notes"].append(f"author mismatch: claimed {c.get('authors')}, found {meta['authors']}")
        return rec

    # 3. No identifiers: DBLP then Crossref search
    for hit in dblp_search(c["title"]):
        s = title_sim(c["title"], hit["title"])
        if s >= TITLE_OK and check_year(c["year"], hit["year"]) and check_authors(c.get("authors", []), hit["authors"]):
            rec.update(status="verified-dblp", sim=round(s, 3), found_title=hit["title"],
                       found_year=hit["year"], found_authors=hit["authors"],
                       found_venue=f"{hit['venue']} vol {hit['volume']} pp {hit['pages']}".strip(),
                       found_doi=hit["doi"], found_url=hit["url"])
            return rec
    hit = crossref_search(c["title"])
    if hit is not None:
        t, y, au = cr_title(hit), cr_year(hit), cr_authors(hit)
        s = title_sim(c["title"], t)
        if check_year(c["year"], y) and check_authors(c.get("authors", []), au):
            rec.update(status="verified-crossref", sim=round(s, 3), found_title=t,
                       found_year=y, found_authors=au,
                       found_venue="; ".join(hit.get("container-title") or []),
                       found_doi=hit.get("DOI", ""))
            return rec
    rec["status"], rec["notes"] = "not-found", ["no identifier; DBLP and Crossref search found no matching record — needs manual check"]
    return rec


def main() -> int:
    claims = json.loads(CLAIMS.read_text())
    keys = [k for k in claims if not k.startswith("_")]
    report = {}
    for i, key in enumerate(keys, 1):
        rec = verify(key, claims[key])
        report[key] = rec
        mark = {"verified-doi": "OK ", "verified-arxiv": "OK ",
                "verified-dblp": "OK ", "verified-crossref": "OK ",
                "mismatch": "MIS", "not-found": "MAN", "error": "ERR"}[rec["status"]]
        print(f"[{i:>2}/{len(keys)}] {mark} {key:<22} {rec['status']:<17} {rec.get('notes') or ''}")
    REPORT.write_text(json.dumps(report, indent=2, ensure_ascii=False))

    counts: dict[str, int] = {}
    for rec in report.values():
        counts[rec["status"]] = counts.get(rec["status"], 0) + 1
    print("\n=== summary ===")
    for status in ("verified-doi", "verified-arxiv", "verified-dblp",
                   "verified-crossref", "mismatch", "not-found", "error"):
        if counts.get(status):
            print(f"  {status:<18} {counts[status]}")
    bad = counts.get("mismatch", 0) + counts.get("not-found", 0) + counts.get("error", 0)
    print(f"  {'TOTAL PROBLEMS':<18} {bad}")
    return 0 if "--strict" not in sys.argv else (1 if bad else 0)


if __name__ == "__main__":
    sys.exit(main())
