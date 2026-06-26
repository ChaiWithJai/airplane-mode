# Positioning: CNCF End User And Inference Ecosystem

Airplane Mode is one artifact with two audiences. The audiences need opposite
registers, and the docs should weight them roughly **70/30 toward the end user**:
lead with the adopter's job and safety boundary, then expose the builder-grade
mechanism for people who want to fork or extend the work.

## CNCF Taxonomy

Use CNCF's distinction precisely:

- **End user:** an organization that uses the technology internally and does not
  sell it. In this repo, that means a clinic, coaching practice, payer team, or
  community-health org that wants to stop pasting sensitive notes into shared
  tools.
- **Inference ecosystem:** the developers, contributors, and vendors who build,
  extend, package, or sell around the stack. In this repo, that means the Rust,
  llama.cpp, MLX, edge-inference, and harness-engineering communities.

The adopter's currency is a journey report, runbook, and reference architecture.
The builder's currency is clean mechanism, reproducibility, named tradeoffs, and
credible extension points.

## Opposite Registers

| Audience | Lead With | Hide / Expose | Proof | CTA |
| --- | --- | --- | --- | --- |
| CNCF-style end user | job done, risk removed, low lift | hide Rust, 1-bit details, and ports unless needed | runbook, safety boundary, synthetic worked examples, case-study shape | run it on a synthetic workflow and change the pack |
| Inference ecosystem | architecture, novelty, and tradeoffs | expose the internals | code, ports, eval harness, 74-point recall lift, named gaps | fork it, extend the port, close the `mlx-swift` text gap |

## End-User Register

Use outcome language:

> Capture a session note on your own hardware, scrub identifiers before anything
> leaves, and send only a clean record to your team channel. Change the pack to
> fit your workflow; do not touch the core.

This audience needs confidence that the workflow is safe to evaluate, not a tour
of the engine. Keep the language concrete:

- raw notes stay local;
- the verifier blocks egress by default;
- only the scrubbed record reaches Slack;
- packs adapt the workflow without changing the core;
- examples are synthetic-only.

Stay inside the substantiation envelope:

- Say **scrubbed** or **redacted**, not legally conclusive "de-identified."
- Do not say "HIPAA-compliant."
- Say synthetic-only, not a medical device, and current web demo uses the Mac as
  the edge node.
- Treat limits as adoption risk protection, not caveats to hide.

## Builder Register

Use mechanism language:

> A small stochastic model is not enough for a trust boundary. The reference
> architecture makes it useful by putting it inside a deterministic harness:
> grammar-shaped output, recall-first union, output hygiene, and a default-deny
> verifier that re-scans the exact outbound payload.

For builders, named gaps create credibility:

- The real iPhone 11/A13 `mlx-swift` text path is not proven yet.
- The iOS package is simulator choreography plus backend-DTO interoperability.
- The Swift simulator now models `TextInferenceProviding.complete(...)` returning
  raw JSON spans before local scrub/gate, so the future MLX adapter has a precise
  replacement point.
- The model is a port; the trust core remains platform-free Rust.
- Packs are declarative; the verifier is not pack-editable.

## Same Honesty, Two Functions

Do not write two different honesties. Write one honest boundary and let it do
different work:

- To the adopter, limits are **risk protection**: they show exactly what is safe
  to evaluate and what is not being claimed.
- To the builder, limits are **craft credibility**: they name the overfit,
  simulator, runtime, and device-measurement gaps before a serious contributor
  has to point them out.

## Bridge Artifact

The bridge is a CNCF-style reference architecture:

```text
capture -> scrub -> gate -> record -> queue -> clean egress
              model is a port
              pack is declarative
              gate is default-deny
```

That artifact is legible to end users as a blueprint they can adopt, and legible
to builders as a structure they can extend. Builders make it a reference by
forking and closing the adapter gaps. End users make it proof by running it on
synthetic versions of their own workflows and producing journey-report evidence.
