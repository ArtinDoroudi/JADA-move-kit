# MANIFEST

Created 2026-11-23 on Artin's Mac (macOS, Apple Silicon). Trial restore of repos, files and the NPRI Core database passed on the Mac.

## Git bundles (all local branches, full history)

| Bundle | Branch | Commit | Message |
|---|---|---|---|
| JADA-SOLUTIONS.bundle | main | 1ee0492 | Document private workspace clone URL |
| npri-clarity-frontend.bundle | codex/welding-npri-v0 | b49a637 | Checkpoint unfinished welding NPRI v0 workspace |
| npri-clarity-frontend.bundle | main | efe0928 | Save frontend workflow updates and workspace setup |
| npri-clarity-frontend.bundle | npri-core | 3fae4a6 | feat(npri): show instant workbook totals and second checks |
| npri-reporter-backend.bundle | codex/welding-npri-v0 | dc4d8db | Checkpoint unfinished welding NPRI v0 with verification handoff |
| npri-reporter-backend.bundle | main | ca29307 | Organize backend setup and pin compatible task transport |
| npri-reporter-backend.bundle | npri-core | 738467f | feat(npri): calculate workbook edits before independent approval |

GitHub remotes: JADA-SOLUTIONS → ArtinDoroudi/JADA-SOLUTIONS, backend → ArtinDoroudi/npri-reporter, frontend → ArtinDoroudi/npri-clarity. Only `main` exists on GitHub; `npri-core` and `codex/welding-npri-v0` exist only in these bundles.

## Versions on the Mac

- Python 3.13.3 (backend venvs), bun 1.3.14, Docker 28.0.4, images postgres:16 and redis:7-alpine
- NPRI Core: alembic head a3d8f2c7b641, tests_npri = 527 tests collected, workbook parity 393/393
- Main: alembic head c8e4f2a6b917 · v0: alembic head c3d4e5f6a7b8

## Ports

| Stack | Postgres | Redis | API | Web |
|---|---|---|---|---|
| NPRI Core | 127.0.0.1:55433 (container jada-npri-core-postgres, user npri_core, DBs npri_core_dev + npri_core_test) | 127.0.0.1:56380 (jada-npri-core-redis) | 58320 | 58321 |
| v0 | 127.0.0.1:55432 (compose project jada-npri-v0, user npri_v0) | 127.0.0.1:56379 | 58000 | 55173 |
| main | 5432 (compose project npri-reporter, user npri) | 6379 | 8000 | 5173 |

## Sizes

```
 24M  repos
 16M  workspace
852M  private
354M  private/ai-history
321M  private/archive
4.6M  private/databases
 44M  private/documents
 20K  private/env
4.0K  private/README.md
128M  private/storage
```

## Not included (on purpose)

- `node_modules`, `.venv`, `__pycache__`, `.output`: reinstalled on the new machine (Mac binaries don't run on Windows).
- `JADA-NPRI-V0-preview`: a throwaway preview copy of v0; v0 itself is included.
- Codex/Claude login tokens (`~/.codex/auth.json` etc.): sign in again on the new machine.
- Other projects in ~/Online, and old Docker containers unrelated to JADA.
