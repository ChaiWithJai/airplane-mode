# Backend Parity Ladder

The community should be able to contribute early experiments without
overclaiming them. Use this ladder to classify how strong a backend comparison
is.

| Level | Name | What It Proves | Typical Evidence |
| --- | --- | --- | --- |
| L0 | Runs | Model loads and generates any output on the device/backend. | Screenshot, log, model artifact, device. |
| L1 | Reproducible command | Another person can run the same command and get comparable speed. | Command, versions, hardware, tokens/sec. |
| L2 | Temp-0 smoke parity | Same prompt produces materially similar output against a baseline. | Prompt, sampling, baseline output, candidate output. |
| L3 | Structured contract parity | Backend can satisfy a schema-shaped or parser-valid output contract. | JSON/schema result, parser result, failure cases. |
| L4 | Logit/KL parity | Backend behavior is numerically close to a reference path. | Logit comparison, KL divergence, model/runtime versions. |
| L5 | Workflow parity | End-user workflow succeeds with the same policy, gate, and egress boundary. | Full workflow trace, gate result, redacted output, user story. |

Airplane Mode ultimately cares about L5 because the trust boundary is the
workflow, not the model. The community lab should still welcome L0-L4 because
those levels identify which runtime paths are worth turning into full workflows.

## Where the real evidence already sits

The community and the repo are already spread across this ladder. The ladder
just names what each existing experiment proves — and what it does not.

| Level | Real evidence (sourced) | Honest gap |
| --- | --- | --- |
| L1 | `./run.sh eval` on llama.cpp F16 reproduces `eval/golden-run.txt` (100% recall / 0 leakage). OxiBonsai ~50 tok/s on M3 (`KitaSan` [1501044087405674677]). | cross-machine determinism not re-verified (repo issue). |
| L1 | Browser-GPU spike: phone **loads** the q1 ONNX weight (290,552,764 bytes) + transformers.js from a first-party edge cache. | **no phone-local tokens/sec captured** — load proven, generation not (`browser-gpu-spike-report.md`). |
| L2 | Community offer: `exe_virus` "single benchmark on both models with temp=0… I can do that this weekend" [1494779390490447895]. | not yet run as a shared submission. |
| L3 | `docs/contracts/scrub-response.schema.json` — a strict structured-output contract ready to test backends against. | only exercised on the llama.cpp path. |
| L4 | Community already does it: `Pashmak` "compared the logits KL divergence should be close to 0" [1494786450628153364]. | not standardized across submissions. |
| L5 | Airplane Mode: the default-deny verifier re-scans the exact outbound payload regardless of backend (ADR-014). | only proven on the Mac edge node, not phone-local (ADR-015). |

The point of the lab is to move real experiments **up** this ladder in public —
and to keep every rung honest about its gap.

