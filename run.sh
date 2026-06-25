#!/usr/bin/env bash
set -euo pipefail
# run.sh — the one entrypoint, four verbs. Implemented at M1 (backlog/m1.md).
# Until M1 lands, this is a placeholder that documents the contract.

verb="${1:-help}"
case "$verb" in
  eval)   echo "TODO(M1-T11/12): run the scrubber over eval/golden, score recall/precision/leakage, match eval/golden-run.txt" ;;
  demo)   echo "TODO(M2): full loop on desktop — text in -> clean record -> Slack -> follow-up note" ;;
  scrub)  echo "TODO(M1-T09): scrub arbitrary text:  ./run.sh scrub \"<text>\"" ;;
  gates)  echo "TODO(M1-T14): run all harness gates on the current pack (see gates/README.md)" ;;
  help|*) cat <<'EOF'
Airplane Mode — run.sh
  ./run.sh eval            reproduce recall/leakage; match eval/golden-run.txt   (the front door)
  ./run.sh demo            full loop on desktop -> Slack
  ./run.sh scrub "<text>"  scrub arbitrary text
  ./run.sh gates           run all harness gates
Not built yet — see backlog/ and AGENTS.md.
EOF
  ;;
esac
