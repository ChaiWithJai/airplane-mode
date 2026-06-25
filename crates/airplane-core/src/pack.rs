//! Pack loader — the declarative, PHI-blind extension unit (ADR-005).
//!
//! A pack is five files (`pack.yaml`, recognizers, `schema.yaml`, `policy.yaml`,
//! `sink.yaml`) and a golden eval set. It can redefine identifiers / schema / policy /
//! sink — never see PHI, read the redaction map, or ship code. [`Pack::validate_blindness`]
//! enforces the "no code, creds sourced" half structurally.

use crate::rules::RulesExecutor;
use anyhow::{bail, Context, Result};
use serde::Deserialize;
use std::path::{Path, PathBuf};

#[derive(Debug, Deserialize)]
struct PackFile {
    metadata: Meta,
    spec: Spec,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
struct Meta {
    name: String,
    version: String,
    #[serde(rename = "targetCore", default)]
    target_core: String,
}

#[derive(Debug, Deserialize)]
struct Spec {
    recognizers: Vec<String>,
    #[serde(default)]
    policy: String,
}

#[derive(Debug, Deserialize)]
pub struct Policy {
    pub deidentification: Deid,
    #[serde(default)]
    pub followup: Option<serde_yaml::Value>,
}

#[derive(Debug, Deserialize)]
pub struct Deid {
    pub profile: String,
    #[serde(rename = "recallThreshold")]
    pub recall_threshold: f64,
    #[serde(rename = "onResidual")]
    pub on_residual: String,
}

/// A loaded pack: its rules executor (built-ins + recognizers) and its policy.
pub struct Pack {
    pub name: String,
    pub dir: PathBuf,
    pub rules: RulesExecutor,
    pub policy: Policy,
}

impl Pack {
    pub fn load(dir: &Path) -> Result<Self> {
        let pf: PackFile = serde_yaml::from_str(
            &std::fs::read_to_string(dir.join("pack.yaml")).context("read pack.yaml")?,
        )
        .context("parse pack.yaml")?;

        let mut rules = RulesExecutor::new();
        for rel in &pf.spec.recognizers {
            rules.load_recognizer_file(&dir.join(rel))?;
        }

        let policy_rel = if pf.spec.policy.is_empty() {
            "policy.yaml".to_string()
        } else {
            pf.spec.policy.clone()
        };
        let policy: Policy = serde_yaml::from_str(
            &std::fs::read_to_string(dir.join(&policy_rel)).context("read policy")?,
        )
        .context("parse policy")?;

        Ok(Self { name: pf.metadata.name, dir: dir.to_path_buf(), rules, policy })
    }

    /// Structural pack-blindness check (the `pack-blindness` gate):
    /// credentials must be sourced (not literal secrets), and the pack carries no code.
    pub fn validate_blindness(dir: &Path) -> Result<()> {
        let sink_path = dir.join("sink.yaml");
        let sink = std::fs::read_to_string(&sink_path).context("read sink.yaml")?;
        if !sink.contains("source:") {
            bail!("sink.yaml has no credential `source:` — secrets must be sourced at runtime, never stored in a pack");
        }
        for path in walk(dir) {
            if let Some(ext) = path.extension().and_then(|e| e.to_str()) {
                if matches!(ext, "sh" | "py" | "js" | "ts" | "rb" | "exe" | "dylib" | "so" | "wasm") {
                    bail!("pack contains executable file {} — packs are declaration only", path.display());
                }
            }
        }
        Ok(())
    }
}

fn walk(dir: &Path) -> Vec<PathBuf> {
    let mut out = Vec::new();
    if let Ok(rd) = std::fs::read_dir(dir) {
        for entry in rd.flatten() {
            let p = entry.path();
            if p.is_dir() {
                out.extend(walk(&p));
            } else {
                out.push(p);
            }
        }
    }
    out
}
