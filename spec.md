# Requirements & Plan Document Generation Specification

## 1. Purpose

This specification defines exactly how a coding agent must create a **combined Requirements Document, Plan Document, and Task List Document** for any feature description provided by the user.

The agent's goal is to produce:

- A clear, professional, and comprehensive requirements section from a **user perspective**.
- A detailed, technically accurate design section from a **developer perspective**.
- A document that is structured identically for every feature, ensuring consistency and ease of reading.
- Code that, when implementation begins, must follow:
  - Readability and maintainability best practices.
  - Proper variable naming and code organization.
  - Inline comments only where logic is non-trivial.
  - Error handling at system boundaries.
- A final output that is **self-contained** — a developer unfamiliar with the feature must be able to implement it without further clarification.

---

## 2. Workflow & Approval Gates

The agent must run the following six phases **in order**. Phases 4 and 6 are hard gates: the agent must stop and wait for the user to approve before continuing.

1. **Discovery** — analyze the codebase first (RipGrep, fzf, or the `Explore` subagent). Identify affected modules, existing conventions, similar implementations, and reusable utilities. Only after this may the agent draft a spec.
2. **Clarification** — if requirements are ambiguous, the agent must ask clarifying questions **before** drafting the spec. Every inferred decision must be labeled in the spec as `**Assumption:** <decision> — <reason>`.
3. **Spec drafting** — generate `.specs/[NN]_[feature_name]_spec.md` containing the metadata (§4), Requirements Document (§5), Plan Document (§6), an initial Traceability Matrix (§8), and the Draft Spec Compliance Checklist (§11.1) result. **No code may be written during this phase.**
4. **Spec approval gate** — the agent stops and waits for explicit user approval of the Requirements and Plan sections before generating the Task List.
5. **Task List generation** — append §7 (Task List Document) to the same spec file, update the Traceability Matrix (§8), and complete the Task List Compliance Checklist (§11.2). Every task must back-reference the requirement and design IDs it implements.
6. **Task approval gate** — the agent stops again and waits for explicit user approval of the Task List before writing any implementation code.

**File-naming rule:** `[NN]_[feature_name]_spec.md`, where `NN` is a zero-padded two-digit number incremented from the highest existing number in `.specs/` and `feature_name` is lower snake case (for example, `01_login_spec.md`, `02_payment_checkout_spec.md`).

**Tool guidance:**

- **Context7 MCP** — use for library, framework, SDK, and API documentation during *Discovery* and *Research* (§6.10). If Context7 is unavailable, fall back to official documentation or current web research, and record the fallback in the Research subsection.
- **Sequential Thinking MCP** — use for complex prompts during *Understanding* (§6.2) and *Solution Design* (§6.3).
- **Research provenance** — every external source cited in §6.10 must include the source URL, documentation version (when available), and the research date (`YYYY-MM-DD`), so future readers can judge staleness.

---

## 3. Document Structure

A generated `.specs/[NN]_[feature_name]_spec.md` file uses this exact section order:

1. **Generated Spec Metadata** (§4) — at the very top.
2. **Requirements Document** (§5).
3. **Plan Document** (§6).
4. **Task List Document** (§7) — appended only after the spec is approved at the gate in §2 phase 4.
5. **Short Summary** (§7.5) — appended together with the Task List, between the Task List Document and the Traceability Matrix.
6. **Traceability Matrix** (§8) — always at the end of the spec.

The first draft contains sections 1, 2, 3, and 6. The Task List and Short Summary sections are added together later at the approval gate.

---

## 4. Generated Spec Metadata

Every generated spec file must begin with a metadata header (YAML front-matter or a Markdown table). All seven fields are required.

```yaml
---
spec_id: 02
feature_name: payment_checkout
status: draft            # draft | awaiting-approval | approved | in-progress | complete
created: 2026-05-12
last_updated: 2026-05-12
source_prompt: |
  Verbatim or summarized user request that triggered this spec.
assumptions:
  - Stripe will be used for card processing because the codebase already integrates it.
  - Refunds are out of scope for v1.
---
```

`status` must be kept current as the spec progresses through the gates in §2.

---

## 5. Requirements Document

The Requirements Document describes **what** the feature does from the end-user's point of view.

### 5.1 Introduction

- 2–4 sentences summarizing the feature.
- State the intended audience or user role, the main goal, and the business value.
- Avoid implementation details.

### 5.2 Functional Requirements

Each functional requirement gets a stable ID `REQ-NNN` (zero-padded, incremented from `REQ-001`).

Each requirement must include:

1. **User Story**, in the format:
   > As a [role], I want [goal], so that [benefit].

2. **Acceptance Criteria** — a numbered list. Each criterion gets a stable ID `AC-NNN` (incremented globally across the spec, not reset per requirement). Criteria use the full **EARS** grammar; pick the form that fits the situation:

   - **Event-driven:** `WHEN <trigger> THEN <expected behavior>`
   - **State-driven:** `WHILE <state> THE SYSTEM SHALL <behavior>`
   - **Unwanted-behavior / conditional:** `IF <condition> THEN <behavior>`
   - **Optional-feature / context:** `WHERE <context> THE SYSTEM SHALL <behavior>`
   - **Compound:** `WHEN <trigger> AND <condition> THEN <behavior>`

   Each criterion must be specific, measurable, and unambiguous.

### 5.3 Non-Functional Requirements

Each NFR gets a stable ID `NFR-NNN`. The spec must address every category below; if a category does not apply, write `None — <one-line justification>`.

- **Performance** — latency, throughput, resource budgets.
- **Security** — authentication, authorization, input validation, secrets handling.
- **Accessibility** — keyboard navigation, screen-reader support, color contrast (for UI features).
- **Observability** — logs, metrics, tracing, alerts.
- **Reliability** — error rates, retries, graceful degradation, rollback.
- **Compatibility** — supported browsers, OS versions, API versions, backwards-compat.

Each NFR must include numbered acceptance criteria using the same EARS grammar as §5.2.

### 5.4 Out of Scope

A bullet list of work explicitly **not** covered by this spec. If everything in the user's request is in scope, write `None`. This section prevents scope creep during implementation.

### 5.5 User Journeys

A short numbered walk-through of the happy path and 1–2 key alternate paths from the user's perspective. Optional, but strongly encouraged for any feature with a UI or multi-step user interaction.

---

## 6. Plan Document

The Plan Document describes **how** the feature will be built from the developer's point of view.

### 6.1 Introduction

2–6 sentences covering:

- Technical details of the core implementation.
- Technical constraints.
- Expected outcomes and success criteria.
- Integration points with existing systems.
- Performance and scalability requirements.
- Specific technologies or frameworks used.

### 6.2 Understanding

- Restate the user's request in the agent's own words to confirm understanding.
- List **key objectives**, requirements, and constraints.
- List any clarifying questions still open (these should be resolved before this section is finalized).

### 6.3 Solution Design

A complete solution design containing:

- **High-level approach** — what will be built and why this approach is best.
- **Data flow & architecture** — how components and modules interact.
- **Step-by-step execution plan** — an ordered list of actions.
- **Edge cases & failure handling** — how the solution handles unexpected input or errors.
- **Scalability & performance considerations**.

Each architectural decision gets a stable ID `DES-NNN` and a line listing the requirements it satisfies, for example: `DES-003 — satisfies: REQ-001, REQ-004`.

### 6.4 Components & Interfaces

For each new or modified module, list:

- **Name**.
- **Responsibility** — one sentence.
- **Public API signature** — function or class signatures the rest of the system calls.
- **File path** — relative to the repository root.

### 6.5 Dependencies

List any new libraries, frameworks, or tools to be added. For each:

- **Name**.
- **Version constraint**.
- **Reason for choice** (one sentence).

### 6.6 Integration Points

Concrete fenced code snippets showing how new code plugs into existing modules. Each snippet must use the correct language identifier (for example `elixir`, `javascript`, `sql`, `json`) and be syntactically correct.

### 6.7 Testing Strategy

Describe how the feature will be verified across these layers (use `None — <reason>` for any layer that does not apply):

- **Unit tests**.
- **Integration tests**.
- **End-to-end tests**.
- **Regression tests**.
- **Manual QA**.

Each planned test gets a stable ID `TEST-NNN` and a line listing the acceptance criteria it verifies, for example: `TEST-002 — verifies: AC-003, AC-004`.

### 6.8 Rollout Plan

Describe how the change ships safely:

- **Migration steps** — database migrations, data backfills, config changes.
- **Backwards compatibility** — how existing callers, data, or contracts remain unbroken during deployment.
- **Rollback procedure** — concrete steps to revert if the change fails in production.
- **Observability** — new logs, metrics, traces, or alerts to add.
- **Feature flags** — gating strategy, if applicable.

If a sub-item does not apply, write `None — <reason>`.

### 6.9 Risks & Mitigations

A short table identifying the most significant risks:

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Example risk | Low / Medium / High | Low / Medium / High | One-sentence mitigation |

If there are no material risks, write `None`.

### 6.10 Research

Web research findings relevant to the feature. For every citation, record:

- **Source URL**.
- **Documentation version** (when available).
- **Research date** (`YYYY-MM-DD`).

Cover, where applicable: best practices, library documentation, similar implementations, common patterns, alternative approaches considered. If Context7 MCP was unavailable and a fallback source was used, note it.

### 6.11 Codebase Analysis

For an existing codebase, document:

- Architecture patterns observed.
- Coding conventions in use.
- Testing approaches in use.
- Similar implementations already in the repo (with file paths).
- Integration points new code must hook into.
- Existing utilities or helpers to reuse.

---

## 7. Task List Document

Generated **only after** the Requirements and Plan sections are approved (gate in §2 phase 4). Appended to the same `.specs/[NN]_[feature_name]_spec.md` file, then the Traceability Matrix (§8) must be updated with final `TASK-NNN` mappings.

### 7.1 Format

A Markdown checklist. Tasks must be ordered in implementation sequence and topologically sorted by dependency: setup, data/model changes, core logic, integrations, UI/API surfaces, tests, documentation, final verification.

Each task must use this format:

```markdown
- [ ] **TASK-NNN** [type] <single concrete action>. Paths: `<path>` or `N/A — <reason>`. Implements: `REQ-NNN`, `DES-NNN` or `N/A`. Verifies: `TEST-NNN` covering `AC-NNN` or `N/A`. Depends: `TASK-NNN` or `None`. Done when: <observable completion condition>.
```

Allowed task types:

- `[setup]`
- `[migration]`
- `[model]`
- `[service]`
- `[api]`
- `[ui]`
- `[integration]`
- `[test]`
- `[docs]`
- `[verification]`

### 7.2 Task Rules

- Each task must describe exactly one implementation action.
- Every implementation task must reference at least one `REQ-NNN` and one `DES-NNN`.
- Every test task must reference the relevant `TEST-NNN` and the acceptance criteria covered by that test.
- Verification-only tasks may use `Implements: N/A`, but must include the exact command or manual check in `Done when`.
- File paths are required when known. If no file path applies, use `Paths: N/A — <reason>`.
- Do not renumber approved task IDs. If a task changes materially after approval, append a new task ID and mark the old task as superseded.

### 7.3 Granularity

Tasks must be small enough for a developer to complete and verify independently. Avoid broad tasks such as *"implement checkout"*. Prefer tasks such as *"Add `CheckoutSession` schema in `lib/app/billing/checkout_session.ex` with fields `:user_id`, `:provider_id`, and `:status`."*

A good task has:

- One primary file or closely related file group.
- One clear behavioral outcome.
- One completion condition.
- Explicit dependency references when ordering matters.

### 7.4 Required Coverage

The Task List must include tasks for:

- Creating each new file or directory.
- Modifying each existing file named in Components & Interfaces.
- Adding or updating each dependency from Dependencies.
- Implementing each integration point from Integration Points.
- Creating migrations, seeds, or config changes from Rollout Plan.
- Writing every test from Testing Strategy.
- Running final verification commands, including relevant test, lint, build, or manual QA checks.

### 7.5 Short Summary

After the Task List Document, the agent must append a `## Short Summary` section to the generated spec file. It appears between the Task List Document (§7) and the Traceability Matrix (§8) in the generated `.specs/[NN]_[feature_name]_spec.md`.

The Short Summary is written for a human reader — typically a developer, reviewer, or stakeholder who wants to understand what the spec is about in under a minute, without reading the full Requirements and Plan sections.

Requirements:

- **Length** — 3–6 short sentences, or a 4–6 item bullet list. No long paragraphs.
- **Audience** — human reader, plain language. No `REQ-NNN`, `DES-NNN`, `TASK-NNN`, or `AC-NNN` references.
- **Content** — cover, in plain terms: what the feature does, who it is for, why it is being built, and the high-level approach. Optionally one sentence on what is explicitly out of scope.
- **Tone** — clear, simple, and professional. Avoid jargon and internal acronyms unless already defined in the spec.
- **Source of truth** — the summary describes the spec; the spec is not derived from the summary. If the summary and the body disagree, the body wins and the summary must be updated.

This section is informational only and is not part of the Traceability Matrix.

---

## 8. Traceability Matrix

A required table at the end of every generated spec, mapping every artifact end-to-end. This lets a reviewer confirm that every requirement has design, task, and test coverage.

During the first draft, task coverage is not available yet; use `Pending task approval` in the `TASK-IDs` column. After Task List generation, update every row with final task IDs.

```
| REQ-ID | AC-IDs           | DES-IDs | TASK-IDs        | TEST-IDs |
| ------ | ---------------- | ------- | --------------- | -------- |
| REQ-001 | AC-001, AC-002  | DES-001 | Pending task approval | TEST-001 |
| REQ-002 | AC-003          | DES-002 | Pending task approval | TEST-002 |
```

Every `REQ-NNN` must appear in this table with at least one design mapping and one test mapping in the first draft. After Task List generation, every `REQ-NNN` must also have at least one task mapping.

---

## 9. Style & Formatting Rules

- **Voice** — refer to the actor as "the agent" throughout. Do not use "I", "you", or "AI".
- **Dates** — ISO format (`YYYY-MM-DD`).
- **File paths** — relative to the repository root.
- **Headings** — `#` for the spec title, `##` for top-level document sections and the matrix, `###` for subsections, and `####` for individual requirement or NFR entries when needed.
- **Bold** — for component names, file paths, variables, and important terms.
- **Lists** — numbered for acceptance criteria and ordered steps; bullets for unordered items.
- **Code blocks** — fenced, with correct language identifiers. All snippets must be syntactically correct.
- **Avoid** vague filler such as "etc." or "and so on" — list the items explicitly.
- Maintain a clear, professional tone throughout.

---

## 10. Output Guarantees

The agent must:

- **Always** produce the Requirements and Plan sections, the Metadata header, and the Traceability Matrix on the first pass.
- **Always** produce the Task List after the Requirements and Plan sections are approved, then update the Traceability Matrix.
- **Never** omit acceptance criteria for any requirement.
- If a required subsection does not apply, write `None — <reason>` rather than removing the heading.
- Mark every inferred decision as `**Assumption:** <decision> — <reason>` and also list it under `assumptions:` in the metadata header.
- If details are missing, ask clarifying questions **before** generating the spec.

---

## 11. Compliance Checklist

### 11.1 Draft Spec Compliance Checklist

Before finalizing the initial spec draft, the agent must verify each item below.

- [ ] Metadata header present, all seven fields filled.
- [ ] Requirements Document, Plan Document, and Traceability Matrix present.
- [ ] Every functional requirement has `REQ-NNN`, a User Story, and numbered `AC-NNN` acceptance criteria.
- [ ] NFR section addresses all six categories (or each missing category has an explicit `None — <reason>`).
- [ ] Out-of-Scope section present (or explicit `None`).
- [ ] Plan Document contains all eleven subsections (§6.1 – §6.11).
- [ ] Each `DES-NNN` lists which `REQ-NNN`(s) it satisfies.
- [ ] Components & Interfaces lists file paths for every entry.
- [ ] Dependencies entries include name, version, and reason.
- [ ] Integration Points use fenced code blocks with correct language identifiers.
- [ ] Testing Strategy maps each `TEST-NNN` to the `AC-NNN`(s) it verifies.
- [ ] Rollout Plan present, including rollback steps (or explicit `None` per sub-item).
- [ ] Risks table populated (or explicit `None`).
- [ ] Research entries include source URL, version, and research date.
- [ ] Task List is absent unless the spec was approved at the gate in §2 phase 4.
- [ ] Initial Traceability Matrix maps every `REQ-NNN` to `AC-NNN`, `DES-NNN`, and `TEST-NNN`; `TASK-IDs` may be `Pending task approval`.
- [ ] No placeholders (`TBD`, `TODO`) remain.
- [ ] All assumptions explicitly labeled in both the metadata header and the body.
- [ ] All code snippets use fenced code blocks with correct syntax highlighting.

### 11.2 Task List Compliance Checklist

Before finalizing the Task List, the agent must verify each item below.

- [ ] Task List exists only after Requirements and Plan approval.
- [ ] Every task follows the §7.1 task format.
- [ ] Every implementation task references `REQ-NNN` and `DES-NNN`.
- [ ] Every test task references `TEST-NNN` and the acceptance criteria it covers.
- [ ] Every task has file paths or `Paths: N/A — <reason>`.
- [ ] Every task has `Depends:` set to another task ID or `None`.
- [ ] Every task has an observable `Done when:` condition.
- [ ] Tasks are ordered in implementation sequence and dependency order.
- [ ] Traceability Matrix is updated so every `REQ-NNN` has at least one `TASK-NNN` and one `TEST-NNN`.
- [ ] Final verification tasks include exact test, lint, build, or manual QA commands/checks.

---

## 12. Appendix: Spec Skeleton

Copy-paste skeleton for a new `.specs/[NN]_[feature_name]_spec.md` file. Replace every placeholder before the spec is submitted for approval.

````markdown
---
spec_id: NN
feature_name: <lower_snake_case_name>
status: draft
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
source_prompt: |
  <verbatim or summarized user request>
assumptions:
  - <assumption — reason>
---

# NN — <Feature Title>

## Requirements Document

### Introduction
<2–4 sentences: audience, main goal, business value>

### Functional Requirements

#### REQ-001 — <name>

**User Story**

> As a <role>, I want <goal>, so that <benefit>.

**Acceptance Criteria**

1. **AC-001** — WHEN <trigger> THEN <expected behavior>.
2. **AC-002** — IF <condition> THEN <behavior>.

### Non-Functional Requirements

#### NFR-001 — Performance
1. **AC-003** — WHEN <trigger> THEN response time SHALL be under <N> ms at the 95th percentile.

#### NFR-002 — Security
<criteria or `None — <reason>`>

#### NFR-003 — Accessibility
<criteria or `None — <reason>`>

#### NFR-004 — Observability
<criteria or `None — <reason>`>

#### NFR-005 — Reliability
<criteria or `None — <reason>`>

#### NFR-006 — Compatibility
<criteria or `None — <reason>`>

### Out of Scope
- <item>
- <item>

### User Journeys
1. **Happy path:** <numbered steps>
2. **Alternate path:** <numbered steps>

---

## Plan Document

### Introduction
<2–6 sentences of technical detail>

### Understanding
<restate request, list objectives>

### Solution Design

**High-level approach** — <text>

**Data flow & architecture** — <text or diagram>

**Step-by-step execution plan**
1. <step>
2. <step>

**Edge cases & failure handling** — <text>

**Scalability & performance** — <text>

**Decisions**
- **DES-001** — <decision>. satisfies: REQ-001
- **DES-002** — <decision>. satisfies: REQ-002

### Components & Interfaces
- **<Module>** — <responsibility>. API: `<signature>`. Path: `<path/from/repo/root>`.

### Dependencies
- **<library>** `<version>` — <reason>.

### Integration Points

```<language>
<snippet>
```

### Testing Strategy
- **Unit:** **TEST-001** — verifies: AC-001, AC-002
- **Integration:** **TEST-002** — verifies: AC-003
- **End-to-end:** <or `None — <reason>`>
- **Regression:** <or `None — <reason>`>
- **Manual QA:** <or `None — <reason>`>

### Rollout Plan
- **Migration:** <steps or `None`>
- **Backwards compatibility:** <text>
- **Rollback:** <steps>
- **Observability:** <new logs/metrics/alerts>
- **Feature flag:** <strategy or `None`>

### Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| <risk> | <L/M/H> | <L/M/H> | <mitigation> |

### Research
- <source URL> — version <X>, accessed YYYY-MM-DD — <one-line takeaway>

### Codebase Analysis
- **Patterns:** <text>
- **Conventions:** <text>
- **Testing approach:** <text>
- **Similar implementations:** `<path>` — <text>
- **Reusable utilities:** `<path>` — <text>

---

## Task List Document
<!-- Appended only after spec approval -->

- [ ] **TASK-001** [setup] <single concrete action>. Paths: `<path>`. Implements: `REQ-001`, `DES-001`. Verifies: `N/A`. Depends: `None`. Done when: <observable completion condition>.
- [ ] **TASK-002** [test] <single concrete test action>. Paths: `<path>`. Implements: `REQ-001`, `DES-001`. Verifies: `TEST-001` covering `AC-001`, `AC-002`. Depends: `TASK-001`. Done when: <exact command or manual check passes>.

---

## Short Summary

<3–6 sentence plain-language description of what this feature spec is about, who it is for, why it is being built, and the high-level approach. No requirement, design, task, or AC IDs.>

---

## Traceability Matrix

| REQ-ID | AC-IDs | DES-IDs | TASK-IDs | TEST-IDs |
| --- | --- | --- | --- | --- |
| REQ-001 | AC-001, AC-002 | DES-001 | TASK-001 | TEST-001 |
| REQ-002 | AC-003 | DES-002 | TASK-002 | TEST-002 |
````
