# DR-2026-06-26: Public Context Graph

Status: Accepted

## Decision

The public repo should foreground the smallest context graph that helps a new
healthcare hackathon user get started, understand the trust boundary, contribute
safely, and extend the pack.

Keep the durable graph:

- runnable code: `crates/`, `shells/`, `packs/`, `gates/`, `scripts/`
- product orientation: `README.md`, `CANON.md`, `docs/bonsai-ecosystem-plan.md`
- demo operation: `docs/demo/`, `docs/contracts/`, `docs/model-setup.md`
- extension path: `docs/extending.md`, `docs/sovereign-network-pattern.md`
- durable decisions: `files/`, `docs/deprecations/decision-records/`

Keep raw sausage local-only:

- root `spike/`
- `docs/deprecations/spikes/`
- `docs/superpowers/`
- raw transcripts such as `full-ctx.md`
- generated run outputs, logs, local certificates, vendored browser/model assets

## Why

The validated strategy is not "show every artifact." It is:

1. Lead with Jai's intro and why this is Bonsai ecosystem work.
2. Show a reliable sovereign demo path.
3. Teach the verifier-gated architecture.
4. Let adopters change packs without touching the core.
5. Let builders revive old experiments through GitOps when they have a real use
   case.

Spikes, raw transcripts, and superseded specs create extraneous cognitive load
for the adopter and false implementation promises for the builder. They can be
nurtured locally, but they should not be part of the default starter graph until
they become a current guide, ADR, or maintained code path.

## Revival

Use `docs/deprecations/gitops-revival-runbook.md` to recover any removed tracked
artifact from history:

```bash
git log -- <old-path>
git show <commit>:<old-path>
git switch -c revive/<pattern>
git restore --source <commit> -- <old-path>
```

Promote revived material only after it has a clear owner, a current claim
boundary, and verification evidence.
