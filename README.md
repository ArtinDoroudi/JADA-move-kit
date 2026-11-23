# JADA move kit (Mac → Windows work laptop)

Everything needed to rebuild Artin's JADA NPRI workspace on another computer. It was made on
2026-11-23 from the Mac and tested there with a trial restore.

**What it brings over**
- The original app: backend and frontend, `main`.
- NPRI Core: all the new Codex work on branch `npri-core`, which was never pushed anywhere else.
- v0: the old attempt.
- Every planning and guideline document, the demo screenshots and the packs.
- The three databases: users, reports, and your Edmonton test.
- Uploaded SDS files, client documents, the archive, and the Codex/Claude history.
- The 7 planning pages from claude.ai (progress report, welding pilot, v0 audit, architecture
  map, all-industry scope, pack-based architecture, blueprint) in `artifacts/`. Open
  `artifacts/index.html` in any browser. They work offline, and the diagram library is bundled.

## Two parts

| Part | Where | What |
|---|---|---|
| Public-ish | this GitHub repo (private) **and** the USB | git bundles of all repos (all branches), uncommitted docs, setup guide, scripts |
| `private/` | **USB only, never GitHub** | `.env` keys, database dumps, client documents, SDS uploads, archive, AI history |

## How to use it on the Windows laptop

1. Copy `JADA-move-kit` from the USB to the laptop (or clone this repo and copy only `private/` from the USB).
2. Open Claude Code or Codex **inside WSL Ubuntu** and tell it:
   > Read `~/JADA-move-kit/AI-SETUP-WINDOWS.md` and set everything up, following its rules.
3. It installs WSL tools, restores the folders, recreates the databases, installs dependencies,
   starts the demo and checks it, using the expected numbers in the guide.

When it's done:
- Open <http://127.0.0.1:58321/login>. The logins are in `~/Online/JADA-NPRI-CORE/backend/.env`
  (`NPRI_DEMO_*`).
- Then delete `private/` from the USB: it holds client data and the API key.

See `MANIFEST.md` for exact commits, versions, ports and sizes.
