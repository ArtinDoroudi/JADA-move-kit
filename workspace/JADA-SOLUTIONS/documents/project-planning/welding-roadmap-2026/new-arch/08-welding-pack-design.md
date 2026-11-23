# 08 — The welding and metal fabrication pack (`metal_fab`)

Prepared: 2026-11-09. Status: proposed pack design. It covers the same 28 families as the [process catalogue](../process-catalogue.md) and the same questions as the [questionnaire](../questionnaire.md). The workbook counts were measured read-only from the official ECCC welding/cutting/spraying calculator on 2026-11-09 ([05](05-calculators-and-factors.md) has the hash). Beta states are proposals. Nothing here approves a factor or method.

> **Revised 2026-11-11:** Beta states move toward automatic: the "Other" paths and Method 2 become automatic once workbook parity passes, and batch-by-batch electrode review (§3.3) is replaced by one manifest review plus parity ([00 §8.1](00-automation-first-plan.md#81-workbook-parity-the-main-accuracy-gate)).

## 1. What the pack is

`metal_fab` is the first industry pack. It assembles:

- **shared modules** that later packs will reuse: welding, cutting, blasting, coating, degreasing, combustion, tanks, waste, water, roads;
- **a few pack-specific modules** for operations that only matter as screens in fabrication: specialist surface treatment, other joining, outsourced work;
- **whole-facility golden cases** built from the roadmap's completion scenarios.

v0's `catalogue_2026.json` already holds the right IDs: 28 processes; 128 questions (17 G, 8 M, 8 O, 95 Pxx); answer values `yes`, `no`, `unknown` and `other_party`. However, every v0 question has one of only three answer types: `process_screen`, `yes_no_unknown_other_party` or `text_or_structured`. The structure of answers (tables of electrode class × mass, fuel by equipment, and so on) was hand-coded in the frontend editors instead. In the pack, each question gets a **real typed schema**. That is what lets one renderer replace those editors ([09](09-review-workflow-and-generated-ui.md)).

## 2. Family → module → calculator map

States:

- **A** = automatic in Beta A (N2);
- **B** = automatic in Beta B / year one;
- **M** = manual-supported (structured `jada.manual_result`, same trace);
- **S** = screen and specialist manual only.

| Family | Module (`shared/` unless marked) | Calculator bindings | Factor source | Proposed state | v0 today |
|---|---|---|---|---|---|
| P01 Consumable arc welding | `welding_arc` | `activity_x_factor` (listed; Other Method 1); `composition` (PM2.5 from PM10; Method 2) | S05 workbook, full import | **A** for listed SMAW/GMAW/FCAW/SAW rows; Other M1 **A** with eligibility; M2 **M**→**B** | E310 only (9 rows) |
| P02 TIG / plasma | `welding_tig_plasma` | `activity_x_factor` with `cond_filler: required` | S05 (GTAW/PAW rows) | **A** with filler; autogenous **M** | Screen only |
| P03 Other joining | `metal_fab/other_joining` | — | — | **M** | Screen only |
| P04 Oxy-fuel joining, brazing, soldering | `brazing_soldering` | `fuel_combustion` (fuel part only) | AP-42 per fuel | Fuel **B**; filler/flux **M** | Screen only |
| P05 Thermal cutting / gouging | `thermal_cutting` | `activity_x_factor` (g/min × active minutes); `composition` `speciate_output` (metals = fraction × TPM) | S05 Part 4 cutting rows; Part 1 cutting formulas | **A** for listed subtypes | Oxy PM10 (1 row) |
| P06 Mechanical cutting, waterjet | `mechanical_cutting` | `activity_x_factor` for supported saw rows only | S05 (reciprocating saw, arc saw, grinder) | Listed **B**; shears, punching, waterjet **M** | Screen only |
| P07 Grinding, finishing | `mechanical_finishing` | — (overlap check with P05 grinder row) | — | **M** | Screen only |
| P08 Abrasive blasting | `abrasive_blasting` | `activity_x_factor` with `wind_class` derivation | S07 ECCC page and calculator, AP-42 13.2.6 | Dry sand **A**; cabinet, wet, recycled shot **M** | Dry sand (5 rows) |
| P09 Thermal spraying | `thermal_spray` | `activity_x_factor` (PM g/kg feedstock; metals g/kg constituent with `fraction_of_activity`) | S05 spraying rows | **A** for listed processes | Plasma (2 rows) |
| P10 Machining, fluids | `machining_fluids` | `mass_balance` (fluid concentrate) for waste only | — | **M** | Screen only |
| P11 Forming, forging | `metal_fab/forming` | Links to P20 fuel and P21 lubricants | — | **M** | Screen only |
| P12 Cleaning, degreasing | `degreasing` | `mass_balance` (bounded solvent balance) | Accepted composition; no default evaporation fraction | **A** for the bounded balance; vapour degreaser and aqueous **M** | `solvent-balance-v1` |
| P13 Liquid coatings | `surface_coating` | `composition` (as-applied constituents); `mass_balance` (retained, waste, overspray) | Accepted composition | **B** | `liquid-coating-balance-v1` |
| P14 Powder coating | `powder_coating` | `mass_balance` (virgin/reclaim flow); curing **M** | — | **M**→**B** | Screen only |
| P15 Coating removal | `coating_removal` | Routes mechanical removal to P07/P08 once; chemical work via `mass_balance` | — | **M** | Screen only |
| P16 Chemical surface preparation | `metal_fab/specialist_surface` | — | — | **S** | Screen only |
| P17 Plating, anodizing | `metal_fab/specialist_surface` | — (triggers the Cr(VI) override rule screen) | — | **S** | Screen only |
| P18 Hot-dip coating | `metal_fab/specialist_surface` | — | — | **S** | Screen only |
| P19 Heat treatment, quenching | `heat_treatment` | `fuel_combustion` (heat source) | AP-42 | Fuel **B**; chemistry **M** | Screen only |
| P20 Combustion equipment | `boilers_heaters`, `stationary_engines` | `fuel_combustion` | AP-42 1.4 (natural gas), 1.5 (LPG), 1.3 (oil, after I05), 3.x engines | Natural-gas small boiler **A**; others **B**/**M** | NG small boiler (2 rows) |
| P21 Assembly and inspection chemicals | `process_chemicals` | `composition` + `mass_balance` | Accepted composition | **B** | Screen only |
| P22 Storage and transfer | `storage_tanks` | `tank_losses` (N5) | S15 | **M** | Screen only |
| P23 Waste, recycling, residues | `waste_streams` | `composition` (constituent mass); `measured_concentration` later | Accepted composition and tests | **M** (required ledger from Beta A) | Partial (residue streams) |
| P24 Water and wastewater | `water_routes` | `measured_concentration` (later) | Accepted tests | **M** | Partial |
| P25 Yard traffic, outdoor dust | `road_dust` | `fugitive_dust` (N5) | S14 | **M**→**B** | Screen only |
| P26 Melting, casting, smelting, incineration | `metal_fab/specialist_thermal` | — (Part 3 and §1(1)(a) screen) | — | **S** | Screen only |
| P27 Maintenance, incidents | `maintenance_incidents` | `manual` | — | **M** | Screen only |
| P28 Outsourced, contractor, mobile | core boundary questions | — (boundary decisions, no factors) | — | **M** (always JADA) | Partial |

Every family is screened from the first beta. "M" and "S" are not omissions: a positive screen creates an expected manual result, and the package cannot be approved without it. That is the [roadmap's product boundary](../README.md#recommended-product-boundary), now enforced by the module's `fallback: manual` and its `coverage` entries.

## 3. Importing the full ECCC workbook

The workbook is the largest single coverage gain available. v0 loaded 12 of its 733 factor positions. The import is a **reviewed, repeatable script plus manifest**, not hand-typing.

### 3.1 What is in the workbook (measured)

| Block | Positions | Breakdown | How the pack represents it |
|---|---|---|---|
| Part 1 metals × arc welding (`Part 1 Releases!A19:J489`) | 392 | 317 numeric (139 non-zero, 178 published zero); 70 method-conditional "Other" cells (`=IF(Method 1, a, b)`); 5 cells written `=0.001/2` | One CSV row per numeric cell. Two rows per conditional cell (`method_variant: other_method1` / `other_method2`). 5 `derived` rows flagged for review. |
| Part 1 metals × cutting (`L19:V…`) | 80 | All `NA`; release = cutting mass fraction × TPM × 1000 (`S19 = Q19*R19*1000`) | No factor rows. One `composition@1 speciate_output` binding per metal, with the fraction from the cutting input question. |
| Part 1 metals × spraying (`X19:AH…`) | 60 | All numeric, g/kg of constituent (6 processes × 10 metals) | 60 rows; binding multiplies by feedstock composition once |
| Part 4 PM × arc welding (`Part 4 Releases!A12:H196`) | 159 | 92 numeric (PM10 and TPM blocks); 7 method-conditional; 7 references (`=D33`, … for "Other" TPM = PM10); 53 `NA` (the PM2.5 block) | Numeric and conditional rows. References become explicit duplicate rows citing their target cell. PM2.5 comes from `composition` at 0.75 × PM10 (`Instructions!A61`). |
| Part 4 PM × cutting | 24 | 16 numeric (g/min), 8 `NA` (PM2.5) | 16 rows plus the same PM2.5 binding |
| Part 4 PM × spraying | 18 | 12 numeric (g/kg feedstock), 6 `NA` (PM2.5) | 12 rows plus the PM2.5 binding |
| Parts 2–3, Part 5 tabs | — | "No information available" | **Not** a factor. The module declares `screening_domains` for Parts 2, 3 and 5 so that their absence is evidenced, not assumed ([regulatory inventory](../v0-regulatory-inventory.md#exact-candidate-process-variants-seen-in-w2)). |

There are 47 distinct welding process/electrode labels. Examples: `E6010`, `E6011`, `E6013`, `E7018`, `E7024`, `E308`, `E309`, `E310`, `E316`, `E410`, `ER70S`/`E70S`, `E70T`/`E71T`, `ER4043`, `ER5356`, `ERNiCrMo`, `GMAW - E308L`, `SAW - EM12K`, `SMAW - 14Mn-4Cr`, and the "Other …" rows for SMAW, GMAW, FCAW, SAW, GTAW, PAW and "Other Welding Methods". The expected CSV size is roughly 600–700 rows across the welding, cutting and spraying tables. The import manifest records the exact count, and the loader checks it.

### 3.2 The import manifest

```yaml
# packs/metal_fab/import/eccc-welding-2022-10-26.manifest.yaml
source_id: S05
file_sha256: 4c3e6f6a0fc1acd8038ab5ccd6e82cf65cd65e5d6bc69a7372b0a2a23dddaa93
blocks:
  - {sheet: "Part 1 Releases", range: "A19:J489", target: welding_arc/factors.csv,
     substance_col: A, process_col: C, value_col: D, rating_col: E,
     activity_unit: kg_electrode, numerator_unit: g, quantity_kind: release, medium: air,
     conditional_formula: {pattern: "IF('Input Arc Welding Information'!$C$6=\"Method 1\",a,b)",
                           variants: {a: other_method1, b: other_method2}}}
  - {sheet: "Part 4 Releases", range: "C12:H196", target: welding_arc/factors.csv, ...}
  # cutting, spraying ...
substance_map: substance_map.csv     # workbook label → notice identity or unresolved:* (reviewed)
expected_counts: {welding_arc: <filled by first import, then frozen>, thermal_cutting: …, thermal_spray: …}
assumptions:                          # workbook statements needing explicit approval as rows
  - {id: fume_is_pm10,  locator: "Instructions!A58", review_state: published_unreviewed}
  - {id: pm10_eq_tpm,   locator: "Instructions!A60", review_state: published_unreviewed}
  - {id: pm25_75pct,    locator: "Instructions!A61", review_state: published_unreviewed}
  - {id: uncontrolled,  locator: "Instructions!A63", review_state: published_unreviewed}
```

`jada-pack import` reads the workbook with formulas (not cached values), applies the manifest and writes CSV. The output is byte-stable for the same workbook, and it fails if the counts or file hash differ. The importer is the only code. The CSV is reviewed like any data change.

### 3.3 Review of imported rows

Rows arrive as `published_unreviewed`. Promotion to `jada_reviewed` is done in batches by electrode family, so practitioner effort goes where clients are. The proposed order follows the scope plan's N2 list:

1. SMAW `E7018`, `E6010`, `E6011`, `E6013`, and the stainless rows `E308`, `E309`, `E316`;
2. GMAW `E70S`/`ER70S` and `GMAW - E308L`;
3. FCAW `E70T`/`E71T`;
4. SAW `EM12K`;
5. the rest as clients appear.

Each batch needs 2 signed golden cases before its branch can be `automatic` ([10](10-golden-cases-and-verification.md)).

## 4. The "other electrode" paths

The workbook gives two alternatives when the electrode is unknown or not listed (`Instructions!A68–A86`):

| Path | Workbook guidance | Binding | Eligibility (accepted facts) |
|---|---|---|---|
| Method 1: average emission factors | Recommended default | `arc-other-method1-v1` → `activity_x_factor`, `method_variant: other_method1` | `jada.method_eligibility = other_method1_justified`: electrode class unknown or unlisted, and the process is known |
| Method 2: modified San Diego mass-fraction approach | Use when Method 1 is unreasonable, for example when it predicts an element the electrode does not contain | `arc-other-method2-v1` → `composition` with factor rows `method_variant: other_method2` and electrode mass fractions from `Input Arc Welding (Method 2)` | `jada.method_eligibility = other_method2_justified` plus accepted electrode composition (P01-4) and the reason Method 1 is unreasonable |
| GTAW/PAW "Other" | Only if filler is used | `cond_filler: required` on rows | P02 filler fact = `used` |
| "Other Welding Methods" | Process unknown or not one of the six | Method 1/2 rows for `Other Welding Methods` | As above, plus a `jada` classification of the process |

The exact Method 2 arithmetic — the weight-averaged mass fractions in `Input Arc Welding (Method 2)!P4:Z11` and their use in the Part 1 formulas — must be transcribed from the workbook formulas and checked against a recalculated workbook cell before the binding is promoted. Until then Method 2 is `manual_supported`. **This is a known verification task, not a solved one.**

No path is chosen just because its inputs are available. That is the [catalogue's internal method gate](../process-catalogue.md#p01--consumable-arc-welding), now an eligibility fact.

## 5. Identity mapping that stays unresolved

Some workbook outputs don't map cleanly to 2026 NPRI identities. The [regulatory inventory](../v0-regulatory-inventory.md#candidate-in-tmpjada-welding-researchwelding-calculatorxlsx) records why. The pack keeps them explicit:

| Workbook output | Pack `substance_id` | Effect |
|---|---|---|
| "Chromium and its compounds" | `unresolved:chromium_basis` | Contribution is computed and shown. The Part 1A `NA - 04` assessment stays `pending` with a `practitioner` item until the factor basis (total vs non-hexavalent) is decided. Nothing is subtracted to derive a residual. |
| "Hexavalent Chromium compounds" | `part1B:NA - 19` | Mapped |
| "Lead and its compounds (except tetraethyl lead)" | `unresolved:lead_subject_to_group_qualifier` | The stainless/brass/bronze exclusion (Table A2 note 8) needs a per-material qualifier decision |
| Cobalt | `part1B:NA - 05` | Mapped. Regression case for the stale "1A" classification (I02). |
| Nickel, manganese, zinc | `part1A:NA - 11`, `NA - 09`, `NA - 14` | Mapped |
| Copper, silver, antimony | Mapped on import after identity review | |

The mapping lives in `substance_map.csv` with a reviewer and date per row. Resolving `unresolved:chromium_basis` is one data change plus golden-case updates, not a code change.

## 6. Beta A and Beta B content

| Beta | Automatic content | Manual-supported | Gate |
|---|---|---|---|
| **Beta A** (N2, Feb – mid-Mar 2027) | P01 listed (batches 1–2 above) plus Other Method 1; P02 with filler; P05 listed cutting; P08 dry sand; P09 listed spray; P12 bounded solvent balance; P20 natural-gas small boiler | All other P-families; P23/P24 ledgers; stacks under I03/I04 holds | The 11 roadmap pilot scenarios signed as golden cases; every present activity in each pilot shop resolvable |
| **Beta B** (after the filing season) | P13 coating; P21 chemicals; P04/P19 fuel portions; more P20 fuels; P06 listed saws; Method 2; remaining electrode batches | Specialist families stay manual | Each promoted branch has ≥2 signed cases; mixed-shop case reconciles |

Admission rule, unchanged from the roadmap: a facility enters Beta A only if every present activity can be resolved automatically or manually. A welding-only automatic module does not make a welding-only facility package.

## 7. Golden cases the pack ships with

Module cases cover 2–5 small scenarios each. Whole-facility cases come from the [roadmap's completion tests](../README.md#completion-tests-for-the-pilot) and the [implementation plan's mandatory scenarios](../v0-implementation-plan.md#completion-and-independent-review-gates):

| Case file | Scenario | Exercises |
|---|---|---|
| `f01-known-electrode.yaml` | Arc welding with known consumables | `activity_x_factor`, Part 1 pending (Cr basis), Part 4 not met |
| `f02-unknown-electrode.yaml` | Unknown electrode: eligible vs ineligible alternative | Method 1 eligibility; `no_supported_factor` without it |
| `f03-tig-no-filler.yaml` | No-filler TIG beside a filler station | Autogenous path is not dropped; manual expected |
| `f04-weld-plus-cut-shared-collector.yaml` | Welding plus cutting sharing an alloy and a dust collector | Control routing; residue stream; no double count |
| `f05-batch-cut-grind-weld.yaml` | Same stock batch cut, ground and welded | Lineage; one MPO origin |
| `f06-mixed-shop.yaml` | Welding, blasting, coating, cleaning and gas heating | Cross-process aggregation; VOC views |
| `f07-low-hours-fuel.yaml` | Low hours plus fuel-burning equipment | Part 4/5 facility case; §14 exemption conditions |
| `f08-outsourced-paint-onsite-blast.yaml` | Painting offsite, contractor blasting onsite | P28 boundary |
| `f09-specialist-positive.yaml` | Positive specialist screen, unknown composition, missing method | Cannot reach `can_approve` |
| `f10-destinations.yaml` | Captured dust, waste solvent, wastewater and an air outlet | Stream and water routes |
| `f11-stack-conflict.yaml` | Stack/source conflict and changed control | I03/I04 holds; staleness |
| `f12-prior-reporter-dnmc.yaml` | Prior reporter no longer meeting criteria | DNMC action |
| `f13-threshold-met-zero-release.yaml` | Part 1 threshold met, zero releases | Substance report still required |
| `f14-pfas-unknown.yaml` | Unknown PFAS composition | Part 1C pending |
| `f15-heater-plus-engine.yaml` | Heater plus stationary engine | Different methods; engine manual |
| `f16-recirculated-water.yaml` | Recirculated water with purge and sludge | Water reconciliation |
| `f17-late-discovery.yaml` | Late activity discovery after approval | Reopen and staleness |
| `f18-carry-forward.yaml` | Carry-forward into an unapproved future year | No silent reuse |

The first 11 are the Beta A gate. All 18 are the year-one gate.

## 8. What v0 content carries over unchanged

- The 128 question IDs and prompts, with typed schemas added.
- The 12 factor rows, reproduced exactly by the import (parity check).
- The 5 blasting rows and 2 natural-gas rows.
- The coverage register's 171 declared branches, as module `coverage` entries. The latest v0 count was 109 implemented, 6 manual-supported and 50 unsupported as of the 165-branch revision on 2026-11-05. They are re-declared per module and re-reviewed. They are not imported as "approved".
- The synthetic mixed-facility fixtures, as source material for `f06` and `f10`. Their known chemistry issue is noted in the [implementation plan](../v0-implementation-plan.md#lifecycle-envelope-regression-and-chemistry-review-2026-11-05): total VOC treated as both a constituent and a volatile subfraction. That must be fixed in the case, not copied.
