---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - docs/_bmad-output/planning-artifacts/prds/prd-winnow-2026-05-22/prd.md
---

# Winnow - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Winnow, decomposing the requirements from the PRD into implementable stories.

## Requirements Inventory

### Functional Requirements

FR-1: User selects a category for the items being scored (features, epics, prospects, etc.) from preset options or free text.
FR-2: User provides domain context (product, market, or area) to ground downstream research queries.
FR-3: User selects scoring criteria — default RICE (Reach, Impact, Confidence, Effort, 1–5, Effort inverted), or customizes by starting from the default template or blank. For each criterion: keep/modify name/description/scale, remove, or add new. User names and saves the criteria set to a file for reuse. User can import a previously saved criteria set file.
FR-4: User configures criterion weights — equal by default, or per-criterion numeric values.
FR-5: User provides items inline as a list of names with optional descriptions.
FR-6: System ingests items from an MD file in structured frontmatter format, H2 sections format, or heuristic fallback; generates MD templates on request; detects and acknowledges embedded context/criteria/weights.
FR-7: System iterates through every item×criterion pair in criterion-first order, asking the user for an estimate or offering research per pair.
FR-8: System dispatches the Winnow Research skill as a subagent for researchable criteria, presenting an evidence-only report with confidence signal and sources; never assigns a score.
FR-9: For non-researchable criteria (default: Effort), system provides a speculative breakdown of what building the item involves to aid user sizing.
FR-10: System records user-assigned scores, catches non-numeric entries with a re-prompt, and stores scores by item×criterion.
FR-11: System displays a ranked markdown table of all items × all criteria + weighted total, sorted descending, with tie indicators.
FR-12: System enters an interactive review loop allowing score adjustment, weight adjustment, and re-ranking until the user explicitly signals completion; weight changes offered at least once.
FR-13: System warns the user if all items carry low confidence scores, recommending more research before committing; user can override.
FR-14: System writes `winnow-<slug>-<date>.md` containing recommendation narrative, decision notes, scored table, and config block.
FR-15: System writes `winnow-<slug>-<date>.json` containing the same data in machine-readable structured JSON.
FR-16: System writes research artifacts to `research/<criterion>-<item-slug>.md`, including stub artifacts for failed research.
FR-17: System ships as a directory with `SKILL.md` (scoring agent), `winnow-research/SKILL.md` (research agent), `README.md`, and `examples/example-items.md`.
FR-18: System supports invocation across Claude Code (`/winnow`), Claude Desktop (MCP/custom instructions), BMAD (skill conventions), and general LLM shells (SKILL.md as canonical interface).

### NonFunctional Requirements

NFR-1: Scoring agent voice must be direct, warm, and efficient — short clear questions, smooth transitions, no buzzword padding.
NFR-2: Research agent voice must be analyst-style — evidence-first, sourced, confidence-calibrated, neutral, ≤200 words per report.
NFR-3: System must function across four runtime targets (Claude Code, Claude Desktop, BMAD, general LLM shells) with a single canonical SKILL.md.
NFR-4: Research agent fallback must work inline when the runtime lacks subagent/task spawning capability.
NFR-5: Score and weight values must be freeform numeric — no enforced bounded range.
NFR-6: The research agent must never assign or recommend a score — evidence and confidence only.

### Additional Requirements

*No Architecture document found. Architecture decisions (two-agent pattern, subagent dispatch, package structure) are captured in PRD §4.3 and §4.6.*

### UX Design Requirements

*No UX Design document found. Winnow is a conversation skill — UX is defined by user journeys (UJ-1, UJ-2) and tone specifications in PRD §2.3 and §6.*

### FR Coverage Map

| FR | Epic | Description |
|---|---|---|
| FR-1 | Epic 1 | Category selection |
| FR-2 | Epic 1 | Domain context probe |
| FR-3 | Epic 1 / Epic 2 | Criteria selection (default-only in Epic 1; full customization in Epic 2) |
| FR-4 | Epic 1 / Epic 2 | Weight configuration (equal-only in Epic 1; full adjustment in Epic 2) |
| FR-5 | Epic 1 | Inline item entry |
| FR-6 | Epic 2 | MD file ingestion (structured/H2/heuristic + template generation) |
| FR-7 | Epic 1 / Epic 2 | Criterion-by-criterion loop (basic in Epic 1; research offer in Epic 2) |
| FR-8 | Epic 2 | Research agent dispatch |
| FR-9 | Epic 2 | Non-researchable criteria handling (effort speculation) |
| FR-10 | Epic 1 | Score recording |
| FR-11 | Epic 1 | Ranked table display |
| FR-12 | Epic 2 | Interactive review loop |
| FR-13 | Epic 2 | Low-confidence guardrail |
| FR-14 | Epic 3 | Report output (markdown) |
| FR-15 | Epic 3 | Report output (JSON) |
| FR-16 | Epic 3 | Research artifacts |
| FR-17 | Epic 1 / Epic 3 | Skill package structure (scaffold in Epic 1; finalize in Epic 3) |
| FR-18 | Epic 3 | Cross-runtime invocation |

### NFR Coverage Map

| NFR | Epic | Description |
|---|---|---|
| NFR-1 | Epic 2 | Scoring agent voice — direct, warm, efficient |
| NFR-2 | Epic 2 | Research agent voice — analyst-style, evidence-first, sourced, ≤200 words |
| NFR-3 | Epic 3 | Cross-runtime function — single canonical SKILL.md |
| NFR-4 | Epic 3 | Research agent inline fallback when subagents unavailable |
| NFR-5 | Epic 1 | Freeform numeric scores and weights — no enforced bounds |
| NFR-6 | Epic 2 | Research agent never assigns or recommends a score |

## Epic List

### Epic 1: Quick Decision — Default RICE, Inline Items, Ranked Table

The thinnest end-to-end slice delivering the "aha" moment. A user invokes Winnow, picks a category, provides domain context, accepts default RICE criteria and equal weights, types items inline, scores each manually (no research yet), and gets a ranked markdown table. The SKILL.md scaffold and directory skeleton exist. User is scoring in under a minute.

**FRs covered:** FR-1, FR-2, FR-3 (default-only), FR-4 (equal-only), FR-5, FR-7 (basic loop, no research offer), FR-10, FR-11, FR-17 (minimal scaffold)
**NFRs covered:** NFR-5

### Epic 2: Research & Refinement — Customization, Research Agent, Review Loop

Layers in what makes Winnow Winnow: full criteria customization (modify/add/remove/save/import criteria sets), weight adjustment, MD file ingestion with template generation, research agent dispatch (evidence-only reports with confidence signals for researchable criteria), effort speculation for non-researchable criteria, interactive review loop with score/weight adjustment, and the low-confidence guardrail. Research agent SKILL.md is created as a standalone, self-contained skill. Confidence handling (FR-8 signal + FR-13 guardrail) is co-located.

**FRs covered:** FR-3 (full customization), FR-4 (weight adjustment), FR-6, FR-7 (research offer), FR-8, FR-9, FR-12, FR-13
**NFRs covered:** NFR-1, NFR-2, NFR-6

### Epic 3: Output & Distribution — Reports, Artifacts, Cross-Runtime

Generates the `.md` recommendation report (narrative, decision notes, ranked table, config block), the `.json` machine-readable sidecar, and research artifacts in `research/<criterion>-<item-slug>.md`. Finalizes the package structure (README.md, example-items.md). Documents cross-runtime invocation (Claude Code, Claude Desktop, BMAD, general LLM shells) with inline fallback handling for runtimes without subagent capability.

**FRs covered:** FR-14, FR-15, FR-16, FR-17 (finalize), FR-18
**NFRs covered:** NFR-3, NFR-4

---

## Epic 1: Quick Decision — Default RICE, Inline Items, Ranked Table

The thinnest end-to-end slice delivering the "aha" moment. A user invokes Winnow, picks a category, provides domain context, accepts default RICE criteria and equal weights, types items inline, scores each manually (no research yet), and gets a ranked markdown table. The SKILL.md scaffold and directory skeleton exist. User is scoring in under a minute.

### Story 1.1: Skill Scaffold & Session Bootstrap

As a decision-maker,
I want to invoke Winnow, tell it what I'm scoring and in what domain, and give it my items inline with sensible defaults,
So that I can start a scoring session quickly without any configuration overhead.

**Acceptance Criteria:**

**Given** the user is in an LLM shell with Winnow installed
**When** the user invokes Winnow via trigger phrase ("let's prioritize", "winnow this", `/winnow`)
**Then** Winnow responds by asking "What are we scoring — epics, stories, features, tech stacks, prospects, directions, or something else?"
**And** the user can select from the preset list or type a free-text category

**Given** the user has selected a category
**When** Winnow asks "{Category} for what product or domain?"
**Then** the user's domain context response is recorded in session state
**And** Winnow proceeds even if the user skips with an empty answer

**Given** the user has provided category and domain context
**When** Winnow presents the default RICE criteria — Reach (1–5), Impact (1–5), Confidence (1–5), Effort (1–5, inverted: 1 = hardest, 5 = easiest) — and confirms equal weights
**Then** the user can accept these defaults and proceed
**And** criteria and weights are recorded in session state

**Given** criteria and weights are confirmed
**When** Winnow asks "Give me the items — names, optionally with descriptions"
**Then** the user can type item names with optional descriptions (comma-separated, newline-separated, or numbered list)
**And** each item is added to the scoring queue with its name and description (empty description allowed)
**And** items are ordered per the user's input

**Given** the Winnow skill directory exists
**When** inspected
**Then** the directory contains `SKILL.md` as the canonical self-contained scoring agent entry point
**And** the SKILL.md includes invocation triggers, the session bootstrap flow, and all code needed for this story
**And** the `winnow-research/` subdirectory skeleton exists (content populated in Epic 2)

### Story 1.2: Criterion-First Scoring Loop

As a decision-maker,
I want to score each item against each criterion one pair at a time in criterion-first order,
So that I can compare items on the same dimension and give each assessment focused attention.

**Acceptance Criteria:**

**Given** the session is bootstrapped with category, domain, criteria (RICE defaults), weights (equal), and items
**When** the scoring loop begins
**Then** Winnow iterates item×criterion pairs in criterion-first order: all items for Reach, then all items for Impact, then all items for Confidence, then all items for Effort
**And** every pair is visited exactly once before the loop completes

**Given** the loop is on an item×criterion pair (e.g., "Feature X, Reach")
**When** Winnow asks "Got an estimate for {item}, {criterion}?"
**Then** the prompt includes the criterion's scale context (e.g., "1–5 scale: 1 = minimal reach, 5 = broad reach")
**And** no research offer is presented (research agent not yet implemented)

**Given** the user provides a numeric score
**When** the value is a valid number
**Then** the score is recorded in session state keyed by item name × criterion name
**And** Winnow advances to the next pair

**Given** the user provides a non-numeric entry (e.g., "high", "maybe", empty)
**When** validation detects the non-numeric value
**Then** Winnow re-prompts: "I need a number to calculate the weighted total. Try a different value?"
**And** the user can retry until a numeric value is entered

**Given** the user has completed all item×criterion pairs
**When** the final score is recorded
**Then** Winnow signals scoring is complete and proceeds to ranked table display
**And** all scores are available in the session state for downstream use

### Story 1.3: Ranked Table Display

As a decision-maker,
I want to see my items ranked in a markdown table with per-criterion scores and weighted totals,
So that I can identify the top-ranked option and understand the breakdown behind each ranking.

**Acceptance Criteria:**

**Given** all item×criterion scores are recorded and weights are equal (default)
**When** Winnow computes the final display
**Then** a markdown table is produced with: items as rows, criteria as column headers (Reach, Impact, Confidence, Effort), and a Weighted Total column
**And** each cell shows the user's numeric score for that item×criterion
**And** the Weighted Total column = sum(criterion_score × criterion_weight) for each item
**And** rows are sorted descending by weighted total

**Given** two or more items have weighted totals within a 10% margin
**When** the table is displayed
**Then** a tie indicator is shown (e.g., "≈" or a note below the table)
**And** if confidence scores overlap for tied items, Winnow notes the signal conflict

**Given** the ranked table is displayed
**When** the user views it
**Then** the table uses the criterion names as configured in session state
**And** the display is clean markdown compatible with LLM rendering

---

## Epic 2: Research & Refinement — Customization, Research Agent, Review Loop

Layers in what makes Winnow Winnow: full criteria customization (modify/add/remove/save/import criteria sets), weight adjustment, MD file ingestion with template generation, research agent dispatch (evidence-only reports with confidence signals for researchable criteria), effort speculation for non-researchable criteria, interactive review loop with score/weight adjustment, and the low-confidence guardrail. Research agent SKILL.md is created as a standalone, self-contained skill. Confidence handling (FR-8 signal + FR-13 guardrail) is co-located.

### Story 2.1: Criteria Customization

As a decision-maker,
I want to customize my scoring criteria — modify, add, or remove criteria, save the set to a reusable file, and import previously saved sets,
So that I can define the evaluation dimensions that matter for my specific decision and reuse them across sessions.

**Acceptance Criteria:**

**Given** the user reaches the criteria selection phase in Winnow
**When** Winnow presents the criteria options — "Default RICE, or customize?"
**Then** the user can accept default RICE (Reach, Impact, Confidence, Effort, 1–5, Effort inverted) and proceed
**And** the user can choose to customize from the default template
**And** the user can choose to start from a blank slate
**And** the user can choose to import a previously saved criteria set file

**Given** the user chooses "customize from default"
**When** Winnow walks through each criterion one at a time
**Then** for each criterion, Winnow asks: "Keep {name} ({scale}, {description})? Want to change the name, description, scale, or remove it?"
**And** the user can keep it unchanged, modify any field (name, description, scale), mark as researchable or not-researchable, or remove it
**And** after all default criteria are reviewed, Winnow asks: "Add any more criteria?"
**And** the user can add new criteria by specifying name, short description, scale, and researchability flag

**Given** the user chooses "start from blank"
**When** Winnow prompts for each new criterion
**Then** for each criterion, Winnow asks for: name, short description, scale (e.g., "1–5" or "0–100"), and whether it's researchable
**And** user can stop adding and finalize at any point
**And** at least 1 criterion must be defined before proceeding

**Given** the user has finalized a custom criteria set
**When** the set is complete
**Then** Winnow asks the user to name the set
**And** Winnow saves the criteria set to a portable file (yaml or frontmatter markdown format)
**And** the file includes: set name, each criterion's name/description/scale/researchability flag
**And** Winnow confirms: "Criteria set '{name}' saved to {filename}"

**Given** the user chooses "import criteria set"
**When** the user provides the path to a previously saved criteria set file
**Then** Winnow reads the file, validates the structure, and loads all criteria into session state
**And** Winnow acknowledges: "Imported criteria set '{name}' — {N} criteria: {list}"
**And** setup proceeds directly without per-criterion prompts

**Given** custom criteria are loaded into session state
**When** the scoring loop runs
**Then** each criterion's researchability flag gates whether the research agent is offered (researchable) or skipped (not-researchable)

### Story 2.2: Weight Configuration

As a decision-maker,
I want to assign different weights to my scoring criteria beyond equal defaults,
So that criteria I care more about have proportional influence on the final ranking.

**Acceptance Criteria:**

**Given** criteria are confirmed in session state (from defaults or customization)
**When** Winnow asks "How heavy — equal weighting, or adjust?"
**Then** the user can accept equal weights (all criteria weighted 1) and proceed
**And** the user can choose to adjust weights

**Given** the user chooses to adjust weights
**When** Winnow prompts per criterion: "Weight for {criterion name}? (current: {current})"
**Then** the user enters a numeric weight value for each criterion
**And** NFR-5 applies: values are freeform numeric, no enforced bounded range
**And** weight values are recorded in session state

**Given** weight values are set (equal or custom)
**When** the weighted total is computed during scoring or display
**Then** weighted total = sum(criterion_score × criterion_weight) for all criteria
**And** weight values are included in the output config block of reports (Epic 3)

### Story 2.3: MD File Ingestion & Template Generation

As a decision-maker,
I want to import items from a markdown file and generate template files for offline preparation,
So that I can prepare items ahead of time in my editor and skip the inline entry step.

**Acceptance Criteria:**

**Given** the user is in the item intake phase
**When** the user provides a path to an MD file instead of typing items inline
**Then** Winnow reads the file and attempts to parse it using the canonical structured frontmatter format first

**Given** the file uses structured frontmatter format (lines starting with `# Category:`, `# Domain:`, `# Criteria:`, `# Weights:` followed by `- Item: description` lines)
**When** Winnow parses the file
**Then** all metadata lines are extracted and used to skip corresponding setup questions (FR-2, FR-3, FR-4)
**And** items are extracted with names and descriptions
**And** Winnow acknowledges: "Imported — {N} {category} for {domain}, {criteria set}, {weights}"
**And** any unrecognized frontmatter key is surfaced for user confirmation

**Given** the file uses H2 sections format (`## Item Name` followed by description paragraphs)
**When** Winnow parses the file
**Then** H2 headings become item names and following paragraph text becomes descriptions
**And** if domain context is present as introductory text before the first H2, it's captured as domain context

**Given** the file uses neither structured frontmatter nor H2 sections
**When** Winnow falls back to heuristic parsing
**Then** bullet-list items are extracted as item names
**And** the first non-bullet line that reads as context (e.g., mentions "for" or a product name) is treated as domain context
**And** if no context line is found, Winnow asks for domain context separately
**And** if multiple potential context lines exist, Winnow surfaces them: "I see what might be context on multiple lines — can you confirm which is the domain?"

**Given** parsing is ambiguous for any line
**When** Winnow cannot determine if a line is an item or metadata
**Then** Winnow asks: "I couldn't parse line X. Is '{text}' an item name, a description, or metadata?"

**Given** the user wants a template during session setup
**When** the user asks for a template (or Winnow offers one when items aren't immediately provided)
**Then** Winnow generates an MD template file pre-populated with the current session's category, criteria names, and input format instructions
**And** the template uses the canonical structured frontmatter format
**And** Winnow explains: "Fill this out with your items and feed it back — I'll skip the setup questions next time"

### Story 2.4: Research Agent SKILL.md & Dispatch

As a decision-maker,
I want Winnow to research external evidence for criteria like Reach and Impact and present me a sourced, confidence-rated report,
So that my scores are grounded in real-world signals rather than gut feel alone.

**Acceptance Criteria:**

**Given** the research agent skill directory `winnow-research/` exists
**When** inspected
**Then** `winnow-research/SKILL.md` is a standalone, self-contained skill file
**And** the SKILL.md can be loaded independently by an LLM as a research agent
**And** it accepts input: item name, item description, criterion name, category, domain context

**Given** the research agent is dispatched with valid inputs
**When** the agent produces its report
**Then** the report is ≤200 words (markdown)
**And** every claim is backed by a source (URL or data description)
**And** the report includes an explicit confidence signal: `high` (multiple independent sources converge), `medium` (one source or mixed signals), or `low` (thin data, weak signals, speculative)
**And** the agent never assigns or recommends a score — evidence and confidence only (NFR-6)
**And** the agent voice is analyst-style: neutral, sourced, confidence-calibrated (NFR-2)

**Given** no relevant signals are found for a research query
**When** the agent produces its report
**Then** the report states: "No relevant signals found" with what was searched and why nothing surfaced
**And** this is presented as valid information, not a failure

**Given** the agent produces a report (successful or "no signals")
**When** Winnow receives the report
**Then** the full research artifact is saved to `research/<criterion>-<item-slug>.md`
**And** item slugs are generated: lowercase, spaces → hyphens, special characters stripped
**And** the report includes the source list and confidence level

**Given** the runtime does not support subagent/task spawning (e.g., general LLM shell)
**When** the user requests research
**Then** Winnow detects subagent unavailability and performs research inline (NFR-4)
**And** the same output contracts apply (≤200 words, confidence, sources)
**And** the artifact is saved identically to `research/<criterion>-<item-slug>.md`

### Story 2.5: Scoring Loop — Research Offer & Effort Speculation

As a decision-maker,
I want the scoring loop to offer me research for evidence-based criteria and give me a speculative breakdown for Effort,
So that I can decide when to gather evidence and when to rely on my own judgment.

**Acceptance Criteria:**

**Given** the scoring loop is at an item×criterion pair where the criterion is tagged `researchable` (default: Reach, Impact, Confidence)
**When** Winnow presents the pair
**Then** the prompt is: "Item X, {criterion}. Got an estimate, or want me to research?"
**And** the user can provide a score directly or request research

**Given** the user requests research for a researchable criterion
**When** the research agent (Story 2.4) is dispatched
**Then** Winnow presents the report: "Here's what I found — [summary]. Confidence: [high/medium/low]. Sources: [links]."
**And** Winnow then asks: "What's your score?"
**And** the user assigns the score after reviewing the evidence
**And** Winnow never assigns the score

**Given** the research agent fails or returns "no signals"
**When** the report indicates no useful findings
**Then** Winnow flags it: "No useful signals found for this criterion. Your estimate?"
**And** a stub research artifact is saved recording what was attempted

**Given** the scoring loop is at an item×criterion pair where the criterion is `Effort` (default: not-researchable)
**When** Winnow presents the pair
**Then** Winnow provides a speculative breakdown: "Effort is internal — I can't research that. Here's a rough sense of what building {item} might involve: [speculative scope breakdown — describes what would broadly be involved, not complexity or person-hours]. What do you think?"
**And** the user assigns the effort score based on the breakdown
**And** the research agent is NOT offered for non-researchable criteria

**Given** a custom criterion is tagged `not-researchable` by the user
**When** the scoring loop reaches that criterion
**Then** Winnow skips the research offer and asks for the user's estimate directly
**And** no speculative breakdown is generated unless it's the default Effort criterion

**Given** research was performed for one or more items
**When** the session continues
**Then** all research artifacts are saved to `research/<criterion>-<item-slug>.md` (including stubs for failures)
**And** the `research/` directory is created if it doesn't exist

### Story 2.6: Interactive Review Loop & Low-Confidence Guardrail

As a decision-maker,
I want to review the ranked table, adjust scores or weights interactively, and get warned if my scores rest on weak evidence,
So that I can iterate toward a decision I trust and avoid shipping a gut-feel ranking as if it were rigorous.

**Acceptance Criteria:**

**Given** the ranked table is displayed (Story 1.3)
**When** Winnow enters the review loop
**Then** Winnow asks: "Anything look off? You can adjust individual scores, change weights, or re-rank."
**And** the user can choose to adjust a score, adjust weights, or signal completion

**Given** the user chooses to adjust a score
**When** the user specifies item name + criterion name + new value
**Then** the score is updated in session state
**And** the weighted total is recalculated
**And** the table is re-ranked and redisplayed
**And** Winnow re-enters the review prompt

**Given** the user chooses to adjust weights
**When** the user provides new weight values for one or more criteria
**Then** weights are updated in session state
**And** ALL weighted totals are recalculated with the new weights
**And** the table is re-ranked and redisplayed
**And** Winnow re-enters the review prompt
**And** Winnow explicitly offers weight adjustment as an option at least once during the review loop

**Given** the user signals completion ("looks good", "proceed", "write the report", or similar)
**When** Winnow detects the completion signal
**Then** the review loop ends
**And** Winnow does NOT auto-finalize — only explicit user signal terminates the loop

**Given** the review loop is active and all scored items carry low confidence in their research reports (if research was used)
**When** the user signals completion
**Then** Winnow warns: "It looks like you're trying to make a gut-feel decision. I'm not the best tool for that — more research is recommended before committing."
**And** the user can override ("proceed anyway") or return to the review loop for more research
**And** if overridden, a low-confidence indication is flagged for inclusion in the decision notes of the output report (Epic 3)

**Given** fewer than all items carry low confidence
**When** the user signals completion
**Then** no guardrail warning is triggered
**And** low-confidence items are still noted individually in the table display

**Given** all Winnow prompts throughout the session
**When** interacting with the user
**Then** the scoring agent voice (NFR-1) is direct, warm, and efficient — short clear questions, smooth transitions, no buzzword padding

---

## Epic 3: Output & Distribution — Reports, Artifacts, Cross-Runtime

Generates the `.md` recommendation report (narrative, decision notes, ranked table, config block), the `.json` machine-readable sidecar, and research artifacts in `research/<criterion>-<item-slug>.md`. Finalizes the package structure (README.md, example-items.md). Documents cross-runtime invocation (Claude Code, Claude Desktop, BMAD, general LLM shells) with inline fallback handling for runtimes without subagent capability.

### Story 3.1: Markdown Report Generation

As a decision-maker,
I want Winnow to write a complete decision report as a markdown file with narrative, notes, table, and configuration details,
So that I have a shareable, justifiable record of how the decision was made.

**Acceptance Criteria:**

**Given** the user has finalized the review loop and signaled completion
**When** Winnow generates the report
**Then** a file named `winnow-<slug>-<date>.md` is written to the current working directory
**And** the slug is provided by the user — if missing during invocation, Winnow asks for it now: "One last thing — what should I call this report? (a short slug for the filename)"
**And** the file is formatted in clean markdown

**Given** the report file is generated
**When** its contents are inspected
**Then** the report contains a **Recommendation Narrative** section (1–2 paragraphs) that:
  - States the clear winner or an honest tie statement
  - Flags confidence gaps and effort outliers
  - Notes near-ties (items within 10% margin)
  - Provides relative comparisons between top items
  - Offers the safe next-best option if the top item has low overall confidence

**Given** the report file is generated
**When** its contents are inspected
**Then** the report contains a **Decision Notes** section (bullet list) covering:
  - Outliers (exceptionally high or low scores on individual criteria)
  - Ties and near-ties with rationale
  - Conflicting signals (e.g., high impact but low confidence)
  - Any user overrides (e.g., low-confidence guardrail override)

**Given** the report file is generated
**When** its contents are inspected
**Then** the report contains the **Scored Table** in markdown (identical to Story 1.3/2.6 output):
  - Items as rows, criteria as columns, weighted total column
  - Sorted descending by weighted total
  - Tie indicators where applicable

**Given** the report file is generated
**When** its contents are inspected
**Then** the report contains a **Config Block** with:
  - Date of the session
  - Category (e.g., "features", "epics")
  - Domain context
  - Criteria used (name, scale, researchability flag per criterion)
  - Weights applied (per criterion)
  - References to research artifact file paths (not embedded content)

### Story 3.2: JSON Report Sidecar

As a decision-maker,
I want a machine-readable JSON sidecar alongside the markdown report,
So that I can pipe the decision data into other tools, dashboards, or scripts.

**Acceptance Criteria:**

**Given** the markdown report is generated (Story 3.1)
**When** Winnow generates the JSON sidecar
**Then** a file named `winnow-<slug>-<date>.json` is written to the same directory (matching the slug and date of the `.md` report)
**And** the JSON is valid and well-formed

**Given** the JSON file is generated
**When** its structure is inspected
**Then** it matches the schema:
  - `meta`: `{ slug, date, category, domainContext, criteria: [{ name, scale, researchable }], weights: { criterionName: value } }`
  - `items`: `[{ name, description, scores: { criterionName: value }, weightedTotal }]`
  - `research`: `[{ item, criterion, filePath, confidence }]`
**And** arrays preserve the order from the scoring session
**And** items appear in ranked order (descending weighted total)

**Given** no research was performed in the session (Epic 1 basic path)
**When** the JSON is generated
**Then** the `research` array is empty
**And** the JSON is still structurally valid

### Story 3.3: Research Artifacts & Package Finalization

As a decision-maker,
I want all research reports saved as standalone files and the Winnow package directory finalized,
So that the research is preserved as a durable artifact and the package is ready for distribution.

**Acceptance Criteria:**

**Given** research was dispatched for any item×criterion pair during the session
**When** Winnow finalizes
**Then** every research result (successful or "no signals") is written to `research/<criterion>-<item-slug>.md`
**And** item slugs are generated: lowercase, spaces → hyphens, special characters stripped
**And** the `research/` directory is created in the current working directory if it doesn't already exist
**And** stub artifacts are written even for failed or "no signals" research, recording the query attempted and what was searched

**Given** an item name is "User Onboarding v2"
**When** generating the slug
**Then** the resulting slug is "user-onboarding-v2"
**And** the file path becomes e.g., `research/reach-user-onboarding-v2.md`

**Given** the Winnow package directory
**When** inspected after Epic 3 completion
**Then** it matches the FR-17 structure:
```
winnow/
├── SKILL.md                     # Scoring agent (Epics 1+2)
├── winnow-research/
│   └── SKILL.md                 # Research agent (Story 2.4)
├── README.md                    # Install/usage docs (Story 3.4)
└── examples/
    └── example-items.md         # Sample MD input format (Story 3.4)
```
**And** `SKILL.md` is self-contained — loading it into any LLM session activates the full scoring agent with all features from Epics 1–2
**And** `winnow-research/SKILL.md` is self-contained — it can be invoked standalone or as a subagent

### Story 3.4: README, Examples & Cross-Runtime Documentation

As a decision-maker or Winnow installer,
I want clear installation and usage instructions for each target runtime and an example input file,
So that I can get Winnow running on Claude Code, Claude Desktop, BMAD, or any LLM shell.

**Acceptance Criteria:**

**Given** the `winnow/README.md` file
**When** read by an installer
**Then** it contains install instructions for each target runtime:
  - **Claude Code**: how to register `/winnow` or trigger phrases ("let's prioritize", "winnow this") as a custom slash command or skill
  - **Claude Desktop**: how to register Winnow as a custom instruction or MCP tool under the name `winnow`
  - **BMAD**: how to install Winnow following BMAD skill conventions (e.g., `bmad-*` invocation patterns)
  - **General LLM shells**: how to load `SKILL.md` as the canonical interface — copying the file content into the system prompt or uploading as a skill file
**And** each runtime section is self-contained and actionable by a non-developer

**Given** the README
**When** referencing subagent/task spawning
**Then** it documents that research uses whatever task/subagent mechanism the runtime provides (NFR-3)
**And** it explains that when subagents are unavailable, research falls back to inline execution automatically with the same output quality (NFR-4)
**And** runtime-specific invocation details are in README.md, not in SKILL.md (SKILL.md remains runtime-agnostic)

**Given** the `winnow/examples/example-items.md` file
**When** inspected
**Then** it demonstrates the canonical structured frontmatter format:
  - `# Category:` line
  - `# Domain:` line
  - `# Criteria:` line
  - `# Weights:` line (optional)
  - `- Item Name: description` lines
**And** it includes sufficient sample items (3–5) to make the format self-explanatory
**And** it contains a brief comment explaining that frontmatter lines skip setup questions

**Given** the README and example file
**When** reviewed for quality
**Then** all file paths and commands are copy-pasteable
**And** the language is runtime-agnostic in SKILL.md (readme carries runtime specifics)
**And** the README references `example-items.md` with a brief description of how to use it
