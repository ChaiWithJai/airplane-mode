# packs/ — declarative, PHI-blind extension units

A **pack** is how a practice (or vertical, or adopter) makes the demo theirs **without forking the core**. Five declarative files, no executable code. Authored at M0 (`backlog/m0.md`).

```
coach-session/                 # the reference pack every adopter copies
├── pack.yaml                  # name, version, targetCore, signature ref
├── recognizers/*.json         # identifiers: regex + context + checksum + lists (Presidio-style)
├── schema.yaml                # the record shape
├── policy.yaml                # de-id profile + recall threshold + the autonomy reward block
├── sink.yaml                  # where clean records go (credential SOURCED, never stored)
└── eval/golden|expected/      # ~20 synthetic golden notes + expected redactions
```

**A pack can:** redefine what an identifier is, the record schema, the policy, and the sink.
**A pack can never:** see raw PHI, read the redaction map, alter the verifier, or ship code.

That boundary is what makes packs safe to write and safe to share — and it's the "make it yours" mechanism an adopter recognizes. Config format is **YAML + JSON, not HCL** (CANON.md D2 resolved; see `files/rfc-002-final-ship.md` §4 for the canonical shapes).
