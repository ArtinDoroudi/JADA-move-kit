# 07 — Regulation as data

Prepared: 2026-11-09. Status: proposed structure. The **content** is the existing sourced material in the [regulatory inventory](../v0-regulatory-inventory.md) and the [source register](../sources-and-decisions.md). This document defines where that content lives and how the engine consumes it. No rule interpretation here is new. Where the inventory records an unresolved conflict, it stays an explicit interpretation hold.

> **Revised 2026-11-11:** Interpretation holds now block only the cases where they change an outcome ([00 §7.6](00-automation-first-plan.md#76-open-interpretation-items-become-conditional)).

## 1. Principle

> **Parameters and identities are data. Logic is a small library of named, versioned functions. The notice folder binds the two.**

v0 already did the first half for substances: `substances_2026.json` has 493 records, matched by identity, with source rows and qualifiers. It did not do it for obligations and Part rules, which live in `reporting_obligations.py` (1,031 lines), `reporting_metadata.py` (961) and `reporting_duties.py` (306). This proposal finishes the job.

## 2. Folder layout

```text
content/regulation/notice_2025_2027/
  notice.yaml                 # identity, years, sources and digests, deadline rules
  substances.json             # identities, parts, groups, thresholds, qualifiers (from v0)
  groups.yaml                 # explicit group membership and aggregation semantics
  parts.yaml                  # Part definitions: facility types, gates, threshold rule bindings
  exemptions.yaml             # §1(1)(a), §1(2), §2–§4 exclusions, §14, §17
  facility_cases.yaml         # Part 4/5 case selection (§§11–13, §16) parameters
  stacks.yaml                 # Schedule 4 Table 4 minimums, height, temperature, exclusions
  obligations.yaml            # Schedule 4 reporting categories per Part (from reporting_obligations_2026.json)
  filing_fields.yaml          # field IDs, locators, applicability/validator IDs (from filing_fields_2026.json)
  annual_actions.yaml         # report / DNMC / sale-closure-purchase / voluntary / no-filing
  holds.yaml                  # interpretation holds (I02, I03, I04, …) and their current status
  conversions.yaml            # regulatory unit conventions (tonnes vs kg per Part, TEQ, etc.)
  sources/                    # retained source copies or digests + locators
content/core/rules/           # Python: the rule function library (versioned)
```

## 3. `notice.yaml`

```yaml
id: notice_2025_2027
title: Notice with respect to substances in the NPRI for 2025, 2026 and 2027
gazette: {part: I, date: 2025-03-08, url: "https://gazette.gc.ca/rp-pr/p1/2025/2025-03-08/html/sup1-eng.html"}
reporting_years: [2025, 2026, 2027]
deadlines: {default: "June 1 of the following year"}   # 2026 → 2027-06-01
retention_years: 3
prevails_over: [G1]                                   # S02 guide
sources:
  N1: {source_id: S01, digest: "sha256:…", retrieved: 2026-11-04}
  G1: {source_id: S02, digest: "sha256:…", retrieved: 2026-11-05}
  W1: {source_id: S03, digest: "sha256:3f59b956…26e2dd8"}
amendment_audit:
  last_checked: 2026-11-04
  method: "Gazette notices index + targeted search"
  exhaustive: false                                    # carried from S01 note; recheck before release
```

`amendment_audit` is a release gate. A pack release that pins this notice fails CI if `last_checked` is older than a configured window, 30 days during filing season.

## 4. Substances and groups

`substances.json` is v0's `substances_2026.json`, kept as is (`dataset_version`, per-record source rows, bilingual names, `threshold_subject_id`, threshold value/unit/kind, concentration threshold with explicit basis, reporting unit, flags, qualifiers). Measured composition:

| Part | Records |
|---|---|
| 1A | 177 |
| 1B | 33 |
| 1C (PFAS) | 163 |
| 2 (PAH) | 32 |
| 3 (dioxins/furans/HCB) | 19 |
| 4 (CAC) | 7 |
| 5 (speciated VOC) | 62 |
| **Total** | **493** |

Every record still carries `review_state: source_import_pending_notice_reconciliation`. Moving it to `notice_reconciled` is a practitioner task per Part, tracked as open items on the notice itself, not on client cases. Until a substance is reconciled, any assessment that uses it carries a non-blocking `jada` warning in staging. In production, it is a release gate for packs that declare it in an `automatic` branch.

`groups.yaml` makes aggregation semantics explicit, which v0 handled partly in code:

```yaml
- group_id: "part1B:benzothiazoles"
  members_from: substances.json#group_member_cas_rns
  threshold_scope: group_total          # one threshold over the group
  concentration_eligibility: needs_interpretation   # regulatory inventory open gate 3
- group_id: "part1C:*"
  threshold_scope: individual           # each PFAS separately; never combined
- group_id: "part4:particulate"
  members: ["part4:NA - M08", "part4:NA - M09", "part4:NA - M10"]   # TPM, PM10, PM2.5
  relation: nested                      # separate assessments; never summed together
```

## 5. Parts: rule bindings with parameters

```yaml
# parts.yaml (excerpt)
part1A:
  facility_types: [contiguous, offshore]
  gates:
    - rule: employee_hours_or_exempt_activity@1
      params: {min_hours: 20000, exempt_activities: exemptions.yaml#s1_1_a}
  threshold:
    rule: mpo_threshold@1
    params:
      basis_from: substances.json      # threshold_kg, concentration_threshold_percent per record
      comparator: gte
      count_regardless_of_concentration: [by_product, tailings, waste_rock_non_clean_inert]
      range_policy: average_after_supplier_followup     # G1 §5.2.2; review required
  reporting_unit: tonnes
  report_when_met: [air_release, disposal, transfer_for_recycling]   # see obligations.yaml
part2:
  facility_types: [contiguous, portable, offshore]
  gates:
    - rule: employee_hours_or_exempt_activity@1
      params: {min_hours: 20000}
  threshold:
    rule: aggregate_group_trigger@1
    params: {group: "part2:all_pah", trigger_kg: 50, comparator: gte,
             sources: [incidental_manufacture, tailings], exclude: ["naphthalene"]}
  special_branches:
    - rule: creosote_unconditional@1
  individual_reporting: {min_kg: 5}
part3:
  facility_types: [contiguous, portable, offshore]
  trigger:
    rule: specified_activity@1
    params: {activities: exemptions.yaml#part3_activities}   # incineration ≥26 t, PCP preservation, base-metal smelting, EAF steel, ...
  no_information_permitted: true
part4:
  facility_types: [contiguous, portable, pipeline, offshore]
  threshold:
    rule: air_release_threshold@1
    params:
      comparator: gte
      thresholds_from: substances.json   # part4 records carry threshold_value/unit:
      # part4:630-08-0 CO 20 t · part4:11104-93-1 NOx 20 t · part4:NA - M10 PM2.5 0.3 t
      # part4:NA - M09 PM10 0.5 t · part4:7446-09-5 SO2 20 t · part4:NA - M08 TPM 20 t
      # part4:NA - M16 total VOC 10 t
      road_dust: {min_vehicle_km: 10000, comparator: gt}
  facility_case: facility_cases.yaml#part4
  exemptions: [exemptions.yaml#s14_external_combustion]
part5:
  facility_types: [contiguous, portable, pipeline, offshore]
  threshold:
    rule: air_release_threshold@1
    params: {comparator: gte, default_threshold_t: 1, per_identity: true}
  facility_case: facility_cases.yaml#part5
  exemptions: [exemptions.yaml#s17_external_combustion]
  not_prerequisite: [total_voc]
```

The numeric values above are those recorded in the [regulatory inventory](../v0-regulatory-inventory.md#part-by-part-decision-inventory) and in v0's `substances_2026.json` Part 4 records. Thresholds are read from the substance records, not repeated in `parts.yaml`, so there is one place to change them. The loader rejects any rule parameter keyed to an ID that does not exist in `substances.json`.

## 6. The rule function library

Each rule is a pure function in `core/rules/` with a fixed signature, registered by `id@version`:

```python
@rule("mpo_threshold", version=1)
def mpo_threshold(agg: Aggregate, subject: SubstanceRecord, params: MpoParams) -> Assessment: ...
```

Planned library for notice 2025–2027 (estimate ~1.5k lines total):

| Rule | Used for | Notes |
|---|---|---|
| `employee_hours_or_exempt_activity@1` | Part 1, 2, (3) gates | Per-Part; unknown categories → `needs_input` |
| `facility_type_in@1` | All Parts | Category must be evidenced |
| `mpo_threshold@1` | 1A, 1B, 1C | Concentration gating, qualifiers, by-product/tailings/waste-rock clauses, ranges |
| `aggregate_group_trigger@1` | Part 2, group thresholds | Group semantics from `groups.yaml` |
| `creosote_unconditional@1` | Part 2 special branch | |
| `specified_activity@1` | Part 3, §1(1)(a) | Activity facts only; never keyword matching |
| `air_release_threshold@1` | Part 4, 5 | Inclusive comparators; per-identity; nested PM |
| `part45_facility_case@1` | §§11–13, §16 | Selects the source set used in stage 5 |
| `external_combustion_exemption@1` | §14, §17 | All conditions: exclusive source, capacity < 10 MMBtu/h, listed fuels only |
| `hexavalent_chromium_override@1` | Part 1B | Chromium Electroplating, Anodizing and Reverse Etching Regulations override |
| `individual_stack@1` | Schedule 4 §§20, 23 | Height, Table 4 minimum, temperature; holds |
| `annual_action_plan@1` | Annual closure | Prior reporter, ownership, criteria met |

When the next notice arrives, most rules are reused with new parameters. A rule whose *logic* changes gets `@2`, the new notice binds `@2`, and the old notice keeps `@1`.

## 7. Exemptions, facility cases and stacks

```yaml
# exemptions.yaml (excerpt)
s1_1_a:                                  # employee-hours-exempt activities
  - {id: incineration_non_haz_ge_26t,    locator: "Sch. 3 §1(1)(a)"}
  - {id: incineration_biomedical_ge_26t, locator: "Sch. 3 §1(1)(a)"}
  - {id: incineration_hazardous,         locator: "Sch. 3 §1(1)(a)"}
  - {id: incineration_sewage_sludge,     locator: "Sch. 3 §1(1)(a)"}
  - {id: wood_preservation,              locator: "Sch. 3 §1(1)(a)"}
  - {id: terminal_operations,            locator: "Sch. 3 §1(1)(a)"}
  - {id: wastewater_ge_10000_m3_day,     locator: "Sch. 3 §1(1)(a)"}
  - {id: pit_quarry_production_ge_500000_t, locator: "Sch. 3 §1(1)(a)"}
s14_external_combustion:
  applies_to: part4
  conditions:
    exclusive_source: stationary_external_combustion
    capacity_total_lt_mmbtu_h: 10        # strict "<"; equality does not qualify
    fuels_only: [commercial_natural_gas, lpg, fuel_oil_no1, fuel_oil_no2]
```

Each `s1_1_a` entry becomes a **core JADA question** (`jada.s1_1_a.<id>`) with states present / absent / unknown. The roadmap's mandatory internal reconciliation of the exceptional-activity lists is therefore generated from data rather than hand-built.

`stacks.yaml` holds the Schedule 4 Table 4 minimums from the inventory:

| Part 4 stack minimum (Notice) | Value |
|---|---|
| CO | 10 t |
| NOx | 10 t (hold I03: Guide says 20 t) |
| PM2.5 | 0.25 t |
| PM10 | 0.5 t |
| SO2 | 25 t |
| TPM | 25 t |
| Total VOC | 5 t |
| Each Part 5 speciated VOC | 0.25 t |

The file also holds: height ≥ 25 m, vertical; temperature "measured to be above 50 °C" (hold I04); and the exclusions for horizontal stacks, rain caps and storage-tank vents.

## 8. Interpretation holds are data

```yaml
# holds.yaml
I03:
  topic: Individual stack NOx threshold
  notice: "Sch. 4 Table 4: 10 t"
  guide: "App. D Table 18: 20 t"
  status: open                             # open | resolved
  engine_effect: needs_interpretation      # for any outlet whose NOx falls in [10 t, 20 t)
  owner: practitioner
I04:
  topic: Stack temperature comparator and unmeasured temperature
  status: open
  engine_effect: needs_interpretation      # for unmeasured, estimated, permit or exactly-50 °C cases
I02:
  topic: Cobalt Part classification in S04 vs S01/S03
  status: resolved
  resolution: "Part 1B per S01/S03; regression case required"
waste_rock_arsenic_equality:
  topic: "Sch. 3 §3(3) 'more than 12 mg/kg' vs Guide §5.3.2 'less than 12 mg/kg'"
  status: resolved_by_precedence
  resolution: "Notice prevails; exactly 12 mg/kg remains excludable"
```

Rule functions consult `holds.yaml`. While a hold is `open`, the affected decision returns `needs_interpretation` with a `practitioner` open item. Resolving a hold means changing data and bumping the notice content version, with the practitioner's name and reasoning. It is never a code change.

## 9. Obligations and filing fields

`obligations.yaml` absorbs `reporting_obligations_2026.json` (Part 1 categories with detail codes, Part 4 categories, remaining duties such as condensable PM status) and the per-duty special cases currently coded in `reporting_duties.py` and the `part4_*` modules. Each duty is one entry:

```yaml
- id: part4_monthly_distribution
  applies_when: {assessment: part4, outcome: met}
  locator: "Sch. 4 §20"
  question: F.part4.monthly_distribution          # a filing-field question; facts hold the values
  validator: monthly_percentages_sum_to_100@1
  state: supported
- id: part4_condensable_pm_status
  applies_when: {assessment: part4, substances: [TPM, PM10, PM2.5], route: stack_or_point}
  locator: "Sch. 4 §20(c)"
  question: F.part4.condensable_pm
  validator: enum_known@1
  state: supported
- id: part4_egu_details
  applies_when: {facility_fact: has_electricity_generating_unit, equals: true}
  locator: "Sch. 4 §21"
  state: parked                                    # see migration: behind a flag until a client needs it
```

`filing_fields.yaml` comes from `filing_fields_2026.json`. Each field has an identifier, source locator, data path (a question ID or a run path), unit, allowed values, and **named** applicability and validator IDs, never predicate strings. That was already the [closure design](../v0-closure-design.md#6-filing-fields-and-annual-actions-are-independent-gates)'s rule.

The result: a new Schedule 4 duty of an existing shape is a YAML entry plus a question, with no new service, schema, route or editor. A duty of a genuinely new shape needs one validator function.

## 10. Adding the next notice

1. Create `notice_2028_2030/` (or whatever the Gazette publishes) by copying the previous folder.
2. Re-import the substance list from the new official workbook using the same identity-based importer. Diff it against the previous notice.
3. Update parameters. Bump any rule whose logic changed to `@N+1`.
4. Update `holds.yaml`: carry forward open holds and close any the new text resolves.
5. Run the notice's regression cases (the regulatory inventory's boundary fixtures, re-parameterized), then all packs' golden cases with the new notice pinned in a branch.
6. Release packs targeting the new notice as `2028.1`.

Old notices are never edited after a filed revision references them.
