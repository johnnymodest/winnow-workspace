---
title: Winnow
status: final
created: 2026-05-22
updated: 2026-05-22
---

# PRD: Winnow
*LLM skill for structured, research-assisted, RICE-based decision making.*

## 0. Document Purpose

This PRD defines the Winnow LLM skill for implementation by a developer agent. It describes the conversation flow, agent architecture, output artifacts, and functional requirements. The document builds on the project brief at `docs/PROJECT_BRIEF.md` — design decisions resolved there are referenced, not duplicated. Assumptions are tagged `[ASSUMPTION]` inline and indexed in §7. Glossary terms (§8) are used verbatim throughout; no synonyms.

## 1. Vision

Winnow is an LLM skill that helps decision-makers score and rank options using a RICE-based framework. Like its farming namesake — separating grain from chaff — it separates signal from noise in product decisions.

The user opens their LLM shell, invokes Winnow, and is guided through a structured conversation: what they're scoring, against what criteria, with what evidence. A research agent can be dispatched per item/criterion pair to gather external signals (web search, training data), but it never scores. The human always puts the number down. Winnow provides the structure, the research, and the guardrails — the user provides the judgment.

The bet: structured conversation + delegated research without delegated judgment produces better, more defensible decisions than either pure intuition or pure spreadsheet — and leaves a record that holds up to stakeholder scrutiny.

At the end, Winnow produces a shareable report: ranked table, narrative recommendation, decision notes, and a machine-readable sidecar. The user walks away with a decision they can justify and a record they can revisit.

## 2. Target User

### 2.1 Primary Persona

**The decision-owner.** A professional 4+ years into their field who makes choices that affect resources, people, or direction — and must justify those choices to others. Product Managers are the obvious fit, but the role spans: C-level weighing market entries, marketing managers ranking campaigns, sales reps qualifying prospects, support managers picking tooling.

They live in Slack, Notion, and their calendar. They're not spreadsheet-averse but resent how long a good decision matrix takes. Their brain drifts mid-research — six open tabs, lost thread. The decision gets made anyway, often on gut feel, and a week later they can't reconstruct why.

### 2.2 Jobs To Be Done

- When I'm facing a multi-option decision, I want a structured process that keeps me focused and moving forward, so I don't lose hours to scattered research or second-guessing.
- When I've made a decision, I want a clear record of how I got there — criteria, weights, evidence — so I can justify it to stakeholders and recall my reasoning later.
- When I'm unsure about a criterion, I want a research assistant that gathers relevant signals without substituting my judgment.

### 2.3 Key User Journeys

*UJ-1 is the primary session. UJ-2 covers the pre-prepared file import path. Both lead to the same scoring and review loop.*

**UJ-1. A decision-owner scores and ranks options from scratch.**

- **Persona + context:** The decision-owner with a set of options to rank. Needs a justified, shareable decision.
- **Entry state:** In their LLM shell (Claude Code, Claude Desktop, or BMAD). No file prepped.
- **Path:**
  1. Invokes Winnow: `/winnow` or "let's prioritize" or "winnow this."
  2. Winnow: "What are we scoring — epics, stories, features, tech stacks, prospects, something else?" → User names the category.
  3. Winnow: "{Category} for what product or domain?" → User provides context. This grounds downstream research.
  4. Winnow: "Scoring criteria — default RICE (Reach, Impact, Confidence, Effort, 1–5, Effort inverted), or customize?" → User accepts default or customizes. Custom path: start from default template or blank, modify/add criteria, name the set, save to file.
  5. Winnow: "How heavy — equal weighting, or adjust?" → User sets relative weights or accepts equal default.
  6. Winnow: "Give me the items, or point to an MD file." → User provides names and descriptions inline (or pastes file).
  7. For each item × each criterion, Winnow asks: "Got an estimate, or want me to research?"
     - **Research-eligible criteria** (Reach, Impact, Confidence): if requested, a research agent dispatches — web search + training data — and returns a structured evidence report. No score. The user reviews the evidence and assigns the score.
     - **Effort**: Winnow does not research externally but offers a speculative breakdown — what building this would broadly involve — to help the user reason about sizing. User assigns the effort score.
     - **Internal/custom criteria flagged as non-researchable**: Winnow skips research and asks the user directly.
  8. All items scored. Winnow displays the ranked table.
  9. **Review loop**: "Anything look off? You can adjust individual scores, change weights, or re-rank." Weight changes are explicitly offered at least once. The user can iterate until satisfied.
  10. **Low-confidence guardrail**: if all items carry low confidence scores, Winnow warns: *"This looks like a gut-feel decision. I'm not the best tool for that — more research is recommended before committing."* User can override or return to research.
  11. Winnow writes the report: `winnow-<slug>-<date>.md` + `.json`. Research artifacts saved to `research/<criterion>-<item-slug>.md`.
- **Climax:** The moment the ranked table appears and the user recognizes their decision — or spots a counter-intuitive result the structured process surfaced that gut feel would have missed.
- **Resolution:** User has a shareable report. The `.json` sidecar enables piping into other tools.

**UJ-2. A decision-owner imports a pre-prepared item list from an MD file.**

- **Persona + context:** The decision-owner prepared their items ahead of time using Winnow's template format. They want to skip setup and go straight to scoring.
- **Entry state:** In their LLM shell. They have an MD file ready.
- **Path:**
  1. Invokes Winnow with the file: `/winnow my-decision --file items.md`.
  2. Winnow reads the file, detects the structured frontmatter. Category: features. Domain: mobile banking app. Criteria: default RICE. Weights: equal. Acknowledges each: "Imported — 7 features for mobile banking app, default RICE, equal weights."
  3. Winnow begins scoring immediately: "First up: Feature X, Reach. Got an estimate, or want me to research?"
  4. The scoring loop, review loop, and report generation proceed identically to UJ-1.
- **Climax:** Same as UJ-1 — the ranked table appears. The user's prep work paid off; they got straight to the decision.
- **Resolution:** Same as UJ-1. Report written, shareable.

## 3. Features

### 3.1 Session Setup

**Description:** Winnow opens by asking a short sequence of setup questions that frame the scoring session. Realizes UJ-1 steps 2–5.

**Functional Requirements:**

#### FR-1: Category selection

Winnow asks the user what they are scoring, offering a list of common categories with a free-text fallback.

- "What are we scoring — epics, stories, features, tech stacks, prospects, directions, or something else?"

**Consequences (testable):**
- Category is recorded in the output config block.
- The category string is passed verbatim to every research agent prompt so downstream behavior is deterministic.

#### FR-2: Domain context probe

Winnow asks for the product, market, or domain the items belong to.

- "{Category} for what product or domain?"

**Consequences (testable):**
- Domain context is recorded and passed to every research agent dispatch.
- If the user skips (empty answer), Winnow proceeds without context and the research agent works with only item names and descriptions.

#### FR-3: Criteria selection

Winnow defaults to the standard RICE set: four criteria — Reach, Impact, Confidence, Effort — each on a 1–5 scale, with Effort inverted (1 = hardest, 5 = easiest).

The user can accept this default or customize:
- **Start from default**: Winnow walks through each criterion — "Keep Reach (1–5)? Want to change the name, description, or scale?" User can keep, modify, or remove each.
- **Start from blank**: User defines criteria from scratch — for each new criterion: name, short description, scale, and whether it's researchable.
- After criteria are defined, the user names the set and Winnow saves it to a file for reuse and sharing.
- **Import criteria set**: user can point to a previously saved criteria file to load a named set, skipping all definition questions.

**Consequences (testable):**
- Selected criteria are recorded in the output config block and in the criteria set file.
- Each criterion is tagged `researchable` or `not-researchable`, which gates whether the research agent is offered during scoring.
- `[ASSUMPTION: The default mapping of criteria to researchability — Reach/Impact/Confidence = researchable, Effort = not researchable — is based on the framework's design. User can override during customization.]`
- Score and weight values are freeform numeric. Winnow does not enforce a bounded range — the user defines what makes sense per criterion.
- Criteria set files use a structured format (yml or frontmatter markdown) so they're human-editable and portable across sessions.

#### FR-4: Weight configuration

Winnow asks for relative criterion weights, defaulting to equal.

- "How heavy — equal weighting, or adjust?" If adjusting, the user specifies per-criterion weight values.

**Consequences (testable):**
- Weights are recorded in the output config block.
- Weighted total in the scored table is computed as `sum(criterion_score × criterion_weight)` for all criteria.

### 3.2 Item Intake

**Description:** Winnow collects the items to be scored — either inline or from an MD file. Realizes UJ-1 step 6 and UJ-2.

**Functional Requirements:**

#### FR-5: Inline item entry

User provides a list of item names, optionally with descriptions.

**Consequences (testable):**
- Each item is added to the scoring queue with its name and description (empty description is allowed).
- Items are ordered per the user's input; reordering is not offered (order doesn't affect scoring).

#### FR-6: MD file ingestion

User points to a markdown file containing items. Winnow parses it and extracts items, context, and optionally criteria/weights. If the user doesn't have a file, Winnow can generate a template MD file with the current session's category, criteria, and structure — the user can use this to prepare items offline and re-ingest later.

**Canonical format (structured, preferred):**
```markdown
# Category: features
# Domain: mobile banking app
# Criteria: default-rice
# Weights: equal

- Item X: description here
- Item Y: description here
```

Frontmatter lines (starting with `#`) define session metadata. Winnow detects this structured format and skips the corresponding setup questions. Any frontmatter line with an unrecognized key is surfaced for user confirmation.

**Format B — H2 sections** (richer descriptions):
```markdown
## Feature X
Description and context...

## Feature Y
Description and context...
```

**Fallback (heuristic):** If the file uses neither the structured frontmatter format nor H2 sections, Winnow attempts a bullet-list heuristic. The first non-bullet line that reads as context (e.g., mentions "for" or a product name) is treated as domain context. If no such line is found, Winnow asks for domain context separately. Ambiguous cases (multiple potential context lines) are surfaced for the user to clarify.

**Consequences (testable):**
- Items are extracted from the file and added to the scoring queue.
- Structured frontmatter lines are parsed and used to skip corresponding setup questions (FR-2, FR-3, FR-4).
- If parsing is ambiguous, Winnow asks the user: "I see what might be context on multiple lines — can you confirm which is the domain?"
- Malformed input is surfaced: "I couldn't parse line X. Is '{text}' an item name, a description, or metadata?"
- Winnow can produce an MD template on request during setup, pre-populated with the session's category and criteria, for the user to fill out and re-ingest.
- `[NOTE FOR PM]` MD parsing and template acceptance need real-world validation across user file formats. The structured format is a starting point — expect users to bring unexpected structures. Budget for iterative refinement after first user feedback.

### 3.3 Per-Item Scoring

**Description:** For each item × each criterion, Winnow asks the user for a score, optionally dispatching the Winnow Research agent to gather evidence. This is the core loop. Realizes UJ-1 steps 7–8 and UJ-2 step 3.

The Winnow Research agent is a separate skill (`winnow-research/SKILL.md`) dispatched by Winnow. It does not interact with the end user directly; its output is presented by the scoring agent.

**Research agent core behavior:**
- **Evidence-first.** Every claim is backed by a source. Web search and training data are the primary inputs. Sources are cited inline.
- **Confidence-signaled.** Every report includes an explicit confidence level: *High* (multiple independent sources converge), *Medium* (one source or mixed signals), *Low* (thin data, weak signals, speculative). The confidence signal is presented to the user alongside the evidence so they can weigh it in their score.
- **Neutral.** The research agent describes, it never judges. "Three comparable products shipped similar features and saw 15-30% feature adoption" → not "This feature would be very successful."
- **Knows its limits.** "No relevant signals found" is a valid response, not a failure. The agent states what it searched for and why nothing surfaced.
- **Concise.** Summary ≤200 words. The user is mid-scoring — they need signal, not a dissertation.

**Research agent input contract:**
- Item name and description
- Criterion name
- Category (e.g., "features")
- Domain context (e.g., "mobile banking app")

**Research agent output contract:**
- Summary (≤200 words, markdown)
- Confidence: `high` | `medium` | `low`
- Sources: list of URLs or data descriptions
- File path: where the full research artifact was written (`research/<criterion>-<item-slug>.md`)

**Functional Requirements:**

#### FR-7: Criterion-by-criterion loop

Winnow iterates through every item/criterion pair, one at a time. For each, it asks: "Item X, {criterion}. Got an estimate, or want me to research?"

**Consequences (testable):**
- Every pair is visited exactly once before the review loop begins.
- The loop order is: all items for criterion 1, then all items for criterion 2, etc. Grouping by criterion reduces cognitive switching for the user. `[ASSUMPTION: Criterion-first loop order is the better UX — comparing items on the same dimension is easier than switching dimensions per item. This may need validation; an item-first order could be offered as an option in future iterations.]`

#### FR-8: Research agent dispatch

If the user requests research and the criterion is tagged `researchable`, Winnow spawns the Winnow Research skill as a subagent. The subagent receives: item name, item description, criterion name, category, domain context. It returns a structured evidence report (≤200 words) and a confidence signal. It does not return a score.

**Consequences (testable):**
- Winnow presents the report to the user: "Here's what I found — [summary]. Confidence: [high/medium/low]. Sources: [links]."
- The user then assigns the score. Winnow never assigns it.
- The research artifact is saved to `research/<criterion>-<item-slug>.md`.
- If subagents are unavailable in the runtime, Winnow researches inline and writes the artifact itself, then flushes from context.
- If the research agent fails or returns no signal, Winnow flags it: "No useful signals found for this criterion. Your estimate?" The failure is recorded in a stub research artifact.

#### FR-9: Non-researchable criteria handling

For criteria tagged `not-researchable` (default: Effort), Winnow does not offer the research agent. For Effort specifically, Winnow provides a speculative breakdown of what building the item would involve to help the user reason about sizing.

**Consequences (testable):**
- "Effort is internal — I can't research that. Here's a rough sense of what this might involve: [speculative breakdown]. What do you think?"
- The speculative breakdown describes scope, not complexity or person-hours.

#### FR-10: Score recording

After the user provides a score (with or without research), Winnow records it and moves to the next pair.

**Consequences (testable):**
- All scores are recorded in the scoring state, keyed by item × criterion.
- Non-numeric scores are caught with a prompt: "I need a number to calculate the weighted total. Try a different value?"
- Score values are recorded as-entered; Winnow does not validate range or enforce bounds.

### 3.4 Review Loop

**Description:** After all items are scored, Winnow presents the ranked table and enters an interactive review loop. Realizes UJ-1 steps 9–10.

**Functional Requirements:**

#### FR-11: Ranked table display

Winnow displays a markdown table with all items × all criteria + weighted total, ranked descending.

**Consequences (testable):**
- Table uses the user's criteria names as column headers.
- Weighted total column uses the weights from FR-4.
- Ties are indicated per the tie rules in the project brief (≤10% margin, confidence overlap).

#### FR-12: Interactive review

Winnow asks: "Anything look off?" The user can adjust individual scores, change weights, or re-rank. Weight adjustment is explicitly offered as an option at least once.

**Consequences (testable):**
- Score changes: the user specifies item + criterion + new value. The table updates and re-ranks.
- Weight changes: the user specifies new per-criterion weights. All weighted totals recalculate and the table re-ranks.
- The loop continues until the user signals they're done ("looks good," "proceed," "write the report").
- The loop never ends without the user's explicit signal — Winnow does not auto-finalize. `[ASSUMPTION: Manual finalization is safer than auto-finalizing — an auto-finalize with an undo would be an alternative design, but adds complexity for v1.]`

#### FR-13: Low-confidence guardrail

If all items carry low confidence scores across the board, Winnow warns the user before the report is written.

**Consequences (testable):**
- Warning: "It looks like you're trying to make a gut-feel decision. I'm not the best tool for that — more research is recommended before committing."
- User can override ("proceed anyway") or return to research.
- Low-confidence indication is included in the decision notes section of the output report.

### 3.5 Report Generation

**Description:** When the user finalizes, Winnow writes the output artifacts. Realizes UJ-1 step 11.

**Functional Requirements:**

#### FR-14: Report output (markdown)

Winnow writes `winnow-<slug>-<date>.md` containing:
- **Recommendation narrative** (1–2 paragraphs): clear winner or honest tie statement; flags confidence gaps, effort outliers, near-ties; relative comparisons; safe next-best option if top item has low confidence.
- **Decision notes** (bullets): outliers, ties, conflicting signals, PM overrides.
- **Scored table** (markdown): all items × all criteria + weighted total, ranked.
- **Config block**: criteria used, weights applied, date, category, domain context.

**Consequences (testable):**
- Report is written to the current working directory.
- The slug is the one provided at invocation; if missing, Winnow asks for it during report generation.
- Research artifacts are referenced by file path, not embedded.

#### FR-15: Report output (JSON)

Winnow writes `winnow-<slug>-<date>.json` containing the same data in machine-readable form.

**Consequences (testable):**
- JSON structure: `{ meta: { slug, date, category, domainContext, criteria, weights }, items: [{ name, description, scores: { criterion: value }, weightedTotal }], research: [{ item, criterion, filePath, confidence }] }`.

#### FR-16: Research artifacts

Each research agent dispatch writes its output to `research/<criterion>-<item-slug>.md`.

**Consequences (testable):**
- The `research/` directory is created if it doesn't exist.
- Item slugs are generated from item names: lowercase, spaces → hyphens, special characters stripped.
- Stub artifacts are written even for failed research, recording what was attempted.

### 3.6 Runtime Manifestation

**Description:** Winnow must be installable and invokable across multiple LLM environments.

**Functional Requirements:**

#### FR-17: Skill package structure

Winnow ships as a directory containing two skills and installation documentation.

```
winnow/
├── SKILL.md                     # Winnow scoring skill
├── winnow-research/
│   └── SKILL.md                 # Research skill
├── README.md                    # Install instructions per runtime
└── examples/
    └── example-items.md         # Sample MD input format
```

**Consequences (testable):**
- `SKILL.md` is self-contained — loading it into an LLM session activates the scoring agent.
- `winnow-research/SKILL.md` is self-contained and can be invoked as a standalone agent or as a subagent.

#### FR-18: Cross-runtime invocation

The user can invoke Winnow across target runtimes:
- **Claude Code**: `/winnow` or trigger phrase ("let's prioritize," "winnow this").
- **Claude Desktop**: registered as a custom instruction or MCP tool under the name `winnow`.
- **BMAD**: loaded as a skill via `bmad-*` conventions; BMAD compatibility is secondary but must work.
- **General LLM shells**: the `SKILL.md` is the canonical interface — loading it activates Winnow.

**Consequences (testable):**
- `SKILL.md` is written in runtime-agnostic language. Runtime-specific invocation details are documented in `README.md`, not in the skill files.
- The research agent dispatch uses whatever task/subagent mechanism the runtime provides. Fallback to inline research is handled per FR-8.
- `[NOTE FOR PM]` Cross-runtime subagent dispatch may vary significantly between Claude Code, Claude Desktop, and BMAD. Test on all four target runtimes before launch — do not assume one mechanism ports cleanly.

## 4. Scope

### 5.1 In Scope

- Invocation via `/winnow` or trigger phrases across Claude Code, Claude Desktop, and BMAD
- Session setup: category, domain context, criteria selection (default RICE or customize from template/blank), weight configuration, criteria set import
- Item intake: inline entry and MD file ingestion (both formats, with template generation)
- Per-item scoring loop with research agent dispatch for researchable criteria
- Research agent with evidence-only output + confidence signal
- Effort speculation for non-researchable criteria
- Review loop with score adjustment, weight adjustment, low-confidence guardrail
- Report generation: `.md` narrative + table + notes + config, `.json` sidecar, research artifacts in `research/`
- `README.md` with install instructions per target runtime
- Example items file for MD input format

### 5.2 Out of Scope for MVP

- Persistent config / reusable weight profiles [v2 — user defines weights each session]
- Cross-session history, comparison, or trend analysis [v2]
- Visual UI or web artifact [future]
- Integrations with project management tools (Jira, Linear, etc.) [future]
- Multi-user or collaborative sessions [future]
- Internationalization / localization [future]
- Headless/non-interactive mode [post-MVP]
- User-defined research agent behavior profiles [post-MVP]

### 5.3 Non-Goals (principled exclusions)

- Winnow is **not** a web application, a spreadsheet plugin, or a visual UI. It is a conversation skill.
- Winnow is **not** a persistent decision database. Each session produces standalone artifacts.
- Winnow is **not** a replacement for human judgment. It never assigns scores. It structures the process and gathers evidence.
- Winnow is **not** a RICE purist tool. It supports custom criteria and custom weights; the framework is a starting point.

## 5. Aesthetic and Tone

Winnow has two voices: the scoring agent (user-facing) and the research agent (presented through the scoring agent). Both are conversational but distinct.

### Scoring agent voice

- **Direct, warm, efficient.** The user is making a decision — don't waste their time. Questions are short and clear. Transitions are smooth, never abrupt.
- **Curious, not prescriptive.** "Got an estimate, or want me to research?" — not "You should research this." Winnow offers options; the user chooses.
- **Honest about uncertainty.** "No useful signals found for this criterion. Your estimate?" — not "Unable to complete research." Winnow frames gaps as information, not failures.
- **Supportive at the finish.** "Here's what we found." The report narrative is confident in the data but never overstates. Ties are stated plainly. Weak signals are flagged.
- **No jargon without cause.** RICE terminology is introduced once and used consistently. No PM-buzzword padding.

### Research agent voice (presented via scoring agent)

- **Analyst, not advisor.** Presents evidence and confidence. Never says "this is a good idea" or "this scores high."
- **Sourced.** Claims are traceable. "Three comparable products shipped similar features → 15-30% adoption" with links.
- **Calibrated.** Confidence is stated explicitly in every report: high, medium, or low.
- **Concise.** ≤200 words. The user is mid-scoring — they need signal, not a dissertation.

## 6. Open Questions

1. **Subagent availability detection**: how does Winnow determine at runtime whether subagent/task spawning is available, and what's the user experience when it isn't? The inline fallback (FR-8) works for the research agent, but the scoring loop itself may need to adjust its conversational rhythm for platforms that can't spawn tasks.
2. **Large session handling**: what is the maximum practical session size before context-window pressure degrades the conversation? A 50-item × 4-criterion session generates 200 turns — at what point should Winnow warn the user to split the session or use the MD batch path?
3. **Effort speculation guardrails**: how does Winnow generate the speculative Effort breakdown without hallucinating implementation details? The prompt to the LLM for Effort speculation needs a defined structure — what that structure is remains open.
4. **Cross-runtime invocation differences**: FR-18 targets four runtime types. How different are the actual invocation mechanisms, and does Winnow's `SKILL.md` need per-runtime variants or is one canonical file sufficient? Testing across all four targets before launch is assumed but not yet planned.

## 7. Assumptions Index

*Every `[ASSUMPTION]` from the document, surfaced for explicit confirmation:*

- §3.1 FR-3 — Classic RICE defaults: Reach/Impact/Confidence = researchable; Effort = not researchable. Based on RICE framework design — external signals for the first three, team-internal for Effort.
- §3.3 FR-7 — Criterion-first loop order (all items for criterion 1, then criterion 2, etc.) is the better UX. Item-first order could be offered as a future option.
- §3.4 FR-12 — Manual finalization is safer than auto-finalizing for v1.

## 8. Glossary

- **Item** — One option being scored (a feature, epic, prospect, strategy, etc.). Has a name, an optional description, and scores per criterion.
- **Criterion** — A dimension on which items are evaluated (e.g., Reach, Impact, Confidence, Effort). Has a weight.
- **Weight** — The relative importance of a criterion in the final score. Defaults to equal across all criteria.
- **Score** — The numeric value a user assigns to an item for a given criterion. Always human-assigned.
- **Research agent** — A subagent dispatched per item/criterion pair. Gathers external evidence (web, training data) and returns a structured report. Never assigns a score.
- **Scoring agent** — The main conversation loop. Owns setup, intake, per-item conversation, review loop, and report generation.
- **Slug** — A short, file-safe identifier the user provides, used in output filenames: `winnow-<slug>-<date>.*`.
- **Category** — What the items represent (features, epics, prospects, etc.). Frames how research is conducted and described.
- **Domain context** — The product, market, or area the items belong to. Grounds research queries.
- **RICE** — Reach, Impact, Confidence, Effort. Winnow's default scoring framework: each criterion scored 1–5, Effort inverted (1 = hardest, 5 = easiest).
- **Criteria set** — A named collection of criteria with their scales and researchability flags, saved as a portable file. Can be exported, imported, and shared across sessions.
