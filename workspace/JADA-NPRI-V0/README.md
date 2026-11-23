# JADA NPRI v0 isolated workspace

This workspace contains separate `backend/` and `frontend/` Git worktrees on `codex/welding-npri-v0`. Its development services use isolated ports, a separate Compose project, and a unique PostgreSQL volume. The original `JADA-SOLUTIONS` checkout and its `npri-reporter` database remain separate.

## Local setup

Prerequisites: Python 3.13, Bun 1.3.14, and Docker Compose v2.

From `backend/`, create a fresh Python environment and install the pinned application requirements:

```sh
python3.13 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
if [ ! -e .env ]; then cp .env.v0.example .env; fi
```

From `frontend/`, install the frozen Bun dependency graph and create the ignored local browser configuration:

```sh
bun install --frozen-lockfile
if [ ! -e .env ]; then printf 'VITE_API_BASE_URL=http://localhost:58000\n' > .env; fi
```

The frontend `.env` points to the isolated backend port `58000`. No API service is defined in the isolated Compose file.

## Isolated infrastructure

Run these commands from `backend/`. They always name the v0 file and project; do not substitute the default `docker-compose.yml`.

```sh
docker compose -p jada-npri-v0 -f docker-compose.v0.yml config
docker compose -p jada-npri-v0 -f docker-compose.v0.yml up -d
docker compose -p jada-npri-v0 -f docker-compose.v0.yml ps
```

This binds PostgreSQL to `127.0.0.1:55432`, Redis to `127.0.0.1:56379`, and uses volume `jada-npri-v0-postgres-data`. The initial database is `npri_v0_test`, solely for the test suite. The configured development database `npri_v0_dev` is intentionally not created during environment preparation. Create it only after the application plan is approved and development use is needed.

## Safe verification

From `backend/`, with `.venv` active and the isolated PostgreSQL service available:

```sh
python -m pytest tests/ -v
```

The test fixture drops and recreates tables in `TEST_DATABASE_URL`; this environment points it only at `npri_v0_test`. Keep external LLM calls mocked. Use the v0 contract and isolated Compose project for migrations, seed data, API or worker runs.

The migration proof uses a separate dedicated database and refuses other database names. Create it once:

```sh
docker compose -p jada-npri-v0 -f docker-compose.v0.yml exec -T postgres createdb -U npri_v0 npri_v0_migration_test
DATABASE_URL=postgresql://npri_v0:npri_v0_local_only@127.0.0.1:55432/npri_v0_migration_test .venv/bin/python scripts/verify_workspace_migration.py
```

The proof downgrades and upgrades only the six workspace tables in that explicitly named test database; it never drops the database.

After plan approval, start the API from `backend/` with `.venv` active:

```sh
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 58000
```

Start the frontend from `frontend/`:

```sh
bun run dev --host 127.0.0.1 --port 55173
```

From `frontend/`:

```sh
bun run build
bun run lint
```

## Baseline before v0 implementation

The v0 worktrees were checked at the following clean `main` commits:

| Repository | Baseline commit |
|---|---|
| backend | `ca29307689c8bc1d34bdcd96b0c8708b9233faed` |
| frontend | `efe092844cc2583b5cfe27fc6ea4f498051b6885` |

Baseline results: backend `239 passed` (84.61 seconds on the first run); frontend build passed; frontend lint reported 68 existing Prettier errors and 7 Fast Refresh warnings. Raw command logs are kept outside the repository at `/tmp/jada-npri-v0-backend-baseline.log`, `/tmp/jada-npri-v0-frontend-build.log`, and `/tmp/jada-npri-v0-frontend-lint.log`. The isolated workspace migration proof log is `/tmp/jada-npri-v0-workspace-migration.log`.

## v0 implementation verification ledger

Focused workspace API/schema/digest checks passed after lifecycle routes were added: `27 passed, 92 warnings in 10.99s`. The run covers staged evidence attachment semantics, a controlled full review/certification/filing sequence, historical exports after later edits, draft revisions with pending blockers, the engine approval/file gate, versioned carry-forward, and the filing-field map. The captured log is `/tmp/jada-npri-v0-lifecycle-tests.log`. A parent-run full backend regression is tracked separately; this focused result is not a claim that the numerical engine or the complete NPRI filing package is finished.

The full backend regression then passed: `313 passed, 399 warnings in 93.01s`, log `/tmp/jada-npri-v0-full-backend-tests.log`. After adding explicit CSV/HTML lifecycle envelope assertions, the historical export lifecycle case passed again (`1 passed, 23 warnings in 2.18s`), log `/tmp/jada-npri-v0-export-lifecycle-test.log`.

To reseed the local-only smoke users and period in `npri_v0_dev` after migrations, run from `backend/`:

```sh
DATABASE_URL=postgresql://npri_v0:npri_v0_local_only@127.0.0.1:55432/npri_v0_dev .venv/bin/python scripts/seed_v0_smoke.py
```

The script refuses any database other than the isolated `npri_v0_dev`; local credentials are written to ignored `.local-v0-smoke-credentials.md`. Use synthetic data only.

To stop only the isolated services, run from `backend/`:

```sh
docker compose -p jada-npri-v0 -f docker-compose.v0.yml stop
```

Never use `down -v` for cleanup. Preserve the isolated volume and the original `npri-reporter_postgres_data` volume.
