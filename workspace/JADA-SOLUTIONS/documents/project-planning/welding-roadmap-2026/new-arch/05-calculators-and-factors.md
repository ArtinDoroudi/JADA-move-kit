# 05 — Calculators and factor tables

Prepared: 2026-11-09. Status: proposed contract. Factor counts below were measured from the official ECCC *Electric Arc Welding, Cutting and Spraying Calculator* (linked workbook dated 2022-10-26, SHA256 `4c3e6f6a0fc1acd8038ab5ccd6e82cf65cd65e5d6bc69a7372b0a2a23dddaa93`). That is the same file v0 cites as [S05](../sources-and-decisions.md#s05). It was inspected read-only on 2026-11-09. No factor is approved by this document. Every row keeps `published_unreviewed` until it passes the gates in [10](10-golden-cases-and-verification.md).

> **Revised 2026-11-11:** The §3 rule that "Other" rows need a JADA eligibility fact is replaced by the Method 1 default ([00 §6.3](00-automation-first-plan.md#63-starter-default-set-for-metal_fab-proposed-each-needs-one-time-approval)); promotion is by workbook parity ([00 §8.1](00-automation-first-plan.md#81-workbook-parity-the-main-accuracy-gate)).

## 1. What a calculator is

A calculator is a pure function that implements one kind of quantification math, for any industry, from typed inputs and factor rows.

```python
# core/calculators/activity_x_factor.py
@calculator("activity_x_factor", version=1,
            inputs={"activity": Dim.ANY, "fraction_of_activity": Dim.FRACTION | None},
            factor_dims=("output_per_activity",))
def run(ctx: CalcContext, activity: Quantity, factor: FactorRow,
        fraction_of_activity: Quantity | None = None) -> list[ContributionDraft]:
    basis = activity.to(factor.activity_unit)                  # exact unit-table conversion
    if fraction_of_activity is not None:
        basis = basis * fraction_of_activity.as_mass_fraction()
    amount = (basis * factor.value).to(ctx.output_unit)        # Decimal, no rounding
    return [ContributionDraft(
        substance_id=factor.substance_id, chemical_basis=factor.chemical_basis,
        quantity_kind=factor.quantity_kind, medium=factor.medium,
        quantity=amount, rating=factor.rating, flags=factor.flags,
        trace=[ctx.step("activity", activity), ctx.step("factor", factor.ref),
               ctx.step("result", amount)],
    )]
```

Rules for every calculator:

1. **Pure.** No I/O, no clock, no globals, no randomness.
2. **Typed inputs with dimensions.** The registry checks at content-load time that a module's binding supplies the dimensions the calculator declares. Mass into a time-based factor is a load error, not a runtime surprise.
3. **Decimal only.** No float. Intermediate values are never rounded.
4. **Never invents.** If a needed input or factor is absent, the calculator is not called. Stage 3 raises the open item instead.
5. **Full trace.** Every draft lists its activity fact, factor row ID, conversions and result.
6. **Versioned.** `activity_x_factor@1` is immutable once a filed revision uses it. A behavior change is `@2`, and both stay registered for replay ([11](11-lifecycle-freshness-and-replay.md#5-replay)).
7. **Small.** Most calculators are 50–200 lines. Complex ones such as tanks or landfill gas stay under ~400.

## 2. The registry: 14 calculators across all industries

These estimates come from the [all-industry scope](https://claude.ai/artifact/BjfGdcG6SJU5E8JPszasGs). Welding needs the first four, plus the built-in `manual`.

| # | Calculator | Math | Typical inputs | Welding pack uses | First needed |
|---|---|---|---|---|---|
| 1 | `activity_x_factor` | activity × factor (× optional fraction of activity) | consumable kg, active cutting minutes, feedstock kg, abrasive tonnes, production tonnes | Arc welding P01/P02 listed rows and "Other" averages; cutting PM (g/min); spraying PM and metals (g/kg of constituent); blasting (kg/t) | N1 |
| 2 | `composition` | quantity × mass fraction; three modes: `material_fraction` (MPO), `speciate_output` (fraction × a parent contribution), `constituent_mass` (feeds another binding) | material mass and composition; parent output and fraction | Part 1 MPO from SDS composition; cutting metals = fraction × TPM; welding PM2.5 = 0.75 × PM10; spray constituent mass | N1 |
| 3 | `mass_balance` | inputs − stock change − outputs = residual, assigned to a declared route only if the module allows it | purchased, opening/closing stock, waste, recovered, retained in product | Solvent cleaning (P12), liquid coating (P13), powder flows (P14), product chemicals (P21) | N1 |
| 4 | `fuel_combustion` | fuel quantity × (site HHV ÷ reference HHV) × factor per fuel unit; or energy × factor per energy | fuel volume/mass/energy, HHV, equipment class, capacity, control | Heaters, boilers, ovens (P20) and fuel portions of P04/P14/P19 | N1 |
| 5 | `tank_losses` | standing plus working losses (AP-42 7.1 / ECCC storage-tank method) | tank geometry, contents, throughput, temperature, vapour pressure | P22 (manual first) | N5 |
| 6 | `flaring` | gas volume × composition × (1 − destruction efficiency) plus combustion products | flared volume, composition, efficiency | — | N5 |
| 7 | `equipment_leaks` | component counts × factors, or LDAR-based | component inventory, service, hours | — | N5 |
| 8 | `fugitive_dust` | road dust (AP-42 13.2.2 / ECCC unpaved road guide), handling, piles | vehicle km, weights, silt, precipitation days, control | P25 road segments | N5 |
| 9 | `sour_gas_so2` | sulfur balance (inlet S − recovered S) → SO2 | gas volume, H2S content, recovery | — | N5 |
| 10 | `measured_continuous` | integrate CEMS or PEMS series with data substitution rules | hourly series, flags | — | Later |
| 11 | `measured_concentration` | concentration × flow × time per segment (stack test, wastewater, waste stream) | concentration, flow/volume, operating hours, detection limits | P24 water and P23 waste with measured data (manual first) | N4 |
| 12 | `tailings_waste_rock` | composition × mass with clean/inert rules | mass, composition, arsenic test | — | Wave 4 |
| 13 | `wastewater_fate` | influent load × removal and fate fractions | flow, concentration, process type | — | Wave 3 |
| 14 | `landfill_gas` | first-order decay (LandGEM-style) × collection and destruction | waste in place by year, k, L0, collection efficiency | — | Wave 3 |
| — | `manual` (built-in) | wraps an accepted `jada.manual_result` as contributions | reviewed outputs with method, locator and steps | Every family without an automatic method | N1 |

**Rule of two:** a calculator is generalized, or a new mode is added, only when a second module needs it. `measured_concentration` covers stack tests, wastewater and waste streams with one implementation because the math is identical. It is not built until the first pack needs it automatically.

## 3. Factor selection

Each module binding names its factor table and its **match keys** ([06](06-pack-format-spec.md#3-moduleyaml)). Selection is exact and returns exactly one of four outcomes, as in the [roadmap](../README.md#factor-and-formula-handling):

| Outcome | When | Effect |
|---|---|---|
| `applicable` | Exactly one row matches all keys and its conditions are satisfied by accepted facts | Value, units, basis and source go to the calculator |
| `needs_input` | A match key's fact is unknown, such as the electrode class | `client` open item for that fact |
| `no_supported_factor` | No row for this key combination, or the row is `not_available` | `jada` open item: choose an eligible alternative binding or a manual result |
| `incompatible` | A row exists but its conditions fail, such as wrong control basis, wind class, filler condition or method variant | `jada` open item with the failed condition |

Further rules:

- **Exact keys only.** No fuzzy product-name match decides a factor. A product name maps to a classification through a reviewed fact (`P01-2.class`), and the classification matches the row.
- **"Other" rows need an explicit binding.** The workbook's "Other SMAW", "Other GMAW", … "Other Welding Methods" rows are not a silent fallback. They sit in a separate binding (`welding_arc.other_method1`) whose `eligible_when` requires an accepted `jada.method_eligibility` fact stating why the listed path does not apply. The same applies to Method 2 composition ([08 §4](08-welding-pack-design.md#4-the-other-electrode-paths)).
- **Published zero is not "no factor".** `value_kind: published_zero` produces a contribution of exactly 0 with its source, and the slot closes as `evidenced_zero`. `value_kind: not_available` produces `no_supported_factor`.
- **Duplicates are content errors.** Two applicable rows for one key set fail validation at load time, not at runtime.
- **Site-specific factors** are facts (`jada.site_factor`) with evidence and independent review. A binding may prefer them (`prefer: site_factor`). They never edit the pack's CSV.

## 4. The factor table contract

Factor tables are long-format CSV, with one row per (key combination × output). Columns:

| Column | Required | Meaning |
|---|---|---|
| `row_id` | yes | Stable, human-readable: `w2:p1:SMAW:E310:chromium` |
| key columns | yes | Declared by the module, for example `process`, `consumable_class`, `method_variant`, `wind_class`, `equipment_class`, `fuel` |
| `substance_id` | yes | Notice identity such as `part1A:NA - 09`, or `unresolved:<reason>` when the source basis is not yet mapped |
| `chemical_basis` | yes | The source label and basis, for example `as Mn`, or `chromium_factor_basis_unresolved` |
| `quantity_kind` | yes | `release`, `assessment`, `fraction`, … |
| `medium` | for releases | `air`, `water`, `land` |
| `value` | unless `value_kind` ≠ number | Decimal string, exactly as published |
| `value_kind` | yes | `number`, `published_zero`, `not_available`, `derived` |
| `numerator_unit` / `activity_unit` | yes | For example `g` per `kg_electrode`, `g` per `min_active_cutting`, `kg` per `t_abrasive`, `lb` per `MMscf` |
| `control_basis` | yes | `uncontrolled`, `controlled`, `not_stated` |
| condition columns | optional | `cond_filler: required`, `cond_wind_kmh: 8`, `cond_capacity_lt_mmbtu_h: 100` |
| `rating` | yes | Source quality rating (A–E, `-`) |
| `source_id` | yes | S-ID from the [source register](../sources-and-decisions.md) |
| `source_locator` | yes | Sheet, cell, table and footnote: `Part 1 Releases!D23` |
| `source_digest` | yes | SHA256 of the retained source edition |
| `review_state` | yes | `published_unreviewed`, then `jada_reviewed`, then `approved_for_automatic` |
| `notes` | optional | For example the source formula of a derived cell |

`value_kind: derived` records a value the source computes, such as the five Part 1 cells written `=0.001/2` in the workbook. The row stores `0.0005`, the original formula text in `notes`, and the open question of what the convention means. Each derived row needs practitioner review before it is used.

The loader validates every table against these rules:

- every row has a source and a digest;
- keys are complete;
- units exist in the unit table and match the calculator's dimensions;
- `value` parses as a finite, non-negative Decimal;
- there are no duplicate key sets;
- the row count matches the import manifest.

## 5. The manual calculator

`manual@1` turns an accepted `jada.manual_result` fact into contributions. The fact's value schema is v0's manual contract:

- named source, activity and output slots;
- the reason automatic methods do not apply;
- method and source locator, and the eligibility rationale;
- typed operands with units and evidence;
- calculation steps or an attached reproducible workbook;
- output quantities, identities, basis and destinations;
- uncertainty and assumptions.

Review policy is `independent`.

Because the output goes through the same stage 4 reconciliation and slot binding as automatic results, **manual parity is structural**. There is no separate manual aggregation path to keep in sync. A manual result that collides with an automatic result on the same slot blocks until one is superseded.

## 6. Units and numbers

- **Unit table** (`core/units.yaml`) lists each unit's dimension and its exact factor to the base unit. Examples: `g→kg 0.001`; `lb→kg 0.45359237` (exact); `min→h 1/60`; `US_gal→L 3.785411784` (exact); `scf→m3 0.028316846592` (exact geometric; reference conditions are a separate fact); `MMBtu→Btu 1000000`; `t→kg 1000`.
- Volume of gas at reference conditions is **not** converted to mass or to other conditions unless a binding supplies an accepted reference-conditions fact. This is v0's `reference_conditions_match` rule, now a declared calculator input.
- Percent and fraction are separate units (`percent`, `mass_fraction`). They are converted once at the calculator boundary. A concentration like selenium's 0.000005 % must round-trip exactly. That precision test is carried over from the [v0 plan](../v0-implementation-plan.md#companion-rule-inventory-and-precision-constraint).
- Display rounding happens only in export, per the reporting unit (tonnes or kg) and the filing system's three-decimal convention. Thresholds compare unrounded values.

## 7. Calculator acceptance

A calculator version is accepted when all of these pass:

1. **Dimensional tests:** every declared input dimension and every unit in the table that it can receive.
2. **Two independent expected-value origins:** hand-worked arithmetic, plus an official worked example or recalculated workbook cell where one exists. Expected values never come from calling the calculator.
3. **Edge cases:** zero activity, published zero factor, range inputs (lo/hi propagate), maximum-precision Decimal inputs and negative or invalid inputs (rejected).
4. **Trace completeness:** every output references its input facts and factor row.
5. **Review:** a developer other than the author approves the code, and a practitioner confirms the worked examples' meaning.

### Worked examples used as acceptance fixtures

These come from data already in v0 or the official sources. They are the first fixtures for each calculator. Results are arithmetic only; reportability still depends on stages 5–7.

| Calculator | Case | Arithmetic | Result |
|---|---|---|---|
| `activity_x_factor` | SMAW E310, 1,200 kg electrode, factor 2.53 g/kg (`Part 1 Releases!D23`, rating C) | 1,200 × 2.53 ÷ 1,000 | **3.036 kg**, `chemical_basis: chromium_factor_basis_unresolved` |
| `activity_x_factor` | SMAW E310 PM10, 15.1 g/kg (`Part 4 Releases!D16`) | 1,200 × 15.1 ÷ 1,000 | **18.12 kg** PM10; TPM equal per workbook `Instructions!A60` |
| `composition` (`speciate_output`) | PM2.5 = 75% of PM10 (`Instructions!A61`) | 18.12 × 0.75 | **13.59 kg** PM2.5 |
| `activity_x_factor` | Oxy cutting PM10 0.38 g/min, 100 active hours | 100 × 60 × 0.38 ÷ 1,000 | **2.28 kg** |
| `composition` (`speciate_output`) | Oxy-cutting chromium = cutting mass fraction × TPM (`Part 1 Releases!S19 = Q19 × R19 × 1000`) | for an 18% Cr stock and 2.28 kg TPM: 0.18 × 2.28 | **0.4104 kg** |
| `activity_x_factor` | Blasting, sand on mild steel, 10 t abrasive, 8 km/h class (ECCC blasting page, AP-42 13.2.6-1) | 10 t × 27 kg/t (TPM), 10 t × 13 kg/t (PM10), 10 t × 1.3 kg/t (PM2.5) | **TPM 270, PM10 130, PM2.5 13 kg**; matches the v0 plan's gate |
| `mass_balance` | Solvent: 100 in, +10 stock, 20 in waste, 5 recovered, 15 retained in product | 100 − 10 − 20 − 5 − 15 | **50 kg** residual to air, only if the module's boundary declares air as the residual route; a negative residual blocks |
| `fuel_combustion` | Natural gas, small boiler, uncontrolled, 10 MMscf at HHV 1,020 Btu/scf, NOx 100 lb/MMscf (AP-42 Table 1.4-1) | 10 × 100 × (1,020 ÷ 1,020) × 0.45359237 | **453.59237 kg** NOx as NO2 |

## 8. Where v0's method code goes

| v0 code | Becomes |
|---|---|
| `methods.py` `CandidateFactor`, `CandidateEstimate`, loaders | `core/calculators/types.py` (FactorRow, ContributionDraft) and the generic factor loader |
| `_build_arc_e310_outputs` (322 lines) | `activity_x_factor@1` plus `welding_arc/factors.csv` rows plus the binding in `welding_arc/module.yaml` |
| `_build_abrasive_blasting_outputs` (203 lines) | `activity_x_factor@1` plus `abrasive_blasting/factors.csv` (5 rows today) plus the `wind_class` derivation |
| `combustion.py` / `combustion_adapter.py` (~800 lines) | `fuel_combustion@1` plus `boilers_heaters/factors.csv` (2 rows today) |
| `organic_methods.py` (980 lines; `solvent-balance-v1`, `liquid-coating-balance-v1`) | `mass_balance@1` plus `degreasing` and `surface_coating` module bindings |
| `process_methods.py` (854 lines; cutting, spraying) | `activity_x_factor@1` and `composition@1` bindings in `thermal_cutting` and `thermal_spray` |
| `composition.py`, `_build_part1_material_assessments` | `composition@1` (`material_fraction` mode) bound by core material assessment |
| `manual-calculation-v1`, `manual-result-review-v1` | `manual@1` plus the `jada.manual_result` question |

v0 method IDs (`arc-listed-v1`, `abrasive-blast-v1`, …) are preserved as **binding IDs** inside modules, so runs and filed history remain traceable across the migration ([12](12-migration-from-v0.md)).
