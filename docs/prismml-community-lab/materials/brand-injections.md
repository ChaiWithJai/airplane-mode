# Two Brand Injections (reusable)

Sharp, sourced distillations of the two brand sections in `essay.md`, formatted for reuse in the Discord → Twitter → newsletter loop and in partner conversations. Honor the substantiation envelope (`docs/positioning/cncf-end-user-and-inference-ecosystem.md`): say **scrubbed/redacted**, not "de-identified"; no "HIPAA-compliant"; synthetic-only; quotes attributed.

---

## Injection 1 — For builders: what problem this solves (so you adopt)

**One line:** *Bonsai lets you put capable inference inside a deterministic harness, on hardware you already own, for workflows that were impossible to run locally before.*

**The means / motivation / opportunity, in builder terms:**
- **Means** — a genuinely small, genuinely capable model, **free under Apache 2.0**: sign-only weights {−1, +1}, an 8B at ~1.15GB, a 1.7B at ~0.24GB. It runs on CPU (community-clocked "40+ tg/s" on an Intel mobile chip, no VRAM — *twoxfh* [1510145798464340100]), in the browser (a q1 ONNX weight small enough to "load on a webpage" — *exe_virus* [1489008574267920586]), and at the edge.
- **Motivation** — local unlocks what cloud can't serve well: privacy, latency (game-loop NPC dialogue), cost, offline, zero setup. Honest catch: a 1-bit model is **stochastic** and not a trust boundary by itself (Qwen3-8B still beats Bonsai-8B on raw MMLU/GSM8K; "intelligence density" is PrismML's self-coined metric). The unlock is the *harness around it*, not a benchmark win.
- **Opportunity** — fork the worked example today: model-as-a-port, a default-deny verifier **outside** the model, a declarative pack for your identifiers, a reproducible eval (`./run.sh eval` → 100% scrub recall, 0 leakage). You bring the runtime and the vertical; the trust harness is built.

**Thread skeleton (for X):**
1. "1-bit Bonsai isn't 'GPT but smaller.' It's the first model small enough to put *inside a real trust harness* on your own hardware. Here's a working PHI-scrub demo that proves it ↓"
2. rules alone: 26% recall. rules ∪ Bonsai-1.7B: 100% recall, 0 leakage. reproducible: `./run.sh eval`.
3. the trick: the model is a *port*; a default-deny verifier re-scans the exact outbound payload. swap the runtime, the trust boundary holds.
4. honest gaps: single-pass is ~80% & stochastic (we union seeded passes); precision 51% (recall-first); phone-local generation not yet proven.
5. "what can *you* now run locally that you couldn't before? bring it to #community-hardware-lab."

---

## Injection 2 — The purpose, and the founder arc

**The paragraph (for a newsletter / partner intro):**
PrismML is a Caltech spinout on a long, slow bet: that you can compress a network to 1-bit *without* losing its reasoning. CEO Babak Hassibi puts the time horizon plainly — *"We spent years developing the mathematical theory required to compress a neural network without losing its reasoning capabilities. We see 1-bit not as an endpoint, but as a starting point."* The timing is the tell: the datacenter power ceiling (investor Amir Salek: *"Power has become the ultimate bottleneck for scaling AI datacenters"*), edge silicon crossing a line (~130 tok/s on an iPhone 17 Pro Max at 0.24GB), and the privacy/latency pull that on-device dissolves. So they gave the artifact away — 8B/4B/1.7B **free under Apache 2.0** — because when the model is free, the scarce asset is the **ecosystem**. Vinod Khosla's framing is the whole bet: *"AI's future will not be defined by who can build the largest datacenters. It will be defined by who can deliver the most intelligence per unit of energy and cost."* The community hardware lab is how that ecosystem gets proven — honestly, one local workflow at a time.

**Quote bank (attributed; use verbatim):**
- Hassibi (CEO): "1-bit not as an endpoint, but a starting point."
- Khosla (Khosla Ventures): "the most intelligence per unit of energy and cost."
- Salek (Tracker/Cerberus, ex-Google TPU): "Power has become the ultimate bottleneck for scaling AI datacenters" · "a new frontier for innovation in computer architecture for AI inference."
- Whitepaper (PrismML's claims): "each weight is represented only by its sign {−1, +1}, with a shared scale factor" · "14× smaller, 8× faster, and 5× more energy efficient on edge hardware" · "the world's first commercially viable 1-bit large language models."

**Do-not-overclaim:** "intelligence density" is self-coined and loses on raw benchmarks; "1-bit" is sign-only weights (lineage: BitNet 2017, "Era of 1-bit LLMs" 2024); these are PrismML's claims, not independent results. Provenance: quotes captured from PrismML launch materials via our research (`full-ctx.md`); verify against the original release before print.

---

## The throughline both injections serve

> Who can now do what, locally, because this works?

Injection 1 is the answer for the builder who will fork it. Injection 2 is the reason the company — and the ecosystem around it — is worth building. The community hardware lab is where the two meet: builder evidence becomes adopter proof, and adopter proof becomes the next builder's reason to show up.
