# Citation verification report

All identifier-bearing citations in the top-level research documents were
verified on **2026-09-03** by `tools/verify_citations.py` against Crossref,
the arXiv API, and DBLP (raw results: `citation_verification.json`; claims
inventory with per-entry notes: `citation_claims.json`).

**Result: 24/25 verified by API lookup.** The single remaining entry
(`plaza1989`) cites 1989 ISMIS proceedings that no public index records; its
Springer reprint DOI (`10.1007/s11229-007-9168-7`) was confirmed via Crossref,
and the original-venue citation stands with the reprint noted.

| Status | Count | Meaning |
|---|---:|---|
| verified-doi | 14 | DOI resolved via Crossref; title/year/authors match |
| verified-arxiv | 5 | Verified against the arXiv API |
| verified-dblp | 5 | Matched on DBLP |
| not-found (manual) | 1 | Original not indexed; reprint DOI verified |

## Corrections made

These are the errors the verification round caught, all now fixed in the
docs:

| Document | Error | Correction |
|---|---|---|
| `ONTOLOGY_RESEARCH.md` | `Devillers2025GroundOnto` entry with author "{Various authors}", venue "Information Systems Journal", year 2012 — no such record exists | Real paper: **Fiorini, Abel & Scherer (2013)**, *Information Systems* 38(5), 784–799, doi:10.1016/j.is.2012.11.013; entry renamed `Fiorini2013GroundOnto` |
| `COLLECTIVE_RESEARCH.md` | van der Hoek & Wooldridge ATL-ETL paper dated 2007 (bib key said 2006) | **Studia Logica 75(1), 125–157, 2003** per DBLP; key renamed `VanderHoekWooldridge2003CKT` |
| `ONTOLOGY_RESEARCH.md` | DOLCE paper cited as an LOA-CNR techreport | Actually **EKAW 2002, LNCS 2473, pp. 166–181**, doi:10.1007/3-540-45810-7_18 |
| `CONTROL_FILTER_RESEARCH.md` | Friston et al. "Active Inference and Learning" had no DOI and a bare "et al." | Full author list (Friston, FitzGerald, Rigoli, Schwartenbeck, O'Doherty, Pezzulo), doi:10.1016/j.neubiorev.2016.06.022 (online 2016, issue 2017) |
| `CONTROL_FILTER_RESEARCH.md` | Kalman 1960 had no volume/pages/DOI | *J. Basic Engineering* 82(1), 35–45, doi:10.1115/1.3662552 |
| `COLLECTIVE_RESEARCH.md` | Aumann 1976, Gerbrandy & Groeneveld 1997 had no DOIs | Added 10.1214/aos/1176343654 and 10.1023/A:1008222603071 |
| `COLLECTIVE_RESEARCH.md` | Plaza 1989 unindexed | Added note: reprinted in *Synthese* 169(2), 231–262 (2007), doi:10.1007/s11229-007-9168-7 |
| `DIFFUSION_SPEECH_LOGIC_RESEARCH.md` | Bunt et al. LREC 2020 had no locator | Added pages 549–558 and ACL Anthology ID `2020.lrec-1.69` (DOI registered but absent from Crossref) |
| `DIFFUSION_SPEECH_LOGIC_RESEARCH.md` | DiffuSeq listed as "ICLR 2023" in text but arXiv 2022 in bib | Annotated: arXiv 2210.08933, published at ICLR 2023 |
| `DIFFUSION_SPEECH_LOGIC_RESEARCH.md` | ProsodyLM mentioned in text with no bib entry | Added `qian2025prosodylm` (arXiv:2507.20091) |

## Suspicion overturned

Two entries were flagged as suspicious during extraction and turned out to be
**correct** — a reminder that suspicion is a hypothesis, not a finding:

- `nyga2018grounding`: "PMLR 87 (2018)" looked wrong (v87 sounded like CoRL
  2017), but CoRL **2018** proceedings are exactly PMLR v87, pp. 714–723.
- `milettegagnon2023`: *The Routledge Handbook of Semiosis and the Brain* was
  suspected not to exist; it does (García & Ibáñez, eds.), and the chapter
  has DOI 10.4324/9781003051817-5, pp. 49–65 (online 2022, print 2023).

## Tooling

`tools/verify_citations.py` is rerunnable: it reads `citation_claims.json`,
checks each entry against Crossref/arXiv/DBLP with disk caching and polite
pacing, and rewrites `citation_verification.json`. Books and web resources
are inventoried in the claims file under `_books_manual` and verified by
inspection, consistent with the policy used for the gen-ai-limits write-up
(see its `VERIFICATION.md`).
