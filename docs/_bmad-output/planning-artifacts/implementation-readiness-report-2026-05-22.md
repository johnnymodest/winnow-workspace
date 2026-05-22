---
stepsCompleted: [1, 2, 3, 4, 5, 6]
inputDocuments:
  - docs/_bmad-output/planning-artifacts/prds/prd-winnow-2026-05-22/prd.md
  - docs/_bmad-output/planning-artifacts/epics.md
missingDocuments:
  - Architecture
  - UX Design
---

# Implementation Readiness Assessment Report

**Date:** 2026-05-22
**Project:** winnow

## Document Inventory

### PRD
- **Whole Document:** `docs/_bmad-output/planning-artifacts/prds/prd-winnow-2026-05-22/prd.md` (430 lines)

### Architecture
- **NOT FOUND** — No architecture document exists. Architecture decisions captured inline in PRD §4.3 and §4.6.

### Epics & Stories
- **Whole Document:** `docs/_bmad-output/planning-artifacts/epics.md`

### UX Design
- **NOT FOUND** — No UX design document exists. Winnow is a conversation skill; UX defined by user journeys in PRD §2.3 and tone specs in §6.

## PRD Analysis

**Source:** `prd-winnow-2026-05-22/prd.md`

### Functional Requirements (18)

| FR | Description |
|---|---|
| FR-1 | User selects a category for the items being scored (features, epics, prospects, etc.) from preset options or free text. |
| FR-2 | User provides domain context (product, market, or area) to ground downstream research queries. |
| FR-3 | User selects scoring criteria — default RICE (Reach, Impact, Confidence, Effort, 1–5, Effort inverted), or customizes by starting from the default template or blank. For each criterion: keep/modify name/description/scale, remove, or add new. User names and saves the criteria set to a file for reuse. User can import a previously saved criteria set file. |
| FR-4 | User configures criterion weights — equal by default, or per-criterion numeric values. |
| FR-5 | User provides items inline as a list of names with optional descriptions. |
| FR-6 | System ingests items from an MD file in structured frontmatter format, H2 sections format, or heuristic fallback; generates MD templates on request; detects and acknowledges embedded context/criteria/weights. |
| FR-7 | System iterates through every item×criterion pair in criterion-first order, asking the user for an estimate or offering research per pair. |
| FR-8 | System dispatches the Winnow Research skill as a subagent for researchable criteria, presenting an evidence-only report with confidence signal and sources; never assigns a score. |
| FR-9 | For non-researchable criteria (default: Effort), system provides a speculative breakdown of what building the item involves to aid user sizing. |
| FR-10 | System records user-assigned scores, catches non-numeric entries with a re-prompt, and stores scores by item×criterion. |
| FR-11 | System displays a ranked markdown table of all items × all criteria + weighted total, sorted descending, with tie indicators. |
| FR-12 | System enters an interactive review loop allowing score adjustment, weight adjustment, and re-ranking until the user explicitly signals completion; weight changes offered at least once. |
| FR-13 | System warns the user if all items carry low confidence scores, recommending more research before committing; user can override. |
| FR-14 | System writes `winnow-<slug>-<date>.md` containing recommendation narrative, decision notes, scored table, and config block. |
| FR-15 | System writes `winnow-<slug>-<date>.json` containing the same data in machine-readable structured JSON. |
| FR-16 | System writes research artifacts to `research/<criterion>-<item-slug>.md`, including stub artifacts for failed research. |
| FR-17 | System ships as a directory with `SKILL.md` (scoring agent), `winnow-research/SKILL.md` (research agent), `README.md`, and `examples/example-items.md`. |
| FR-18 | System supports invocation across Claude Code (`/winnow`), Claude Desktop (MCP/custom instructions), BMAD (skill conventions), and general LLM shells (SKILL.md as canonical interface). |

### Non-Functional Requirements (6)

| NFR | Description |
|---|---|
| NFR-1 | Scoring agent voice must be direct, warm, and efficient — short clear questions, smooth transitions, no buzzword padding. |
| NFR-2 | Research agent voice must be analyst-style — evidence-first, sourced, confidence-calibrated, neutral, ≤200 words per report. |
| NFR-3 | System must function across four runtime targets (Claude Code, Claude Desktop, BMAD, general LLM shells) with a single canonical SKILL.md. |
| NFR-4 | Research agent fallback must work inline when the runtime lacks subagent/task spawning capability. |
| NFR-5 | Score and weight values must be freeform numeric — no enforced bounded range. |
| NFR-6 | The research agent must never assign or recommend a score — evidence and confidence only. |

### Additional Requirements

- Architecture decisions (two-agent pattern, subagent dispatch, package structure) captured in PRD §4.3 and §4.6.
- Winnow is a conversation skill — not a web app, spreadsheet plugin, or visual UI.
- Out of scope for MVP: persistent config, cross-session history, visual UI, Jira/Linear integrations, multi-user sessions, i18n, headless mode.

### PRD Completeness Assessment

- PRD is thorough with clear user journeys (UJ-1, UJ-2), personas, scope boundaries, and open questions.
- All FRs are testable with explicit "Consequences (testable)" sections.
- 3 assumptions are tagged `[ASSUMPTION]` and indexed in §7.
- 4 open questions in §6 — none block implementation but may need resolution during dev.
- Glossary (§8) establishes consistent terminology.

## Epic Coverage Validation

### Coverage Matrix

| FR | PRD Requirement | Epic / Story Coverage | Status |
|---|---|---|---|
| FR-1 | Category selection | Epic 1 Story 1.1 | ✓ Covered |
| FR-2 | Domain context probe | Epic 1 Story 1.1 | ✓ Covered |
| FR-3 | Criteria selection (default + customize + save/import) | Epic 1 Story 1.1 (default) + Epic 2 Story 2.1 (full customization) | ✓ Covered |
| FR-4 | Weight configuration (equal + adjust) | Epic 1 Story 1.1 (equal) + Epic 2 Story 2.2 (full adjustment) | ✓ Covered |
| FR-5 | Inline item entry | Epic 1 Story 1.1 | ✓ Covered |
| FR-6 | MD file ingestion + template generation | Epic 2 Story 2.3 | ✓ Covered |
| FR-7 | Criterion-by-criterion loop (basic + research offer) | Epic 1 Story 1.2 (basic) + Epic 2 Story 2.5 (research offer) | ✓ Covered |
| FR-8 | Research agent dispatch (evidence, confidence, sources) | Epic 2 Stories 2.4 + 2.5 | ✓ Covered |
| FR-9 | Non-researchable criteria handling (Effort speculation) | Epic 2 Story 2.5 | ✓ Covered |
| FR-10 | Score recording (numeric validation, storage) | Epic 1 Story 1.2 | ✓ Covered |
| FR-11 | Ranked markdown table (sorted, ties) | Epic 1 Story 1.3 | ✓ Covered |
| FR-12 | Interactive review loop (score/weight adjustment) | Epic 2 Story 2.6 | ✓ Covered |
| FR-13 | Low-confidence guardrail (warn + override) | Epic 2 Story 2.6 | ✓ Covered |
| FR-14 | Markdown report output (narrative, notes, table, config) | Epic 3 Story 3.1 | ✓ Covered |
| FR-15 | JSON report sidecar (structured schema) | Epic 3 Story 3.2 | ✓ Covered |
| FR-16 | Research artifacts (per pair, stubs) | Epic 3 Story 3.3 | ✓ Covered |
| FR-17 | Skill package structure (SKILL.md, dirs) | Epic 1 Story 1.1 (scaffold) + Epic 3 Story 3.3 (finalize) | ✓ Covered |
| FR-18 | Cross-runtime invocation (Claude Code, Desktop, BMAD, LLM shells) | Epic 3 Story 3.4 | ✓ Covered |

### NFR Coverage Matrix

| NFR | Description | Epic / Story Coverage | Status |
|---|---|---|---|
| NFR-1 | Scoring agent voice — direct, warm, efficient | Epic 2 Story 2.6 | ✓ Covered |
| NFR-2 | Research agent voice — analyst, sourced, ≤200 words | Epic 2 Story 2.4 | ✓ Covered |
| NFR-3 | Cross-runtime function — single canonical SKILL.md | Epic 3 Story 3.4 | ✓ Covered |
| NFR-4 | Research agent inline fallback (no subagents) | Epic 2 Story 2.4 + Epic 3 Story 3.4 | ✓ Covered |
| NFR-5 | Freeform numerics — no enforced bounds | Epic 1 Story 1.2 | ✓ Covered |
| NFR-6 | Research agent never assigns/recommends a score | Epic 2 Story 2.4 | ✓ Covered |

### Coverage Statistics

- **Total PRD FRs:** 18
- **FRs covered in epics:** 18
- **Coverage:** 100%
- **Total NFRs:** 6
- **NFRs covered in epics:** 6
- **NFR Coverage:** 100%

### Missing Requirements

None. All 18 FRs and 6 NFRs have traceable story coverage.

## UX Alignment Assessment

### UX Document Status

**Not Found.** No UX design document exists in `planning_artifacts`.

### Assessment

**UX document is not required.** Winnow is a conversation skill — explicitly not a web application, not a visual UI. Per PRD §5.3:

> Winnow is **not** a web application, a spreadsheet plugin, or a visual UI. It is a conversation skill.

Per PRD §5.1 (Out of Scope for MVP):

> Visual UI or web artifact [future]

The "user experience" for Winnow is defined via:
- **User journeys** UJ-1 and UJ-2 (PRD §2.3) — implemented across Epics 1–3
- **Tone specifications** (PRD §6) — scoring agent voice (NFR-1, Story 2.6) and research agent voice (NFR-2, Story 2.4)
- **Conversation flow** — structured as a state machine across the three epics

### Warnings

None. No UI components, accessibility requirements, responsive design, or visual patterns are implied. The conversational UX is fully addressed by NFR-1 and NFR-2 in the story acceptance criteria.

## Epic Quality Review

### Epic Structure Validation

#### User Value Focus

| Epic | User-Centric Title | User Outcome | Pass? |
|---|---|---|---|
| Epic 1 | Quick Decision — Default RICE, Inline Items, Ranked Table | User invokes Winnow, scores items with defaults, sees ranked table | ✓ |
| Epic 2 | Research & Refinement — Customization, Research Agent, Review Loop | User gets evidence-backed scores, customizes criteria, iterates rankings | ✓ |
| Epic 3 | Output & Distribution — Reports, Artifacts, Cross-Runtime | User gets shareable reports and Winnow runs on their preferred LLM platform | ✓ |

No technical-milestone epics (no "Database Setup", "API Development", "Infrastructure Setup"). All pass user-value test.

#### Epic Independence

| Check | Assessment |
|---|---|
| Epic 1 stands alone | ✓ — complete end-to-end session: invoke → score → ranked table |
| Epic 2 functions with Epic 1 output | ✓ — extends scoring loop; needs session state from Epic 1 |
| Epic 3 functions with Epic 1+2 output | ✓ — generates reports from scores and review data |
| No forward dependencies across epics | ✓ — Epic 2 doesn't need Epic 3; Epic 1 doesn't need Epics 2 or 3 |

### Story Dependency Analysis

**Epic 1 (3 stories):**
- 1.1 → standalone (SKILL.md scaffold + bootstrap). ✓
- 1.2 → depends on 1.1 (session state). ✓
- 1.3 → depends on 1.2 (scores). ✓

**Epic 2 (6 stories):**
- 2.1 → depends on Epic 1 (criteria to customize). ✓
- 2.2 → depends on Epic 1 (criteria to weight). ✓
- 2.3 → depends on Epic 1 (session to import into). ✓
- 2.4 → depends on Epic 1 scaffold; standalone subagent. ✓
- 2.5 → depends on 2.4 (research agent) + 1.2 (scoring loop). ✓
- 2.6 → depends on 2.5 (scoring complete). ✓

**Epic 3 (4 stories):**
- 3.1 → depends on Epics 1+2 (scores + review complete). ✓
- 3.2 → depends on Epics 1+2 (same data). ✓
- 3.3 → depends on Epics 1+2 (research artifacts). ✓
- 3.4 → depends on 3.3 (final dir layout). ✓

**Result:** No forward dependencies found in any epic. All stories build only on previous stories or completed epics.

### Story Quality Assessment

#### Sizing & Completeness

All 13 stories are sized for single dev agent completion. Each story has:
- Clear user story (As a/I want/So that)
- Multiple Given/When/Then acceptance criteria
- Error/edge case coverage (non-numeric validation, empty input, missing files, subagent unavailability, no-signals research, etc.)

#### Acceptance Criteria Quality

Sampled review:

| Story | ACs | Happy Path | Error Cases | Testable |
|---|---|---|---|---|
| 1.1 | 5 | ✓ category, domain, criteria, items, directory | ✓ empty domain context, free text category | ✓ |
| 1.2 | 4 | ✓ criterion-first loop, score recording | ✓ non-numeric re-prompt, all pairs completed | ✓ |
| 2.3 | 6 | ✓ structured format, H2 format, template gen | ✓ heuristic fallback, ambiguous parsing, malformed input | ✓ |
| 2.4 | 4 | ✓ agent creation, evidence report | ✓ no signals found, subagent unavailable | ✓ |
| 3.2 | 3 | ✓ JSON generation, schema match | ✓ empty research array | ✓ |

No vague ACs. All criteria are specific and independently testable.

### File Churn Assessment

**SKILL.md** is the single canonical file for the Winnow scoring agent. It is touched across all 3 epics:

- Epic 1: Session bootstrap and basic scoring flow
- Epic 2: Extended scoring with research, customization, review
- Epic 3: Report generation tie-ins

**Assessment:** This pattern is inherent to a single-file conversation skill. Each epic appends a distinct, non-overlapping conversation phase to the same linear flow. The churn is additive (new sections appended), not rework of existing sections. Considered and accepted during epic design with the rationale that a single SKILL.md is the architectural requirement (NFR-3: "single canonical SKILL.md").

### Database/Entity Check

Not applicable. Winnow has no database. State is conversational (in-memory during session) and serialized to files at session end.

### Starter Template / Greenfield

No Architecture doc specifies a starter template. The project is greenfield — Epic 1 Story 1 creates the SKILL.md scaffold from scratch using the PRD-defined directory structure.

### Best Practices Compliance

| Criterion | Status |
|---|---|
| Epics deliver user value | ✓ |
| Epics function independently | ✓ |
| Stories appropriately sized | ✓ |
| No forward dependencies | ✓ |
| Tables/entities created when needed | N/A |
| Clear acceptance criteria | ✓ |
| Traceability to FRs maintained | ✓ |

### Findings Summary

| Severity | Count | Details |
|---|---|---|
| 🔴 Critical | 0 | — |
| 🟠 Major | 0 | — |
| 🟡 Minor | 1 | Story 2.5 and Story 3.3 both reference research artifact writing (`research/<criterion>-<item-slug>.md`). Slight redundancy in responsibility — 2.5 writes during scoring, 3.3 ensures finalization and directory creation. Not a dependency issue; clarify ownership during implementation. |

## Summary and Recommendations

### Overall Readiness Status

**READY** — The project is clear for Phase 4 implementation.

### Assessment by Dimension

| Dimension | Status | Notes |
|---|---|---|
| PRD completeness | ✓ | 18 FRs, 6 NFRs, clear testable consequences, glossary |
| Architecture | ○ | Missing — decisions captured inline in PRD §4.3, §4.6; acceptable for conversation skill |
| UX Design | ○ | Missing — not required (conversation skill, no visual UI) |
| FR coverage in epics | ✓ | 100% — all 18 FRs and 6 NFRs have traceable story coverage |
| Epic quality | ✓ | User-value focused, independently functional, no forward deps |
| Story quality | ✓ | Proper BDD ACs, error cases covered, single-agent sized |

✓ = Pass  ○ = N/A or acceptable gap  ✗ = Fail

### Critical Issues Requiring Immediate Action

None.

### Findings Summary

- **0 critical** issues blocking implementation
- **0 major** issues requiring rework
- **1 minor** observation (research artifact writing ownership between Stories 2.5 and 3.3 — clarify during implementation)

### Recommended Next Steps

1. **[SP] Sprint Planning** (`bmad-sprint-planning`) — generate the sequenced story implementation plan from `epics.md`
2. **[CS] Create Story** (`bmad-create-story`) — prepare the first story (1.1: Skill Scaffold & Session Bootstrap) with full dev context
3. **[DS] Dev Story** (`bmad-dev-story`) — implement Story 1.1
4. **Iterate** through remaining 12 stories following sprint plan order

### Final Note

This assessment found 0 blocking issues across 5 dimensions of analysis. The epics and stories are well-formed, cover all requirements, and are ready for a dev agent to begin implementation. Winnow's unique nature as a conversation skill (single SKILL.md, no database, no UI) means fewer documents are needed than for a traditional web application — the missing Architecture and UX docs are appropriate gaps for this product type.
