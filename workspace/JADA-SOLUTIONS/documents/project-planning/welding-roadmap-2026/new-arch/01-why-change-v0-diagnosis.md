# 01 — Why change: diagnosis of v0

Prepared: 2026-11-09. Status: read-only diagnosis of the isolated `JADA-NPRI-V0` backend and frontend worktrees (branch `codex/welding-npri-v0`), measured on 2026-11-09. Nothing was edited. Line counts come from `wc -l` on tracked source files. Where a count was taken earlier in this planning work, it is marked with that date.

This document does not criticize the v0 goals. The [v0 implementation plan](../v0-implementation-plan.md) set a correct and demanding bar, and much of the code meets parts of it. The problem is the cost per unit of coverage. That cost decides whether JADA can serve more than one industry.

## 1. What v0 got right and must be kept

These ideas are sound and carry into the new architecture unchanged in meaning:

| v0 idea | Where it lives in v0 | Why it is right |
|---|---|---|
| Unknown is not zero; missing coverage cannot conclude "below threshold" | `thresholds.py`, `readiness.py`, the closure design | This is the core regulatory safety property |
| Separate threshold quantity, release, disposal and recycling | `Contribution.quantity_kind`, `aggregation.py` | The Notice treats these differently |
| Typed decision envelope (`resolved / needs_input / needs_interpretation / unsupported`) | Implementation plan, evaluator decisions | It makes gaps explicit and assignable |
| Manual work as an accountable method with an independent reviewer | `manual-calculation-v1`, `manual-result-review-v1` | Most of the 28 families stay manual through beta |
| Frozen runs, immutable revisions, canonical digests, stale detection | `workspace/digests.py`, `catalogue_snapshot.py`, `lifecycle_projection.py` | Required for defensible filing and replay |
| Factor rows that keep their source locator, rating and `published_unreviewed` status | `data/npri_v0/welding_candidate_factors.json` | This is exactly the shape a factor table needs |
| Substance registry as data, matched by identity and not by row order | `data/npri_v0/substances_2026.json` (493 records) | Already the right "regulation as data" pattern |
| Process and question catalogue as data | `workspace/catalogue_2026.json` (28 processes, 128 questions) | Already the right "pack" pattern |
| Quantity origin vs aggregation key; lineage vs consumable split | Closure design §3, `material_lineage.py` | Prevents double counting across sequential operations |
| Coverage register (implemented, manual-supported, unsupported) per branch | `release_coverage_2026.json` | Honest declaration of scope |

The proposal mostly **finishes the direction these data files started**. The catalogue and factor files are already data. The engine just doesn't use them as data.

## 2. Where the size came from

### Measured totals

| Area | Before v0 | After v0 | Added |
|---|---|---|---|
| Backend application code | 7.2k | 43.1k | +35.9k |
| Backend tests | 5.1k | 36.1k | +31.0k |
| Frontend | 19.7k | 48.6k | +28.9k |
| JSON data (catalogues, factors, substances, coverage) | — | 28.9k | +28.9k |
| Migrations and scripts | — | — | +1.9k |
| **Total new lines** | | | **~127k** |

Inside the backend, the rule engine `app/services/npri_v0/` has 36 modules and 18,458 lines. The workspace service layer `app/services/workspace/` has 11,085 lines, schemas have 6,200 and the API has 3,670. There are 25 tables, 23 Alembic migrations, 83 HTTP routes and 164 backend test files.

### The largest files

| File | Lines | What it does |
|---|---|---|
| `frontend/src/routes/admin.workspace.tsx` | 6,004 | The whole JADA case screen |
| `backend/app/services/npri_v0/evaluator.py` | 5,945 | Every evaluation branch |
| `frontend/src/routes/_client.workspace.tsx` | 4,846 | The whole client case screen |
| `backend/app/services/workspace/service.py` | 3,632 | Persistence, resolutions, lifecycle; `evaluate_workspace` starts at line 2540 |
| `backend/app/schemas/workspace.py` | 2,811 | Every payload type |
| `frontend/src/components/workspace/reporting-metadata-editor.tsx` | 2,292 | One feature's editor |
| `frontend/src/routes/admin.reports.$id.tsx` | 1,519 | Legacy report screen, extended |
| `frontend/src/components/workspace/part4-egu-details-editor.tsx` | 1,357 | Electricity-generating-unit details, for a welding pilot |

### Six structural causes

**1. Every rule is an eight-layer vertical slice.** A new reporting duty such as Part 4 monthly distribution, prior-year comparison or EGU details was built as:

1. a pure engine module (`npri_v0/part4_monthly_distribution.py`);
2. a review service (`workspace/part4_monthly_review.py`);
3. a schema family;
4. resolution kinds;
5. digest and freshness hooks;
6. HTTP routes;
7. a TypeScript DTO;
8. a hand-written editor, plus tests at each layer.

That is why, for example, the EGU (generator) feature alone is about 7,300 lines across `egu_details.py`, `egu_reporting.py`, `egu_review.py`, `egu_details_review.py`, two schema files and a 1,357-line editor.

**2. Methods are code paths, not data.** `_build_arc_e310_outputs` (`evaluator.py:2294`) is a 322-line function that runs only when `method_id == "arc-listed-v1"`. Blasting has its own 203-line builder (`_build_abrasive_blasting_outputs`, line 2616). Natural gas has `combustion_adapter.py` (627 lines). Organics have `organic_methods.py` (980 lines). There are 37 places in `npri_v0/` that branch on a method or process ID, and 15 places that hard-code a `"Pxx"` literal. The factor file already carries an `activity_basis` and even a `formula` string (`factor_g_per_kg * electrode_kg / 1000`), but no generic code consumes them.

**3. Each human decision got its own resolution kind.** `app/schemas/workspace.py` and its siblings define 15 `payload_type` kinds:

- `fact`, `applicability`, `inclusion`, `method_assignment`, `manual_contribution`;
- `source_inventory`, `source_scope`, `output_closure`, `stack_decision`;
- `reporting_output`, `reporting_category_coverage`, `reporting_metadata`, `prior_report_acceptance`;
- `other_process_mapping`, `filing_workflow`.

Each kind brought a validator, a review path, dependency hooks and UI. They are all the same thing: a person states something about a subject, with evidence, and another person accepts it.

**4. Rare branches were built before common coverage.** The pilot is welding, but v0 built Part 4 EGU positive branches, Part 5 low-hours oil-and-gas benzene branches and crude-battery cases. It also built condensable-PM review and prior-year comparison. Meanwhile, only one electrode class (E310) has release factors loaded. The [implementation plan checkpoints](../v0-implementation-plan.md#completion-audit-checkpoint-2026-11-04) record this sequence.

**5. One file absorbed every feature.** `evaluate_frozen_inputs` is 804 lines and calls about 40 helpers. Almost every checkpoint edited it or `service.py`. 39 of the 104 recorded checkpoints are repairs of earlier work: fixture drift, shadowed variables, wrong tuple shapes and stale dependency wiring. Concurrent agents editing the same god-files make this predictable.

**6. Generated code is verbose by default.** Agent-written tests often build the expected value by calling the production helper. Defensive type guards repeat at every layer, and each feature carries its own copy of the common plumbing. The [plan itself](../v0-implementation-plan.md#automatic-method-scope-and-numerical-gates) warns that such tests "are not validation".

## 3. The coverage paradox, in numbers

The clearest single measurement:

| | Count |
|---|---|
| Factor positions in the official ECCC welding/cutting/spraying workbook (SHA256 `4c3e6f6a…aa93`, the same file v0 cites) | 733 |
| – Part 1 metals: arc welding / cutting / spraying | 392 / 80 / 60 |
| – Part 4 particulate: arc welding / cutting / spraying | 159 / 24 / 18 |
| Numeric non-zero factors among them | 319 |
| Published zeros (must stay distinct from "no factor") | 178 |
| Formula-derived or `NA` positions (method-conditional "Other" rows, composition-weighted cutting metals, derived PM fractions) | 236 |
| Distinct welding process/electrode labels | 47 |
| **Factor rows loaded in v0** | **12** (9 for SMAW E310, 1 oxy-cutting, 2 plasma-spray) |

So v0 has about 1.6% of the welding factor data behind 43k lines of backend. In a data-driven design, the other 98% is a spreadsheet import with review, not engineering work. This is the main reason v0 covers about 60% of one industry after roughly 20 hours of agent time. The time went into machinery for rare branches and per-feature plumbing, not into coverage.

## 4. Projected cost if v0's style continues

These are estimates for planning only.

| Assumption | Value |
|---|---|
| Application code per finished process family in v0's style (~65k new app lines ÷ ~60% of 28 families) | ~3.9k lines |
| Process slots across the 16 industry packs in the scope plan, before sharing | 488 |
| Distinct process families after sharing | ~280 (≈45 shared modules + ≈236 sector-specific) |
| Projected application code, v0 style, no reuse (3.9k × 488) | ~1.9M lines |
| Projected application code, pack-based (core ~45k + calculators ~20k + 45 × ~1.2k + 236 × ~0.6k) | ~260k lines, mostly data and golden cases |

Even if the v0 style were reused at 50%, the codebase would be too large for one reviewer to understand. The engine would then become the bottleneck for every new client.

## 5. What this diagnosis does not claim

- It does not claim v0 calculations are wrong. Many are carefully bounded and well tested within their scope.
- It does not claim that the per-feature review work was unnecessary. Most of those duties are real Schedule 4 requirements. The claim is that they should be **facts and rule parameters**, not separate subsystems.
- It does not recommend a rewrite. [12 — Migration](12-migration-from-v0.md) keeps the lifecycle code, uses v0 outputs as a parity oracle, and replaces the engine behind a flag.

## 6. Requirements the new architecture must meet

These come from the diagnosis and are the acceptance criteria for this proposal:

1. **Coverage scales with data.** Adding an electrode, fuel, coating, substance row or a duty with the same shape needs no engine code.
2. **One review path.** Any human statement (answer, classification, inclusion, method choice, manual result, closure) is a fact with schema, evidence, author, reviewer and dependency digest.
3. **Small, independently testable engine.** No engine file over about 400 lines. Each stage can be tested with a frozen input alone.
4. **Reviewable by practitioners.** The thing an HSE practitioner signs is a golden case (inputs, expected kg, expected open items), not code.
5. **Same safety bar.** Every C1–C12 gate in the [implementation plan](../v0-implementation-plan.md#completion-and-independent-review-gates) remains satisfiable, and none is weakened.
6. **Incremental adoption.** The new engine must produce the same results as v0 on v0's supported cases before v0 paths are removed.
