# RICE Decision Tool — Project Brief

## What this is

An interactive LLM skill that helps product managers score and rank a set of options using a RICE-based framework. The value proposition over a spreadsheet is twofold: guided discovery (the tool asks the right questions) and AI-assisted research (the tool can investigate criteria it doesn't know, rather than relying on the PM to estimate blind).

**Target runtimes**: Claude Code, Claude Desktop (MCP-custom instructions), and any LLM environment that supports subagent/task spawning. BMAD-compatible but not BMAD-dependent.

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

---

## Success metrics (external)

Winnow runs in the user's LLM shell — it cannot instrument session time, completion rates, or in-app feedback. Success is measured externally:

- **GitHub stars** — prompted at end of session: "Winnow helped? Star the repo."
- **GitHub issues / PRs** — bug reports and feature requests signal active use
- **Social mentions** — X, LinkedIn, PM community forums
- **Direct feedback** — issues, emails, DMs from users

These do not inform the build; they validate whether anyone uses what was built.

---

## Resolved design decisions

### Invocation

Canonical name: `rice-score`. Trigger phrases: "score these options," "run RICE scoring," "rice score this."

One required arg: the **slug** (used for output filenames `rice-<slug>-<date>.md`). Optional arg: path to a markdown file with pre-populated items.

Runtime manifestations:
- **Claude Code**: `/rice-score <slug> [path-to-items.md]`
- **Claude Desktop**: custom instructions or MCP tool registered as `rice-score`
- **Other runtimes**: the skill's SKILL.md / prompt file is the canonical interface — the runtime loads it and the agent follows its instructions

Interactive by default in all runtimes. Accepts `--headless` for non-interactive execution where supported.

### Research subagent spawning

The skill ships a dedicated research prompt (`research-item.prompt.md`) that any runtime's subagent/task mechanism can consume. It specifies: inputs (item name, description, criterion, item type), output format (summary ≤200 words, recommended score, confidence signal, sources), and file-write path (`research/<criterion>-<item-slug>.md`).

The research subagent is spawned with **no conversation context** to avoid anchoring bias. It returns only a compact digest (score + confidence + file path) — the parent never holds full research text.

**Fallback**: if the runtime lacks subagent/task spawning, the scoring agent researches inline, writes the artifact, then flushes from context.

**Runtime examples:**
- Claude Code: spawning via Task tool with the prompt file as instructions
- Claude Desktop: spawning via MCP subagent or inline fallback
- BMAD: spawning via Task agent with the prompt file

### Error handling: research returns no useful signal

Three-tier handling:
1. **Subagent fails/times out** — criterion flagged `NO_SIGNAL`, PM asked to estimate manually, execution continues.
2. **Subagent returns with low/no confidence** — score recorded with low-confidence flag.
3. **All research for a criterion returns NO_SIGNAL** — decision notes explicitly warn the criterion is unverified.

Failed research still writes a stub artifact recording what was attempted and why it failed.

### Handling ties

Two tiers:
- **Numeric near-tie**: ≤10% difference between adjacent scores → flagged as "within margin."
- **Confidence overlap**: if confidence intervals overlap → functional tie regardless of raw score.

Recommendation never forces a false winner. Ties are stated honestly with the trade-off described.

### MD file input format

Two accepted structures:

**Format A — bullet list** (entry-level):
```markdown
- Feature X: description here
- Feature Y: description here
```

**Format B — H2 sections** (richer descriptions):
```markdown
## Feature X
Description and context...

## Feature Y
Description and context...
```

Missing descriptions → tool asks PM to provide them during intake.
