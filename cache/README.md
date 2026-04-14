# cache/

Runtime scratch folder for local state, logs, and downloaded artifacts.

This folder is **gitignored** — nothing inside is committed except this README
and `.gitkeep` (so the folder exists after a fresh clone).

## What goes here

Anything that is:

- **Regenerable** — sync state JSON, cache indexes, crawl results
- **Transient** — log files from scripts, scratch images/screenshots
- **Local-only** — per-machine state that shouldn't be shared via Git

Examples from sibling repos:

- `*-sync-state.json` — last-run state for recurring jobs
- `*.log` — rolling logs from scheduled scripts
- `name-cache.json` — cached lookups to avoid repeated API calls
- `logos/`, `*-frame.jpg` — downloaded or generated media

## What does NOT go here

- Source code (goes in `src/`)
- Knowledge base notes (goes in `knowledge-base/`)
- Documentation (goes in `docs/`)
- Config or secrets (use `.env` or `.claude/`)

## Gitignore rules

The root `.gitignore` already excludes `cache/`. If you need to commit a
specific file from this folder, add a negation rule:

```
cache/
!cache/README.md
!cache/.gitkeep
!cache/your-file-to-commit.json
```
