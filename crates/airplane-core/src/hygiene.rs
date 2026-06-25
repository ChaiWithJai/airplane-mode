//! Output hygiene — the core never trusts raw model output (Constitution IX).
//!
//! Ternary Bonsai may emit a Qwen3-style `<think>…</think>` block and/or code
//! fences around its JSON. We strip those and extract the JSON object before parsing.

/// Strip a leading `<think>…</think>` block and surrounding code fences, then return
/// the outermost `{…}` JSON object substring, if present.
pub fn extract_json_object(raw: &str) -> Option<String> {
    let after_think = match raw.find("</think>") {
        Some(end) => &raw[end + "</think>".len()..],
        None => raw,
    };
    let trimmed = after_think
        .trim()
        .trim_start_matches("```json")
        .trim_start_matches("```")
        .trim_end_matches("```")
        .trim();
    let start = trimmed.find('{')?;
    let end = trimmed.rfind('}')?;
    if end > start {
        Some(trimmed[start..=end].to_string())
    } else {
        None
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn strips_think_and_fences() {
        let raw = "<think>let me reason</think>\n```json\n{\"spans\": []}\n```";
        assert_eq!(extract_json_object(raw).unwrap(), "{\"spans\": []}");
    }

    #[test]
    fn handles_plain_json() {
        assert_eq!(extract_json_object("{\"a\":1}").unwrap(), "{\"a\":1}");
    }

    #[test]
    fn none_when_no_object() {
        assert!(extract_json_object("no json here").is_none());
    }
}
