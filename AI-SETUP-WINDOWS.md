# AI setup guide: JADA NPRI workspace on a Windows laptop

**Audience:** an AI coding agent (Claude Code or Codex) running on the new Windows laptop, working
with Artin. Follow the phases in order. Each phase ends with a check. Stop and ask Artin if a check
fails twice. Do not improvise around it.

**Goal:** the same seven checkouts, three databases, uploaded files, documents and running demo that
existed on Artin's Mac on 2026-11-23, working under **WSL2 Ubuntu + Docker Desktop**.

---

## 0. Rules (read first, they still apply after setup)

1. **Never print secrets.** That covers `.env` values (the `ANTHROPIC_API_KEY`, `SECRET_KEY`, database
   passwords and `NPRI_DEMO_*_PASSWORD`). Refer to them by variable name. When you need to check
   one, print its length or `true/false`, never the value.
2. **Never put `private/` content in git or on GitHub.** That covers `.env`, databases, client
   documents and SDS uploads. The kit's `.gitignore` already excludes `private/`.
3. **Respect each repo's `AGENTS.md`.** In short:
   - `JADA-SOLUTIONS/backend` and `/frontend` (`main`) are **read-only references**.
   - `JADA-NPRI-V0/*` (`codex/welding-npri-v0`) is a **read-only reference**.
   - Active development happens only in `JADA-NPRI-CORE/*` on branch `npri-core`. Commit locally;
     **push only when Artin explicitly asks.**
4. **Tests only touch databases whose name ends in `_test`.** Never run `docker compose down -v`,
   `DROP DATABASE` or any destructive command against `*_dev` or `npri_reporter`.
5. **Never use a bare `git stash`.** Use a WIP commit, or `git stash push -m <unique-tag>` and apply by SHA.
6. **Human review is Artin's job.** Do not accept, approve or second-check NPRI facts on his behalf
   using the demo staff accounts, unless he explicitly asks for that specific action.
7. Work **inside the WSL filesystem** (`~/Online`, i.e. `\\wsl$\Ubuntu\home\<user>\Online`).
   **Not** under `/mnt/c/...`: that is 10–50× slower, breaks file watching, and mangles permissions.

---

## 1. What is in this kit

```
JADA-move-kit/
  README.md                 short human overview
  AI-SETUP-WINDOWS.md       this file
  MANIFEST.md               commits, branches, versions, ports, sizes
  SHA256SUMS                checksums for every file in repos/ and private/
  repos/                    git bundles, ALL branches, full history
    JADA-SOLUTIONS.bundle          workspace repo (docs, scripts)       main
    npri-reporter-backend.bundle   backend      main | npri-core | codex/welding-npri-v0
    npri-clarity-frontend.bundle   frontend     main | npri-core | codex/welding-npri-v0
  workspace/                files that were NOT committed anywhere (safe, no client data)
  scripts/restore-workspace.sh     rebuilds the folder layout (tested on the Mac)
  scripts/verify-kit.sh            checks SHA256SUMS
  private/   (USB ONLY, never on GitHub)
    env/          5 x .env (API key, DB passwords, demo logins)
    databases/    npri_reporter.dump, npri_core_dev.dump, npri_v0_dev.dump  (pg_dump -Fc, Postgres 16)
    storage/      uploaded SDS / purchase files for each backend
    documents/    client documents (Bradken, CASL, samples...), Edmonton test screenshots
    archive/      JADA-SOLUTIONS/archive, recovery folder from 2026-11-03
    ai-history/   Codex sessions, Claude memory (optional)
```

The GitHub copy of this kit (private repo `ArtinDoroudi/JADA-move-kit`) has everything **except
`private/`**. `private/` comes only from the USB stick.

Target layout after setup (identical to the Mac, under `~/Online`):

| Folder | Git | Branch | Commit | Role |
|---|---|---|---|---|
| `JADA-SOLUTIONS` | own repo | main | 1ee0492 | workspace docs + scripts |
| `JADA-SOLUTIONS/backend` | npri-reporter | main | ca29307 | original app API (read-only) |
| `JADA-SOLUTIONS/frontend` | npri-clarity | main | efe0928 | original app UI (read-only) |
| `JADA-NPRI-CORE/backend` | worktree of backend | npri-core | 738467f | **active development** |
| `JADA-NPRI-CORE/frontend` | worktree of frontend | npri-core | 3fae4a6 | **active development** |
| `JADA-NPRI-V0/backend` | worktree of backend | codex/welding-npri-v0 | dc4d8db | old attempt (read-only) |
| `JADA-NPRI-V0/frontend` | worktree of frontend | codex/welding-npri-v0 | b49a637 | old attempt (read-only) |

> `npri-core` and `codex/welding-npri-v0` were **never pushed** to `npri-reporter` / `npri-clarity`.
> The bundles (and the `JADA-move-kit` GitHub repo) are their only off-machine copies.

---

## Phase 1: Windows prerequisites (Artin may need to click through these; some need admin)

1. **WSL2 + Ubuntu 24.04.** In an *admin* PowerShell: `wsl --install -d Ubuntu-24.04`, reboot, then
   open "Ubuntu" from the Start menu and create a Linux user.
   Check: `wsl -l -v` shows Ubuntu with VERSION 2.
2. **Docker Desktop for Windows.** Install it, then go to Settings → General → "Use the WSL 2 based engine" ✔
   and Settings → Resources → WSL integration → enable **Ubuntu-24.04**.
   Check (inside Ubuntu): `docker run --rm hello-world`.
3. **Inside Ubuntu**, install the base tools:
   ```bash
   sudo apt update && sudo apt install -y git curl unzip ca-certificates build-essential
   git config --global core.autocrlf input   # keep LF line endings
   git config --global user.name  "Artin Doroudi"
   git config --global user.email "<ask Artin>"
   curl -LsSf https://astral.sh/uv/install.sh | sh          # Python manager
   curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.14" # same bun as the Mac
   exec bash -l
   uv python install 3.13
   ```
   Check: `uv run --python 3.13 python --version` prints 3.13.x and `bun --version` prints 1.3.14.

If a company policy blocks WSL, see **Appendix A (native Windows)**.

---

## Phase 2: Restore files

1. Get the kit into WSL:
   - **From USB** (shows up as e.g. `E:` → `/mnt/e`):
     `cp -r /mnt/e/JADA-move-kit ~/JADA-move-kit`
   - **Or from GitHub** (no `private/`):
     `git clone https://github.com/ArtinDoroudi/JADA-move-kit.git ~/JADA-move-kit`,
     then copy only the private part from USB: `cp -r /mnt/e/JADA-move-kit/private ~/JADA-move-kit/`.
2. Verify integrity: `bash ~/JADA-move-kit/scripts/verify-kit.sh` → must end with `ALL OK`.
3. Lock down secrets: `chmod -R go-rwx ~/JADA-move-kit/private`.
4. Rebuild the layout: `bash ~/JADA-move-kit/scripts/restore-workspace.sh ~/Online`
   - It refuses to overwrite existing folders.
   - It recreates the seven checkouts, copies uncommitted docs, places the five `.env` files
     (chmod 600), and unpacks uploads, client documents, the archive and the recovery folder.

**Check:** the script's final table matches the commit table above. Then:
- `git -C ~/Online/JADA-SOLUTIONS status --short | wc -l` → 12 (uncommitted docs; expected)
- `JADA-NPRI-V0/backend` shows 1 and `JADA-NPRI-V0/frontend` shows 2 uncommitted files (expected);
  all other checkouts are clean.

---

## Phase 3: Docker databases and Redis

Run from Ubuntu. `PRIV=~/JADA-move-kit/private`. All three stacks can run at the same time
(different ports). Use `--restart unless-stopped` so they come back whenever Docker Desktop starts.

```bash
PRIV=~/JADA-move-kit/private
cd ~/Online
```

### 3a. NPRI Core (the one Artin demos). Postgres 127.0.0.1:55433, Redis 127.0.0.1:56380
These containers were created by hand on the Mac (no compose file), so recreate them the same way.
The password is read from the `.env` without printing it:

```bash
CORE_PW=$(python3 -c "
from urllib.parse import urlparse
for l in open('JADA-NPRI-CORE/backend/.env'):
    if l.startswith('DATABASE_URL='):
        print(urlparse(l.split('=',1)[1].strip().strip('\"\'')).password)")
docker volume create jada-npri-core-postgres-data
docker run -d --name jada-npri-core-postgres --restart unless-stopped \
  -e POSTGRES_USER=npri_core -e POSTGRES_PASSWORD="$CORE_PW" -e POSTGRES_DB=npri_core_dev \
  -p 127.0.0.1:55433:5432 -v jada-npri-core-postgres-data:/var/lib/postgresql/data postgres:16
unset CORE_PW
docker run -d --name jada-npri-core-redis --restart unless-stopped -p 127.0.0.1:56380:6379 redis:7-alpine
until docker exec jada-npri-core-postgres pg_isready -q -U npri_core; do sleep 1; done; sleep 2
docker exec jada-npri-core-postgres createdb -U npri_core npri_core_test
docker exec -i jada-npri-core-postgres pg_restore -U npri_core -d npri_core_dev --no-owner --no-acl \
  < $PRIV/databases/npri_core_dev.dump
```

### 3b. Original app (main). Compose project `npri-reporter`, Postgres :5432, Redis :6379
```bash
cd ~/Online/JADA-SOLUTIONS/backend
docker compose up -d
until docker compose exec -T postgres pg_isready -q -U npri; do sleep 1; done; sleep 2
docker compose exec -T postgres pg_restore -U npri -d npri_reporter --no-owner --no-acl \
  < $PRIV/databases/npri_reporter.dump
```
If port 5432 or 6379 is already taken on Windows (e.g. a local PostgreSQL install), stop that
service; do not change the repo's compose file (main is read-only).

### 3c. v0 (old attempt). Compose project `jada-npri-v0`, Postgres 127.0.0.1:55432, Redis 127.0.0.1:56379
```bash
cd ~/Online/JADA-NPRI-V0/backend
docker compose -p jada-npri-v0 -f docker-compose.v0.yml up -d
until docker compose -p jada-npri-v0 -f docker-compose.v0.yml exec -T postgres pg_isready -q -U npri_v0; do sleep 1; done; sleep 2
docker compose -p jada-npri-v0 -f docker-compose.v0.yml exec -T postgres createdb -U npri_v0 npri_v0_dev
docker compose -p jada-npri-v0 -f docker-compose.v0.yml exec -T postgres pg_restore -U npri_v0 -d npri_v0_dev --no-owner --no-acl \
  < $PRIV/databases/npri_v0_dev.dump
```
(The compose file creates `npri_v0_test` itself.)

**Check:**
```bash
docker exec jada-npri-core-postgres psql -U npri_core -d npri_core_dev -tAc \
 "select (select count(*) from users), (select count(*) from npri_runs), (select version_num from alembic_version)"
# expect: 4|2|a3d8f2c7b641
```
Expected migration heads: main `c8e4f2a6b917`, v0 `c3d4e5f6a7b8`, core `a3d8f2c7b641`.
User counts: main 13, v0 8, core 4. **Do not run `alembic upgrade`**; the dumps are already at head.
On a fresh restore, `pg_restore` may print warnings about extensions or comments. Errors about
missing tables are a real failure.

---

## Phase 4: Install dependencies (do not copy `.venv` / `node_modules` from the Mac)

```bash
cd ~/Online
for b in JADA-SOLUTIONS/backend JADA-NPRI-V0/backend; do
  (cd $b && uv venv --python 3.13 .venv && uv pip install --python .venv/bin/python -r requirements.txt)
done
(cd JADA-NPRI-CORE/backend && uv venv --python 3.13 .venv && \
  uv pip install --python .venv/bin/python -r requirements.txt -r requirements-npri.txt)
for f in JADA-SOLUTIONS/frontend JADA-NPRI-CORE/frontend JADA-NPRI-V0/frontend; do
  (cd $f && bun install --frozen-lockfile)
done
```
**Check:** `JADA-NPRI-CORE/backend/.venv/bin/python -c "import app.main, npri"` (run inside that folder) exits 0.

---

## Phase 5: Run the NPRI Core demo (three Ubuntu terminals)

```bash
# T1: API
cd ~/Online/JADA-NPRI-CORE/backend && .venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port 58320
# T2: SDS extraction worker (needs Redis 56380 + ANTHROPIC_API_KEY)
cd ~/Online/JADA-NPRI-CORE/backend && .venv/bin/python -m celery -A app.celery_app worker --loglevel=info --pool=threads --concurrency=3 -n npri-core@%h
# T3: web
cd ~/Online/JADA-NPRI-CORE/frontend && bun run dev --host 127.0.0.1 --port 58321 --strictPort
```
Open in the **Windows** browser: <http://127.0.0.1:58321/login>. The logins are the `NPRI_DEMO_*`
variables in `JADA-NPRI-CORE/backend/.env`. Tell Artin to open that file himself; do not print them.

| Role | Variables | Use |
|---|---|---|
| Client | `NPRI_DEMO_CLIENT_EMAIL/PASSWORD` | client report pages |
| Classifier | `NPRI_DEMO_CLASSIFIER_EMAIL/PASSWORD` | second check in the workbook |
| Reviewer | `NPRI_DEMO_REVIEWER_EMAIL/PASSWORD` | admin NPRI case review |

**Checks (all must pass):**
1. The demo case <http://127.0.0.1:58321/admin/npri/7af5bd2e-dda4-5ee5-aab4-e3f72bbf7d26> loads.
   The PM10 total is **95.64 kg**.
2. Artin's test report <http://127.0.0.1:58321/admin/npri/0b24e815-9e12-4929-bae8-76d296316609>
   shows "Edmonton Coating Plants · Reporting year 2026" with a calculation run and about 255 open
   items. Its values are *Unknown* on purpose: the facility answers await a human reviewer.
3. `cd JADA-NPRI-CORE/backend && .venv/bin/python -m celery -A app.celery_app inspect ping` → `1 node online`.
4. Tests (they only touch `npri_core_test`):
   `cd ~/Online/JADA-NPRI-CORE/backend && .venv/bin/python -m pytest tests_npri -q`
   → 527 tests collected (at 738467f), all pass, including the 393/393 workbook parity cases.
5. To reset the synthetic demo case only: `.venv/bin/python -m npri.tools.seed_demo --reset`.
   This leaves Artin's Edmonton report alone.

**If the Windows browser can't reach 127.0.0.1:58321:**
- First try `http://localhost:58321`.
- Otherwise create `%UserProfile%\.wslconfig` with:
  ```
  [wsl2]
  networkingMode=mirrored
  ```
  Then run `wsl --shutdown` and start again.
- As a last resort, start vite and uvicorn with `--host 0.0.0.0`.

### Other stacks (only when needed)
- **Main app:**
  - API: `cd JADA-SOLUTIONS/backend && .venv/bin/python -m uvicorn app.main:app --port 8000`
  - Worker: `.venv/bin/python -m celery -A app.celery_app worker --loglevel=info`
  - Web: `cd JADA-SOLUTIONS/frontend && bun run dev`, on port 5173. It has no `.env`; the default
    API is localhost:8000.
- **v0:**
  - API: `cd JADA-NPRI-V0/backend && .venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port 58000`
  - Web: `cd JADA-NPRI-V0/frontend && bun run dev --host 127.0.0.1 --port 55173`
  - Its `ANTHROPIC_API_KEY` is a placeholder (39 characters). Extraction there only works if Artin
    asks you to copy the real key in.

### Ports
| Stack | Postgres | Redis | API | Web |
|---|---|---|---|---|
| NPRI Core | 127.0.0.1:55433 | 127.0.0.1:56380 | 58320 | 58321 |
| v0 | 127.0.0.1:55432 | 127.0.0.1:56379 | 58000 | 55173 |
| main | 5432 | 6379 | 8000 | 5173 |

---

## Phase 6: AI tools and history (optional)

- Install **Claude Code** and **Codex CLI inside Ubuntu**, not in Windows. Use their official
  install instructions and sign in again. Auth tokens were deliberately not copied.
- **Claude memory:**
  ```bash
  mkdir -p ~/.claude/projects/-home-$USER-Online
  tar -xzf $PRIV/ai-history/claude-memory.tgz -C ~/.claude/projects/-home-$USER-Online
  ```
  The folder name is the project path with `/` replaced by `-`. Check the name Claude Code actually
  creates after the first run and move the folder if it differs.
- **Codex history** (read-only reference; the sessions mention Mac paths like `/Users/artindoroudi/...`):
  `mkdir -p ~/.codex && tar -xzf $PRIV/ai-history/codex-sessions.tgz -C ~/.codex`
- Each repo's `AGENTS.md` carries the working rules for Codex, so they travel with git.

---

## Phase 7: Finish

1. Tell Artin which checks passed, quoting the outputs. Don't print secrets.
2. Remind him:
   - The USB stick holds client documents and the API key. Delete `private/` from it (or the whole
     kit) after setup and empty the Recycle Bin, or keep the stick locked away.
   - Ask JADA whether the work laptop should use a **company** Anthropic API key. If so, replace
     `ANTHROPIC_API_KEY` in `JADA-NPRI-CORE/backend/.env` and `JADA-SOLUTIONS/backend/.env`.
   - Docker Desktop must be running for the demo. The containers restart on their own.
3. Optionally add `~/JADA-move-kit/scripts/start-core-demo.sh` later. Do not change the repos for it.

---

## Project context (so you can continue the work)

- **Product:** a semi-automated NPRI (Canada National Pollutant Release Inventory) report generator
  for welding and metal-fabrication shops. The client uploads SDS, purchase records and answers; the
  engine calculates; a JADA admin reviews the decision trail. Target HSE time is 30 minutes or less
  per report. **Full release by 31 March 2027** (reporting to Jason).
- **Architecture docs:** `JADA-SOLUTIONS/documents/project-planning/welding-roadmap-2026/new-arch/`
  (00–16; delivery slices in `13-delivery-cycles.md`).
- **Done on `npri-core`:**
  - Backend: S01–S13 including S05, S08, S09 and S10a/b/c, plus F1, F1b, F2 and F2b.
  - Frontend: S21 plus F1, F1b, F2 and F2b.
  - Covered so far: 8 engine stages, the metal_fab pack 2026.1 (welding, thermal cutting, thermal
    spray), 393/393 parity with the ECCC workbook, the admin case summary, the calculation
    workbook with live edit, and the second check.
- **Next:** S14, then pin second-check items. Also:
  - put "start Docker, Redis and the worker" in the runbook;
  - support reporting year 2025 (the pack covers 2026 only);
  - a staff UI to accept facility facts;
  - group the "practitioner decisions" count;
  - coverage gaps: electroplating/Cr(VI), abrasive blasting, solvents, and grinding hours (S13b).
- **Ways of working:**
  - Artin pastes slice prompts into Codex. Codex implements and commits on `npri-core`.
  - The planning assistant (Claude) verifies read-only and writes the next Codex prompt.
  - Don't edit Codex's in-progress work unless asked.

---

## Appendix A: native Windows (only if WSL is not allowed)

- Install:
  - Git for Windows; run `git config --global core.autocrlf false` and `git config --global core.longpaths true`;
  - Python 3.13 (python.org) or `uv`;
  - bun for Windows (`powershell -c "irm bun.sh/install.ps1|iex"`);
  - Docker Desktop.
- Run `scripts/restore-workspace.sh` from **Git Bash** (it uses bash, tar and install). Put the
  workspace at a short path such as `C:\dev\Online`; one research file has a 230-character path.
- Command differences:
  - virtualenv binaries are in `.venv\Scripts\python.exe`, not `.venv/bin/python`;
  - Celery must use `--pool=threads` or `--pool=solo`, because prefork does not work on Windows;
  - the Phase 3 `docker exec -i ... < file` redirection works in Git Bash, but not in PowerShell
    (use `Get-Content -AsByteStream ... |` or `docker cp` the dump into the container first).
- Expect more friction (file watching, line endings, path length). WSL is strongly preferred.
