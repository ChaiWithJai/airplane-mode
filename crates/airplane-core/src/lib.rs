//! # airplane-core
//!
//! The portable, auditable **trust core** for the Bonsai PHI Scrubber on-device PHI scrubber.
//! It owns the deterministic, legally-critical logic and depends only on *ports* —
//! never on a platform, a model runtime, or a network.
//!
//! - **rules executor** ([`rules`]) — deterministic recognizers from a pack
//! - **verifier gate** ([`gate`]) — re-scan output, default-deny egress
//! - **pipeline** ([`pipeline`]) — `rules ∪ inference → gate`
//! - **pack loader** ([`pack`]) — declarative, PHI-blind extension unit
//! - **eval** ([`eval`]) — recall / leakage scoring against a golden set
//!
//! The model is an [`InferenceProvider`] *port* (see ADR-014). Adapters live in the shells.

pub mod eval;
pub mod gate;
pub mod hygiene;
pub mod model;
pub mod pack;
pub mod pipeline;
pub mod ports;
pub mod rules;

pub use eval::{finalize, score_note, Score};
pub use gate::{GateDecision, VerifierGate};
pub use model::{Expected, ExpectedSpan, Sampling, Span};
pub use pack::{Pack, Policy};
pub use pipeline::{bonsai_layer, scrub, ScrubResult};
pub use ports::{Capture, InferenceProvider, InferenceRequest, SecureStore, Sink};
pub use rules::RulesExecutor;
