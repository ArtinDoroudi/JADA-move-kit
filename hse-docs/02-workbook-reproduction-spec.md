# 16 — Welding workbook reproduction and activity derivation

Prepared: 2026-11-12. Status: proposed, with D10 decided by JADA on 2026-11-12. This document extends [00 — Automation-first plan](00-automation-first-plan.md). It does not change any code.

**Sources:**

- The ECCC workbook: [`Electric Arc Welding, Cutting and Spraying Calculator_2022_10_26.xlsx`](../../../guidelines/official/Electric%20Arc%20Welding%2C%20Cutting%20and%20Spraying%20Calculator_2022_10_26.xlsx), SHA-256 `4c3e6f6a0fc1acd8038ab5ccd6e82cf65cd65e5d6bc69a7372b0a2a23dddaa93`.
- The calculation guide extracted from it: [`electric-arc-welding-cutting-and-spraying-calculation-guide.md`](../../../guidelines/official/electric-arc-welding-cutting-and-spraying-calculation-guide.md), cited below as **G** with its section number (for example G §9.2).

## Contents

1. [The two goals](#1-the-two-goals)
2. [The workbook is the reference (D10)](#2-the-workbook-is-the-reference-d10)
3. [Workbook paths mapped to the engine](#3-workbook-paths-mapped-to-the-engine)
4. [Factor table contract additions](#4-factor-table-contract-additions)
5. [Output status: zero is not one thing](#5-output-status-zero-is-not-one-thing)
6. [Activity derivation: getting the workbook's inputs from documents](#6-activity-derivation-getting-the-workbooks-inputs-from-documents)
7. [Composition sources](#7-composition-sources)
8. [Choosing Method 1 or Method 2 automatically](#8-choosing-method-1-or-method-2-automatically)
9. [Releases versus thresholds](#9-releases-versus-thresholds)
10. [Verification](#10-verification)
11. [Changes to the slice plan](#11-changes-to-the-slice-plan)
12. [Decisions](#12-decisions)
13. [Beyond welding: the same pattern for other calculators](#13-beyond-welding-the-same-pattern-for-other-calculators)

---

## 1. The two goals

1. **Calculate exactly like the government's workbook.** For the same inputs, the engine's welding, cutting and spraying results equal the workbook's results, cell for cell. The workbook is the reference and G is the specification.
2. **Fill the workbook's inputs automatically.** The workbook needs three activity measures and some compositions:

   | Workbook input | Unit | What a client usually has instead |
   |---|---|---|
   | Electrode/filler used, per electrode class (`U`) | kg/year | Invoices with product names and pack sizes |
   | Active cutting time, per cutting process (`H`) | hours/year | Invoices for grinding discs, plasma consumables, gouging carbons, gas cylinders; rarely a time log |
   | Material sprayed, per spraying process (`M`) | kg/year | Invoices for wire or powder |
   | Element fractions (Method 2, cutting, spraying) | mass fraction | SDS for consumables; steel grade on stock invoices |

   Most clients can't answer "how many hours did you grind in 2026?". They can upload the invoices that show they bought 600 grinding discs. The software turns the second into the first, with a range, and asks a person only when the range could change an outcome ([00 §7](00-automation-first-plan.md#7-materiality-the-robustness-test-and-the-exception-queue)).

---

## 2. The workbook is the reference (D10)

**Decision (JADA, 2026-11-12):** the official workbook is the reference, and the engine follows its formulas as written. The workbook is the Government of Canada's published method, so matching it is the defensible position, and the guide documents every formula.

What "exactly" includes (all from G):

| Behavior | G § | How the engine reproduces it |
|---|---|---|
| Eight activity references that read a different electrode's input (`Part 1 Releases!F181`, `F421:F427`) | 12.1 | As **data**: the factor row's `activity_label` points to the input the workbook actually reads. Each such row carries `workbook_note: G§12.1`, the trace shows it, and the eight rows are listed once for practitioner confirmation. Nothing is hard-coded. |
| Cutting Cr(VI) is "NA", turned into 0 by `IFERROR` | 8.3 | The output is 0 with status `not_estimated_by_method` ([§5](#5-output-status-zero-is-not-one-thing)) |
| "Other" welding releases are zero unless an item is unknown or unlisted (the C4/C5 gate) | 4.2 | The engine sets the gate from facts: `other_enabled` is true when any welding consumable maps to an "Other" category |
| One method (C6) for all "other" welding in the facility | 4.2 | One method per facility-year, chosen by policy ([§8](#8-choosing-method-1-or-method-2-automatically)) |
| Exact constants: SAW chromium K = 0.01432 against 0.0143 for other SAW elements; `=0.001/2` factors | 7.2, 12.4 | Factor values are imported as exact literals from the formulas, never retyped |
| Method 2 zero-total branch: a process with zero total usage gets fraction 0 | 7.1 | Implemented in the weighted-fraction step |
| Spraying PM10/TPM = max(base estimate, sum of nine metals), **per process**, Cr(VI) excluded from the sum | 9.2 | A `max_of` step per process before summing processes |
| PM2.5 = 0.75 × PM10 for every activity; TPM = PM10 for welding and cutting defaults | 5.2, 7.3, 8.1 | Imported as factor relations, not as code constants |
| Copper, silver and antimony are not calculated for listed electrodes | 5.1 | Status `not_modelled` for those rows |
| Control efficiency is applied outside the workbook, per process and substance, before facility totals | 11.1 | A separate, flagged adjustment step. Default: uncontrolled ([00 §6.3](00-automation-first-plan.md#63-starter-default-set-for-metal_fab-proposed-each-needs-one-time-approval)) |
| No rounding during calculation; display rounds to three decimals | 11.3 | Matches the S04 rule: round only at output |

The engine also keeps what the workbook can't: provenance, intervals and distinct statuses (G §14.1 recommends exactly that). Those extras never change the central number.

If ECCC publishes a corrected workbook, it becomes a new pack version with a new import. The import picks up whatever the new formulas read, so those eight rows follow automatically.

---

## 3. Workbook paths mapped to the engine

| Workbook path | G § | Engine steps (calculators from S06 plus the new steps in §11) | Inputs (facts) |
|---|---|---|---|
| Listed electrode, metals | 5.1 | `activity_x_factor@1`: EF (g/kg electrode) × U ÷ 1,000 | U per workbook label |
| Listed electrode, PM10/TPM, PM2.5 | 5.2 | `activity_x_factor@1` for PM10 and TPM (separate factor cells); PM2.5 = 0.75 × PM10 | U |
| Other welding, Method 1 | 6 | `activity_x_factor@1` with the Method 1 constants (G App. B.1) | U per "Other" process |
| Other welding, Method 2, weighted fractions | 7.1 | **`weighted_fraction@1`** (new): Σ(Uᵢ × fᵢ) ÷ ΣUᵢ, zero-total branch | Per-item U and fractions |
| Other welding, Method 2, metals | 7.2 | `composition@1`: K × f̄ × U ÷ 1,000. Cr(VI) uses K_CrVI × f̄_Cr | f̄ per process, U per process |
| Other welding, Method 2, particulate | 7.3 | `activity_x_factor@1`: process factor × U. Composition is not used. | U per process |
| Cutting, particulate | 8.1 | `activity_x_factor@1`: H × 60 × R (g/min) | H per cutting process |
| Cutting, metals | 8.2 | `composition@1` (`speciate_output`): f × TPM | Time-weighted f per process |
| Cutting, Cr(VI) | 8.3 | Fixed output 0, status `not_estimated_by_method` | — |
| Spraying, metals | 9.1 | `composition@1`: EF (g per kg **of that substance**) × f × M ÷ 1,000 | M and mass-weighted f per process |
| Spraying, PM10/TPM | 9.2 | `activity_x_factor@1` for the base, the sum of nine metals, then **`max_of@1`** (new) per process | M, the spraying metal outputs |
| Totals | 10 | Aggregation (S10): process → activity → facility | — |

Units come from the factor row's `unit_basis` ([§4](#4-factor-table-contract-additions)), so the ÷1,000 and ×60 steps are unit conversions in the S04 unit table, not literals in code.

**Interval behavior of the two new steps:**

- `max_of`: low = max(lows), central = max(centrals), high = max(highs). Monotone, so widening an input never narrows the result.
- `weighted_fraction`: for non-negative usage and fractions, the bounds use the interval rules from S04. For the central value it is the exact workbook formula. If the bounds are hard to state tightly, the low and high fractions can be bounded by the lowest and highest item fraction, which is always valid and conservative.

---

## 4. Factor table contract additions

These extend the `factors.csv` contract in [05 §4](05-calculators-and-factors.md#4-the-factor-table-contract) for the welding, cutting and spraying modules.

| Column | Meaning | Example |
|---|---|---|
| `label` | Workbook label, exact text (including trailing spaces in sheet names, normalized and recorded) | `E310`, `Other SMAW`, `Grinder` |
| `process_family` | SMAW, GMAW, FCAW, SAW, GTAW, PAW, other_arc, cutting, spraying | `SMAW` |
| `method` | listed, method1, method2, cutting, spraying | `method2` |
| `substance` | Workbook output (Cr, Co, Ni, Mn, CrVI, Pb, Zn, Cu, Ag, Sb, PM10, TPM, PM2.5) | `CrVI` |
| `value` | Exact literal from the formula or cell, as a string | `0.01432`, `0.0005` |
| `unit_basis` | `g_per_kg_electrode`, `g_per_kg_substance_in_material`, `g_per_kg_material`, `g_per_min` | `g_per_kg_substance_in_material` |
| `uses_fraction_of` | For Method 2 and spraying: which fraction multiplies the factor (Cr(VI) uses Cr) | `Cr` |
| `status` | `value`, `published_zero`, `not_available`, `not_modelled` | `published_zero` |
| `rating` | Workbook rating (A–E, `-`) | `C` |
| `source_cell` | Workbook address | `Part 1 Releases!D23` |
| `activity_label` | The input this row actually reads. Equals `label` except the eight rows in G §12.1 | `E309` for the F181 row |
| `workbook_note` | Guide reference when the row follows a workbook formula that differs from its label | `G§12.1` |

The importer (S11) generates this file from the workbook's formulas. It then checks it against the guide's appendices A–C, which list every factor. A difference between the two is an import failure, not something to fix by hand.

---

## 5. Output status: zero is not one thing

The workbook prints 0 for four different situations (G §12.2). The engine keeps them apart:

| Status | Meaning | Example | In the HSE summary |
|---|---|---|---|
| `value` | A calculated number, possibly 0 because activity is 0 | E7018, 0 kg used | Normal |
| `published_zero` | The workbook's factor is a literal 0 | Many listed-electrode factors | Normal; listed in the factor table |
| `not_estimated_by_method` | The method can't estimate it and returns 0 | Cutting Cr(VI) | **Listed in the assumptions:** "The ECCC calculator does not estimate Cr(VI) from cutting." |
| `not_modelled` | The workbook has no row for it | Cu, Ag, Sb for listed electrodes | Listed in the assumptions |

This refines rule 7 of [00 §19](00-automation-first-plan.md#19-rules-for-coding-agents-copy-into-agentsmd-for-the-new-branch): unknown is still never zero. The only zeros allowed are a calculated zero, a published zero, or a zero the official method itself defines, and the last two always carry their status into the package.

---

## 6. Activity derivation: getting the workbook's inputs from documents

### 6.1 The idea

For each workbook input, the engine uses the best rung of the data ladder ([00 §6.1](00-automation-first-plan.md#61-the-data-ladder)) that the documents support:

```text
measured / logged value        (a time log, machine controller report, scale tickets)
  ↓ else
derived from purchase records  (consumables × approved conversion parameters)
  ↓ else
client band answer             ("about how many hours a week does someone grind?")
  ↓ else
policy default                 (conservative, approved once)
```

A derivation is a typed calculation with approved parameters. It is never an LLM estimate. The parameters live in `defaults.yaml` with a source, a range and an approval, like every other default ([00 §6.2](00-automation-first-plan.md#62-default-entry-format)).

### 6.2 The derivation library

| Workbook input | Evidence in documents | Derivation | Parameters (in `defaults.yaml`) |
|---|---|---|---|
| Electrode/filler kg, per label | Invoice lines for rod, wire, filler | Σ (packs × pack size), converted to kg; stock change if known, else ± `stock_uncertainty` | Pack sizes come from the invoice or the SDS/TDS; `stock_uncertainty` (proposed 25%) |
| **Grinder hours** | Grinding discs, flap discs, cut-off wheels used on angle grinders | Σ (discs of type t × active minutes per disc of type t) ÷ 60 | Active minutes per disc, by type and diameter |
| Plasma arc cutting hours | Plasma electrodes and nozzles | electrodes consumed × arc-on hours per electrode | Arc-on life per electrode, by amperage class |
| Oxy-fuel cutting hours | Acetylene, propane or MAPP cylinders, oxygen | fuel gas volume × cutting share ÷ torch consumption per hour | Consumption per tip size; cutting share of the gas (the rest may be heating or brazing) |
| Air carbon arc (gouging) hours | Gouging carbons | carbons × burn minutes per carbon ÷ 60 | Burn minutes per carbon, by diameter |
| Laser cutting hours | Controller runtime report, or assist-gas volume | runtime directly; else gas volume ÷ flow rate | Assist-gas flow rate |
| Reciprocating or arc saw hours | Blades | blades × active minutes per blade ÷ 60 | Minutes per blade |
| Sprayed kg, per spraying process | Wire or powder invoices | Same as electrode kg | Pack sizes |

Rules for derivations:

- **One consumable feeds one activity.** The class map ([00 §5.3](00-automation-first-plan.md#53-classification-product--material-class)) assigns each consumable to exactly one cutting process. A cut-off wheel on an angle grinder is `Grinder`. Where the workbook's categories don't fit cleanly (for example a band saw), the class map entry needs practitioner approval (D13).
- **Parameters are ranges.** Every life or rate parameter has low, central and high values, so the derived hours are an interval. That is what lets the robustness test decide whether anyone needs to be asked.
- **The trace shows the derivation.** "Grinder: 600 discs (invoices 3, 7, 12) × 15–25–40 min ÷ 60 = 150–250–400 h. Disc life from `defaults.yaml#grinding.disc_125mm`."
- **A logged value always wins.** If the client uploads a time log or a controller report, the derivation isn't used.

### 6.3 Worked example: grinding from disc purchases

The disc-life numbers below are **placeholders for illustration**. Real values need a source (manufacturer data or the practitioner's experience) and approval (D13).

```text
Evidence:  600 × 125 mm grinding discs bought in 2026 (3 invoices)
Parameter: active grinding minutes per disc, 125 mm = 15 / 25 / 40   (low / central / high)

Hours      = 600 × (15, 25, 40) ÷ 60            = 150 / 250 / 400 h
PM10       = hours × 60 × 0.39 g/min (G App. C.1, Grinder)
           = 3.51 / 5.85 / 9.36 kg
TPM        = PM10 (equal default factors)        = 3.51 / 5.85 / 9.36 kg
PM2.5      = 0.75 × PM10                         = 2.6325 / 4.3875 / 7.02 kg

Base metal: 304 stainless bought as stock; Cr 18–20 % (grade standard), central 19 %
Cr release = Cr fraction × TPM (G §8.2)         = 0.6318 / 1.1115 / 1.872 kg
```

The Part 4 PM10 air-release threshold is 0.5 tonnes (500 kg). Even the high estimate, 9.36 kg, is far below 500 × (1 − 0.2) = 400 kg, so the outcome is **robust not met** and nobody is asked about grinding hours. The disc-life guess can be quite rough without changing the answer. This is why derivation plus the robustness test is enough for most shops.

If a shop's numbers were close to a threshold, the sensitivity step ([00 §7](00-automation-first-plan.md#7-materiality-the-robustness-test-and-the-exception-queue)) would rank grinding hours as a driver. It would then ask one band question ("About how many hours per week does someone grind?") or ask for a log.

### 6.4 New question type use

No new question types are needed. A derived value is shown to the client as a `confirm_prefill` ("We estimate about 250 hours of grinding from 600 discs. [Looks right] [Change]"), only when the robustness test says it matters. Otherwise it appears only in the HSE summary and the assumptions appendix.

---

## 7. Composition sources

| Workbook input | First source | Fallback |
|---|---|---|
| Method 2 electrode fractions (Cr, Co, Ni, Mn, Pb, Zn, Cu, Ag, Sb) | The electrode's SDS, via the platform's `sds_extractor` (% ranges → intervals) | Method 1 for that process ([§8](#8-choosing-method-1-or-method-2-automatically)) |
| Cutting fractions, time-weighted per process (G §3.4) | Base-metal grades from `metal_stock` invoice lines, looked up in `metal_grades.csv` (grade standard ranges) | Policy default: the shop's highest-alloy grade on record, flagged |
| Allocation of cutting hours across base metals | Purchased stock mass share by grade (a default, flagged) | Client confirmation if the robustness test says it matters |
| Spraying fractions, mass-weighted per process (G §3.5) | The feedstock SDS | Bounding rule ([00 §6.4](00-automation-first-plan.md#64-the-bounding-rule-for-unknown-composition)) |

The workbook expects these averages to be prepared outside it (G §3.4, §3.5). The engine prepares them with `weighted_fraction@1` and records every item that went into each average.

Validation the workbook doesn't do, from G §14.3: fractions must lie between 0 and 1; the nine tracked fractions may sum to less than 1 but not more; quantities are non-negative; the same usage can't be allocated twice. A missing composition is an unknown, not a zero, so it can't silently dilute a weighted average (G §12.3).

---

## 8. Choosing Method 1 or Method 2 automatically

The workbook applies one method to all "other" welding in a facility (C6, G §4.2). It recommends Method 1 by default and Method 2 when Method 1 isn't reasonable and composition is known (`Instructions!A79:A83`).

Proposed policy (`policy.yaml: other_welding_method`, D12):

1. Listed electrodes always use their listed rows (both methods leave them alone).
2. If no consumable maps to an "Other" category, the gate is off and "other" releases are zero, as in the workbook.
3. Otherwise compute **both** methods. Method 2 is possible only if every "other" consumable has an SDS composition.
4. Report with **Method 1** (the workbook's default), unless:
   - the practitioner's policy says Method 2 when composition is complete; or
   - the two methods give different threshold outcomes. Then the case goes to the HSE summary as one decision: "Method 1 says met, Method 2 says not met. Composition is from SDS for all 4 products. Choose."
5. The chosen method and the reason are recorded in the package.

---

## 9. Releases versus thresholds

The workbook calculates **air releases**. It does not calculate the quantities that decide whether a substance must be reported (G §1).

- **Thresholds** use the manufactured, processed or otherwise used quantity (MPO): for example the chromium contained in the electrodes and base metal used. That comes from composition × mass, in S07's rules and the core material assessment.
- **Releases** are what gets reported once a threshold is met. That is the workbook's output.

One open point for the practitioner (D14): Cr(VI) in welding fume is formed during welding. Whether, and how, the workbook's Cr(VI) release estimate should count toward the Cr(VI) MPO quantity ("manufactured") is an interpretation question, not something the workbook answers.

---

## 10. Verification

| Check | What it proves | Slice |
|---|---|---|
| **Parity, single category:** the 74 single-category scenarios the guide used (46 listed, 7 Method 1, 7 Method 2, 8 cutting, 6 spraying; G §15), each at several quantities | Every factor row and path matches the workbook | S12 |
| **Parity, mixtures and edge cases:** weighted Method 2 mixtures, both gate states, a blank method selector (takes Method 2), Table B row 106 included and row 107 excluded, both spraying-floor branches, the eight G §12.1 rows | Every branch and formula is reproduced | S12 |
| **Guide worked examples** G §13.1–13.7, as fixed tests with the guide's numbers written as literals | Independent hand-checkable arithmetic | S06b, S12 |
| **Derivation tests:** hand-worked arithmetic for each derivation mode, with intervals (§6.3 is the first) | Derivations are correct | S13b |
| **Property tests:** widening a derivation parameter never narrows the result; `max_of` is monotone | Robustness logic stays sound | S06b, S13b |

Parity target: **100% of generated cases, no exception list**, at 1e-9 relative tolerance. The G §12.1 rows are handled as data, so no row needs an exception.

Parity speed: S01 measured 0.85 s per case when copying the workbook each time. S12 should load the workbook once and change only the inputs between cases, so thousands of cases run in minutes.

---

## 11. Changes to the slice plan

These update the table in [00 §16](00-automation-first-plan.md#16-work-breakdown-for-agents).

| ID | Slice | Depends on | Done when | Size |
|---|---|---|---|---|
| **S06b** (new) | `max_of@1` and `weighted_fraction@1` (with the zero-total branch), interval-aware; guide examples G §13.3, §13.5, §13.6 as fixtures | S06 | Fixtures and property tests pass | 0.4k |
| **S11** (expanded) | `jada-pack import`: generate welding, cutting and spraying `factors.csv` from the workbook formulas with the §4 columns (status, unit basis, `activity_label`, `workbook_note`, exact literals); cross-check against G appendices A–C | S02, S06b | CSVs byte-stable; 0 differences from G appendices; counts frozen | 1.2k |
| **S12** (expanded) | `jada-pack parity`: the §10 scenario set; workbook loaded once per run | S01, S11, S09 | 100% parity, no exception list | 1.0k |
| **S13b** (new) | `derive_activity@1` (modes: `count_x_life`, `volume_div_rate`, `mass_from_packs`, `share_allocation`) and placeholder derivation defaults marked unapproved | S13, S16 | §6.3 example and one test per mode pass; unapproved defaults can't be used by an `auto` path | 0.8k |
| **S16** (expanded) | The class map also covers derivation consumables: grinding discs, cut-off wheels, plasma consumables, gouging carbons, cutting gases, saw blades, spray wire/powder, and `metal_stock` grades | S02 | Parser and map tests on real invoice lines | 1.0k |

Suggested order after S07: S06b → S11 → (S05, then S08–S10) → S12 → S13 → S16 → S13b. S06b and S11 need no database, so they can run while the database is set up for S05.

---

## 12. Decisions

| # | Decision | Recommendation | Status |
|---|---|---|---|
| D10 | The official workbook is the reference; the engine follows its formulas as written | — | **Decided** by JADA, 2026-11-12 |
| D11 | Cutting Cr(VI): report the workbook's result (not estimated) and disclose it in the assumptions | Accept; follows from D10 | Proposed |
| D12 | Method 1 or Method 2 for "other" welding ([§8](#8-choosing-method-1-or-method-2-automatically)) | Method 1 by default; both computed; the practitioner decides only when they disagree on an outcome | Proposed |
| D13 | Derivation parameters (disc life, consumable life, gas rates) and class-map entries for consumables that don't fit a workbook category | The practitioner approves each with a source; start with the consumables seen in pilot clients' invoices | Proposed; needed before S13b's defaults are approved |
| D14 | Whether welding-fume Cr(VI) counts toward Cr(VI) MPO ("manufactured") | The practitioner's interpretation, recorded as policy | Open |

---

## 13. Beyond welding: the same pattern for other calculators

The same three-part pattern applies to every ECCC calculator JADA adopts (blasting, combustion, the road-dust calculator in the same folder):

1. **A guide like G**, extracted from the official file: every formula, factor, gate and special case.
2. **A faithful import plus parity**, with special cases as data and statuses for zero values.
3. **A derivation library** that turns the documents clients actually have into the calculator's inputs, with approved ranges, and lets the robustness test decide whether to ask anyone.

For a new sector, step 1 comes first. It is what made this document possible, and it turns "trust the agent's reading of the spreadsheet" into a reviewable specification.
