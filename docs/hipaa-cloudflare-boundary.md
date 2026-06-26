# HIPAA, Cloudflare HTTPS, And This Demo

Question: can we make the phone/WebGPU path HIPAA compliant by putting it behind
Cloudflare HTTPS?

Short answer: **No, not by HTTPS alone.** HTTPS is a transport safeguard. HIPAA
requires a broader compliance posture, and any cloud service provider that
creates, receives, maintains, or transmits ePHI for a covered entity or business
associate generally needs a Business Associate Agreement (BAA) and appropriate
Security Rule safeguards.

This repo should keep saying:

- synthetic-only;
- scrubbed/redacted, not legally conclusive de-identified;
- not HIPAA compliant;
- no real patient/member/session data.

## What Cloudflare HTTPS Can Do For This Project

Cloudflare HTTPS can help with **non-PHI capability testing**:

- prove an iPhone browser exposes WebGPU in a secure context;
- check whether the Hugging Face Bonsai/WebGPU path is plausible;
- avoid the local-LAN HTTP secure-context problem for a browser GPU probe.

However, because we cannot assume a Cloudflare BAA is available, Cloudflare must
not become part of the Airplane Mode sensitive workflow. Prefer local HTTPS for
our own app and use external services only to test generic browser capability.

If a tunnel is used at all, it must be restricted to the separate
capability-only server:

```bash
./scripts/serve-gpu-probe.sh
cloudflared tunnel --url http://127.0.0.1:8098
```

That server serves only:

- `/gpu`
- `/api/client-capability`
- `/api/status`

It does **not** serve:

- `/api/scrub`
- `/api/send`
- `/api/trajectory`
- the raw-note demo UI

So exposing the GPU probe through a tunnel does not move raw notes, PHI, Slack
records, or trajectory data through Cloudflare. Still, the default project path
should be local HTTPS, not a public tunnel.

## What Cloudflare HTTPS Must Not Do In This Demo

Do **not** put the full Airplane Mode web app behind a public tunnel for notes,
dictation, `/api/scrub`, `/api/send`, or `/api/trajectory`.

That would send the raw-note workflow or clean-record workflow through a cloud
service provider. For synthetic demos, it would still muddy the story. For real
PHI, it is out of bounds unless there is a proper HIPAA program and a signed BAA
covering the exact services. If we cannot sign that BAA, the answer is simply:
do not put PHI there.

## How We Get Past The WebGPU HTTPS Problem

Use **local HTTPS or an IT-managed private network**, not Cloudflare, for our app:

```bash
./run.sh web
./run.sh https-proxy
```

The proxy serves the existing local app over `https://<mac-lan-ip>:8443` and
keeps traffic on the local network. It generates a local development CA in:

```text
.airplane/certs/airplane-local-ca.pem
```

Install/trust that CA on the iPhone before testing WebGPU secure-context
behavior. This solves the browser secure-context problem without introducing a
third-party transport into the note path.

This still does **not** make the project HIPAA compliant. It only removes
Cloudflare from the sensitive data path.

In a real organization, the analog is an internal hostname and IT-managed
certificate on a private LAN/VPN. The pattern is not "Jai's laptop forever"; it
is a first-party edge node under the adopter's control. See
[`sovereign-network-pattern.md`](sovereign-network-pattern.md).

## Why HTTPS Is Not HIPAA Compliance

HIPAA is not one control. It is a set of privacy, security, breach notification,
contractual, and operational obligations.

For a cloud path that handles ePHI, the minimum questions include:

- Is the operator a covered entity, business associate, or subcontractor?
- Is Cloudflare creating, receiving, maintaining, or transmitting ePHI?
- Is there a signed BAA covering the exact Cloudflare services used?
- Are logs, analytics, cache, WAF inspection, Workers, tunnels, and support
  access configured in scope for that BAA and risk analysis?
- Are access controls, audit controls, integrity controls, transmission security,
  incident response, retention, and workforce procedures defined?
- Is the app itself designed to avoid unnecessary PHI collection and disclosure?

HTTPS helps with transmission security, but it does not answer those questions.

## Structural Rule For This Repo

Use two separate surfaces:

| Surface | URL | May Be Publicly Tunneled? | Why |
| --- | --- | --- | --- |
| GPU capability probe | `http://127.0.0.1:8098/gpu` | Only if needed, capability-only | no notes, no Slack, no trajectories |
| Full scrub demo | `http://127.0.0.1:8099/` or LAN URL | No public tunnel | captures notes and calls scrub/send endpoints |
| Full scrub demo over local TLS | `https://<mac-lan-ip>:8443/` | No public tunnel | secure context without third-party transport |

This avoids the recurring failure mode: needing HTTPS for WebGPU and accidentally
putting the sensitive workflow through a third party.

## Production Path If Real PHI Ever Enters Scope

Before real PHI:

1. Get legal/compliance review.
2. Determine covered entity / business associate status.
3. Execute BAAs with every service provider that creates, receives, maintains, or
   transmits ePHI.
4. Confirm the exact Cloudflare products used are covered and configured
   appropriately.
5. Disable or scope logs/caches/inspection that could retain PHI outside the
   intended boundary.
6. Add authentication, authorization, audit logging, incident response, retention
   policy, and risk analysis.
7. Run a security review of the application itself.

Until then, the safe statement is:

> Airplane Mode is a synthetic, verifier-gated reference architecture. Cloudflare
> is not in the sensitive workflow. Browser secure-context testing should use
> local HTTPS for the app, and optional public capability probes must never carry
> notes, Slack records, or trajectories.

## Sources

- HHS cloud computing guidance: <https://www.hhs.gov/hipaa/for-professionals/special-topics/health-information-technology/cloud-computing/index.html>
- HHS cloud service provider FAQ: <https://www.hhs.gov/hipaa/for-professionals/faq/2075/may-a-hipaa-covered-entity-or-business-associate-use-cloud-service-to-store-or-process-ephi/index.html>
- HHS business associate contract guidance: <https://www.hhs.gov/hipaa/for-professionals/covered-entities/sample-business-associate-agreement-provisions/index.html>
- Cloudflare privacy/compliance resources: <https://www.cloudflare.com/trust-hub/privacy-and-data-protection/>
