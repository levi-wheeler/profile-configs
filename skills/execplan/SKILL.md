---
name: execplan
description: >
  Author and maintain ExecPlans — the project's self-contained execution
  specifications for complex work. Triggers: writing features, significant
  refactors, creating specs, "make an execplan", "write an execplan",
  multi-agent context sharing, or any task that needs a persistent plan
  a future agent session can pick up and continue.
---

# ExecPlan Skill

## Purpose

ExecPlans are the primary mechanism for tracking complex work across agent sessions. Each ExecPlan is a fully self-contained specification that enables any agent — or a human novice — to implement a feature end-to-end without prior context.

This skill covers **authoring only**: creating, formatting, and maintaining ExecPlans. Execution and orchestration belong to `$orchestrate-subagents`.

## When to Create an ExecPlan

Create an ExecPlan when:

- The task spans multiple files, modules, or sessions
- A future agent will need to pick up where the current one left off
- The user asks for a spec, plan, or execplan
- Work involves significant refactoring or new feature development
- Multiple subagents need a shared source of truth

Do **not** create an ExecPlan for trivial edits, single-file fixes, or work that fits in one session without coordination.

## Lifecycle

1. **Create** — Research the problem, read relevant source code, and author the ExecPlan following the rules in `references/authoring-rules.md`. Start from the skeleton and flesh it out.
2. **Implement** — Invoke `$orchestrate-subagents` to execute the plan. The orchestrator reads this plan, derives acceptance criteria from its milestones and "Validation and Acceptance" sections, and coordinates all subagent work. Do not attempt to execute milestones directly in the `$execplan` skill; execution belongs to `$orchestrate-subagents`.
3. **Maintain** — Keep all sections current at every stopping point. Update `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` as work proceeds. Every revision must remain fully self-contained.
4. **Close** — Write a final `Outcomes & Retrospective` entry summarizing what was achieved, what remains, and lessons learned.

## Locating Existing Plans

ExecPlans live in `execplans/` at the repository root. Check there before creating a new plan — the work may already have one. Subdirectories (e.g., `execplans/pre-launch/`) group related plans.

## Authoring Rules

The full specification for ExecPlan format, requirements, and conventions is in [`references/authoring-rules.md`](references/authoring-rules.md). Read it before authoring or substantially revising any ExecPlan.

Key principles (see the reference for details):

- **Self-contained**: every plan includes all knowledge needed for a novice to succeed
- **Living document**: update as progress is made and decisions are finalized
- **Outcome-focused**: anchor to observable, verifiable behavior
- **Plain language**: define every term of art; no undefined jargon
- **Prose-first**: prefer sentences over lists except in `Progress` (where checklists are mandatory)

## Collaborative Planning

When the user wants to plan collaboratively (brainstorm, design, explore options):

1. Treat the conversation as the primary deliverable until the user approves a direction
2. Reflect the problem back, identify open decisions, get confirmation
3. Ask at most 1–3 focused questions at a time
4. Only write the ExecPlan once the user has approved the direction

## Working with `$orchestrate-subagents`

When an ExecPlan exists and work is being orchestrated:

- The orchestrator reads the plan and derives acceptance criteria from it
- The orchestrator updates `Progress`, `Surprises & Discoveries`, and `Decision Log` as milestones complete
- This skill owns the **format and authoring standards**; the orchestrator owns **execution and delegation**
