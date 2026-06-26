# ADR-014 — Portable Rust core + ports; Swift is a shell, not the core
**Status:** Accepted (2026-06-25). Resolves CANON.md drift item **D1**. Extends the build-vs-reuse call in `battletest-harness-engineering.md`.

## Context
The canon assumed a "native Swift regex engine" for the rules executor and gate (eng-spec, technical-survey, clinic-pack, component-design, RFC-002 §6). But the demo's job is to **role-model value migration** for application developers, who must be able to apply the pattern to their own vertical *and runtime*. A Swift-only core is locked to iOS — the opposite of a portable, repatriable workload. Separately, `battletest-harness-engineering` had already argued for a Rust core on the trust path (owned, auditable, runs on laptop and phone).

## Decision
Build **`airplane-core`** as a thin **Rust crate** owning the deterministic, legally-critical logic: rules executor, verifier gate (default-deny egress), pipeline orchestration, pack loader + schema validation, and output hygiene (`<think>`-strip, JSON-extract, clamp). It depends only on four **port traits** — `InferenceProvider`, `SecureStore`, `Capture`, `Sink` — via dependency inversion. The **model is a port, never in the core.**

Ship three adapters in v1:
- **iOS** (Swift via UniFFI): mlx-swift inference, Secure Enclave, ASR, airplane-mode UI — the conversion proof.
- **CLI** (Rust bin): llama-server HTTP inference — the reproduction front door (Tier 1).
- **MCP/agent** (Rust bin): thin transport over the same core API — the agent-native proof.

## Alternatives rejected
- **Native Swift core** — locked to iOS; can't reproduce on a laptop or embed in an agent; not a portable workload. (The thing every earlier doc assumed.)
- **Fat Rust core bundling inference** — heavier, harder to audit; iOS still needs mlx-swift for performance, so you maintain two inference paths anyway. Inference stays a port.
- **Minimal core (gate only)** — the recall-determining rules executor would fork per runtime, weakening the reproduction story that is the whole point.

## Consequences
- One auditable trust core; the verifier gate (a legal control) is owned, not a dependency.
- The *identical* recall-critical logic runs across runtimes → a reproduced recall number is meaningful.
- Same artifact serves all three adoption audiences (developer reproduces on laptop, champion shows on phone, agent embeds via MCP).
- **Supersedes** the "native Swift" stack rows in the docs above. Those need a one-line update (mechanical); CANON.md D1 is now resolved.
- Current port contract detail lives in `crates/airplane-core/README.md`,
  `docs/demo/reference-architecture.md`, and `docs/seed/bonsai-ecosystem-brief.md`.
