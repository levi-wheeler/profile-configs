---
name: agent-handoff
description: >
  Write, pick up, and clear a single shared handoff file between agent sessions.
  Use only when the user explicitly invokes this skill by name (for example,
  "$agent-handoff") or explicitly asks to write/read/clear the shared handoff file.
  Do not use for normal tasks or implicit context transfer.
---

# Agent Handoff

Use this skill only on explicit user request.

## Rules

1. Require explicit invocation before reading or writing the handoff file.
2. Use one shared file: `/tmp/codex-agent-handoff.md`.
3. Write atomically to avoid partial handoffs.
4. Include `ready: true` only when handoff content is complete.
5. On pickup, read then clear the file.
6. Keep handoff concise and action-oriented.

## Commands

Use `scripts/handoff_file.sh`:

```bash
# Write atomically from stdin
cat <<'HANDOFF' | /home/rocky/.codex/skills/agent-handoff/scripts/handoff_file.sh write
ready: true
timestamp: 2026-03-12T19:05:00-07:00
branch: main
commit: abc1234

goal:
- ...

completed:
- ...

key_files:
- /abs/path/file.ext :: why it matters

verification:
- command: ...
- result: PASS

remaining_work:
1. ...
2. ...

blockers_risks:
- ...

assumptions:
- ...

next_command:
- ...

next_agent_prompt:
- ...
HANDOFF

# Read without clearing
/home/rocky/.codex/skills/agent-handoff/scripts/handoff_file.sh read

# Pick up and clear (fails unless ready: true)
/home/rocky/.codex/skills/agent-handoff/scripts/handoff_file.sh pickup

# Clear file manually
/home/rocky/.codex/skills/agent-handoff/scripts/handoff_file.sh clear
```

## Handoff Template

Use this structure:

```markdown
ready: true
timestamp: <ISO-8601>
branch: <git-branch>
commit: <short-sha>

goal:
- <target outcome>

completed:
- <concrete change>

key_files:
- </abs/path/file> :: <reason>

verification:
- command: <exact command>
- result: <PASS|FAIL|NOT RUN>
- notes: <key output or reason>

remaining_work:
1. <highest priority next step>

blockers_risks:
- <risk and mitigation>

assumptions:
- <assumption to validate>

next_command:
- <first command to run>

next_agent_prompt:
- <copy/paste prompt for the next agent>
```
