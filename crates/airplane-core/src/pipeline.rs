//! Pipeline orchestration: `rules ∪ inference → redact → gate`.
//!
//! The union is recall-first (redact if *either* layer flags). The model layer is
//! reached only through the [`InferenceProvider`] port. The redaction map (PHI → token)
//! is the radioactive artifact — it stays with the caller / Secure Enclave, never a sink.

use crate::gate::{GateDecision, VerifierGate};
use crate::hygiene;
use crate::model::{Sampling, Span};
use crate::ports::{InferenceProvider, InferenceRequest};
use crate::rules::RulesExecutor;
use anyhow::Result;
use serde::Deserialize;
use serde_json::{json, Value};
use std::collections::HashSet;

pub struct ScrubResult {
    /// PHI → token table. The radioactive artifact; never leaves the device.
    pub redaction_map: Vec<Span>,
    /// The de-identified text safe to forward past the gate.
    pub scrubbed_text: String,
    /// Egress decision (default-deny).
    pub gate: GateDecision,
}

/// The JSON schema the model output is constrained to (CLI: server-side; iOS: client-side).
pub fn bonsai_schema() -> Value {
    json!({
        "type": "object",
        "additionalProperties": false,
        "required": ["spans"],
        "properties": {
            "spans": {
                "type": "array",
                "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": ["text", "entity"],
                    "properties": {
                        "text": { "type": "string" },
                        "entity": { "type": "string" }
                    }
                }
            }
        }
    })
}

#[derive(Deserialize)]
struct ModelSpans {
    #[serde(default)]
    spans: Vec<ModelSpan>,
}
#[derive(Deserialize)]
struct ModelSpan {
    text: String,
    #[serde(default)]
    entity: String,
}

/// The contextual layer — ask the model for identifiers, parse defensively.
/// Never panics on bad output: a parse failure yields no spans (the rules layer
/// and the gate still hold the line).
pub fn bonsai_layer(text: &str, model: &dyn InferenceProvider, sampling: Sampling) -> Result<Vec<Span>> {
    let schema = bonsai_schema();
    let req = InferenceRequest {
        system: "You are a PHI de-identification engine. Extract every identifier \
                 — names, dates, locations, relationships, ids, contact info — from \
                 the note. Respond with JSON only.",
        user: text,
        json_schema: &schema,
        sampling,
    };
    let raw = model.complete(&req)?;
    let spans = hygiene::extract_json_object(&raw)
        .and_then(|j| serde_json::from_str::<ModelSpans>(&j).ok())
        .map(|m| {
            m.spans
                .into_iter()
                .filter(|s| !s.text.trim().is_empty())
                .map(|s| {
                    let entity = if s.entity.is_empty() { "UNKNOWN".to_string() } else { s.entity };
                    Span::new(s.text, entity, "bonsai")
                })
                .collect()
        })
        .unwrap_or_default();
    Ok(spans)
}

/// Full scrub: union the layers, redact, and run the verifier gate.
///
/// `passes` runs the contextual layer K times with consecutive seeds and unions the
/// results. Single-pass recall on a 1.7B ternary model is ~80% and *stochastic* (it
/// misses a different subset each seed); unioning K deterministic passes drives recall
/// toward the gate — latency traded for the recall a PHI boundary requires.
pub fn scrub(
    text: &str,
    rules: &RulesExecutor,
    model: Option<&dyn InferenceProvider>,
    sampling: Sampling,
    passes: u32,
) -> Result<ScrubResult> {
    let mut spans = rules.find(text);
    if let Some(m) = model {
        for i in 0..passes.max(1) {
            let mut s = sampling;
            s.seed = sampling.seed.wrapping_add(i as u64);
            spans.extend(bonsai_layer(text, m, s)?);
        }
    }

    // Dedup by case-insensitive text; longest spans first so redaction is greedy.
    spans.sort_by_key(|s| std::cmp::Reverse(s.text.len()));
    let mut seen: HashSet<String> = HashSet::new();
    spans.retain(|s| seen.insert(s.key()));

    // Redact: replace each identifier with an [ENTITY] token.
    let mut scrubbed = text.to_string();
    for s in &spans {
        if s.text.trim().is_empty() {
            continue;
        }
        scrubbed = scrubbed.replace(&s.text, &format!("[{}]", s.entity));
    }

    let gate = VerifierGate::new(rules).check(&scrubbed);
    Ok(ScrubResult { redaction_map: spans, scrubbed_text: scrubbed, gate })
}
