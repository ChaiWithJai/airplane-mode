# Incident: Phone Demo Capture And Secure Context Failures

## Incident Metadata
- Incident ID: `INC-2026-06-26-phone-demo-capture-secure-context`
- Date: June 26, 2026
- Severity: `S2 demo-blocking UX`
- Class: operational demo incident
- Status: mitigated in code
- Customer impact: `direct` for the live demo operator

## Executive Summary
- What failed: voice note capture could destabilize the first screen while the user was talking, and Browser GPU could be selected from a phone over plain HTTP, leading to `HTTPS required for WebGPU`.
- Why it mattered: the core demo depends on a calm, hands-on phone flow. Losing the screen during dictation or hitting a late WebGPU error creates avoidable cognitive load during the pitch.
- What changed: dictation lifecycle updates now mutate the existing capture controls instead of re-rendering the screen, and the capture screen now surfaces the secure local HTTPS URL before Browser GPU is attempted from LAN HTTP.

## Customer / Business Impact
- Customer-facing effect: demo operator could not reliably voice a note and could hit a Browser GPU failure after starting the scrub.
- Business/system risk: the demo would appear unstable even though the verifier/Sink path was working.
- No-impact statement: no raw note, Slack payload, or PHI-handling boundary changed. This was a browser-shell UX and secure-context routing incident.

## Detection And Timeline
| Time | Event |
|---|---|
| 2026-06-26 12:30 EDT | User reported that the screen exits while trying to talk into voice note capture. |
| 2026-06-26 12:31 EDT | Code inspection found `render()` calls inside speech-recognition `onstart`, `onerror`, `onend`, and the manual stop path. |
| 2026-06-26 12:34 EDT | User reported `Browser GPU probe did not complete (HTTPS required for WebGPU)`. |
| 2026-06-26 12:35 EDT | Local proxy confirmed listening on `0.0.0.0:8443`; current LAN phone URL is `https://192.168.1.88:8443/`. |

## Thread Of Execution
- Voice path: `data-act="dictate"` -> `toggleDictation()` -> `SpeechRecognition` event handlers -> `setCaptureNote()` / capture controls.
- Secure-context path: `data-act="scrub"` -> `doScrub()` -> `runBrowserGpuSpanProbe()` -> browser `navigator.gpu` secure-context requirement.
- File anchor: `shells/web/static/index.html`.

## Root Cause Analysis
| Problem surface | Evidence anchor | Code-smell label | Code Complete challenge class | Counter-signal |
|---|---|---|---|---|
| Voice capture re-rendered the active screen while mobile speech recognition was running. | Previous `toggleDictation()` called `render()` from speech lifecycle handlers. | DOM replacement during active input | State management / event lifetime | `setCaptureNote()` already supported in-place textarea updates. |
| Browser GPU was a default mode but the HTTP phone route was still allowed to reach the probe. | `runBrowserGpuSpanProbe()` correctly returned `HTTPS required for WebGPU`, but only after the user started the workflow. | Late validation | Environment precondition | Local HTTPS proxy and network status already existed. |

## Stochastic Lens
- Speech recognition is event-driven and browser-specific. Re-rendering during interim transcripts increases variability because focus, permission UI, keyboard behavior, and recognition callbacks can race.
- WebGPU availability depends on browser, device, and secure context. The UI must treat secure context as a precondition, not as an inference failure.

## Inversion Lens
- To guarantee this failure happens again, re-render the full capture screen on every speech lifecycle event and let a LAN HTTP phone select Browser GPU without visible HTTPS guidance.
- Controls that prevent that path: no full-screen render during active capture, in-place updates for dictation controls, and a secure URL callout plus early scrub guard for Browser GPU on non-secure LAN origins.

## Mitigations And Corrective Actions
| Change | Why | Status |
|---|---|---|
| Added `updateDictationControl()` and changed speech lifecycle handlers to mutate controls in place. | Prevents DOM replacement and viewport churn while talking. | Done |
| Removed automatic `focusNote()` before supported speech capture. | Avoids opening the mobile keyboard when the user is trying to use speech recognition. | Done |
| Added secure-context callout with computed HTTPS phone URL. | Makes WebGPU's HTTPS requirement visible before the scrub. | Done |
| Added early Browser GPU scrub guard on non-secure LAN HTTP. | Converts a late probe failure into an actionable setup instruction. | Done |

## Evidence Provenance
- Code: `shells/web/static/index.html`
- Local secure URL for this run: `https://192.168.1.88:8443/`
- HTTPS proxy command: `./run.sh https-proxy`
- Phone observer command: `AIRPLANE_WEB_URL=https://192.168.1.88:8443 ./run.sh phone-observe`
