# Third-party notices and provenance boundaries

This file records material that MOWGLI uses, cites, or describes without
relicensing it. It is intentionally conservative: an interface, algorithmic
idea, citation, or source manifest is not by itself a copy of the upstream
work.

## Mercury

The `.m` modules are original MOWGLI source written for the Mercury language.
They use Mercury syntax and standard-library APIs but do not include copied
Mercury compiler or standard-library source. The Mercury distribution has its
own licensing notices, including the compiler repository's `COPYING` file.
Anyone redistributing a Mercury compiler, runtime, or bundled generated code
must inspect and preserve those upstream notices separately.

- Project: <https://mercurylang.org/>
- Source repository: <https://github.com/Mercury-Language/mercury>
- Upstream license record: `COPYING` in the Mercury source distribution

## Research literature

The project discusses and implements small, independently written prototypes
inspired by published work on probabilistic logic programming, semirings,
model checking, modal logic, event calculus, Bayesian filtering, semiotics,
and related areas. The project does not claim ownership of those theories or
of the authors' publications. Citations and bibliographies remain governed by
applicable copyright and quotation rules.

## Film media

The local film files used for annotation are deliberately outside Git. Their
presence on a developer's workstation does not grant MOWGLI permission to
redistribute them. An annotation, timestamp, hash, or source URL is not a
license for the underlying audiovisual work.

The current local sources are recorded in the film-source manifest on the
film-relations branch. The Blender Studio entries identify *Coffee Run* and
*Spring* as CC BY 4.0 sources with their required attribution. Preserve the
source URL, creator attribution, and license when distributing annotations or
other material that relies on those works.

*Meshes of the Afternoon* is treated conservatively: the particular local
encode, restoration, soundtrack, subtitles, and territory may have separate
rights even where the underlying historical film is described as public
domain in some jurisdictions. Do not infer a blanket distribution license
from the source manifest.

## Python and local tools

The current prototype uses Python's standard library for its checked-in
adapters and tests. Optional local experiments involving LLaDA, transformers,
speechbrain, faster-whisper, librosa, datasets, soundfile, or other projects
must retain their upstream licenses and notices if they are later vendored or
added as dependencies.

## Scope rule

A file or directory added later with its own license or notice remains under
that license. When in doubt, add a specific entry here and keep the material
separate rather than assuming the repository-wide category policy applies.
