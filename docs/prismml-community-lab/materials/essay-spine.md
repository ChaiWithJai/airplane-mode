# Essay Spine

Working title:

> From Discord Chatter To Reference Evidence: Building A Community Hardware Lab
> For Bonsai

## 1. Start With The End User

Local inference only matters when it changes a workflow: privacy, latency, cost,
offline use, setup friction, or hardware access.

Benchmarks answer whether the workflow is practical. Case studies answer why
anyone should care.

## 2. Show The Repo As The First Case Study

Airplane Mode tried to move a sensitive Bonsai workflow toward the edge while
keeping a verifier gate outside the model.

The important pattern:

```text
raw workflow data -> local Bonsai-assisted processing -> verifier gate -> clean egress
```

The model is valuable because it participates in a trustworthy workflow, not
because its raw output is trusted.

## 3. Admit What Fell Short

We did not prove every backend.

We did not finish a universal backend parity harness.

We did not prove that the Hugging Face WebGPU demo proves Airplane Mode's full
PHI-scrub workflow.

We learned that browser GPU was the densest next move, while native MLX remained
a later proof path.

## 4. Name The Reusable Method

Use means, motivation, opportunity:

- Means: what can we measure now?
- Motivation: why does the result matter to adoption?
- Opportunity: what ecosystem opening makes the timing right?

This keeps the work grounded in practical evidence rather than wishcasting.

## 5. Turn UGC Into A System

The community is already posting evidence:

- runtime wrappers;
- browser experiments;
- CPU and GPU results;
- failure modes;
- hardware offers;
- app demos;
- end-user proxy stories.

Give that energy a shared template, parity ladder, and channel.

## 6. Call Builders In

Bring your hardware. Bring your runtime. Bring your failure. Bring your end-user
workflow.

The goal is reference status, not a one-off benchmark.

