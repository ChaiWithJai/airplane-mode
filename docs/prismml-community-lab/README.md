# PrismML Community Hardware Lab — evidence package

An honest operating system for turning scattered Bonsai experiments into reusable evidence and end-user case studies. Not a finished benchmark claim — a framework, proven against one real case study (Airplane Mode) and the real PrismML Discord UGC.

The throughline for everything here:

> **Who can now do what, locally, because this model / runtime / hardware path works?**

## What's in the folder

**Read first**
- `materials/essay.md` — the case study, fully brought to life: real logs, the community model of understanding, the two brand injections, and what Jai will do next for PrismML's ecosystem.
- `materials/evidence-and-context.md` — the citeable map: every Discord `message_id` tied to the repo artifact (commit / log / ADR) that gives it meaning.

**The lab instruments (bring your experiment)**
- `materials/benchmark-submission-template.yaml` — the shared submission format, with two **worked examples** filled from real repo numbers (and an honest "what's not measured" entry).
- `materials/backend-parity-ladder.md` — L0–L5, annotated with where the real community + repo evidence already sits.
- `materials/community-hardware-lab-pinned-post.md` — the proposed `#community-hardware-lab` pinned invitation.

**Reusable brand**
- `materials/brand-injections.md` — the two PrismML brand injections (builder adoption · purpose/founder arc) distilled for the Discord → Twitter → newsletter loop.

**The corpus**
- `data/ugc-action-evidence.json` — tagged Discord UGC grouped by action area + impact level.
- `data/discord-{showcase,ideas-and-feedback,all-tagged}.messages.json` — the raw tagged messages.
- `data/tag-taxonomy.json` — cohort / intent / action-area / impact definitions.

`GOAL.md` is the spec this package fulfills.

## How to use it (Definition of Done)

1. Open this folder → see the tagged UGC corpus (`data/`).
2. Cite specific Discord messages by `message_id` (via `evidence-and-context.md`).
3. Cite repo context for why each signal matters (same file).
4. Post the `#community-hardware-lab` invitation.
5. Ask the community for benchmarks in the shared format.
6. Keep end-user case studies as the throughline (`essay.md`).
7. Be honest about where Airplane Mode got close, where it fell short, and what the community can prove next.

## The honesty envelope (non-negotiable)

Per `docs/positioning/cncf-end-user-and-inference-ecosystem.md`: say **scrubbed / redacted**, never legally-conclusive "de-identified"; do not say "HIPAA-compliant"; examples are **synthetic-only**; the web demo's "device" is the **laptop as edge node** (ADR-015); PrismML's "intelligence density" is **self-coined** and loses on raw benchmarks; founder quotes are attributed and provenance-flagged. Limits are not caveats to hide — for adopters they are risk protection, for builders they are craft credibility.
