# eval/ — the reproduction target

`golden-run.txt` (the committed expected eval output a stranger matches with `./run.sh eval`)
is generated and committed at **M1-T12**. The golden *notes* themselves live in the pack:
`packs/coach-session/eval/golden/` + `expected/` (authored at M0).

Determinism: greedy/temp-0, pinned model hash, pinned commit. Matching this file IS the proof.
