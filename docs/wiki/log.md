# Changelog

Append-only. Newest entries at the bottom. Never edit or remove past entries.
Format defined in [`../schema/AGENTS.md`](../schema/AGENTS.md).

## 2026-09-06 — Repository scaffold

- Ingested: setup task defining the AI boilerplate environment (LLM wiki
  pattern + modular skills architecture). No files added to `docs/raw/`.
- Created capabilities layer: `.ai/skills/go-standards.md`,
  `.ai/skills/php-standards.md`, `.ai/agents/` (empty), and root
  `AGENTS.md` with the dynamic context-loading rules.
- Created documentation layer: `docs/raw/`, `docs/wiki/`, `docs/schema/`,
  the documentation protocol at `docs/schema/AGENTS.md`, and this log.
- Index: initialized `docs/wiki/index.md` with empty category sections.

## 2026-09-06 — HoYoLAB daily check-in automation

- Ingested: `docs/raw/2026-09-06-hoyolab-daily-signin.md` — captured
  browser `curl` for the HoYoLAB `sol/sign` endpoint (credentials
  redacted), with field notes on headers, auth cookies, and retcodes.
- Created `docs/wiki/scheduled-automations.md` (process) — the
  one-workflow-per-task pattern, script conventions, and secret
  naming/scoping guidance.
- Created `docs/wiki/hoyolab-daily-signin.md` (component) — the workflow
  and script, env configuration, `HOYOLAB_COOKIE` secret, retcode
  handling, and operational notes (cookie expiry, ToS).
- Index: added the two pages under Processes and Components.

## 2026-09-06 — Scope automation secrets to GitHub Environments

- Decision: each scheduled automation names a bare GitHub Environment
  (`environment: <service>`, no protection rules) so its credential is
  isolated from other workflows.
- Updated `docs/wiki/scheduled-automations.md` (shape + Secrets sections)
  and `docs/wiki/hoyolab-daily-signin.md` (Secret section, files table)
  to require the `hoyolab` environment.
- Updated `.github/workflows/hoyolab-genshin-signin.yml`: added
  `environment: hoyolab` to the job and revised the setup comment.
