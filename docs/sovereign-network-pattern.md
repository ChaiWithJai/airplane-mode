# Sovereign Network Pattern

Airplane Mode is a first-party edge workload, not a SaaS proxy. The phone talks
to infrastructure the adopter controls: a laptop, clinic server, private Wi-Fi,
hotspot, or IT-managed private network. The sensitive path does not require
Cloudflare, ngrok, a vendor tunnel, or any third-party relay.

This is the "hackathon heroes" shape: bring a phone and a laptop, run a
sensitive workflow locally, post only a scrubbed record to Slack, and leave with
a pattern a real organization can extend inside its own environment.

## Rule

```text
raw note -> first-party network -> local edge -> verifier gate -> clean egress
```

The raw note and redaction map stay inside the adopter-controlled boundary. Only
the verifier-approved scrubbed record may leave for the configured sink.

The same rule applies to demo dependencies. For the browser GPU path, cache the
runtime and model artifacts on the first-party edge node before a live walkthrough:

```bash
./run.sh vendor-browser-runtime
./run.sh vendor-browser-model
```

The phone can then fetch `/vendor/transformers.js` and
`/models/onnx-community/Bonsai-1.7B-ONNX/...` from the laptop or managed edge
node instead of pulling the runtime/model from a public CDN during the sensitive
workflow.

The local artifact server supports `HEAD`, `Content-Length`, and byte ranges for
these files. That matters for browser ML runtimes because large ONNX sidecars
should be metadata-probeable and range-fetchable instead of behaving like ad hoc
demo blobs.

For demo proof, `/api/status.browser_requests` exposes a bounded, PHI-free list
of recent browser-surface requests. It is there to show that a real phone on the
first-party network consumed the app/runtime/model artifacts without recording
notes, records, or Slack payloads.

## What Counts As First-Party

Acceptable demo/adopter paths:

- phone and laptop on the same private Wi-Fi;
- phone connected to the laptop through Personal Hotspot;
- clinic-owned Wi-Fi or LAN;
- IT-managed VPN;
- Tailscale, ZeroTier, WireGuard, or equivalent private network when owned and
  governed by the adopter;
- local HTTPS with a first-party or IT-managed certificate for browser
  secure-context behavior.

Non-goals for the sensitive path:

- Cloudflare Tunnel;
- ngrok;
- public reverse proxies;
- hosted app servers that receive raw notes;
- third-party analytics, logs, cache, or inspection of raw notes.

Third-party public services may still be used for **capability-only** checks when
they do not carry notes, records, or trajectories. Example: the Hugging Face
Bonsai WebGPU Space proves a browser runtime can work. It does not become the
Airplane Mode data path.

## End-User Extension Model

| Demo Piece | End-User Equivalent |
| --- | --- |
| Jai's iPhone | care-team phone, tablet, kiosk, or workstation |
| Jai's laptop | clinic laptop, mini PC, edge server, or workstation |
| Personal Hotspot / Wi-Fi | organization-owned LAN or VPN |
| local HTTPS cert | IT-issued certificate or private CA |
| `.airplane/browser-vendor` | approved internal runtime mirror |
| `.airplane/browser-models` | approved internal model artifact mirror |
| `packs/coach-session` | adopter's workflow pack |
| Slack webhook | adopter's approved team channel or internal sink |

They extend the workflow by changing the pack and sink configuration, not by
changing the verifier or moving raw notes into a vendor-controlled cloud.

## Constitution Fit

- **Default-deny egress:** the network path does not bypass the verifier.
- **Model is never trusted raw:** local inference output is still parsed,
  validated, clamped, and re-scanned.
- **Raw input + redaction map never leave the first-party boundary:** the
  private network is part of the adopter's edge, not a third-party relay.
- **Packs are PHI-blind and code-free:** adopters customize workflow data files,
  not executable trust logic.
- **Synthetic data only in the demo:** the template shows the pattern without
  claiming production compliance.

## Why This Is Better Than A Public Tunnel

Public tunnels solve one demo problem and create a trust problem. They make the
URL easy, but they put a third party in the path and force BAA/compliance
questions a hackathon starter should avoid.

First-party networking is slightly more operational, but it is the correct
shape:

- no third-party processor for raw notes;
- easier to explain to cautious adopters;
- compatible with IT-managed VPNs;
- closer to how regulated organizations actually deploy edge workloads;
- still low-friction for hackathons through phone hotspot or same Wi-Fi.

## Browser GPU Implication

WebGPU may require an HTTPS secure context. Solve that with first-party local
HTTPS or IT-managed certificates, not a public tunnel for the full app.

For local testing:

```bash
./run.sh web
./run.sh https-proxy
```

Then open the printed `https://<mac-lan-ip>:8443` URL on the phone after trusting
the local development CA. In an organization, replace that local CA with the
organization's normal private CA or device-management profile.

## Demo Language

Use:

> Bring a phone and a laptop. Put them on the same trusted network or hotspot.
> The phone captures the note, the first-party edge scrubs and gates it, and only
> the scrubbed record posts to Slack.

Use for extension:

> Replace the laptop with your managed edge node, replace the hotspot with your
> private network or VPN, change the pack for your workflow, and keep the same
> verifier gate.
