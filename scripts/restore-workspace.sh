#!/usr/bin/env bash
# Rebuild the JADA folders from this kit. Run inside WSL Ubuntu (or Linux/macOS).
#
#   bash scripts/restore-workspace.sh [DEST]          DEST defaults to ~/Online
#   PRIVATE_DIR=/path/to/private bash scripts/restore-workspace.sh
#
# It only creates new folders. It refuses to run if any target folder already exists.
# It does not touch Docker, databases, or install packages (see AI-SETUP-WINDOWS.md).
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-$HOME/Online}"
PRIV="${PRIVATE_DIR:-$KIT/private}"

say() { printf '\n== %s\n' "$*"; }

for f in JADA-SOLUTIONS.bundle npri-reporter-backend.bundle npri-clarity-frontend.bundle; do
  [ -f "$KIT/repos/$f" ] || { echo "missing $KIT/repos/$f"; exit 1; }
done
mkdir -p "$DEST"
cd "$DEST"
for d in JADA-SOLUTIONS JADA-NPRI-CORE JADA-NPRI-V0 JADA-SOLUTIONS-recovery-2026-11-03; do
  [ -e "$d" ] && { echo "refusing: $DEST/$d already exists (move it away first)"; exit 1; }
done

say "1/5 git repositories (all branches)"
git clone -q "$KIT/repos/JADA-SOLUTIONS.bundle" JADA-SOLUTIONS
git clone -q -b main "$KIT/repos/npri-reporter-backend.bundle" JADA-SOLUTIONS/backend
git clone -q -b main "$KIT/repos/npri-clarity-frontend.bundle" JADA-SOLUTIONS/frontend

say "2/5 worktrees: JADA-NPRI-CORE (npri-core) and JADA-NPRI-V0 (codex/welding-npri-v0)"
for r in backend frontend; do
  (
    cd "JADA-SOLUTIONS/$r"
    git branch -q npri-core origin/npri-core
    git branch -q codex/welding-npri-v0 origin/codex/welding-npri-v0
    git worktree add -q "../../JADA-NPRI-CORE/$r" npri-core
    git worktree add -q "../../JADA-NPRI-V0/$r" codex/welding-npri-v0
  )
done

# Point remotes back at GitHub. The two work branches were never pushed to GitHub,
# so drop the bundle's remote-tracking copies to avoid a misleading "origin/npri-core".
git -C JADA-SOLUTIONS remote set-url origin https://github.com/ArtinDoroudi/JADA-SOLUTIONS.git
git -C JADA-SOLUTIONS/backend remote set-url origin https://github.com/ArtinDoroudi/npri-reporter.git
git -C JADA-SOLUTIONS/frontend remote set-url origin https://github.com/ArtinDoroudi/npri-clarity.git
for r in backend frontend; do
  for b in npri-core codex/welding-npri-v0; do
    git -C "JADA-SOLUTIONS/$r" update-ref -d "refs/remotes/origin/$b" || true
  done
done

say "3/5 files that were not in git (uncommitted docs, packs, demo screenshots)"
cp -a "$KIT/workspace/." "$DEST/"

say "4/5 private files"
if [ -d "$PRIV" ]; then
  install -m 600 "$PRIV/env/JADA-SOLUTIONS_backend.env"  JADA-SOLUTIONS/backend/.env
  install -m 600 "$PRIV/env/JADA-NPRI-CORE_backend.env"  JADA-NPRI-CORE/backend/.env
  install -m 600 "$PRIV/env/JADA-NPRI-CORE_frontend.env" JADA-NPRI-CORE/frontend/.env
  install -m 600 "$PRIV/env/JADA-NPRI-V0_backend.env"    JADA-NPRI-V0/backend/.env
  install -m 600 "$PRIV/env/JADA-NPRI-V0_frontend.env"   JADA-NPRI-V0/frontend/.env
  tar -xzf "$PRIV/storage/JADA-SOLUTIONS_backend_storage.tgz"   -C JADA-SOLUTIONS/backend
  tar -xzf "$PRIV/storage/JADA-NPRI-CORE_backend_storage.tgz"   -C JADA-NPRI-CORE/backend
  tar -xzf "$PRIV/storage/JADA-NPRI-V0_backend_storage-v0.tgz"  -C JADA-NPRI-V0/backend
  tar -xzf "$PRIV/documents/JADA-SOLUTIONS_documents_private.tgz" -C JADA-SOLUTIONS
  tar -xzf "$PRIV/documents/edmonton-test-screenshots.tgz"      -C JADA-NPRI-CORE
  tar -xzf "$PRIV/archive/JADA-SOLUTIONS_archive.tgz"           -C JADA-SOLUTIONS
  tar -xzf "$PRIV/archive/JADA-SOLUTIONS-recovery-2026-11-03.tgz" -C "$DEST"
  echo "private files restored (.env files are chmod 600)"
else
  echo "WARNING: no private folder at $PRIV. Code restored, but no .env, uploads or client documents."
  echo "Copy private/ from the USB stick and re-run with PRIVATE_DIR=... on a fresh DEST."
fi

# macOS leaves '._name' AppleDouble files on exFAT/FAT USB sticks; they are junk.
find JADA-SOLUTIONS JADA-NPRI-CORE JADA-NPRI-V0 -type f -name '._*' -delete 2>/dev/null || true
[ -d JADA-SOLUTIONS-recovery-2026-11-03 ] && find JADA-SOLUTIONS-recovery-2026-11-03 -type f -name '._*' -delete || true

say "5/5 check"
for d in JADA-SOLUTIONS JADA-SOLUTIONS/backend JADA-SOLUTIONS/frontend \
         JADA-NPRI-CORE/backend JADA-NPRI-CORE/frontend JADA-NPRI-V0/backend JADA-NPRI-V0/frontend; do
  printf '%-26s %-24s %s\n' "$d" "$(git -C "$d" branch --show-current)" "$(git -C "$d" log --format=%h -1)"
done
echo
echo "Expected commits: JADA-SOLUTIONS 1ee0492 | backend main ca29307 | frontend main efe0928"
echo "                  core backend 738467f | core frontend 3fae4a6 | v0 backend dc4d8db | v0 frontend b49a637"
echo "Uncommitted (expected): JADA-SOLUTIONS docs (12 entries), JADA-NPRI-V0 backend 1, frontend 2. Everything else clean."
echo
echo "Done. Next: AI-SETUP-WINDOWS.md, Phase 3 (Docker + databases)."
