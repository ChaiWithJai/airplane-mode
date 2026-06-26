# Who Can Now Do What, Locally

### Building Bonsai's community hardware lab from one honest case study

*An evidence package, not a victory lap. Every claim below is tied to a real commit, a real log line, a real Discord message id, or a sourced quote. Where we fell short, we say so — that is the point of the method.*

---

## 0. The one question

A local model only matters when it changes a workflow. Not a leaderboard — a workflow. So the throughline for everything here is a single question, and the community hardware lab exists to answer it over and over, with evidence:

> **Who can now do what, locally, because this model / runtime / hardware path works?**

Benchmarks tell you whether a workflow is *practical*. Case studies tell you why anyone should *care*. The lab is the machine that turns scattered benchmarks into the second thing.

---

## 1. The first case study: Airplane Mode (what we actually tried)

Airplane Mode is a synthetic, gated demo: capture a mental-health coaching note, **scrub the identifiers locally**, and let only a clean record reach a team channel. The model does the hard, ambiguous part — catching a name buried in a sentence — but it is never trusted on its own. The trust boundary is a **verifier gate that lives outside the model** (`ADR-014`: *"the model is a port, never in the core"*).

Here is the real journey, with the logs.

**The scrub works — and the numbers are reproducible.** Rules alone (regex) caught **26%** of identifiers. `rules ∪ Bonsai-1.7B` reached **100% recall, 0 leakage** on the golden set (commit `4e49dbb`). The committed `eval/golden-run.txt` records it at scale: **recall 100.0% (71/71), hard-case recall 100.0% (55/55), leakage 0**, across 21 synthetic notes — a full run is **105 serial Bonsai calls**. A stranger can reproduce it: `./scripts/serve-model.sh && ./run.sh eval`.

**The model is small, so it is honest about being stochastic.** Single-pass Bonsai-1.7B recall was **~80% and stochastic** — it missed a *different* subset of hard names on each seed (commit `ae131da`). We didn't paper over that; we engineered around it: **union across seeded passes** (recall-first), settling at 5 passes.

**Every failure became a harness, not a footnote.** Two real bugs, two real fixes (commit `e231e3d`):
- a **field-swap leak** (the model put a name in the category slot) → fixed by constraining `entity` to an **enum in the grammar** plus a few-shot prompt;
- **over-redaction** of ordinary words → fixed by a **deterministic shape-validator**, `plausible()`, that "drops only impossible identifiers" and is unit-tested.

We also tried **voting** instead of union for precision, measured that it **leaks the hardest short names**, and reverted — because a privacy boundary never trades recall for cosmetics. The honest cost is visible: precision is **51.1%**, **68 over-redactions** on the golden set. We report it.

**This is the reusable pattern, and it is backend-agnostic:**

```text
raw workflow data -> local Bonsai-assisted processing -> verifier gate -> clean egress
```

The model is valuable because it participates in a trustworthy workflow, not because its raw output is trusted. That single design choice is what lets the *same* application logic survive a change of runtime — which is exactly what the community is trying to figure out.

---

## 2. Where it fell short (named, not hidden)

Honesty is a feature here — for adopters it is risk protection, for builders it is craft credibility.

- **We did not prove phone-local generation.** The browser-GPU spike (`docs/browser-gpu-spike-report.md`) wired the Hugging Face WebGPU path — `@huggingface/transformers`, `onnx-community/Bonsai-1.7B-ONNX`, `dtype:"q1"` — behind a verifier-gated finalizer, and proved the phone can **load** the runtime and the **290,552,764-byte** q1 weight from a first-party edge cache. It did **not** capture a single phone-local token/sec. Every measured number is the **Mac edge node** (`/api/scrub` 16.53s; browser-GPU fallback 13.6 / 15.8 / 10.9s, all `gate_pass: true`).
- **"Airplane mode" in the web demo is simulated.** `ADR-015` is explicit: the toggle is **not tamper-evident**; if the radios were truly off, the phone's browser couldn't reach the laptop. The literal radios-off proof is **deferred, not abandoned** — it returns on the native MLX/iOS path. The web demo's honest claim is "the raw note never reaches the cloud (the laptop is the edge node)," not "never leaves the phone."
- **We did not finish a universal backend parity harness.** We got close enough to *name* what one should be (§4 below). MLX-Swift text on a real iPhone is unproven; the reference architecture row "Real iPhone text inference works" reads **"not yet proven."**

The useful lesson: we wanted to prove phone-local inference, and the work forced a **narrower, truer** conclusion — use the available browser-GPU path first, keep the trust harness intact, and don't pretend a WebGPU load proves the full scrub workflow.

---

## 3. The community is already running this experiment

We are not the only ones hitting these walls. The PrismML Discord is full of builders answering the same deployment-reality questions from the other direction — and they are *shipping*.

**Real runtimes and tools the community built:**
- **Trillim / DarkNet** — an optimized C++ inference runtime with a Python package; "Trillim now supports Ternary Bonsai in v0.9.0… optimized CPU paths for both x86 AVX2 and Arm NEON" — *Dark_Sca* [1494809201648730152].
- **OxiBonsai** — *KitaSan*'s pure-Rust engine, ~50 tok/s on M3, Metal + CUDA; "GPU support is already there: Apple Silicon: Full Metal backend… NVIDIA: Native CUDA backend (NVRTC)… For AMD (ROCm), I'm actively working" [1501044087405674677].
- **BonsaiDesk / BonsaiCLI** (*Chaika*), **Paramodus** (*Nicky_P*), **Alenface** (an LM-Studio alternative for old M1 Macs), **Neagari** (gradient-free 1-bit patch search).

**The six questions builders keep asking** (these are the lab's P0 backlog):
1. CPU-only or GPU? — *sbsce* [1489145276882227280]
2. Will ONNX/WebGPU run it in the browser? — *exe_virus* [1489008574267920586], *Pashmak* [1494739831916335265]
3. GPU/AMD support plans? — *Frai Beria* [1500938098018877521]
4. Why is my machine slow? ("3t/s", Windows 100% CPU hang) — [1501441624897618082], [1499578271564693565]
5. Is runtime output 1:1 with local? — *exe_virus* "onnx is not always 1:1 with what you'd get locally" [1494749853551562855]
6. Roadmap: smaller models, future quants? — *wenzani* [1495092914458460381]

**The hardware is already on offer:** a 9070 XT (*DarkenedOrigins* [1501358230704754768]), Strix Halo (*-the architect* [1501154631110230109]), an **FPGA** where "1-bit could simplify matrix multiplications a lot (it becomes XNOR gates + popcount)" (*lolan* [1496424364500058152]), Apple Silicon, a GTX 1060Ti, a 256GB box.

**And the end-user stories are already here** — the reason any of it matters:
- *sbsce*: "if it could run in realtime on two cpu threads needing only 1 GB of RAM, it would be usable to be shipped in games for NPC dialogue" [1489149664325275802].
- *Alensoft*: "Many of my friends and family are curious about trying out Bonsai, but the technical hurdles… still using older Mac M1" [1518925428536901632].
- *chaiwithjai*: "I made real time, interactive bed stories with Bonsai!" [1515019482802946088] and a request to "create a case study for intellectual density for hospitals… pulmonary health and reducing patient discharges that lead to readmissions" [1516444519581745313].

That last builder is me. I'm not proposing to start a UGC loop — I'm already in it. The lab is how we make it a *system* instead of scattered posts.

---

## 4. Turning UGC into a model of understanding

Scattered anecdotes don't compound; structured evidence does. The lab gives the community three shared instruments so an experiment in `#showcase` becomes reference evidence instead of a screenshot that scrolls away.

**A shared benchmark template** (`benchmark-submission-template.yaml`) — every submission answers the same minimum questions: hardware, model artifact, backend, command, tokens/sec, memory, failure mode, and *what end-user workflow you were testing*. The workflow field is mandatory; that's what keeps it from being leaderboard theater.

**A backend parity ladder** — so people can contribute without overclaiming:

| Level | Proves | Who's already here |
|---|---|---|
| L0 Runs | loads + generates anything | most `#showcase` posts |
| L1 Reproducible command | someone else gets comparable speed | our `./run.sh eval`; OxiBonsai's M3 numbers |
| L2 Temp-0 smoke parity | same prompt ≈ same output vs baseline | *exe_virus*: "running a single benchmark on both models with temp=0… I can do that this weekend" [1494779390490447895] |
| L3 Structured-contract parity | satisfies a schema/parser contract | our `scrub-response.schema.json` |
| L4 Logit/KL parity | numerically close to reference | *Pashmak*: "compared the logits KL divergence should be close to 0" [1494786450628153364] |
| L5 Workflow parity | end-user workflow succeeds with the same gate + egress boundary | Airplane Mode's target |

The community already operates at every rung — they just haven't been named. Airplane Mode cares about **L5** because the trust boundary is the workflow, not the model; but L0–L4 are exactly how we learn *which* runtime paths are worth turning into full workflows.

**A channel and a pinned ask** (`#community-hardware-lab`) — bring your hardware, your weird runtime, your failure, your workflow. Incomplete posts welcome; just say what's missing.

That is the model of understanding: not "Bonsai is fast on my machine," but a public, append-only map of **who can now do what, locally** — with the gaps marked.

---

## 5. The method that simplified all of it: means, motivation, opportunity

When we wanted to prove phone-local inference, desire outran feasibility. We used **means / motivation / opportunity** as a filter (`docs/phone-feasibility-research-plan.md`) and it cut the work down to something true:

- **Means** — what can we *measure now*? (A working Rust core, a web shell, an iPhone, the HF WebGPU path.)
- **Motivation** — does this *improve the adoption story*, or only the technical prestige? (Browser-GPU moved the adoption story; a hand-rolled MLX port mostly moved prestige.)
- **Opportunity** — is there an ecosystem path that does most of the runtime work for us? (Safari 26 WebGPU + the HF Bonsai Space made the browser the *timely* opening; native MLX got reclassified as "later," not "abandoned.")

Here is the part PrismML will recognize: **this is their own thesis, applied one layer down.** PrismML's model of understanding is *intelligence density* — the most useful intelligence per unit of size and power. Means/motivation/opportunity is the **adoption-side mirror** of that idea. PrismML proved density at the *model* layer (an 8B that fits ~1.15GB and stays competitive in its class). The community lab proves density at the *workflow* layer: the most adoption per unit of builder effort, on hardware people already own. Same instinct — *do more with less, where the data already is* — measured at a different altitude.

---

## 6. Brand injection #1 — what this solves for builders (why adopt)

*For the inference-ecosystem audience: developers, runtime builders, app builders, hardware testers.*

Bonsai gives you a capability that did not exist at this size before, and the question is what you can now build with it.

- **The means.** A genuinely small, genuinely capable model — sign-only weights {−1, +1} with a shared per-group scale factor — **free under Apache 2.0**, with an 8B that fits ~1.15GB and a 1.7B at ~0.24GB. It runs where you are: CPU (*twoxfh* clocked "40+ tg/s" on an Intel mobile chip without VRAM [1510145798464340100]), the browser (a q1 ONNX weight small enough that "users download the model on first visit and not hate their lives" — *exe_virus* [1494379880085721209]), and the edge.
- **The motivation.** Local unlocks the workflows the cloud structurally can't serve well: **privacy** (sensitive notes never leave the machine), **latency** (NPC dialogue in a game loop), **cost and offline** (personal AI on an old M1), **setup friction removed**. The honest catch you should hear from us, not discover later: a 1-bit model is **stochastic** and not a trust boundary by itself — Qwen3-8B still beats Bonsai-8B on raw MMLU/GSM8K, and "intelligence density" is PrismML's *self-coined* metric. The unlock isn't "it beats GPT." The unlock is "you can put capable inference *inside* a deterministic harness, on hardware you own, for workflows that were impossible to run locally before."
- **The opportunity.** Airplane Mode is the worked example you can fork today: model-as-a-port, a default-deny verifier outside the model, a declarative pack for your own identifiers, and a reproducible eval. You bring the runtime and the vertical; the trust harness is already built. **What can you now run locally that you couldn't reasonably run locally before?** That's the whole pitch — and the lab is where you prove your answer.

---

## 7. Brand injection #2 — the purpose, and the founder arc

*For the people who want to know why this company exists, and why building its ecosystem is worth doing.*

PrismML is a Caltech spinout built on a long, slow bet. CEO **Babak Hassibi**: *"We spent years developing the mathematical theory required to compress a neural network without losing its reasoning capabilities. We see 1-bit not as an endpoint, but as a starting point."* The lineage is real and they say so — BitNet (2017), "The Era of 1-bit LLMs" (2024) — and the claim is specific: an 8B that is **14× smaller, 8× faster, and 5× more energy efficient** on edge hardware while staying competitive in its class.

The timing is not an accident; three forces converged in 2026:
1. **The datacenter power ceiling.** Investor **Amir Salek** (who founded Google's TPU program): *"Power has become the ultimate bottleneck for scaling AI datacenters."* He's betting 1-bit opens *"a new frontier for innovation in computer architecture for AI inference."*
2. **Edge-silicon maturity** — the demos only land now because the hardware crossed a line (≈130 tokens/sec on an iPhone 17 Pro Max at 0.24GB).
3. **The privacy/latency pull** — cloud dependence imposes constraints that on-device dissolves.

And the strategy is a tell: they released 8B / 4B / 1.7B **free under Apache 2.0**, trained on Google v4 TPUs, and emerged from stealth (March 2026) as *"the world's first commercially viable 1-bit large language models."* **Vinod Khosla** framed the whole bet in one line: *"AI's future will not be defined by who can build the largest datacenters. It will be defined by who can deliver the most intelligence per unit of energy and cost."*

When you give the artifact away, the scarce asset becomes the **ecosystem**: the reference integrations, the education, the proof that real people now do real things locally. That is the purpose of the community hardware lab. PrismML proved the model. The lab is how the *world* gets proven around it — honestly, with the gaps marked, one case study at a time.

*(Provenance: Hassibi, Khosla, and Salek quotes are attributable to PrismML's launch materials as captured in our research; "intelligence density" is PrismML's self-coined metric; the whitepaper numbers are PrismML's claims, not independent benchmarks.)*

---

## 8. What I'll do next — building the NYC ecosystem

This package is a sample of the work, not a one-off. Concretely, two motions:

**1. NYC end-user demos, by vertical, that make people show up.** Airplane Mode is the **healthcare** demo (coaching/clinical notes, scrubbed locally, gated egress). The same pattern extends to **finance** (sensitive client/transaction notes that can't paste into shared tools) and to **inference itself** (the runtime/hardware lab as its own draw). The goal is to *inspire people to come to demos and meetups, and to use these patterns at hackathons* — each demo is a fork-able starting point, not a slide.

**2. A Discord → Twitter → newsletter UGC loop.** I already produce end-user case studies in the community (the bedtime-stories app; the pneumonia-readmissions case study). The loop systematizes it: surface the best community experiments from `#community-hardware-lab`, turn them into threads and a newsletter, and feed the attention back into the lab and the demos. **This demo is the prime example of the loop's output** — an honest case study that converts scattered builder energy into reference evidence and into a reason to come to the next meetup.

The throughline never changes, for PrismML or for me:

> Who can now do what, locally, because this works? Find the answer, prove it with logs, name the gaps, and tell the story so the next builder shows up.
