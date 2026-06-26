# Backlog — the loop's work queue

The build is decomposed into milestones (M0–M5), each a file in this directory. Each milestone holds tasks. The loop (see `AGENTS.md`) takes the **lowest-numbered `ready` task whose dependencies are ✅**, does exactly it, runs the gates, checks it off, and commits.

## Milestones (build order is the dependency order)

| Milestone | Goal | Reproduces / proves | Gate to advance |
|---|---|---|---|
| **M0.5** ⚡ | Feasibility spike — verify recall, on-device (R1), determinism | **the business case is buildable on 1.7B** | local-only spike promoted into `eval/golden-run.txt` and the pack eval set |
| **M0** | Author the `coach-session` pack + ~20 golden notes | the truth set exists | golden notes hand-labeled; schema valid |
| **M1** | `airplane-core` (rules + gate + pipeline + pack loader) + ports + **CLI shell** + eval harness | **reproduction front door** — `./run.sh eval` matches `golden-run.txt` | `recall`, `leakage`, `pack-blindness` pass |
| **M2** | Structurer + follow-up generator + Slack `Sink` | the full loop on desktop — `./run.sh demo` | all M1 gates + `reward-lint ★`, `scope-boundary ★` |
| **M3** | **iOS shell** (mlx-swift, Enclave, airplane-mode UI) | on-device proof — **R1 measurement gate** | on-device eval parity + a real A13(-ish) latency number |
| **M4** | **MCP/agent shell** + README + recorded demo | agent-native proof + belief for non-builders | MCP scrub matches CLI scrub on golden notes |
| **M5** *(gated)* | Trajectory recorder + counter (no policy training) | the environment grows, gate-clean | `leakage` on trajectory egress; ADR-013 honored |

## Status legend
`ready` (deps met, take it) · `blocked` (waiting on a dep) · `in-progress` · `done` ✅

## Rules of the queue
- **M1 before M3.** Correctness reproduces on a laptop before the phone is attempted (the whole reproduction-ladder logic).
- One task per loop iteration. No batching milestones.
- A task that needs an undecided design choice → **STOP, ask Jai**, record the decision in the canon, *then* build.
- Every milestone boundary is a **HITL checkpoint** (Jai reviews before the next milestone opens).

Detailed, checkable tasks live in `m0.md … m5.md`. M0 and M1 are fleshed out now; M2–M5 are stubbed and get expanded at their HITL checkpoint (don't draw the owl).
