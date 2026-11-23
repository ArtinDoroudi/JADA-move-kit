# 15 — Decisions, risks and open questions

Prepared: 2026-11-09. Status: proposed. Every decision below is **proposed** until the JADA team accepts it. Nothing in this set has been implemented.

> **Revised 2026-11-11:** ADR-007 is superseded and ADR-013 to ADR-017 plus risks V1–V10 are added in [00 §18 and §20](00-automation-first-plan.md#20-how-this-plan-changes-documents-0115); decisions D1–D9 are in [00 §17](00-automation-first-plan.md#17-decisions-jada-needs-to-make).

## 1. Architecture decision records

Each ADR follows the same pattern: context, decision, alternatives considered, consequences.

### ADR-001 — Split the product into engine, packs and regulation data

- **Context:** v0 needs ~3.9k application lines per finished process family, and the all-industry scope has 488 process slots ([01](01-why-change-v0-diagnosis.md)).
- **Decision:** an industry-neutral engine, versioned industry packs built from shared modules, and regulation data per Gazette notice ([02](02-architecture-overview.md)).
- **Alternatives:**
  - (a) continue v0's style and refactor later: rejected, because cost grows linearly with coverage and review becomes impossible;
  - (b) one engine per industry: rejected, because most processes are shared;
  - (c) buy an EHS platform: out of scope for this document, but worth a separate commercial check.
- **Consequences:** about 6 weeks of foundation work (N1) before new coverage ships. In return, new coverage becomes mostly data and practitioner review.

### ADR-002 — One fact model with a fixed set of typed entity kinds

- **Context:** v0 has 15 resolution payload kinds, each with its own validator, review service, routes and editor.
- **Decision:** every human statement is a fact keyed by a question ID, with one review flow. Structure uses 10 fixed entity kinds ([03](03-domain-model-and-facts.md)).
- **Alternatives:** (a) keep per-feature tables: rejected (it is the vertical-slice cause); (b) full EAV including structure: rejected, because it loses referential integrity.
- **Consequences:** rich nested value schemas are allowed. Generic authorization and freshness; one review screen.

### ADR-003 — Calculators are code; factors and bindings are data; formula strings are never evaluated

- **Context:** v0's factor rows carry formula strings, but the math lives in per-method functions.
- **Decision:** a registry of pure, versioned calculators. Packs bind facts to calculators and factor tables. A `formula` text in data is inert documentation ([05](05-calculators-and-factors.md)).
- **Alternatives:** (a) evaluate formula strings safely: rejected, because it creates an untestable language in data; (b) per-method code (v0): rejected.
- **Consequences:** about 14 calculators for all industries; new math needs a reviewed calculator.

### ADR-004 — A closed routing grammar with no arithmetic

- **Context:** question visibility and method eligibility need conditions.
- **Decision:** equality and inclusion over facts, plus `all/any/not`. Numeric and date logic goes into named derivations ([06 §5](06-pack-format-spec.md#5-routing-grammar)).
- **Alternatives:** a general expression language (JSONLogic, CEL): rejected because of the "YAML becomes a programming language" risk.
- **Consequences:** a few more derivation functions. Packs stay reviewable by practitioners.

### ADR-005 — Regulation logic as named rule functions, parameters per notice

- **Decision:** `regulation/notice_2025_2027/` holds identities, thresholds, exemptions, stack criteria, obligations and filing fields. Rule functions are versioned code bound by the notice. Interpretation holds are data ([07](07-regulation-as-data.md)).
- **Consequences:** a new notice is a new folder. Rule logic changes create `@N+1`, and old notices stay replayable.

### ADR-006 — Fixed stage order with eager calculation; no dependency graph

- **Context:** some thresholds depend on emissions, and some reporting outputs depend on thresholds.
- **Decision:** eight fixed stages. Calculate everything computable in stage 3, and decide what is *required* in stage 7 ([04 §3](04-engine-pipeline.md#3-ordering-and-the-threshold-before-emissions-problem)).
- **Alternatives:** a general dependency graph, or iterative evaluation: rejected as unnecessary for facility-sized data.
- **Consequences:** slightly more computation (negligible). Much simpler reasoning and testing.

### ADR-007 — Golden cases signed by practitioners are the specification

- **Decision:** a module branch is `automatic` only with ≥2 signed cases of independent origin. Cases compare exactly. Mutation cases are generated ([10](10-golden-cases-and-verification.md)).
- **Consequences:** practitioner time is the pacing resource and must be planned (about a third of each process estimate).

### ADR-008 — Keep v0's lifecycle, digests and export

- **Decision:** reuse `digests.py`, the snapshot, lifecycle projection and package export, and add content pinning ([11](11-lifecycle-freshness-and-replay.md)).
- **Consequences:** less risk in N1. These are the best-tested parts of v0.

### ADR-009 — Park rare branches; don't delete them

- **Decision:** EGU, prior-year comparison and low-hours oil-and-gas UI are parked behind flags, with a `parked` obligation that blocks if triggered. Monthly distribution and condensable PM become filing-field questions ([12 §2](12-migration-from-v0.md#park-behind-a-flag-rebuilt-as-pack-modules-or-duties-when-a-client-needs-them)).
- **Consequences:** a facility that triggers a parked duty gets a visible developer blocker, never a silent skip.

### ADR-010 — Shared modules live under `packs/shared/` from day one

- **Decision:** generic processes (welding, blasting, coating, degreasing, combustion, tanks, waste, water, roads) are shared modules, even while metal_fab is the only pack.
- **Consequences:** stable module IDs in filed history. A little more care in naming during N1–N2.

### ADR-011 — Content is pinned per workspace; re-pinning is explicit and diffed

- **Decision:** workspaces pin notice and pack versions. JADA re-pins explicitly and sees a diff. Filed revisions never re-pin ([11 §4](11-lifecycle-freshness-and-replay.md#4-re-pinning-content)).

### ADR-012 — Long-format CSV for factor tables, produced by reviewed importers

- **Decision:** one row per key combination × output, with the column contract in [05 §4](05-calculators-and-factors.md#4-the-factor-table-contract), produced by `jada-pack import` from official workbooks with frozen manifests and counts.
- **Consequences:** practitioners can open the CSV in a spreadsheet, and PR diffs show exact row changes.

## 2. Risk register

| # | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| R1 | N1 takes longer than 6 weeks and squeezes Beta A before filing season | Medium | High | Keep lifecycle code; port stages one at a time behind a flag; the parity harness shows progress objectively. If N1 slips past mid-February, run the pilot on v0 for the E310 / blasting / NG paths and finish the migration after June 1. | Tech lead |
| R2 | YAML grows conditions and turns into a language | Medium | High | Closed grammar (ADR-004); schema rejects unknown keys; derivations are reviewed code | Tech lead |
| R3 | Practitioner capacity is the bottleneck for case signing and factor review | High | High | Prioritize electrode batches by pilot demand; schedule practitioner time per cycle; a branch stays manual until signed (that is acceptable) | JADA lead |
| R4 | Parity triage matches v0 bugs instead of fixing them | Medium | Medium | Practitioner decides every regulatory difference; triage log | Tech lead + HSE |
| R5 | Generic fact review feels less guided than v0's bespoke editors | Medium | Medium | Rich value schemas, impact preview, help text; the five custom screens for genuinely complex interactions; usability test with a nontechnical client in N2 | Frontend dev |
| R6 | Unresolved identity mappings (chromium basis, lead qualifier) keep welding Part 1 assessments pending | High | Medium | Explicit `practitioner` open items from N1; decide before Beta A; the pending state is honest, not a defect | HSE |
| R7 | Imported workbook rows carry old assumptions (fume = PM10, PM2.5 = 75%, uncontrolled factors) | High | Medium | Each assumption is a reviewable row in the import manifest ([08 §3.2](08-welding-pack-design.md#32-the-import-manifest)) | HSE |
| R8 | A Gazette amendment lands during the pilot | Low | High | Amendment-audit freshness gate in CI; holds and notice versioning | JADA lead |
| R9 | Over-generalizing for industries nobody has bought | Medium | Medium | Rule of two; Wave 4 only with an anchor client | Tech lead |
| R10 | Uncommitted v0 work is lost before N0 | Low | Very high | N0 week 1: commit everything on the existing branch; never reset or clean | Dev A |
| R11 | Replay breaks after engine changes | Low | High | Calculator and rule versions retained; replay test with broken loaders on every release | Tech lead |
| R12 | Agents produce large unreviewed diffs again | Medium | High | 1–3k-line slices, committed and reviewed per slice; boundary CI check; budgets reported per cycle | Tech lead |

## 3. Open questions

| # | Question | Why it matters | Owner | Needed by |
|---|---|---|---|---|
| Q1 | Accept this architecture direction (ADR-001)? | Everything else depends on it | JADA leadership | Before N1 (7 Dec 2026) |
| Q2 | Chromium factor basis: is the workbook "Chromium and its compounds" total chromium or non-hexavalent? | Part 1A `NA - 04` assessments for all stainless welding | HSE practitioner (source research, possibly an ECCC question) | Before Beta A |
| Q3 | Lead qualifier: how is the stainless/brass/bronze exclusion applied to welding fume outputs? | Part 1B lead | HSE practitioner | Before Beta A |
| Q4 | Method 2 arithmetic: exact transcription and check against a recalculated workbook | Promotes Method 2 from manual to automatic | Developer + HSE | Beta B |
| Q5 | I03 (stack NOx 10 vs 20 t) and I04 (temperature comparator): seek ECCC clarification? | Automatic stack assessment | JADA lead | Before any client with a ≥25 m stack |
| Q6 | I05: oil heater unit-scale issue | Fuel-oil automation | Developer + HSE | Beta B |
| Q7 | The `=0.001/2` derived factor convention in five Part 1 welding cells | Those rows can't be used until understood | HSE practitioner | Before their electrode batch |
| Q8 | Who is authorized to sign golden cases (role, credential)? Is one signer enough for Beta A? | Defines the review gate | JADA leadership | N1 |
| Q9 | Which 3–5 pilot shops, and what is their real process mix? | Picks electrode batches and Beta A content | JADA sales + HSE | N0 |
| Q10 | Practitioner tooling: are CSV/YAML PRs acceptable, or is a small content-editing UI needed? | Practitioner throughput | JADA lead | N2 retrospective |
| Q11 | Content store hosting for replay (database table vs object storage) | Retention and replay | Tech lead | N1 |
| Q12 | When to build multi-site and consultant accounts | Oil-and-gas sales motion | JADA leadership | Before N7 |
| Q13 | Should a commercial EHS or NPRI tool be evaluated before committing to the build? | Build-vs-buy sanity check | JADA leadership | Before N1 |

## 4. What this document set does not decide

- It does not approve any factor, method, interpretation or filing.
- It does not change any code or data. Implementation needs explicit go-ahead per cycle.
- It does not set staffing, pricing or contracts. Effort figures are planning estimates.
- It does not supersede the source register, the regulatory inventory or the C1–C12 gates. It restructures how they are met.
