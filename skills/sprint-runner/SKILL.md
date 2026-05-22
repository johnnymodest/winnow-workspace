---
name: sprint-runner
description: Executes ready-for-dev sprint stories through dev and review. Use when user says 'run sprint' or 'execute sprint stories'.
---

# Sprint Runner

## Overview

This skill executes ready-for-dev stories from a sprint status file. Each story goes through up to 4 sub-agents, each in a **fresh context**: implementer (`bmad-dev-story`) → reviewer (`bmad-code-review`) → fixer (`bmad-dev-story`, if findings remain) → verifier (`bmad-code-review`, final gate). Splitting implementation and review into separate sub-agents keeps context under 100K tokens and ensures the reviewer sees only final code — not the implementer's reasoning trail. The parent sprint-runner orchestrates the phases and sub-agents delegate all work to BMad skills (never implementing or reviewing directly). Output is a deferred-decisions.md artifact capturing findings that need human input.

## Conventions

- Bare paths resolve from the skill root.
- `{skill-root}` resolves to this skill's installed directory.
- `{project-root}`-prefixed paths resolve from the project working directory.
- `{skill-name}` resolves to the skill directory's basename.

## On Activation

Load available config from `{project-root}/_bmad/config.yaml` and `{project-root}/_bmad/config.user.yaml` if present. Use sensible defaults for anything not configured.

If invoked with `--headless` or `-H`, set headless mode: skip all confirmations, but a target epic is still required. If no epic was specified in the invocation, list the available epics from sprint-status.yaml and stop with a message asking the user to specify one.

If the user specifies a target epic (e.g. "epic 3"), lock scope to that epic. Otherwise, list available epics and ask which one to process.

## Stage 1: Setup

Read `{project-root}/docs/_bmad-output/implementation-artifacts/sprint-status.yaml`.

Parse the `development_status` section. Identify stories with status `ready-for-dev` within the target epic. Stories with any other status (`done`, `in-progress`, `review`, `backlog`) are skipped — the sprint-runner only picks up stories explicitly marked ready. Combine the project root with the `story_location` field from sprint-status.yaml to construct each story file path (e.g., if `story_location` is `docs/_bmad-output/implementation-artifacts`, the path is `{project-root}/docs/_bmad-output/implementation-artifacts/<story-id>.md`).

If no ready-for-dev stories exist in the target epic, report and stop.

Display the story list and confirm with the user (skip in headless mode). In headless mode, launch up to `--max-parallel` sub-agents at once (default: 1, sequential). When `--max-parallel` is greater than 1, launch that many sub-agents in parallel, then launch the next batch as each finishes.

## Stage 2: Dispatch Sub-Agents

Each story goes through up to 4 sub-agents, each in a **fresh context** (never reuse a sub-agent session). Keeping implementation and review separate prevents context to grow past 100K tokens and ensures the reviewer sees the code with fresh eyes — not through the implementer's reasoning trail.

The parent (sprint-runner) orchestrates the phases. The parent only reads sprint-status.yaml and sub-agent JSON results — never loads story files or project code. Sub-agents delegate all real work to BMad skills, never implementing or reviewing directly.

### Processing loop (per story)

For each story, execute these phases sequentially. In `--max-parallel` mode, multiple stories can be in different phases simultaneously, but phases within a story are always sequential.

#### Phase A: Implement

Spawn an **implementer** sub-agent (`subagent_type: general`, fresh context):

```
Your ONLY job: load the `bmad-dev-story` skill and execute it against {story-file-path}.
Let it run to completion. Do NOT intervene, do NOT implement code yourself.
When it finishes, return this JSON (extract from the story file's Dev Agent Record and File List):
```json
{{
  "status": "ok" | "failed",
  "story_id": "{story-id}",
  "files_changed": ["<path>", ...],
  "tests_added": <number>,
  "tests_total_pass": <number>
}}
```
If the skill HALTs or the status is not "review", set status to "failed" and report the reason.
```

Parent checks: if `status == "failed"`, stop the sprint and report which story failed.

#### Phase A.5: Commit implementation

The parent commits the implementation changes before proceeding to review:

```
Stage all files listed in files_changed: `git add <file1> <file2> ...`
Commit with message: `git commit -m "story {story-id}: implement — {tests_added} tests, {tests_total_pass} passing"`
```

If `git commit` fails with "nothing to commit", skip quietly. If it fails for any other reason, report and halt. This creates an atomic checkpoint: the reviewer sees exactly what the implementer produced, and the diff is cleanly scoped to this story.

#### Phase B: Review

Spawn a **reviewer** sub-agent (`subagent_type: general`, **fresh context** — not the implementer's session):

```
Your ONLY job: load the `bmad-code-review` skill and run it against {story-file-path}.
You have never seen the implementation process — you see only the final code. This is adversarial review.
When it finishes, return this JSON:
```json
{{
  "status": "ok" | "failed",
  "story_id": "{story-id}",
  "findings_count": <number>,
  "findings_remaining": <number>
}}
```
Count findings from the "Senior Developer Review (AI)" section in the story file.
If the skill HALTs, set status to "failed".
```

Parent checks: if `findings_remaining == 0`, the story is clean — skip to **Phase D.5: Architecture review gate**.

#### Phase C: Fix (only if findings remain)

Spawn a **fixer** sub-agent (`subagent_type: general`, **fresh context**):

```
Your ONLY job: load the `bmad-dev-story` skill and execute it against {story-file-path}.
It will detect the review continuation from the story file and address remaining findings.
Let it run to completion. Do NOT intervene.
When it finishes, return this JSON:
```json
{{
  "status": "ok" | "failed",
  "story_id": "{story-id}",
  "files_changed": ["<path>", ...],
  "tests_added": <number>,
  "tests_total_pass": <number>
}}
```
```

Parent checks: if `status == "failed"`, stop.

#### Phase C.5: Commit fixes

The parent commits the fix changes:

```
Stage all files listed in files_changed: `git add <file1> <file2> ...`
Commit with message: `git commit -m "story {story-id}: fix review findings — {tests_added} tests, {tests_total_pass} passing"`
```

If `git commit` fails with "nothing to commit", skip quietly. If it fails for any other reason, report and halt. This creates an atomic checkpoint of the fix pass, keeping it separate from the initial implementation commit.

#### Phase D: Verify (final review)

Spawn a **verifier** sub-agent (`subagent_type: general`, **fresh context**):

```
Your ONLY job: load the `bmad-code-review` skill and run it against {story-file-path}.
This is the final quality gate — fresh eyes on the fixed code.
When it finishes, return this JSON:
```json
{{
  "status": "ok" | "failed",
  "story_id": "{story-id}",
  "findings_remaining": [
    {{ "finding": "<description>", "reason": "architectural" | "cross-story" }}
  ]
}}
```
Extract findings from the "Senior Developer Review (AI)" section.
Findings that remain after 2 fix passes are deferred — include them here.
```

Parent collects `findings_remaining` as deferred items for this story.

#### Phase D.5: Architecture review gate

If findings_remaining contains items with `"reason": "architectural"`, OR the story's Dev Notes / Files Affected mention shared mutable state, timers, resource limits, concurrency, caching, unbounded collections, or cross-cutting concerns, spawn an architecture review sub-agent:

```
Your ONLY job: perform an architecture review of the changes made in {story-file-path}.

Check for these structural concerns:
1. **Shared mutable state** — static/global variables, module-level state, singletons modified by multiple callers
2. **Unbounded growth** — Sets, Maps, Arrays without TTL, LRU, or size limits; collections that grow with user activity
3. **Concurrency** — async operations in request handlers without synchronization; race conditions in webhooks, SSE, or event processing
4. **Resource limits** — timers, intervals, connections that are never cleaned up; missing abort controllers or cancellation
5. **Brittle coupling** — deep relative imports (../../../../), duplicated logic across modules, missing abstractions

Return this JSON:
```json
{{
  "status": "ok" | "action-required",
  "story_id": "{story-id}",
  "arch_findings": [
    {{ "finding": "<description>", "file": "<path>", "severity": "high" | "medium" | "low", "fix": "<recommended approach>" }}
  ]
}}
```

If `status == "action-required"`, add each finding back as a deferred decision for human review and block marking done.
```

Parent checks: if `status == "action-required"`, append `arch_findings` to the story's `findings_remaining` list and do NOT mark the story done — it stays `review` for human intervention. Otherwise, proceed.

#### Phase E: Mark done

The parent marks the story done:
- Update `{sprint-status-path}`: set `{story-id}` to `"done"`
- Update the story file Status to `"done"`
- Accumulate the implementer's `files_changed`, `tests_added`, `tests_total_pass` for the handoff summary

## Stage 3: Handoff

Write `{project-root}/docs/_bmad-output/implementation-artifacts/deferred-decisions.md`:

```markdown
---
created: {iso-timestamp}
sprint: {epic-key}
stories_processed: [story-id, ...]
---

# Deferred Decisions — {epic-key}

## Story: {story-id}

- **Finding:** {description}
  **Reason deferred:** {architectural | cross-story impact}
```

Summarize: stories processed, stories done, total tests added, count with deferred findings, path to deferred-decisions.md.
