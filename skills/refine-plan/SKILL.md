---
name: refine-plan
description: >
  Refine an existing ExecPlan in place through 3-5 bounded critique-and-revision
  passes. Use when the user asks to refine, strengthen, tighten, review, or
  make an ExecPlan implementation-ready, or asks to find gaps in a plan's
  sequencing, validation, testing, or execution readiness. This skill improves
  how the plan gets executed, but must pause and ask the user before making
  changes that would alter functionality, scope, or acceptance criteria.
---

# Refine Plan

Refine an existing ExecPlan in place. This skill is for strengthening execution quality, not for silently changing product scope.

Use this skill when:

- The user points at an ExecPlan and wants iterative refinement.
- A draft plan feels vague, incomplete, weakly validated, or not ready for implementation.
- You need to tighten testing, sequencing, recovery guidance, or repository-specific detail without changing what the plan is supposed to deliver.

Do not use this skill to create a new plan from scratch. Use `$execplan` for authoring new ExecPlans.

## Goal

Produce an ExecPlan that is precise, executable, and hard to misread. The plan itself should remain fully self-contained, novice-readable, and highly specific about how the work gets done. The chat summary after refinement should stay concise.

## Core Boundary

Refinement may improve:

- implementation detail
- file and command specificity
- sequencing and milestone clarity
- validation and testing expectations
- assumptions, risks, and recovery steps
- overall structure and readability

Refinement must not silently change:

- user-visible functionality
- feature scope
- constraints or non-goals
- acceptance criteria that alter the intended outcome

If a missing detail would change what gets built, pause and ask the user before continuing.

## Decision Stability

Refinement should reduce execution ambiguity, not create plan churn. When the ExecPlan already selects a viable implementation method for a milestone, keep that method sticky unless there is a concrete reason to change it.

Good reasons to revise the chosen method:

- the current method conflicts with acceptance criteria
- the current method introduces a concrete blocker or unexpected dependency
- the alternative materially lowers risk, complexity, or validation burden
- new repository evidence shows the original method does not fit local conventions or architecture

Insufficient reasons to revise the chosen method:

- personal preference for a different pattern
- stylistic disagreement without execution impact
- speculative concern unsupported by repository evidence

If a proposed revision would change behavior, scope, constraints, non-goals, or acceptance criteria, stop and ask the user before making it.

## Pass Count

Run 3 passes by default.

Increase to 4 or 5 passes only when the ExecPlan is broad, risky, migration-heavy, cross-system, or clearly underdeveloped.

Stop early when no high-severity gaps remain and the next pass would mostly rewrite wording instead of increasing executability.

## Workflow

### 1. Read and classify

Read the target ExecPlan closely before editing. Re-read the canonical `$execplan` authoring rules in `execplan/references/authoring-rules.md` before any substantial revision so the refinement stays aligned with the required format and standards. Determine:

- whether it is truly an ExecPlan rather than a generic planning note
- whether the plan is small UI polish, behavior change, bug fix, refactor, or cross-system feature work
- whether the remaining gaps are mostly "how" gaps or "what" gaps

Treat this classification as the basis for deciding pass count and testing expectations.

### 2. Detect blockers

Before any edit pass, check whether the plan is missing a decision that would change the implemented outcome.

Examples that require pausing and asking the user:

- multiple plausible behaviors are possible and the draft does not choose one
- the missing detail would change acceptance criteria
- the plan appears to assume scope that was never approved
- closing the gap would add or remove functionality

Examples that can be resolved autonomously:

- naming exact files, functions, routes, jobs, or commands
- tightening validation steps
- splitting a vague milestone into executable steps
- adding testing detail consistent with the stated goal
- documenting assumptions about implementation mechanics

When you make an execution-level assumption, record it explicitly in the ExecPlan.

When you believe the current implementation method is flawed, do not silently replace it. First classify the issue:

- `execution-only`: the intended outcome stays the same, but the plan's method should change
- `scope-affecting`: changing the method would also change behavior, scope, or acceptance criteria

For `execution-only` issues, record a structured objection in the ExecPlan or your working notes before revising:

- what method the plan currently chooses
- what concrete problem you found
- why it matters for execution or validation
- what alternative you propose
- what evidence from the repository or plan supports the alternative

For `scope-affecting` issues, stop and ask the user instead of filling in the gap yourself.

### 3. Run critique-and-revision passes

For each pass:

1. Identify the highest-value gaps using the rubric below.
2. Revise the file in place.
3. Re-read the updated plan and decide whether another pass is still justified.

Prefer substantive edits over stylistic cleanup. Reorganize the ExecPlan when the current structure makes execution harder, but preserve the original intent and keep any context that future implementers will need.

### 4. Stop criteria

Stop when all of the following are true:

- the plan is precise enough for reliable implementation
- no unresolved high-severity "how" gaps remain
- any remaining unresolved items are true scope questions that require the user
- further editing would mostly change tone or prose density

## Refinement Rubric

Use this rubric on every pass.

### Precision and self-containment

Check whether the ExecPlan names the exact repository paths, modules, functions, commands, and execution surfaces needed to do the work. Tighten vague references such as "update the backend" or "add tests" into concrete instructions. Preserve or add enough context, definitions, and orientation for a novice reader to execute the plan without relying on prior repository knowledge.

### User-visible outcome

Check whether the plan explains what someone can do after the change and how that outcome will be observed. If the plan only describes code edits, strengthen it until the resulting behavior is explicit.

### Sequencing and milestones

Check whether the order of operations is safe and realistic. Break vague milestones into concrete, independently verifiable increments when needed.

### Validation and acceptance

Check whether a human can prove the change works end-to-end. Validation must include exact commands or actions, the environment or working directory when relevant, and the expected observable result.

### Testing strategy

Check whether the plan includes durable testing that matches the size and risk of the change.

Use proportional expectations:

- Small UI-only changes may rely on Playwright or equivalent browser verification when long-term automated coverage is not warranted.
- Larger code changes should include durable automated tests.
- Bug fixes should add regression coverage whenever there is a sensible place to put it.
- If durable automated tests are impractical, the plan must say why and strengthen manual verification instead of pretending coverage exists.

Treat a missing testing strategy as a high-severity gap for non-trivial work.

### Risks, idempotence, and recovery

Check whether the plan explains what can be repeated safely, what can fail halfway, and how to retry or recover. Tighten any risky or destructive step.

### Assumptions and open decisions

Check whether assumptions are stated plainly. If a genuine scope decision is missing, stop and ask instead of filling it in.

### Living sections

Check that `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` are present and usable, not empty placeholders with no operational value.

### Canonical format and required sections

Check that the refined ExecPlan still conforms to the canonical `$execplan` authoring rules, including required sections, prose-first structure, explicit validation, and self-contained explanations. Do not compress or reorganize away context that a future implementer would need.

## Testing Expectations by Work Type

Use these defaults unless the repository context strongly suggests a better fit:

- `ui-polish`: require browser-driven verification such as Playwright, plus any nearby targeted tests if they already exist naturally.
- `behavior-change`: require durable automated coverage at the layer where the behavior lives, plus end-to-end validation when the change is user-facing.
- `bug-fix`: require a regression test whenever practical, plus a short note describing what bug the test guards against.
- `refactor`: require tests that prove behavior remains unchanged in the touched area.
- `cross-system feature`: require layered validation, usually a mix of targeted automated tests and end-to-end verification.

Do not demand a large long-term test harness for a tiny visual change. Do not accept hand-wavy manual testing for a meaningful code change.

## Editing Rules

- Edit the ExecPlan in place.
- Keep the refined ExecPlan aligned with `execplan/references/authoring-rules.md`.
- Keep the ExecPlan extremely precise and concrete.
- Optimize for executability without sacrificing novice readability or self-containment.
- Be concise, but never at the expense of executable detail.
- Remove repetition and filler when they do not improve correctness.
- Do not optimize away necessary context, definitions, or orientation just to make the plan shorter.
- Preserve the intended feature outcome unless the user approves a change.

## Success Criteria

The refinement is successful when all of the following are true:

- the skill triggers for requests to tighten, review, strengthen, or make an existing ExecPlan implementation-ready
- the refined plan preserves the intended outcome unless the user explicitly approves a change
- the refined plan contains concrete sequencing, validation, and testing guidance appropriate to the work type
- the refined plan is specific enough that a future implementer can execute it without guessing at major steps
- the refinement stops and escalates when the remaining gaps are really scope questions rather than execution questions

## Examples

### Example 1: Tighten a weak draft

User says: "Review this execplan and make it implementation-ready."

Actions:

1. Classify the work type and re-read the canonical authoring rules.
2. Identify high-severity gaps such as vague milestones, missing validation commands, and weak testing guidance.
3. Revise the plan in place without changing user-visible scope.
4. Stop once the plan is precise enough for reliable execution.

Result: The ExecPlan keeps the same intended outcome but becomes more concrete about file targets, milestone order, validation, and testing.

### Example 2: Detect hidden scope drift

User says: "Tighten this plan before we implement it."

Actions:

1. Read the draft and notice that one milestone quietly adds functionality not supported elsewhere in the plan.
2. Classify that gap as `scope-affecting` rather than `execution-only`.
3. Pause and ask the user instead of silently rewriting the plan around the new behavior.

Result: The refinement improves clarity without accidentally approving new scope.

### Example 3: Stop instead of over-editing

User says: "Do another pass on this execplan."

Actions:

1. Review the updated plan against the rubric.
2. Confirm there are no remaining high-severity execution gaps.
3. Stop early because another pass would mostly rewrite wording instead of improving executability.

Result: The skill avoids churn and preserves a stable implementation method once the plan is good enough.

## Troubleshooting

### The file is not really an ExecPlan

Symptom: The document is a loose planning note, brainstorm, or status dump rather than a self-contained execution plan.

Response:

1. State that the document is not yet a real ExecPlan.
2. If the user wants a new plan authored, use `$execplan` instead.
3. If the user only wants lightweight cleanup, limit changes to clarification and say that the document still needs full ExecPlan authoring.

### Repository evidence conflicts with the plan

Symptom: The codebase, file layout, or existing architecture contradicts the plan's chosen method.

Response:

1. Treat this as a possible `execution-only` objection first.
2. Record the concrete conflict and the repository evidence supporting it.
3. Revise the implementation method only if the intended outcome stays the same.
4. If resolving the conflict would change behavior or acceptance criteria, stop and ask the user.

### Refinement keeps uncovering "what" questions

Symptom: Each pass reveals missing product decisions rather than missing execution detail.

Response:

1. Stop the refinement loop.
2. Summarize the unresolved `scope-affecting` questions clearly.
3. Ask the user for the missing decisions instead of continuing to rewrite the plan.

### The draft has weak or missing validation

Symptom: Milestones describe code changes but do not explain how a human can prove they worked.

Response:

1. Treat this as a high-severity gap.
2. Add exact validation commands or actions, expected results, and working directory or environment details when relevant.
3. Strengthen testing guidance in proportion to the work type instead of leaving validation hand-wavy.

## Chat Output

After refinement, report back in concise prose. Keep the ExecPlan itself novice-readable and self-contained; the chat summary may be shorter and less detailed.

Include:

- what was strengthened
- any execution-level assumptions you added
- whether the plan now looks ready for implementation
- any blocked functionality-level questions, if refinement had to stop

Keep the chat summary shorter and less dense than the ExecPlan itself.
