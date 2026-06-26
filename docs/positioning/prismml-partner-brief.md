# The Briefcase: Jai x PrismML

Show the repo first. This document is the map after the proof is already on the
table: what I see from the outside, what I have already built, and the 90-day
plan I would run to help make Bonsai a reference point for edge inference.

This is written in the spirit of Ramit Sethi's Briefcase Technique, but with an
abundance posture. Every gap is framed as an opening. The point is not "you have
a problem." The point is "I am already building the missing layer, and it becomes
more valuable if we do it together."

## How To Use This

Open with the live repo, not this page.

1. Run the demo or show the eval output.
2. Show that Bonsai is inside a verifier-gated workflow, not just a benchmark.
3. Then hand over this brief.

The repo is the proof. This document explains the opportunity.

## 1. The Openings I See

From the outside, PrismML has a strong technical thesis: intelligence density,
open weights, edge deployment, and value migrating from centralized inference to
local workflows. The openings below are not criticisms. They are the predictable
next layer around a young technical company with a model that deserves a larger
developer surface.

1. **The ecosystem layer is still forming.**
   PrismML has the model, the thesis, and the technical credibility. The next
   layer is reference integrations, developer education, community cadence, and
   use-case translation for application builders. That seat is valuable because
   it turns model interest into adoption.

2. **The `mlx-swift` on-device text path needs a reference integration.**
   The Apple story is the edge story builders want to believe in. Image demos on
   flagship hardware are promising, but 1.7B text on a measured phone is the path
   application developers will ask for. Bonsai PHI Scrubber now has the simulator-side
   contract and a visible replacement point: `TextInferenceProviding.complete(...)`.
   The next move is real MLX text, measured honestly.

3. **Regulated-vertical proof would make the thesis easier to buy.**
   "Intelligence comes to the data" is compelling. It becomes much stronger when
   paired with a measured workflow in a hard vertical: healthcare coaching,
   benefits navigation, intake, referrals, or EHR-adjacent handoffs. The right
   proof point is not a vague healthcare claim. It is a synthetic, gated,
   reproducible workflow with numbers and clear non-claims.

4. **Distribution is the scarce asset in an open-model category.**
   If the model is open, the category advantage compounds through references,
   docs, integrations, events, case studies, and developer trust. Capital and
   technical credibility open doors. Community and channel turn the thesis into
   repeated adoption.

5. **The Rust, llama.cpp, MLX, and local-inference communities are ready for a
   concrete Bonsai project.**
   Those builders do not need a softer pitch. They need clean ports, reproducible
   evals, named tradeoffs, and a contribution path that matters. The unwired MLX
   text path is not embarrassing. It is a useful magnet if it is framed honestly.

These are the openings I would expect to matter next. I am already working on
the first two through Bonsai PHI Scrubber; the plan below extends that motion.

## 2. What I Have Already Built

There are two forms of proof: the artifact and the community muscle.

### Pillar 1: The Working Reference

`github.com/ChaiWithJai/bonsai-phi-scrubber` is a healthcare hackathon starter and
reference architecture for privacy-sensitive edge workflows on Bonsai.

What it does:

- captures a synthetic coaching note;
- runs a Bonsai-assisted scrub locally;
- treats model output as untrusted text;
- parses, validates, clamps, and redacts;
- re-scans the exact outbound Slack payload;
- blocks egress by default unless the verifier finds zero residual identifiers;
- sends only a scrubbed care record to Slack;
- keeps the model behind a swappable inference port;
- lets adopters change declarative packs instead of editing the trust core.

The measured point is simple: regex alone misses contextual identifiers; Bonsai
inside a deterministic verifier harness catches the cases that matter for the
demo. The current committed eval reports 100% recall and zero leakage on the
synthetic golden set, with the docs naming the precision tradeoff and the open
iOS hardware gap.

The important part for PrismML is not that this one demo is healthcare. The
important part is that it gives Bonsai a repeatable adoption shape:

```text
raw workflow data -> local Bonsai-assisted scrub -> verifier gate -> clean egress
```

That is the kind of shape an application developer can copy into another
vertical.

### Pillar 2: The Community Layer Is Native To My Work

This is not a cold pivot into DevRel.

- I shipped the Nomad UI at HashiCorp, so I understand the infrastructure
  audience and the standard they apply to developer tools.
- I run KVibe Studios, an 8,000 sq ft production space in Jersey City, so the
  venue, content, and event infrastructure for a local community motion already
  exists.
- My actual origin is teaching and coaching. I started by coaching neighborhood
  kids in my sister's driveway, and I am now building a school. Turning people
  into a community of practice is not a side quest; it is the through-line.

That combination matters: I can build the technical reference, teach it clearly,
and convene the people who will extend it.

## 3. The 90-Day Plan

The motion is simple: builders make the reference real, adopters make the proof
credible. Run both tracks at once.

### Days 0-30: Establish The Reference

- Ship the real `mlx-swift` Bonsai text adapter behind the existing
  `TextInferenceProviding.complete(...)` boundary.
- Measure honestly on the oldest available practical iPhone. The headline should
  be whatever actually runs.
- Publish Bonsai PHI Scrubber as a reference architecture: scrub -> gate -> clean
  egress, model-as-port, declarative pack.
- Publish the technical writeup: "How we made a 1-bit model useful inside a
  verifier-gated workflow."
- Open the first contribution path around the MLX text adapter, structured
  output constraints, and pack extensions.

Validated by:

- Bonsai PHI Scrubber already has the simulator-side backend selection and shared DTO
  contract.
- The eval harness already gives a reproducible proof surface.
- The MLX text path is specific enough to be a real contribution, not a vague
  roadmap item.

Milestone:

- Bonsai PHI Scrubber becomes the obvious Bonsai edge-workflow reference for builders
  evaluating on-device text.

### Days 30-60: Convene NYC And Open The Funnel

- Host the first NYC edge-inference build night around Bonsai at KVibe.
- Turn the repo into a contributor surface: good-first issues, adapter notes,
  pack-extension docs, and a short demo video.
- Start the first adopter journey with a clinic, coaching practice, benefits
  navigation team, or community-health workflow using synthetic data.
- Run office hours for builders who want to port the pattern to their runtime or
  vertical.

Validated by:

- CNCF's adoption loop: builders create the reference, end users create the
  journey reports.
- The local NYC AI and edge-inference community needs concrete projects, not
  generic meetups.
- KVibe makes the convening cost low and the production quality high.

Milestone:

- A recurring NYC room, early contributors, and the first adopter journey in
  progress.

### Days 60-90: Compound Into Proof And Presence

- Publish the first regulated-vertical journey report using synthetic workflow
  data and explicit non-claims.
- Establish a content cadence: technical writeups, short demos, office hours,
  and issue-led contribution prompts.
- Anchor a Bonsai presence around NYC Tech Week and AI Engineer World's Fair
  healthcare conversations.
- Package the reference architecture so founders, app teams, and edge builders
  can answer: "What do I build with Bonsai?"

Validated by:

- Open-model adoption compounds through reference projects, technical trust,
  and repeated community touchpoints.
- Regulated-vertical buyers need a boundary and a runbook before they need a
  benchmark.

Milestone:

- Builders cite the reference. Adopters can point to a journey report. PrismML
  has a concrete ecosystem motion online and in NYC.

## 4. How We Would Know It Is Working

The signal should be countable:

- repo forks and meaningful stars;
- external contributors and accepted PRs;
- repeat attendance at the NYC build night;
- inbound from teams adapting packs to their workflows;
- the reference architecture cited in discussion, demos, or issues;
- one published journey report with clear numbers and clear non-claims.

The goal is not vague awareness. The goal is reference status.

## 5. The One Ask

I am building the edge-inference community around Bonsai either way: the reference
integration, the writeups, the NYC room, and the adopter path.

I would rather do it with PrismML than next to PrismML.

**One ask: let me become PrismML's reference and community presence for Bonsai
edge workflows.** Start with Bonsai PHI Scrubber as the reference integration, review
the MLX text adapter assumptions with me, and let me turn the repo, the events,
and the adopter journey into the ecosystem layer this model deserves.

This does not require a big announcement first. The first step can be small:
review the adapter boundary, validate what PrismML wants represented accurately,
and let the work earn the next step.

## 6. Guardrails

The credibility is the product, so I will not overclaim:

- Not "on-device proven" until 1.7B text runs on a real measured device.
- Not "de-identified" or "HIPAA-compliant." The repo says scrubbed, and so do I.
- Not "intelligence density beats the field" as a benchmark claim. I will use it
  as a framing for value migration and local workflow ownership.
- Not "healthcare production-ready." It is a synthetic, verifier-gated starter
  and reference architecture.

Naming these limits is not a weakness. It is what lets cautious adopters trust
the work and serious builders respect it.

## One-Line

I open with the working repo, name the openings I see from the outside, show that
I have already built the hardest reference artifact and have the community muscle
to grow it, then make one ask: build the Bonsai edge-inference ecosystem with
PrismML, not next to PrismML.
