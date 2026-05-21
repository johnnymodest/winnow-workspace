# RICE Decision Tool — Project Brief

## What this is

An interactive LLM skill that helps product managers score and rank a set of options using a RICE-based framework. The value proposition over a spreadsheet is twofold: guided discovery (the tool asks the right questions) and AI-assisted research (the tool can investigate criteria it doesn't know, rather than relying on the PM to estimate blind).

---

## User flow

### 1. Setup

The tool opens a conversation and asks:

- **What are we scoring?** (features, epics, stories, prospects, directions, tech options, or other — affects how research is framed)
- **Scoring criteria** — default is classic RICE (Reach, Impact, Confidence, Effort). PM can customise.
- **Criteria weights** — default is equal. PM can assign relative weights. Weights are recorded in the output.

### 2. Item intake

The tool asks for items to score. The PM can:
- Provide a list of names inline
- Point to an existing markdown file with names and descriptions

### 3. Per-item scoring (for each item × each criterion)

For each item/criterion pair the tool:

1. Asks if the PM already has an estimate
2. If not (or if they want validation) — **offers to research it**
3. Research runs as a subagent with its own context, returns a structured summary + recommended score + confidence signal
4. The conversation loop continues until the PM accepts or overrides the score
5. Research reports are saved as secondary markdown artifacts (`research/<criterion>-<item-slug>.md`), referenced but not embedded in the main output

Research is offered selectively — triggered for criteria where external signals exist (Reach, Impact, Confidence for market/user data) and skipped or simplified for internal criteria (Effort, internal adoption).

### 4. Scoring output

After all items are scored the tool produces:

**A. Recommendation narrative** (prose, 1–2 paragraphs)
- Clear winner, or honest statement of a tie
- Flags: confidence gaps, effort outliers, near-ties within margin of error
- Relative comparisons ("20% lower score but 40% higher confidence") not raw numbers
- If top item has low confidence: names a "safe next-best" option with trade-off stated

**B. Decision notes** (bullets)
- Interesting signals from the matrix: outliers, ties, distortions
- Criteria where research found conflicting signals
- Any PM overrides recorded

**C. Scored table** (markdown table)
- All items × all criteria + weighted total
- Ranked by score

**D. Config block**
- Criteria used
- Weights applied
- Date

---

## Output files

```
rice-<slug>-<date>.md       ← human-readable report (A+B+C+D above)
rice-<slug>-<date>.json     ← machine-readable sidecar (same data)
research/
  <criterion>-<item-slug>.md  ← one file per research run
```

---

## Agents

**Scoring agent** — main conversation loop. Owns setup, intake, per-item conversation, final report generation. Receives research summaries as inputs, does not see raw research context.

**Research subagent** — spawned per item/criterion pair when research is requested. Receives: item name + description, criterion being assessed, item type context. Returns: summary (≤200 words), recommended score, confidence in that score, sources. Saves its own markdown artifact.

---

## Out of scope (MVP)

- Persistent config / reusable weight profiles (user defines weights each session; they are recorded in the report)
- UI / web artifact (CLI / Claude Code first)
- Integrations with Jira, Linear, etc.

---

## Open questions for BMAD analyst

- Invocation: slash command name and expected arguments
- How the research subagent is spawned in the target runtime (Claude Code vs BMAD runner)
- Error handling: research returns no useful signal
- Handling ties: scoring within what margin is considered a tie?
- MD file input format: what structure does the tool expect if the PM provides one?
