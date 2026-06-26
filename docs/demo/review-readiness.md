# Review Readiness

This is the current review map for the Beat 1 / issue #1-#12 branch. It separates
verified local behavior from work that still needs credentials, hardware, or a stronger
production implementation.

## Current Live Demo

- Web shell: `http://127.0.0.1:8099`
- Slack preflight: `curl http://127.0.0.1:8099/api/status | jq .slack`
- Current local Slack state: `route: preview`, `configured: false`
- Reason: no `SLACK_WEBHOOK_URL`, no `SLACK_BOT_TOKEN`, and no Keychain
  `slack-bot-token` on this machine.

The app now reports that state on screen 1 before dictation starts. A real Slack post
requires one runtime credential; see `docs/demo/onboarding.md`.

## Verified Commands

These have passed on this branch:

```bash
cargo test --all
cargo clippy --all-targets --all-features -- -D warnings
./run.sh gates
./scripts/smoke-mcp-cli-parity.sh
(cd shells/ios && swift test)
```

The current committed eval target is `eval/golden-run.txt`:

- notes: 21
- recall: 100.0% (71/71)
- hard-case recall: 100.0% (55/55)
- leakage: 0
- precision: 51.1% (71/139 predicted)
- over-redactions: 68

## Issue Coverage

| Issue | Review state | Evidence |
|---|---|---|
| #1 Pack reveal | Covered for demo | Real `recognizers/benefits.json` is wired in `pack.yaml`; `note-21` eval catches `BEN-MH-7741`; `/api/pack-demo` shows five pack surfaces, baseline miss, real-pack catch, and pack eval smoke. |
| #2 Reward-lint | Covered | `Pack::validate_reward_lint`; `./run.sh gates`; web/CLI tests. |
| #3 Scope-boundary | Covered | `Pack::validate_scope_boundary`; `./run.sh gates`; escalation policy in `policy.yaml`. |
| #4 Follow-up/autonomy | MVP covered | Web structurer emits client-paced follow-up and autonomy signals; clinical-risk language surfaces escalation. Not a trained policy. |
| #5 Trajectory recorder | MVP partial | `/api/trajectory` gates de-identified trajectory text and increments a counter only on clean records. Not an encrypted durable `(s,a,r,s')` store yet. |
| #6 Themes quality | Covered for sample/demo | Themes are grounded, junk-filtered, and have deterministic fallback tests. |
| #7 Precision tuning | Improved, still recall-first | Precision tracked; over-redactions reduced while keeping 100% recall / 0 leakage. Remaining extras are privacy-conservative. |
| #8 MCP shell | Covered for smoke/parity | `shells/mcp`; `./run.sh mcp`; `scripts/smoke-mcp-cli-parity.sh` compares CLI/MCP scrubbed text on golden notes. |
| #9 iOS/R1 | Simulator artifact only; hardware blocked | `shells/ios` Swift package proves choreography only; `docs/ios-shell-scaffold.md` documents non-claims. Real mlx-swift/R1 measurement still requires physical device. |
| #10 Slack bot-token routing | Code covered; live credential missing | Web sink supports webhook, bot token, channel map, and Keychain lookup; `/api/send` re-runs verifier gate before posting; local preflight is currently preview mode. |
| #11 Manifest/provenance | Structural MVP partial | Manifest/provenance gates exist; no real Sigstore/Fulcio/Rekor cryptographic verification yet. |
| #12 Determinism | Covered locally | Two full eval runs matched byte-for-byte after stabilizing report fields; golden report now includes precision and 21 notes. |

## Reviewer Notes

- Do not treat the simulator scaffold as M3 completion. It proves only UI choreography.
- Do not treat the current local Slack state as a successful app-originated Slack post.
  The sink is implemented and gated, but this machine lacks a credential.
- The old manual Slack UI post demonstrates the content is usable in Slack, but the app
  path needs `SLACK_WEBHOOK_URL` or `SLACK_BOT_TOKEN` before final demo review.
