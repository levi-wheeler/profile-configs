# Planning: Admin

## Purpose

Describe the goals for the administrative control plane and internal workflows.

## Admin Priorities

- Operators should be able to understand system state quickly.
- Long-running work should expose progress, status, and failure reasons.
- Administrative tools should favor explicit actions over hidden automation.
- Recovery paths should be available for common failure states.

## Core Workflow Themes

- monitoring jobs and scheduled work
- reviewing queued content or records
- managing configuration and operational settings
- inspecting system state and troubleshooting issues

## UX Principles

- Preserve route state when moving between related admin views.
- Prefer simple, direct controls for high-impact actions.
- Make stale, blocked, or incomplete work obvious.

## Out Of Scope For This File

- Exact route inventories
- Fine-grained keyboard shortcuts
- Schema-level implementation detail
