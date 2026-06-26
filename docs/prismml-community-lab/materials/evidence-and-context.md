# Evidence And Context Map

Ties the tagged Discord UGC to the **real repo journey** (commits, logs, ADRs) and to the materials this package produces. Every UGC row cites a real `message_id`; every repo row cites a real commit, file, or number. Nothing here is hand-waved — that is the standard.

## Source data

- `data/discord-showcase.messages.json` — builders posting runtimes, wrappers, GUIs, hardware wins, app demos.
- `data/discord-ideas-and-feedback.messages.json` — questions about what runs where, ONNX/WebGPU, CPU viability, parity, roadmap.
- `data/ugc-action-evidence.json` — the same messages grouped by action area + impact level.
- `data/tag-taxonomy.json` — cohort / intent / action-area / impact definitions.

## Repo context (real artifacts)

- `eval/golden-run.txt` — the reproducible result: recall 100.0% (71/71), 0 leakage, precision 51.1%, 68 over-redactions, 5 seeded passes, 21 notes.
- `docs/browser-gpu-spike-report.md` — the browser-GPU/WebGPU spike: what was loaded, what was measured (Mac-edge), what was **not** (phone-local tokens/sec).
- `docs/phone-feasibility-research-plan.md` — means/motivation/opportunity applied as a feasibility filter, with kill criteria.
- `docs/webgpu-vs-mlx.md` — "Browser GPU first … Native MLX Swift second."
- `files/adr-014-portable-rust-core.md` — model-as-port; the trust core is platform-free Rust.
- `files/adr-015-airplane-mode-simulated-in-web-demo.md` — the web "airplane mode" is simulated, not tamper-evident.
- `docs/contracts/scrub-response.schema.json` — the structured span contract (redaction summaries only; raw text stays local).
- `docs/positioning/prismml-partner-brief.md`, `docs/positioning/cncf-end-user-and-inference-ecosystem.md` — adopter vs inference-ecosystem registers and the substantiation envelope.

---

## Action areas — UGC ↔ repo ↔ material

### ONNX / WebGPU / browser support · P0
**UGC:** *exe_virus* "1.7B at 1bit finally gets LLMs into the can load on a webpage size" [1489008574267920586]; "at 70MB… download the model on first visit and not hate their lives. 270MB is still a tad heavy" [1494379880085721209]. *Pashmak* "ONNX still has some limitations… probably mix of 2 and 4 bits" [1494751680623804587].
**Repo:** the spike wired `onnx-community/Bonsai-1.7B-ONNX` `dtype:"q1"` through `@huggingface/transformers`; cached the **290,552,764-byte** q1 weight + **431,974-byte** transformers.js on a first-party edge; bounded load to 120s / generation to 60s. Proved the phone can **load** the runtime; did **not** prove phone-local generation (`browser-gpu-spike-report.md`). Real failure modes captured: Safari local-HTTP secure-context, `devicectl` error 10005 (Developer Mode off), `phone-observe` 12s timeout.
**Material:** browser runtime field guide; failure taxonomy; cache/offline checklist (lab template `runtime.cache_or_offline_behavior`).

### CPU-only performance · P0
**UGC:** *twoxfh* "on cpu an intel mobile without vram you can get 40+ tg/s vs 10-20tg/s for a Qwen3 1.7b equivalent" [1510145798464340100]. *Frai Beria* "generating tokens incredibly slow, 3t/s" [1501441624897618082] and "on Windows its causing my CPU to go to 100% use" [1499578271564693565]. *KitaSan* root-caused it: "v0.1.3 which fixes the Windows 100% CPU hang… CPU feature detection was misdetecting SIMD… on Windows AMD CPUs" [1500937707667456002]. *sbsce* set the bar: "realtime on two cpu threads needing only 1 GB of RAM… shipped in games for NPC dialogue" [1489149664325275802].
**Repo:** the reproducibility stance makes the command + hardware part of the proof (`docs/model-setup.md`, `eval/golden-run.txt`). The eval is **105 serial Bonsai calls** — a real throughput workload to benchmark against.
**Material:** the benchmark template + a "good-enough-for-workflow-X" threshold table (NPC dialogue: realtime, 2 threads, 1GB).

### Runtime parity · P0
**UGC:** *exe_virus* "onnx is not always 1:1 with what you'd get locally" [1494749853551562855] and the offer "running a single benchmark on both models with temp=0 and ensure they're identical… I can do that this weekend" [1494779390490447895]. *Pashmak* "ran the model in fp16 and in packed format and compared the logits KL divergence should be close to 0" [1494786450628153364].
**Repo:** ADR-014 makes inference a port; the core **expects untrusted model output** and validates outside the model (grammar enum, `plausible()`, default-deny gate). The structured contract (`scrub-response.schema.json`) is a ready L3 parity target.
**Material:** the backend parity ladder (L2 temp-0 smoke → L4 logit/KL) — the community already operates at L2 and L4.

### What runs where · P0/P1
**UGC:** shipped runtimes — Trillim/DarkNet (*Dark_Sca* "Trillim now supports Ternary Bonsai in v0.9.0… AVX2 and Arm NEON" [1494809201648730152]), OxiBonsai (*KitaSan* "Apple Silicon: Full Metal… NVIDIA: Native CUDA (NVRTC)… AMD (ROCm) actively working" [1501044087405674677]), BonsaiDesk/BonsaiCLI (Chaika), Paramodus (Nicky_P), Alenface (old-M1 LM-Studio alt).
**Repo:** positioning docs separate **builder proof** from **adopter proof**; the partner brief names reference integrations + education as the missing layer.
**Material:** a maintained runtime/device matrix + setup-path-by-audience table; known-good and known-broken paths.

### Roadmap / positioning clarity · P1
**UGC:** *wenzani* "are there any plans to explain further on how Bonsai was made?… This is the future of local AI on consumer devices" [1495092914458460381]. *exe_virus* on ONNX/WASM strategy [1489008574267920586]. *AndrewSong* "trying to figure out if they are a competitor or ally" [1488757411551379566].
**Repo:** honest guardrails already written (`bonsai-ecosystem-brief.md`, `cncf-end-user-and-inference-ecosystem.md`): intelligence density is useful but **self-coined**; Qwen3-8B beats Bonsai-8B on raw benchmarks; "1-bit" is sign-only weights; say **scrubbed/redacted**, not "de-identified"; no "HIPAA-compliant."
**Material:** a public FAQ + "what we can say without the secret sauce" explainer + roadmap-safe contributor prompts.

### Community hardware lab · P0/P1
**UGC:** hardware on offer — 9070 XT (*DarkenedOrigins* [1501358230704754768]), Strix Halo (*-the architect* [1501154631110230109]), FPGA "XNOR gates + popcount" (*lolan* [1496424364500058152]), edge M.2 cards "the 8b ternary model is 1.6gigs… could easily fit" (*Fʟʏɴɴ* [1498170199986278510]), M3 Metal (*KitaSan*), GTX 1060Ti (*Frai Beria*).
**Repo:** the browser-GPU spike already turned runtime uncertainty into a measured path; the case-study docs keep experiments tied to adoption proof.
**Material:** the `#community-hardware-lab` channel, pinned post, benchmark template, parity ladder, and the case-study conversion pipeline.

### End-user case studies · P0 (the throughline)
**UGC:** *chaiwithjai* "I made real time, interactive bed stories with Bonsai!" [1515019482802946088] and "create a case study for intellectual density for hospitals… pulmonary health and reducing patient discharges that lead to readmissions" [1516444519581745313]. *Alensoft* "friends and family are curious about trying out Bonsai, but the technical hurdles… older Mac M1" [1518925428536901632].
**Repo:** Airplane Mode IS the first end-user case study (synthetic healthcare coaching, scrubbed locally, gated egress) — the worked example the rest of the lab points back to.
**Material:** the essay (`essay.md`) and the case-study conversion pipeline: every L0–L4 benchmark should eventually answer "who can now do what, locally."

---

## How to use this map

1. Open this folder → the tagged UGC corpus is in `data/`.
2. Cite a specific message by `message_id` (above), and the repo artifact that gives it meaning.
3. Post the `#community-hardware-lab` invitation (`community-hardware-lab-pinned-post.md`).
4. Ask for benchmarks in the shared format (`benchmark-submission-template.yaml`).
5. Keep end-user case studies as the throughline; convert benchmarks into the essay's narrative.
6. Be honest about where Airplane Mode got close (100% scrub recall, reproducible eval, browser load) and where it fell short (no phone-local generation; simulated airplane mode; unfinished parity harness).
