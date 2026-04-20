---
name: orchestrate-subagents
description: >
  Coordinate long-horizon coding work by acting as a project manager:
  analyze requirements, split work across parallel subagents, integrate
  results, and verify outcomes. Use when tasks are broad, multi-file, or
  benefit from parallel implementation, research, or review.
---

# Orchestrate Subagents

## Overview

Operate as the project manager and technical lead. Keep the critical path local, delegate bounded slices to subagents, and integrate their results into one coherent implementation.

## Working with ExecPlans

ExecPlans are authored via `$execplan`, which owns the format and authoring standards. This skill owns execution and delegation. When an ExecPlan exists for the current task, it is the authoritative source of truth.

1. **Locate and read the exec plan first** — before decomposing work, find the relevant file in `execplans/` or as indicated by the user. Read it fully.
2. **Derive acceptance criteria from the plan** — use the plan's Milestones and "Validation and Acceptance" sections as the authoritative acceptance criteria. Do not invent separate criteria.
3. **Update the plan as work proceeds** — after each milestone completes, update `Progress`, `Surprises & Discoveries`, and `Decision Log` per the `$execplan` authoring rules.
4. **Never mark a milestone `[x]` until its validation commands have passed.** A milestone that has code written but no passing validation is still `[ ]`.

## Workflow

1. Clarify the goal, constraints, and acceptance criteria. If an exec plan exists, read it first.
2. Break the work into dependency-aware slices aligned with the plan's milestones.
3. Decide what must stay local and what can be delegated.
4. Assign each subagent one ownership area and one concrete deliverable.
5. Launch independent slices in parallel.
6. Synthesize the results, reconcile conflicts, and make the final integration edits.
6a. For each completed slice, launch a Reviewer with the diff and exec plan acceptance criteria. Block integration until the Reviewer approves.
7. Validate the full result with tests, commands, or direct inspection.
8. Update the exec plan to reflect completed milestones and any discoveries.

## Delegation Rules

- Use subagents for self-contained work such as module implementation, test coverage, documentation updates, or codebase investigation.
- Prefer parallel work when slices do not share write paths.
- Keep architecture decisions, cross-cutting coordination, and final merges local.
- Give each subagent a tight brief: goal, ownership boundary, constraints, and expected output.
- Do not duplicate the same work in multiple agents.
- Do not ask subagents to coordinate with each other unless there is no alternative.
- If a task is small, tightly coupled, or mostly one file, do it locally.
- If a subagent finds an unexpected dependency, stop that lane and re-plan.

## Decision Stability

Once an execution method is chosen for a milestone, keep it sticky. Subagents must continue with the chosen method unless they can show a concrete blocker, a clear acceptance-criteria mismatch, or a material risk or complexity reduction from switching.

Preference alone is not enough to reopen the decision.

Workers may propose a different method, but they must not switch strategies unilaterally. Structured objections go to the orchestrator, who decides whether to keep the current method, revise the ExecPlan, or escalate to the user.

Use this objection format:

- current chosen method
- concrete problem observed
- impact on correctness, risk, or validation
- proposed alternative
- supporting evidence from the repo, plan, or test surface
- whether the objection is `execution-only` or `scope-affecting`

If the objection is `scope-affecting`, pause and ask the user before proceeding.

## Suggested Roles

- **Explorer**: inspect the codebase, locate relevant files, and summarize patterns.
- **Worker**: implement one bounded slice with explicit file ownership. Execute the current plan rather than re-architecting it; if you object, escalate with the structured objection format instead of changing course on your own.
- **Verifier**: run tests, inspect diffs, or validate behavior independently. If no tests exist for the module, the Verifier must write a minimal smoke test or document explicitly why one isn't needed.
- **Reviewer**: launched after every non-trivial Worker, before integration. Given the Worker's diff/output and the original acceptance criteria from the exec plan. Must independently verify correctness, identify gaps or regressions, and either approve or return specific findings. The orchestrator synthesizes Reviewer findings before merging; findings are never silently discarded. A Reviewer may also act as a tie-breaker when two materially different execution methods are both plausible and the orchestrator wants an independent comparison against plan fit, repo conventions, risk, and validation burden. Reviewers should not invent a third direction unless both options are clearly unsound.

## Management Rules

- Start with a lightweight plan and update it as evidence changes.
- Track dependencies between lanes so the first blocker stays local.
- Keep the user informed about progress, tradeoffs, and integration status.
- Synthesize subagent output before making follow-up edits.
- Preserve repo conventions and respect existing changes.

## Validation Strategy by Change Type

Every lane must pass its typed validation before the orchestrator integrates the result.

| Change type | Required validation |
|---|---|
| Backend / API | `curl` against the running server; check response shape and status code |
| Database schema | Migration runs cleanly; query returns expected shape |
| Frontend (HTML/CSS/JS) | Playwright check via `$playwright` or `$webapp-testing` |
| Jobs / scripts | Dry-run or test invocation with known inputs |
| Config / infra | Ansible check-mode or diff review |

**Frontend rules:**
- Frontend changes are **never** considered done without a passing Playwright check.
- Choose the playwright skill by scenario:
  - `$playwright` — quick CLI snapshot or screenshot
  - `$webapp-testing` — multi-server headless automation
  - `$playwright-interactive` — iterative visual debugging
- If no tests exist for a module, the Verifier must write a minimal smoke test or document why one isn't needed.

## Quality Gates

- Map the final result back to the exec plan acceptance criteria explicitly.
- Every lane must pass its typed validation (see table above) before integration.
- If a Reviewer returns findings, the Worker relaunches with those findings appended as constraints. Findings are never silently discarded.
- Run the best available validation for the scope of the change.
- Resolve conflicting edits before finishing.
- Ensure the final result is understandable without reading agent transcripts.
