# RFC-002 (Final) — Shipping the Airplane Mode Demo
*Status: **Final / Accepted.** Supersedes RFC-001 where they conflict (RFC-001's RL-environment design folds in as deferred M5). This is the single source of truth for building the demo. Builds on Engineering Spec v1 (ADR-001…010) and the battletest.*

---

## 1. Summary

Ship a GitHub-pullable demo of an on-device mental-health-coaching scribe: it de-identifies a session on the phone, posts a clean structured record to Slack, produces a client-paced follow-up, and grows a de-identified RL environment — with the ethical and legal framework enforced as automated gates. Reproducible on any laptop in one command; provable on an iPhone 11 in airplane mode.

## 2. Scope (exactly what ships)

**In:** the airplane-mode loop (capture → scrub → structure → gated egress → Slack), one real follow-up note, the trajectory counter incrementing through the gate, the five-file pack reveal, the eval harness as the reproduction proof, and local/docker parity. Synthetic data only.
**Out (deferred/gated):** RL policy *training* (we grow the environment, train nothing — ADR-013), k8s control plane build, fleet, multiple sinks, certification, second live adopter, voice capture.

## 3. System design layer

Two planes, one loop, config as the interface.

```
config (declarative)  ──drives──>  components (inert without it)
   airplane.yaml ─ loads ─> core (signed, immutable) + model (by hash) + pack
   pack/*        ─ configures ─> scrubber · structurer · sink
   gates/*       ─ admit ─> CI + release gate (the harnessed loop)
   manifest.yaml ─ governs ─> distribution + revocation
```

- **Data plane (on-device):** capture → scrubber (rules ∪ Bonsai) → verifier gate → structurer → sink/follow-up/trajectory. Raw input + redaction map live only in the enclave.
- **Control plane (PHI-free):** signed pack/model registry, eval+gates CI, manifest/revocation, distribution. Reuses CNCF supply chain. **No PHI ever enters it.**
- **The loop:** Author → Verify → Gate → Sign/Release → Distribute → Observe → Scar→Harness.

## 4. Config files (the system design, concrete)

YAML for human-authored declarative config (k8s-ecosystem fit, matches the policy-as-code gates); JSON for tool-exported recognizers (Presidio's native format). *Decision recorded in §6.*

**`airplane.yaml`** — the whole pipeline, declared once:
```yaml
core: "1.0.0"                      # signed, immutable core
model: { name: bonsai-1.7b, sha256: "<hash>" }   # fetched + verified by hash
pack:  coach-session@1.0.0
gates: gates/                     # harnesses that must pass to ship
runtime: mlx-swift                # device; "cpu" for laptop/eval path
```

**`packs/coach-session/pack.yaml`**:
```yaml
apiVersion: airplane/v1
kind: Pack
metadata: { name: coach-session, version: 1.0.0, targetCore: ">=1.0.0 <2.0.0" }
spec:
  recognizers: [recognizers/members.json, recognizers/people.json]
  schema: schema.yaml
  policy: policy.yaml
  sink:   sink.yaml
  eval:   eval/
signature: { keyless: true, rekorLog: "<uuid>" }   # Sigstore/Fulcio + Rekor
```

**`policy.yaml`** — scrub *and* reward (the ethic, as config):
```yaml
deidentification:
  profile: safe-harbor            # all 18 identifiers
  recallThreshold: 0.99           # → recall gate
  onResidual: block               # default-deny egress (Const. IX)
followup:
  cadence: client_controlled      # client owns the interrupt (Const. VIII)
  reward:
    autonomySignals: [commitment_completed, self_initiated, reduced_prompt_need]
    forbiddenTerms:  [engagement, retention, session_count, app_opens]  # → reward lint
  scopeBoundary:
    escalationRequired: true      # → scope-boundary gate
    onClinicalRisk: surface_human_escalation
```

**`schema.yaml`**:
```yaml
record: coach-session
fields:
  - { name: client_pseudonym, type: string, required: true }
  - { name: themes,        type: [string], required: true }
  - { name: commitments,   type: [commitment], required: true }
  - { name: follow_ups,    type: [string] }
  - { name: risk_flags,    type: [string] }
  - { name: next_touch,    type: date }
types:
  commitment: { text: string, due: date, status: "enum[open,done,dropped]" }
```

**`sink.yaml`**:
```yaml
kind: slack
channelMap: { default: "#coach-records" }
credentials: { source: keychain, ref: slack-bot-token }   # sourced, never stored
receives: deidentified-record-only                        # structural: sink never sees PHI
```

**`recognizers/members.json`** (Presidio-style, portable):
```json
{
  "name": "coach_member_id",
  "supported_entity": "MEMBER_ID",
  "patterns": [{ "name": "cm_id", "regex": "\\bCM-\\d{6}\\b", "score": 0.9 }],
  "context": ["member", "client id", "ref"]
}
```

**`eval/golden/note-001.txt`** + **`eval/expected/note-001.json`** (synthetic, fake person):
```
Met with Maria Alvarez (CM-204815) at her place Tuesday. She's the one whose
daughter just started college. Committed to a 10-min morning walk daily.
```
```json
{ "redactions": [
  { "text": "Maria Alvarez", "entity": "PERSON" },
  { "text": "CM-204815", "entity": "MEMBER_ID" },
  { "text": "daughter just started college", "entity": "FAMILY_DETAIL" }
]}
```

**`manifest.yaml`** — signed version manifest + revocation (closes battletest Gap 2):
```yaml
apiVersion: airplane/v1
kind: Manifest
current: { core: 1.0.0, model: bonsai-1.7b@<hash>, pack: coach-session@1.0.0 }
revoked:
  - { pack: coach-session@0.9.0, reason: "recall regression < 0.99" }
signature: { keyless: true, rekorLog: "<uuid>" }
```

**`gates/reward_lint.rego`** — an ethic, as policy-as-code (the beat no one else can show):
```rego
package airplane.gates.reward
# Deny any pack whose follow-up reward references a forbidden engagement term.
deny[msg] {
  t := input.spec.policy.followup.reward.forbiddenTerms[_]
  input.spec.policy.followup.reward.usedSignals[_] == t
  msg := sprintf("reward references forbidden engagement term %q", [t])
}
```

**`run.sh`** — one entrypoint, four verbs:
```
./run.sh eval            # reproduce recall/leakage; match golden-run.txt
./run.sh demo            # full loop on desktop → Slack
./run.sh scrub "<text>"  # scrub arbitrary text
./run.sh gates           # run all harness gates on the current pack
```

## 5. The gates (the harnessed loop, as shipped config)

The full set lives in `gates/`. Each encodes a constitution clause or a legal control and blocks release on failure: **recall**, **leakage**, **pack-blindness**, **reward-lint** ★, **scope-boundary** ★, **signature/provenance**, **manifest/revocation**, **OSCAL-conformance**, **PHI-free-telemetry**. (★ = novel; no k8s/CNCF analog.) These are the demo beats for the k8s path.

## 6. The stack — used, why, rejected (definitive)

| Layer | Used | Why | Rejected |
|---|---|---|---|
| Model | Bonsai 1.7B (1-bit) | Offline on iPhone 11; minimizes regulated-entity exposure | Cloud LLM; 4B/8B (memory) |
| Device runtime | mlx-swift / Locally AI | Native A-series on-device | llama.cpp (desktop); Core ML (conversion) |
| Rules executor | Native Swift regex | Python won't run on iOS; portable packs | Presidio/Philter on-device |
| Recognizer authoring | Presidio (off-device) → JSON | Battle-tested, exports portable defs | Roll-your-own |
| Rule lineage | Philter-derived + Safe Harbor 18 | Highest clinical recall | NLM Scrubber; MITRE MIST |
| Verifier gate | Native re-scan, default-deny | Legal + technical control | Trust-the-model |
| Secure store | Secure Enclave / Keychain | Raw + map never leave hardware | App-sandbox file |
| Sink | Slack Block Kit, pluggable | Demo velocity; swappable | EHR/FHIR-first; Slack-only |
| Config format | YAML (declarative) + JSON (recognizers) | k8s-ecosystem fit; Presidio-native | HCL (less ecosystem fit for k8s demo) |
| Signing | **Keyless Sigstore/Fulcio + Rekor** | No long-lived key to custody (closes Gap 1) | Self-managed CA/HSM key |
| Distribution | Signed OCI + signed manifest + revocation | Tamper-evident, recallable (closes Gap 2) | App-store-only; unsigned pull |
| Gates | OPA (Rego) / Kyverno-JSON | CNCF policy-as-code; CI + admission | Hand-rolled checks |
| Conformance | OSCAL (MHMDA + Safe Harbor) | Machine-checkable controls | Prose compliance |
| Telemetry | Opt-in, de-identified, device-pushed | Fleet health without a backdoor (closes Gap 4) | Pull-based / content telemetry |
| Trajectory store | Enclave-encrypted, on-device | De-identified *and* protected (closes Gap 3) | Plaintext / cloud aggregation |
| Orchestration | None on data path; containers/k8s for control plane only | Workload is fixed to the device | k8s/Nomad on the scrub |

## 7. Resolved battletest gaps (now decisions, not questions)

1. **Signing key custody →** keyless Sigstore/Fulcio + Rekor transparency. No long-lived key to hold.
2. **Manifest + revocation →** signed, monotonically-versioned manifest with a revocation list checked before load.
3. **Trajectory at-rest →** enclave-encrypted on-device; any future pooling gated by the re-identification floor (open).
4. **Fleet observability →** opt-in, de-identified, device-pushed telemetry (version, gate-pass-rate, crashes — never content).

## 8. DevOps surfaces & reproduction

- **Local (`./run.sh`)** — POC / the reproduction front door. Tier 1.
- **Docker / compose** — demo surface; hermetic, OS-independent.
- **k8s (Helm, later/gated)** — control plane only (registry, eval+gates CI, conformance, distribution). Never the scrub.
- **Reproduction acceptance:** a stranger runs `./run.sh eval` and matches the committed `golden-run.txt` (greedy decode, pinned hash/commit). Self-verifying.

## 9. Ship plan (milestones)

- **M0** — author `coach-session` pack + ~20 golden notes. *(The gating dependency.)*
- **M1** — rules executor + Bonsai + verifier gate + eval harness + gates as CLI; Dockerfile. **Reproduction front door.**
- **M2** — structurer + follow-up generator + Slack sink. `./run.sh demo` end-to-end.
- **M3** — iOS app: on-device loop, airplane-mode proof.
- **M4** — record demo; finalize README + five-file reveal.
- **M5 (gated)** — trajectory recorder + counter; no policy training.

Order rule: **M1 before M3** (laptop reproduction before device).

## 10. Open questions (the honest remainder — everything else is decided)

1. **Autonomy-delta measurement** — the reward lint can block engagement terms but can't yet *positively* verify autonomy. Needs a low-burden proxy.
2. **Trajectory re-identification floor** — minimum-cohort / DP threshold before any pooling.
3. **"Is the follow-up actually good?"** — stays human-reviewed; resists automation.

These three are prose, named as such. Everything above them is config or a locked decision.

---

## Canon index (what this finalizes)
Constitution · Scrubber survey · Clinic-pack pattern · Demo spec · Systems characterization · The Floor · Engineering Spec v1 · PRD · RFC-001 · README · Component design · Implementation plan · DevOps-first design · KTHW battletest · Harnessed loop → **all consolidated here for shipping.**

## One-line test
> A builder opens this RFC, creates the config files exactly as written, runs `./run.sh eval` to a green golden-run, and ships M0–M4 without making a single design decision that isn't already recorded here — and the only things left undecided are the three we admit are still prose.
