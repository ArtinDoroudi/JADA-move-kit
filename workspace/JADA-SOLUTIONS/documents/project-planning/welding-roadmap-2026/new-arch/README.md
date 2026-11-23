# Pack-based architecture for JADA NPRI

Prepared: 2026-11-09. Status: **proposed architecture**. It has not been implemented or approved. It is grounded in a read-only inspection of the `JADA-NPRI-V0` worktrees, the existing [welding roadmap](../README.md) set, and the official ECCC welding calculator workbook. No application code, database or client record was changed to write it.

> **Start here (2026-11-11): [00 — Automation-first plan](00-automation-first-plan.md).** It keeps this set's engine, pack and regulation structure and changes how the product collects data and decides when to ask a person: documents in, typed questions only, approved defaults with flags, interval estimates with a robustness test, and workbook parity instead of per-branch signatures. Targets: ≤ 30 min HSE time and ≤ 45 min client time per typical report. Each document below carries a "Revised 2026-11-11" note where 00 changes it.

## The proposal in one paragraph

Split the product into three parts:

- **An industry-neutral engine.** It is written once and reviewed by engineers.
- **Industry packs.** These are versioned folders of questions, method bindings, factor tables and signed sample facilities. They are written by HSE practitioners with a developer.
- **Regulation data.** Substances, thresholds, Part rules, stack criteria and filing fields, stored per Gazette notice.

Welding becomes the first pack, not the shape of the codebase. The engine runs eight small, pure stages. Industry-specific math lives in a registry of about 14 calculators; welding needs 4 of them. Every human answer or JADA decision is a **fact** with one review flow, rather than a feature-specific table, API and editor. The UI is rendered from the pack. Practitioners review the expected answers in golden cases instead of reviewing code.

The goal is unchanged from the [v0 implementation plan](../v0-implementation-plan.md): an evidenced, complete, reviewable 2026 facility package. The completion gates C1–C12, the closure rules in the [closure design](../v0-closure-design.md) and the regulatory branches in the [regulatory inventory](../v0-regulatory-inventory.md) all still apply. This set changes **how** the product is structured so that the gates stay affordable as clients and industries grow.

## Why now

| Measured in v0 (2026-11-09) | Value |
|---|---|
| New lines across backend, tests, frontend and data | ~127k |
| Largest backend file (`app/services/npri_v0/evaluator.py`) | 5,945 lines |
| `evaluate_frozen_inputs`, the single evaluator entry point | 804 lines |
| Welding factor rows actually loaded (`welding_candidate_factors.json`) | **12** |
| Factor positions in the official ECCC welding workbook | **733** (532 Part 1, 201 Part 4) |
| Implementation checkpoints that were repairs of earlier work | 39 of 104 |

Codex wrote roughly 3.9k lines of application code per finished process family. Each new electrode, fuel or reporting duty usually meant a new code path. The [all-industry scope](https://claude.ai/artifact/BjfGdcG6SJU5E8JPszasGs) counts 488 process slots across 16 industry packs. At v0's rate, covering them would take about 1.9M lines, which no team of our size could review. The full reasoning is in [01 — Why change](01-why-change-v0-diagnosis.md).

## Read this set in order

| # | Document | What it answers |
|---|---|---|
| 00 | [Automation-first plan (v2)](00-automation-first-plan.md) | **The build plan.** Goals, document intake, defaults, materiality, verification, client and HSE flows, cycles A0–A3, agent slices |
| 01 | [Why change: v0 diagnosis](01-why-change-v0-diagnosis.md) | What v0 got right, where the size came from, what must not be lost |
| 02 | [Architecture overview](02-architecture-overview.md) | The layers, the seven design rules, the system diagram and boundaries |
| 03 | [Domain model and facts](03-domain-model-and-facts.md) | Entities, the one fact model, decisions, contributions, open items, persistence |
| 04 | [Engine pipeline](04-engine-pipeline.md) | The eight stages, their typed inputs and outputs, ordering and invariants |
| 05 | [Calculators and factors](05-calculators-and-factors.md) | The calculator registry, factor-table contract, selection outcomes, units and Decimal rules |
| 06 | [Pack format specification](06-pack-format-spec.md) | `pack.yaml`, `module.yaml`, `factors.csv`, routing grammar, validation and what YAML may never do |
| 07 | [Regulation as data](07-regulation-as-data.md) | Notice folders, substances, Part rules, exemptions, stacks, filing fields, interpretation holds |
| 08 | [Welding pack design](08-welding-pack-design.md) | P01–P28 mapped to modules and calculators, the full workbook import, beta states |
| 09 | [Review workflow and generated UI](09-review-workflow-and-generated-ui.md) | Client and JADA journeys, the form renderer, one review queue, manual work parity |
| 10 | [Golden cases and verification](10-golden-cases-and-verification.md) | Case format, practitioner sign-off, test layers, numerical gates, the parity harness |
| 11 | [Lifecycle, freshness and replay](11-lifecycle-freshness-and-replay.md) | Runs, revisions, digests, pack/notice pinning, filing actions, historical replay |
| 12 | [Migration from v0](12-migration-from-v0.md) | Keep, convert, park, drop and mine, file by file, with a strangler sequence |
| 13 | [Delivery cycles](13-delivery-cycles.md) | N0–N9 from November 2026 to the 2028 filing season, with exit gates |
| 14 | [Adding an industry](14-adding-an-industry.md) | The playbook, worked through for pits and quarries |
| 15 | [Decisions, risks and open questions](15-decisions-risks-open-questions.md) | ADR log, risk register, unresolved items and who owns them |
| 16 | [Welding workbook reproduction and activity derivation](16-welding-workbook-spec.md) | Exact reproduction of the ECCC workbook (D10), output statuses, deriving hours and kg from purchases (grinding discs and more), Method 1/2 policy, slice changes |

## What stays the same

- **Regulation.** The pilot covers reporting year 2026 under the 2025–2027 Notice, with a June 1, 2027 deadline. The Notice prevails over the Guide.
- **Not knowing is never "nothing".** Unknown is not zero, missing coverage is not "below threshold", and a published factor is not a JADA-approved method.
- **Manual work is first-class.** A manual result needs the same trace and review as an automatic one.
- **Approval is human and gated.** Approval, certification and filing are separate human events, and the server enforces them.
- **Evidence and history.** Evidence is immutable, revisions are frozen, and historical exports stay reproducible.
- **Kept v0 code.** The lifecycle, digest, package export and threshold code is reused (see [12](12-migration-from-v0.md)).

## What changes

| Concern | v0 | Proposed |
|---|---|---|
| Where industry knowledge lives | Spread across catalogue JSON, factor JSON, evaluator branches and frontend editors | One pack folder per industry, built from shared modules |
| Adding an electrode, fuel or coating | New or edited code path | New rows in a factor CSV, plus a golden case |
| Human answers and JADA decisions | A typed collection, resolution kind, review service and editor per feature | One fact model keyed by question ID, one review flow |
| Engine shape | One 5,945-line evaluator calling about 40 helpers | Eight pure stages of about 300 lines each, plus calculators |
| UI | Hand-written editors (two route files of 6,004 and 4,846 lines) | A form renderer driven by the pack, with 3–5 custom screens |
| Regulation | Substances already data; obligations partly in code | One folder per Gazette notice, with rules as named functions plus parameters |
| What reviewers read | 75k+ lines of code and agent-written tests | Golden cases, factor rows and calculator diffs |

## Status of every number in this set

Figures labeled **measured** were read from `JADA-NPRI-V0` or the official workbook on 2026-11-09. Figures labeled **estimate** are planning judgements, not commitments. Line-count targets are estimates for sizing and review effort only. The proposal makes no claim that any method, factor or interpretation has been validated or approved. Each promotion still passes the numerical and practitioner gates described in [10](10-golden-cases-and-verification.md).

## Relationship to the existing roadmap

| Existing document | How this set uses it |
|---|---|
| [Roadmap README](../README.md) | Product boundary, R01–R10 runtime, beta scope and completion scenarios are kept. Cycles C00–C13 are re-expressed as pack and engine work in [13](13-delivery-cycles.md). |
| [Process catalogue](../process-catalogue.md) | Becomes the module list of the metal fabrication pack ([08](08-welding-pack-design.md)). |
| [Questionnaire](../questionnaire.md) | Becomes `questions` blocks in pack modules. Question IDs (G01–G17, M01–M08, O01–O08, Pxx-n) are preserved. |
| [Sources and decisions](../sources-and-decisions.md) | Source IDs S01–S25 and issues I01–I12 stay authoritative. Every factor row and rule parameter cites them. |
| [Regulatory inventory](../v0-regulatory-inventory.md) | Becomes the content of `regulation/notice_2025_2027/` ([07](07-regulation-as-data.md)). Its fixtures become golden cases. |
| [Implementation plan](../v0-implementation-plan.md) | C1–C12 gates and the mandatory scenario set remain the acceptance bar. |
| [Closure design](../v0-closure-design.md) | Source inventory, candidate floor, output slots and quantity origins are kept as engine concepts in stages 2–4 ([04](04-engine-pipeline.md)). |

## Companion visual pages

These private claude.ai pages show the same material visually:

- [Codex v0 audit](https://claude.ai/artifact/84Hb8YMYoLiuSuZfHEfUAM)
- [v0 architecture map](https://claude.ai/artifact/XBJGQSMbkeQgqBCfG2jtj2)
- [All-industry scope, priority and cycles](https://claude.ai/artifact/BjfGdcG6SJU5E8JPszasGs)
- [Pack-based architecture](https://claude.ai/artifact/NRJnsmurauNk3dMFCRCoV8)
