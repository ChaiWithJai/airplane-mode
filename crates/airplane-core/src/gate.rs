//! The verifier gate — the trust boundary, made into code (Constitution II + IX).
//!
//! It re-scans **already-scrubbed** output with the deterministic rules executor.
//! Any residual structured identifier ⇒ **block** (default-deny). The gate guards
//! every egress point (Slack sink *and* the RL-environment trajectory store) with
//! one rule. It is simultaneously the technical control and the MHMDA legal control.

use crate::model::Span;
use crate::rules::RulesExecutor;

#[derive(Debug)]
pub enum GateDecision {
    Pass,
    Block { residual: Vec<Span> },
}

impl GateDecision {
    pub fn is_pass(&self) -> bool {
        matches!(self, GateDecision::Pass)
    }
}

pub struct VerifierGate<'a> {
    rules: &'a RulesExecutor,
}

impl<'a> VerifierGate<'a> {
    pub fn new(rules: &'a RulesExecutor) -> Self {
        Self { rules }
    }

    /// Default-deny: re-scan the candidate (already-scrubbed) text; ANY residual
    /// structured identifier blocks egress.
    pub fn check(&self, scrubbed_text: &str) -> GateDecision {
        let residual = self.rules.find(scrubbed_text);
        if residual.is_empty() {
            GateDecision::Pass
        } else {
            GateDecision::Block { residual }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn blocks_residual_identifier() {
        let rules = RulesExecutor::new();
        let gate = VerifierGate::new(&rules);
        // an SSN survived into the "scrubbed" text -> must block
        assert!(!gate.check("client ssn 123-45-6789 noted").is_pass());
    }

    #[test]
    fn passes_clean_text() {
        let rules = RulesExecutor::new();
        let gate = VerifierGate::new(&rules);
        assert!(gate.check("client [PERSON] committed to a walk").is_pass());
    }
}
