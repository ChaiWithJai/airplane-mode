# Publish Orientation

Demo video:
[Bonsai PHI Scrubber healthcare hackathon demo](https://www.loom.com/share/bf03c0fcc09d40bd811af794d7b7481c)

This page gives collaborators the intent behind the Loom and the safe language to
use when publishing the repo.

## Positioning

Healthcare teams are tired of AI demos that fail at the adoption boundary:

- raw PHI moves into shared tools too early;
- vendors cannot or will not sign a BAA;
- the demo looks impressive but cannot become a local, controlled workflow;
- teams need a template they can adapt at a hackathon or turn into an internal
  business case.

This repo shows a different pattern:

```text
synthetic note -> first-party edge scrub -> verifier gate -> clean Slack record
```

The product story is: capture a synthetic care note, scrub identifiers before
egress, prove the verifier gate sees zero residual identifiers, then post only the
clean care record into Slack.

## Publish-Safe Claim

Use:

> This demo shows a phone-driven PHI-scrubbing workflow over first-party HTTPS:
> a synthetic note is captured in the browser, scrubbed by a local Bonsai-powered
> edge node, verified before egress, and posted to Slack only after the verifier
> gate sees zero residual identifiers.

Also safe:

> Browser GPU and native iPhone inference are the next benchmark paths. The repo
> keeps them visible as extension challenges while the live demo uses the stable
> laptop-edge path.

Avoid:

> This proves raw notes never leave the phone.

Avoid:

> This is HIPAA-compliant or de-identified.

Use "scrubbed", "redacted", "synthetic", "first-party edge", and "verifier-gated".
Do not use "HIPAA-compliant", "de-identified", or "medical device".

## Transcript Orientation

The Loom opens with the adoption problem: healthcare workers see impressive AI
demos, but those demos often fail because PHI is not managed correctly or because
the vendor path requires a BAA the team cannot get on hackathon timelines.

The demo then frames the repository as a template: people can use Codex or Claude
Code to reproduce the workflow, learn the gates, and adapt the pack for their own
hackathon or internal business case.

The walkthrough shows the intended user flow:

1. Choose the runtime path.
2. Dictate or type a synthetic note.
3. Run the scrub.
4. Inspect the identifiers caught.
5. Continue only after the verifier gate reports no residual identifiers.
6. Review the structured clean record.
7. Send the clean record to Slack.

The demo language mentions Browser GPU and iPhone 11 as the direction of travel.
The current published repo should clarify the implementation status: the live web
demo is stable through phone browser + laptop edge over first-party HTTPS, while
Browser GPU/native iPhone inference is the open challenge to benchmark without
weakening the verifier gate.

The close ties the technical point to the ecosystem point: density models like
Bonsai matter when sensitive, regulated workloads need to move closer to the data
instead of forcing every workflow through a centralized cloud service.

## Call To Action

Use this repo if you want to:

- win a healthcare hackathon with a credible privacy boundary;
- build an internal business case for local AI workflows;
- adapt the declarative pack to your own intake, coaching, care navigation, or
  admin workflow;
- contribute a stronger phone-local runtime path while preserving the Rust
  verifier gate.

Start with the README, then run the phone HTTPS runbook:

- [README](../../README.md)
- [Phone HTTPS observability](phone-https-observability.md)
- [How the demo works](how-the-demo-works.md)
- [Reference architecture](reference-architecture.md)
