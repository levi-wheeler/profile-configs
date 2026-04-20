# Agent Instructions

**Root path:** `/path/to/project-root`. Agents starting in `~` should route here via `~/AGENTS.md` before running project commands. Once here, this file is authoritative.
**Frontends:** Public site `https://public.example.internal/` - Admin site `https://admin.example.internal/`

## Database

PostgreSQL container `<db_container_name>`, exposed on `localhost:<db_port>`.

```text
postgresql://<db_user>:<db_password>@localhost:<db_port>/<db_name>
```

- From inside another container: `host.containers.internal:<db_port>`
- Development credentials may use local defaults; production values should come from your secret manager or vault
- Data directory: `{{ host_runtime_root }}/containers/<data_dir>` (rootless, owned by `<runtime_user>`)

## Git Safety Rules (MUST FOLLOW - NO EXCEPTIONS)

**NEVER run any of the following git commands without first asking the user for explicit confirmation:**

- `git restore` in any form
- `git checkout -- <file>` or `git checkout .`
- `git reset --hard`
- `git clean -f`, `git clean -fd`, `git clean -fdx`
- `git stash drop` or `git stash clear`
- Any command that discards or overwrites uncommitted working tree changes

**Why:** These commands can permanently destroy unstaged work. A single accidental restore can wipe out an entire day of work across many files.

**What to do instead:**
1. Run `git status --short` before doing anything that might affect the working tree.
2. If you need to undo your own changes to a file, use a targeted restore on only the specific files you just modified, and still ask first.
3. If the worktree looks dirty and you are unsure whether the changes belong to the user or a previous agent, ask before touching anything.
4. Prefer `git stash` over irreversible commands when you need to temporarily set work aside.

This rule applies to all agents, including autonomous or autopilot sessions.

## Permissions + TLS Guardrails (must follow)

Use these defaults to avoid recurring rootless runtime and self-signed certificate issues.

- Runtime posture: application containers and runtime data are rootless and owned by `<runtime_user>`. Keep system-level components rootful if your environment requires it.
- Do not run container lifecycle commands as `root` when the app is designed for rootless execution; use the rootless user context instead.
- Prefer repo deploy wrappers over raw infrastructure commands for routine deploys:
  - `./scripts/deploy_frontend.sh`
  - `./scripts/deploy_api.sh`
- If you must run automation directly, run playbooks from repo root with a namespaced path:
  - `ansible-playbook ansible/playbooks/<group>/<playbook>.yml`
- If ownership drifts and you see permission problems under your runtime directories, repair them with the project's rootless ownership playbook or equivalent workflow.
- Rootless sanity checks:
  - `loginctl show-user <runtime_user> | rg Linger`
  - `sudo -u <runtime_user> podman ps`

### Self-signed cert workflow

- Internal or local HTTPS endpoints may be self-signed; CLI checks should use insecure mode when appropriate:
  - `curl -k https://public.example.internal/`
  - `curl -k https://admin.example.internal/`
- In smoke tests or API tasks that hit these endpoints, keep certificate validation disabled unless trust is explicitly provisioned.
- For Playwright CLI flows against these hosts, configure the browser context to ignore HTTPS errors.

## Collaborative Planning (must follow)

- If the user asks to plan, brainstorm, design, or "plan this together", treat the conversation itself as the primary deliverable until the user approves a direction.
- In planning mode, do **not** update `docs/planning/`, `docs/implementation/`, or an ExecPlan immediately after first understanding the request. First, reflect the problem back to the user, identify the open decisions, and get confirmation on the approach.
- Before writing planning docs, summarize the proposed direction in chat and call out the main tradeoffs or alternatives when more than one reasonable path exists.
- Ask at most 1-3 focused planning questions at a time, then wait for the user's answer before continuing.
- After each user reply, restate what changed in the plan before moving on to the next decision.
- Only write or update `docs/planning/`, `docs/implementation/`, or an ExecPlan once the user has approved the direction being recorded.
- During collaborative planning, avoid silently converting rough ideas into finalized scope without an explicit checkpoint.

## Scope & Docs (must follow)

- Keep the files in `docs/planning/` as the single source of truth for scope and decisions. Do not change scope, add behavior, or start non-trivial implementation unless the change is recorded there.
- Update order is **`docs/planning/` first, then the corresponding execution details in `docs/implementation/`**. Implementation docs are execution detail only and should not introduce new scope.
- Before coding non-trivial work, confirm requirement status in the relevant planning document. For trivial edits that do not change behavior or scope, `docs/ProjectMap.md` plus the immediately relevant files is enough.
- If anything is ambiguous, pause and ask clarifying questions before implementing.
- Stable IDs live only in `docs/planning/`; `docs/implementation/` should reference existing IDs and must not invent new ones.
- If requirements are not written yet, draft them in `docs/planning/` and get approval before implementing.
- `docs/planning/` should capture durable acceptance or launch-gate criteria when those criteria are part of the lasting requirement. Execution sequencing belongs in `docs/implementation/`.

## Read Order For New Agents On Non-Trivial Work

1. `docs/ProjectMap.md` for repo structure and task-specific orientation.
2. The relevant files in `docs/planning/` for scope, decisions, and non-goals.
3. The relevant files in `docs/implementation/` for execution order, runtime posture, API contracts, schema details, and surface behavior.
4. `docs/frontend/new-page-guide.md` only when adding a new public page.

## Key Docs For Agents

- `docs/planning/` for scope, decisions, and requirement status
- `docs/implementation/` for playbooks, runtime posture, jobs, API contracts, schema, and surface details
- `docs/ProjectMap.md` for the shortest path to the right files

## Deployment

After making code changes, deploy them so they take effect on the running app.

| Changed path | Deploy command |
|---|---|
| `frontend/site/` | `./scripts/deploy_frontend.sh` |
| `api/` | `./scripts/deploy_api.sh` |

Adjust these mappings to match the actual surfaces in your repository.

## Session Completion

- After code changes, run the relevant existing tests, linters, or builds before handoff.
- Summarize what changed, what was verified, and any remaining follow-ups.
- Commit or push only when the user asks for it or when the task explicitly includes landing changes remotely.
- Do not clear stashes or prune branches unless the user explicitly requests cleanup.
