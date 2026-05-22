# PRD Quality Review — Winnow

## Overall verdict
The PRD is solid — a clear thesis (structured, research-assisted, RICE-based decisions with human judgment at the center) runs consistently from Vision through FRs. Non-goals do real work, the glossary is crisp, and the conversation-flow FR structure fits the LLM-skill shape. What's at risk: scope honesty is undermined by a prematurely closed Open Questions section, missing `[ASSUMPTION]` inline tags despite claiming they exist, and zero `[NOTE FOR PM]` callouts at tensions the implementation will encounter. Success metrics are adequate but thin, with only one counter-metric guarding against a degenerate session.

## Decision-readiness — adequate
The PRD makes decisions clearly: the Non-Goals (§5) are explicit and rejecting (no web app, no persistent DB, no multi-user, English only), and the MVP scope (§6) draws unambiguous in/out lines with version tagging (`[v2]`, `[future]`, `[post-MVP]`). The Research Agent behavior profile (§4.4) contains a genuine design decision — evidence-first, confidence-signaled, never scores — that carries through FR-8.

However, the Open Questions section (§9) reads: *"All open questions resolved during PRD finalization. None outstanding."* This is improbable for a green-field PRD with no prior implementation. If the document was genuinely tension-free, the downstream implementation detail (how subagents fail over, what "speculative breakdown" means for Effort, how the review loop handles 50 items) suggests otherwise. The clean closure risks papering over decisions the dev agent will need to make unilaterally.

The Assumptions Index (§10) lists three assumptions, but none are tagged `[ASSUMPTION]` inline in the body, despite §0's declaration: *"Assumptions are tagged `[ASSUMPTION]` inline and indexed in §10."* The index references §4.1, §4.3, §4.5 — yet scanning those sections reveals no `[ASSUMPTION]` tokens. A decision-maker can't see at a glance where the footing is soft.

### Findings
- **high** Open Questions prematurely closed (§9) — "None outstanding" rings false given the implementation depth required for FR-6 (MD parsing heuristics), FR-8 (subagent fallback behavior), and FR-18 (cross-runtime dispatch). *Fix:* Restore 3–5 genuinely open questions — e.g., "How should Winnow handle a 50-item session in a context-limited runtime?" or "What's the fallback behavior when the LLM cannot invoke subagents at all?"
- **medium** Missing `[ASSUMPTION]` inline tags throughout (§10 vs. body) — The PRD's own convention is violated. The three indexed assumptions (researchable defaults, criterion-first loop order, no auto-finalize) lack visible tags where they appear. *Fix:* Add `[ASSUMPTION: …]` tags inline at each assumption's location in §4.1, §4.3, §4.5 matching the index entries.

## Substance over theater — strong
The PRD has one persona ("The decision-owner," §2.1) and it does work — drives the UJ, shapes the tone, and explains *why* someone needs this tool ("six open tabs, lost thread"). The Jobs To Be Done (§2.2) are specific and point back to feature choices (keeping the human in the loop, generating a shareable record). This is the opposite of persona theater.

The Vision (§1) is product-specific: it references the RICE framework, the human-scores/research-agent-gathers dynamic, the farming metaphor ("separating grain from chaff"), and the output artifacts. It would not swap into another PRD without change.

There is no NFR boilerplate — no "system must be scalable/secure/reliable" — which is correct for a conversation skill. The Non-Goals section (§5) substitutes for this and is pointed rather than performative.

### Findings
- **low** Vision could state the primary bet more sharply (§1). Currently it describes *what* Winnow does; it could add one sentence on *why this approach wins* over spreadsheets or gut-feel. *Fix:* Add: "The bet: structured conversation + delegated research without delegated judgment produces better, more defensible decisions than either pure intuition or pure spreadsheet — and leaves a record that holds up to stakeholder scrutiny."

## Strategic coherence — adequate
The thesis is consistent: structure the decision process, augment with research, keep the human as the scorer. The feature flow (§4) follows the thesis naturally — setup → intake → scoring → review → report. The feature is the flow, and it makes sense as a unified arc.

Success metrics are adequate but thin. SM-1 (under 15 min for 5×4) and SM-2 (80% completion) are reasonable but both measure throughput, not decision quality. SM-3 (at least one research dispatch used) measures feature adoption. SM-4 is qualitative and mushy: *"Users report the decision record was useful"* — measured by *"direct feedback in early adoption"* with no method or threshold. A PRD betting on "better decisions" should have at least one metric anchored to decision outcomes (e.g., "user reports increased stakeholder confidence in decision rationale").

The counter-metric SM-C1 is good and honest: *"A 3-minute session where the user accepted defaults for everything and researched nothing is not a win."* But one counter-metric alone can't balance four growth metrics. A second counter-metric would help — e.g., "session volume without completion" or "research requests per session declining over time."

The MVP scope (§6) has clear scope logic — it's an experience MVP, shipping the full conversation flow without integrations or persistence. The scope kind is coherent and matched.

### Findings
- **medium** Success metrics are throughput-skewed (§7). SM-1, SM-2, and SM-3 all measure usage/efficiency; only SM-4 nods at decision quality and it's qualitative without a method. *Fix:* Add a decision-quality metric, e.g., "SM-X: ≥70% of users rate the final ranked table as matching their own intuition OR as an insight they hadn't considered — measured via one-question post-session prompt." Add a second counter-metric alongside SM-C1.
- **low** SM-4 lacks a measurement method (§7). "Qualitative — measured via direct feedback in early adoption" is too vague for a PRD that will feed story creation. *Fix:* Specify "measured via a single Likert-scale question presented at session end" or "POST-session survey link embedded in report footer."

## Done-ness clarity — adequate
Every FR (FR-1 through FR-18) carries "Consequences (testable)" which is commendable. Many are genuinely testable: "Category is recorded in the output config block" (FR-1), "All scores are recorded in the scoring state, keyed by item × criterion" (FR-10), "The loop never ends without the user's explicit signal" (FR-12), "JSON structure: { meta: …, items: …, research: … }" (FR-15 with explicit schema). The low-confidence guardrail (FR-13) even specifies exact warning text.

Weak spots exist:
- FR-1: *"Category influences how the research agent frames its queries"* — this is descriptive, not testable. How does a tester verify that "features" → market/comparative research?
- FR-3: *"Score and weight values are freeform numeric. Winnow does not enforce a bounded range"* — this is a conscious design choice, but what happens when a user enters "banana" as a score? Or negative values? The PRD says "trusts the user" (FR-10) but soft validation boundaries are unstated.
- FR-7: *"The loop order is: all items for criterion 1, then all items for criterion 2"* — is this guaranteed, or is it default behavior that could vary by runtime? If it's guaranteed, say so; if it's a preference, flag it.
- FR-6: MD parsing heuristics — *"the first non-item line mentioning 'for' or a product name"* — is underspecified. What if the file has multiple such lines? What if it contains no such line?
- No FR addresses what happens when the user provides contradictory criteria (e.g., two criteria named "Impact") or when criteria labels collide with reserved terms.

No "reasonable performance," "user-friendly," or "handles X gracefully" weasel words found — a deliberate absence worth noting.

### Findings
- **medium** FR-1 consequence is descriptive, not testable (§4.1 FR-1). "Category influences how the research agent frames its queries (e.g., 'features' → market/comparative research; 'prospects' → company/fit research)" cannot be verified. *Fix:* Either make it testable (e.g., "Research agent prompt includes the category string verbatim") or move it to a note/design intent, not a testable consequence.
- **medium** MD parsing heuristic in FR-6 is fragile (§4.2 FR-6). "The first non-item line mentioning 'for' or a product name is treated as domain context" — undefined when multiple lines match or none do. *Fix:* Define a structured frontmatter convention for MD files as the canonical method; demote the heuristic to a fallback with explicit behavior on ambiguity.
- **low** No invalid-input behavior specified (§4.3 FR-10). "Scores are not validated for range or type — Winnow trusts the user." While trusting the user is a valid choice, a non-numeric entry in a weighted total calculation has undefined behavior. *Fix:* Add a consequence: "Non-numeric scores are caught with a prompt: 'I need a number for this score. Try again?'"

## Scope honesty — thin
The Non-Goals section (§5) is a standout: seven explicit rejections, each with a short justification. The MVP out-of-scope list (§6.2) extends this with eight items, each tagged with a version horizon. This is real scope honesty at work.

What undercuts it:
1. **Open Questions (§9) are closed prematurely.** "All open questions resolved during PRD finalization. None outstanding" — for a green-field PRD this is either dishonest or the resolution process surfaced no tensions, which is improbable. Implementation will surface at least: subagent availability detection, context-window management for large sessions (20+ items), what the speculative Effort breakdown actually contains, and how Winnow distinguishes between "items for a product" vs. "prospects" in research framing — a gap that FR-1 gestures at but doesn't resolve.
2. **No `[NOTE FOR PM]` callouts anywhere.** The entire PRD has zero. Given the cross-runtime ambition (FR-18: Claude Code, Claude Desktop, BMAD, "General LLM shells"), each with different subagent mechanisms, at least one `[NOTE FOR PM]` recognizing this as a runtime-specific tension would be expected. The "skill package structure" (FR-17) is clean, but whether a subagent-invocation pattern works identically across all four runtimes is an assumption worth calling out.
3. **Assumptions lack inline tags** despite §0 claiming they exist. The Assumptions Index (§10) references three assumptions but the body text at those locations reads as declarative consequences, not flagged assumptions.
4. **Open-items density** is 3 (assumptions) + 0 (open questions) + 0 (NOTE FOR PM) = 3 total. For a PRD going to implementation, this is low.

### Findings
- **critical** Open Questions section closed without any remaining items (§9). A green-field LLM skill with multi-runtime ambition, MD parsing heuristics, and subagent dispatch has unresolved tensions. *Fix:* Restore 3–5 open questions covering: (1) subagent availability detection and fallback UX, (2) maximum session size before context-window pressure, (3) how "speculative breakdown" for Effort is generated without hallucinating, (4) runtime-specific invocation differences.
- **high** No `[NOTE FOR PM]` callouts in the entire PRD. With zero callouts, the doc reads as if every decision has been finalized — which undercuts the scope honesty the Non-Goals section otherwise establishes. *Fix:* Add at least 3 callouts: (1) at FR-18 — "Cross-runtime subagent dispatch may vary; test on all four targets before launch," (2) at FR-6 — "MD parsing heuristics need real-world validation across user file formats," (3) at SM-2 — "80% completion target is aspirational; adjust after first 10 user sessions."
- **medium** Assumptions Index references untagged assumptions (§10 → §4.1, §4.3, §4.5). The PRD intro says assumptions are tagged inline — they aren't. *Fix:* Add `[ASSUMPTION: Classic RICE defaults — Reach/Impact/Confidence researchable; Effort not]` at FR-3, and equivalent tags at FR-7 and FR-12.

## Downstream usability — adequate
The glossary (§3) is strong — 11 terms defined, used consistently across the PRD. No synonym drift detected. FR / UJ / SM IDs are contiguous without gaps: FR-1 through FR-18, UJ-1 only, SM-1 through SM-4 plus SM-C1. Cross-references resolve (e.g., "Validates FR-7 through FR-13" in SM-1, "Realizes UJ-1 step 9–10" in §4.5).

UJ-1 references "A PM, C-level, or manager" — these are role examples that map to the singular persona "The decision-owner" (§2.1) but don't restate the exact label. The mismatch is conceptually clear but mechanically imprecise for downstream story creation where a story might reference "decision-owner" yet the UJ text uses "PM, C-level, or manager." This is minor.

The MD file shortcut is a path variant within UJ-1, not a separate UJ — reasonable, since it's an entry-point variation rather than a distinct user journey. That said, the MD shortcut has its own set of parsing rules and behaviors (FR-6) that a separate UJ-2 would help distinguish during story creation.

Sections largely stand alone when extracted — e.g., §4.1 (Session Setup) references glossary terms and FR IDs, not "see above." The Assumptions Index cross-references by § number, which would break if sections were reordered — but for a static PRD this is acceptable.

Report generation (FR-14, FR-15) specifies output structures with sufficient detail that a story author could extract them directly without re-interpreting.

### Findings
- **low** UJ-1 persona reference is not an exact label match (§2.3 UJ-1 vs. §2.1). UJ-1 says "A PM, C-level, or manager" while the persona is "The decision-owner." *Fix:* Change UJ-1 to: "Persona + context: The decision-owner with a set of options to rank."
- **low** Single UJ may under-represent the MD shortcut path (§2.3). The MD file shortcut has distinct behavior (parsing, format detection, context extraction) that could benefit from a UJ-2 to isolate its testing surface. *Fix:* Consider extracting a UJ-2: "A decision-owner imports a pre-prepared item list from an MD file."

## Shape fit — strong
Winnow is an LLM skill — a conversation product with a single-operator role. The PRD's shape reflects this precisely:
- One persona, not a cast of characters.
- One primary UJ with a variant, not a sprawling journey map.
- FRs structured around the conversation flow (setup → intake → scoring → review → report), not around system components.
- No wireframes, mockups, or visual design specs — correct for a conversation product. The "Aesthetic and Tone" section (§8) is the appropriate equivalent, defining voice and character rather than pixels.
- No traditional NFR section (scalability, availability, latency percentiles) — correct for a non-hosted LLM skill.
- The Research Agent behavior profile (§4.4) uses input/output contracts — appropriate for the subagent dispatch architecture.
- Cross-runtime ambition (FR-18) is acknowledged but not over-specified for any single runtime — the `SKILL.md` is the canonical interface.

The rigor level is calibrated: FRs have testable consequences, IDs are contiguous and cross-referenced, and the glossary is robust. This is not an under-formalized "hobby" spec nor an over-formalized enterprise capability spec with UJs for single-click actions. It fits the product.

### Findings
- None.

## Mechanical notes
1. **`[ASSUMPTION]` inline tagging gap.** §0 states: *"Assumptions are tagged `[ASSUMPTION]` inline and indexed in §10."* The Assumptions Index (§10) lists three assumptions referencing §4.1, §4.3, §4.5 — but scanning those sections reveals no `[ASSUMPTION]` tokens in the body. The index round-trips (every indexed assumption appears somewhere in the referenced section), but the visual tagging convention the PRD promises is absent.
2. **UJ persona label mismatch.** UJ-1 uses "A PM, C-level, or manager" while the defined persona label is "The decision-owner" (§2.1). Not a drift in meaning, but a mechanical imprecision for downstream workflows that may reference personas by exact label.
3. **ID continuity.** Clean. FR-1 through FR-18, UJ-1 only, SM-1 through SM-4 + SM-C1. No gaps, no duplicates.
4. **Glossary drift.** No synonym drift detected. "Item," "criterion/criteria," "research agent," "scoring agent," "slug," "category," "domain context" are used consistently. "RICE" and "Simplified RICE" are defined and used as defined.
5. **Required sections.** All expected sections present for the product type and stated stakes.
