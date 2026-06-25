# airplane-core (Rust crate) — the portable trust core

The one thing we **own** and review every line of. Built at M1 (`backlog/m1.md`).

**Owns (deterministic, legal-critical, auditable):**
- rules executor — runs a pack's recognizers (regex · context · checksum · deny/allow)
- verifier gate — re-scan output, **default-deny** egress on any residual identifier
- pipeline orchestration — `capture → rules ∪ inference → gate → structured`
- pack loader + schema validation
- output hygiene — `<think>`-strip, JSON-extract, validate, clamp

**Depends only on ports (traits) — never on a platform:**
`InferenceProvider` · `SecureStore` · `Capture` · `Sink`. The **model is an `InferenceProvider` port**, not in the core (ADR-014).

**Never in here:** an HTTP client, mlx-swift, llama.cpp, Slack, file paths, raw PHI handling beyond the enclave port. If a platform detail is leaking into the core, the seam is wrong.

Compiled to: a CLI bin, an MCP bin, and (via UniFFI) the iOS shell. See `docs/superpowers/specs/2026-06-25-portable-core-architecture-design.md`.
