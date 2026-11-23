# 14 — Adding an industry: the playbook

Prepared: 2026-11-09. Status: proposed process. The worked example (pits and quarries, planned for N6) is **illustrative**. Its sources were identified on 2026-11-09 but not yet read in full, and no factor was extracted or validated. Sources:

> **Revised 2026-11-11:** v2 adds intake taxonomy, defaults, policy and parity steps and drops per-module signatures ([00 §12](00-automation-first-plan.md#12-expandability-adding-a-sector-in-v2)).

- [ECCC Pits and quarries reporting guide](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/pits-quarries-guide.html);
- [Crushed stone processing](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/crushed-stone-processing.html);
- [Sector-specific tools](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/sector-specific-tools-calculate-emissions.html);
- the [2025–2027 reporting guide](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/reporting-guide.html).

## 1. The test of the architecture

If the architecture works, adding an industry is **mostly practitioner work**. Engineering appears only when the industry needs math that no calculator does yet. The playbook makes that visible: every step names who does it and whether code changes.

## 2. Steps

| Step | Who | Output | Code change? | Effort (estimate) |
|---|---|---|---|---|
| 1. Process inventory | Practitioner | List of processes from ECCC sector guidance, NAICS structure and 2–3 real sites; each marked *shared module exists*, *shared module needed* or *pack-specific* | No | 2–5 days |
| 2. Special rules check | Practitioner + developer | Which notice rules the industry triggers (production thresholds, no-hours activities, Part 3 activities, special Part 4/5 branches); confirm they exist in `regulation/` | Only if a rule function is missing | 1–2 days |
| 3. Calculator gap check | Developer | For each process: which calculator, which factor basis. Missing math → new calculator task (rule of two). | Only for genuinely new math | 0.5 day + calculator work |
| 4. Factor import | Developer + practitioner | Import manifests for each official workbook or table; CSVs; substance map | Importer config only | ~1 week per 4 modules |
| 5. Questions | Practitioner + developer | Typed questions per module (reuse core and shared questions first) | No | Included in 4 |
| 6. Golden cases | Practitioner | 2–5 cases per module plus 3–6 whole-facility cases; signed | No | ~0.5 week per module |
| 7. Validate and release | CI + practitioner | Pack passes load-time and release-time checks; coverage diff; release notes | No | 1–2 days |
| 8. Pilot | JADA | First client case in staging, then production; override log | No | — |

## 3. Worked example: pits and quarries

### 3.1 Process inventory (from the ECCC guide's structure)

| Process | Module | Shared or new | Calculator | Notes |
|---|---|---|---|---|
| Overburden removal | `pq_overburden` | New | `activity_x_factor` | Guide: only the three PM sizes are emitted |
| Drilling | `pq_drilling` | New | `activity_x_factor` | |
| Blasting (PM) | `pq_blasting_pm` | New | `activity_x_factor` with a condition | Factor validity limited to blasting depth ≤ 21 m. That becomes a `cond_max_depth_m` column, and a deeper blast gives `incompatible` → manual. |
| Explosives (CO, NOx, H2S, SO2) | `explosives` | **Shared** (reused by mining, construction aggregates) | `activity_x_factor` keyed by explosive type | Guide treats explosive VOC as negligible; record that as an evidenced screening-domain closure with its locator, not as silence |
| Crushing | `crushing_screening` | **Shared** (cement, mining) | `activity_x_factor` with `control_basis` rows | Controlled and uncontrolled factors plus a control-efficiency table |
| Screening | `crushing_screening` | Shared | same | |
| Material handling (drop points, conveyors) | `aggregate_handling` | **Shared** | `fugitive_dust` (handling mode) | Annual tonnage basis |
| Stockpile wind erosion | `stockpiles` | **Shared** | `fugitive_dust` (wind erosion mode) | Exposed surface area basis |
| Unpaved haul roads | `road_dust` | **Shared** (exists from metal_fab P25) | `fugitive_dust` (road mode) | Schedule 3 §12 vehicle-km rule already in regulation data |
| Generators, heaters | `stationary_engines`, `boilers_heaters` | **Shared** (exist) | `fuel_combustion` | |
| Fuel tanks | `storage_tanks` | **Shared** (exists) | `tank_losses` | |
| Waste, water | `waste_streams`, `water_routes` | **Shared** (exist) | as in metal_fab | |

Result: about 4 new pack-specific modules, 4 new shared modules (which later packs reuse) and about 5 reused modules. The math is covered by `activity_x_factor`, `fugitive_dust` (built in N5), `fuel_combustion` and `tank_losses`. **No new calculator.**

### 3.2 Special rules

The 2025–2027 Notice handles pits and quarries through applicability:

- §1(1)(a): pit or quarry production ≥ 500,000 t is an employee-hours-exempt activity;
- §1(2): a facility whose *only* activity is pit or quarry production below 500,000 t is excluded.

The reporting guide also says open-pit mines are not "pits or quarries".

In this architecture:

- `exemptions.yaml#s1_1_a.pit_quarry_production_ge_500000_t` and the §1(2) exclusion already exist as data ([07 §7](07-regulation-as-data.md#7-exemptions-facility-cases-and-stacks)).
- The pack adds one question, `PQ-G01` (annual production in tonnes, with evidence), and one derivation, `pit_quarry_production_class@1`. The derivation turns production into `ge_500000` / `lt_500000` / `unknown`, and the existing rule functions test it by equality.
- A JADA question `jada.pq.is_open_pit_mine` with `independent` review routes open-pit mines away from this pack.
- Practitioner sign-off needed: the production definition, the boundary case at exactly 500,000 t (inclusive per "≥"), and the "only activity" test for mixed sites. Each becomes a regulation boundary case.

### 3.3 Factor import

One import manifest per ECCC table or workbook in the guide and the NPRI Toolbox calculators: crushing, screening, explosives, blasting, handling and wind erosion. Each row gets `source_id` (a new S-ID added to the source register), locator, digest, rating and `control_basis`.

The ECCC guide's metadata suggests it is several years old. Step 4 therefore includes checking each factor against its cited AP-42 section edition. A newer AP-42 edition is **not** automatically adopted. That is the same rule as for combustion ([S13](../sources-and-decisions.md#s13)).

### 3.4 Golden cases

- Module cases: a crushing plant with and without controls; explosives by type; a blast deeper than 21 m (`incompatible` → manual); stockpile area unknown (`needs_input`); haul roads at exactly 10,000 vehicle-km (not included, because the Notice says "more than").
- Whole-facility cases:
  - production below 500,000 t with only pit activity (excluded, documented no-filing);
  - production at exactly 500,000 t with low hours (employee gate removed; Part 4 assessed);
  - a mixed site with an asphalt plant (pack plus a shared `asphalt_plant` module, or manual);
  - an open-pit mine (rerouted).

### 3.5 Expected size

| Item | Estimate |
|---|---|
| New code | ~0.2–0.5k lines (one derivation, importer configs, possibly a `fugitive_dust` mode if N5 didn't cover wind erosion) |
| New data | 8 module folders, ~150–300 factor rows, ~40 questions |
| Golden cases | ~30 module + ~5 facility |
| Effort | ~6 weeks at the assumed staffing (N6, shared with pipelines) |

In v0's style, the same scope would have meant per-process builders, review services and editors: roughly 12 processes × ~3.9k lines.

## 4. When an industry doesn't fit

Some industries need math the 14 calculators don't cover well. Examples are refinery speciation profiles, tailings with clean/inert tests, and smelter Part 3 congener reporting. The response is ordered:

1. **Prefer a new mode of an existing calculator**, if the math is the same shape. Speciation profiles are `composition` in `speciate_output` mode with a profile table.
2. **Add a calculator**, if the math is genuinely new (`tailings_waste_rock`, `landfill_gas`). It is reviewed like engine code and accepted with official examples.
3. **Keep it manual**, if clients are few and the method is case-specific. Manual-supported is a legitimate long-term state.
4. **Never** add an industry branch to the engine stages, and never put logic in the pack.

## 5. Checklist (copy into the pack's PR)

- [ ] Process inventory reviewed by a practitioner; every process mapped to a module or marked manual
- [ ] Special notice rules identified; rule functions exist; boundary cases added
- [ ] Calculator gaps resolved, or explicitly manual
- [ ] Import manifests reviewed; counts frozen; substance map reviewed
- [ ] Every factor row has source ID, locator, digest, rating and control basis
- [ ] Questions typed, owners and review policies set, evidence options listed
- [ ] ≥2 signed cases for every `automatic` branch; whole-facility cases signed
- [ ] Coverage register diff attached; no `automatic` branch on `published_unreviewed` rows
- [ ] Source register updated with new S-IDs
- [ ] Release notes: what is automatic, manual and unsupported
