# GOAL: PrismML Community Hardware Lab Evidence Package

## Objective

Turn PrismML Discord UGC plus Airplane Mode repo context into a practical
community program that converts scattered experiments into reusable evidence,
reference docs, and end-user case studies.

The goal is not to claim the benchmark story is finished. The goal is to make an
honest operating system for learning:

```text
Discord UGC -> tagged evidence -> runtime/hardware experiments -> reference docs
  -> end-user case studies -> adoption proof
```

## Why This Exists

The Discord evidence shows that builders are already trying to answer the same
questions the repo ran into:

- What runs where?
- Does ONNX/WebGPU/browser Bonsai work reliably?
- What is CPU-only performance good enough for?
- Can different backends be compared without hand-waving?
- How should PrismML explain the roadmap without exposing secret sauce?
- Which local workflows become newly practical because Bonsai exists?

Airplane Mode gives the frame for acting on those questions:

- the model is a port;
- the trust boundary stays outside the model;
- runtime claims must be measured;
- gaps should be named, not hidden;
- builder evidence should lead to end-user case studies.

## Primary Outputs

- `data/discord-showcase.messages.json`: parsed and tagged `showcase` messages.
- `data/discord-ideas-and-feedback.messages.json`: parsed and tagged
  `ideas-and-feedback` messages.
- `data/discord-all-tagged.messages.json`: combined message corpus.
- `data/ugc-action-evidence.json`: messages grouped by action area.
- `data/tag-taxonomy.json`: cohort, intent, action-area, and impact definitions.
- `materials/evidence-and-context.md`: evidence map tying UGC to repo context.
- `materials/benchmark-submission-template.yaml`: structured benchmark template.
- `materials/backend-parity-ladder.md`: proof levels for backend comparison.
- `materials/community-hardware-lab-pinned-post.md`: proposed Discord channel
  pinned post.
- `materials/essay-spine.md`: narrative outline for the public essay.

## Program Throughline

Every community experiment should eventually answer:

```text
Who can now do what, locally, because this model/runtime/hardware path works?
```

That keeps the work from becoming leaderboard theater. Benchmarks are evidence;
case studies are the reason the evidence matters.

## Action Areas

### P0: Act Now

- ONNX/WebGPU/browser support and failure modes.
- CPU-only performance and benchmark expectations.
- Runtime parity checks across llama.cpp, MLX, ONNX, WebGPU, and Rust paths.
- Clear docs for what runs where.
- Roadmap and positioning clarity without revealing proprietary methods.

### P1: Turn Into Community Programs

- Community hardware lab channel.
- Benchmark submission workflow.
- Device/runtime matrix.
- Contributor prompts around missing backends and reproducible failures.

### P2: Track As Strategic Research

- Speech-to-speech Bonsai.
- Looping models.
- MoE, spiking, diffusion, FPGA, ASIC, and silicon co-design ideas.

### P3: Acknowledge Without Chasing

- Broad speculative proposals without a measurable path.
- Playful or low-signal comments.
- Interesting but ungrounded future architecture ideas.

## Definition Of Done

This package is useful when it lets Jai or PrismML:

1. Open a single folder and see the tagged UGC corpus.
2. Cite specific Discord messages as evidence.
3. Cite repo context for why each signal matters.
4. Post a clear `#community-hardware-lab` invitation.
5. Ask the community for benchmarks in a shared format.
6. Keep end-user case studies as the throughline.
7. Explain honestly where Airplane Mode got close, where it fell short, and what
   the community can help prove next.

