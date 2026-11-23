# Next calculation implementation

Updated: 2026-11-03
Status: Proposed implementation brief; no regulatory engine or application changes made in this run.

2026-11-04: the [facility roadmap](welding-roadmap-2026/README.md) places this first implementation slice within the broader process coverage, questionnaire and development cycles. This brief remains the starting contract for small decisions, not the complete facility scope.

## The actual problem

Artin clarified that JADA consults the manual to resolve cases during report preparation. Its expertise is not already a complete decision table. The development task therefore includes extracting small, reviewable decisions from those lookups. Neither Artin nor JADA needs to design the entire dependency graph in advance.

Use AI during development to locate candidate passages, draft decision tables, and propose tests. Resolve the interpretation and source applicability before making that rule executable. At runtime, use deterministic functions for accepted rules and calculations; use explicit tasks for missing information or unresolved interpretation. An AI answer with a citation is not itself an approved calculation method.

## What the terms mean

| Term | Meaning in software | Example |
|---|---|---|
| Rule | A decision about whether or how to calculate/report | Decide whether a contribution belongs in an assessment total |
| Exception | A condition changing a specific rule | Article status can affect whether base metal enters threshold calculations |
| Formula | Arithmetic with defined inputs and units | An emission-factor method multiplies activity quantity by the relevant emission factor |
| Factor | A sourced parameter used by a formula | An amount emitted per unit of material used, restricted to a particular process/material/method |
| Method | Applicability, inputs, factors, formulas, and output meaning together | Estimate using published emission factors or using appropriate measurement data |
| Missing information | A required fact that has no accepted value | Active cutting hours required by the selected cutting method |

Source examples: [ECCC welding guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/arc-welding-cutting-spraying-calculator.html), sections on thresholds and active cutting hours; [2025–2027 reporting guide](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/reporting-guide.html), section 3.6. These examples explain modeling, not complete executable rules.

## Current-code boundary

Inspected the active backend, including:

- `app/services/mpo/threshold_calculator.py`: aggregates normalized material mass multiplied by SDS percentages. The same 10,000 kg reporting constant and 1,000 kg review constant are applied across result rows. Process context is not consumed.
- `app/models/npri_substance.py`: has year-specific mass and concentration threshold fields; the inspected calculator does not use those fields for its comparison.
- `app/models/reporting_period.py`: stores processes, control measures, and waste methods as JSON arrays of strings. Their presence does not establish material-to-process allocation or method selection.

This confirms an existing threshold feature, not a complete implementation of NPRI threshold rules. Database contents were not inspected. Do not assume that 2026 rule data is populated or validated. Existing extraction/matching/normalization can feed the next layer without being rebuilt.

## A small decision contract

Every decision returns the same envelope:

```text
decision_id
subject_id                 # facility, activity, contribution, or substance assessment
rule_id + version
state                      # resolved | needs_input | needs_interpretation | unsupported
value                      # typed result, only when resolved
input_references
source_references
reasons
requirements[]             # fact, why needed, evidence options, affected decision
```

Only a resolved decision has an authoritative value. Missing data is not false, zero, below threshold, or not applicable. An unsupported branch records why it cannot be evaluated; a JADA calculation or interpretation must be attached and reviewed before resolving it.

Input requirements should be deduplicated by fact, facility/activity, and reporting year. A client should answer one shared question once, even when several rules depend on it. Some requirements are client facts; others are developer tasks or JADA interpretations. Do not send requests to clients for missing software capabilities.

For the first implementation, run functions in an explicit order and recalculate a draft case after edits. Each function declares its required facts. No graph database, arbitrary expression evaluator, or general workflow language is required. More selective invalidation can come later; approved outputs must still reference a frozen input/version set.

## Separate two kinds of quantity

Keep a substance's material quantity, threshold-assessment contribution, and release/disposal/recycling contribution distinct. Do not overwrite them with one `total_kg`.

The official welding example assesses manganese using material composition, then estimates emissions; its particulate example uses emissions for threshold comparison. This is why the architecture must allow dependencies to differ by rule family. See [ECCC examples](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/arc-welding-cutting-spraying-calculator.html).

Proposed records:

```text
AssessmentContribution(material/activity, substance, quantity, basis, inclusion_decision)
EmissionContribution(activity, substance, quantity, destination, method_version)
ThresholdAssessment(facility_year, substance_or_group, basis, total, rule_version, outcome)
```

An excluded assessment contribution remains visible with its reason. Exclusion from one calculation does not automatically exclude it from every output. Facility aggregation operates on approved contribution meanings, not simply all rows with the same CAS number.

## The first coding task

Build the decision contract and one bounded threshold-assessment path. Keep facility reporting readiness separate from that individual comparison.

Suggested task to give Codex:

> Extend the existing backend with a deterministic assessment layer for the 2026 pilot. Reuse normalized quantities and matched SDS facts. First implement typed decision results, missing-input requirements, and traceable threshold contributions. Add one explicitly supported ordinary Part 1A assessment path, based on a reviewed source decision table. Require explicit resolved facility applicability and contribution treatment; if either is absent, return a structured pending decision. Do not infer those facts from a product name, an empty field, or the welding industry label. Keep unsupported rule families and exceptions visible as unresolved. Use verified year/substance rule data; do not fall back to a universal threshold or another year's row. Preserve the existing APIs while introducing clearly labeled draft assessment results. Do not mark a facility ready to file from a single threshold comparison.

Before implementing that specific Part 1A path, attach a short source-backed decision table that defines ordinary input contributions, concentration handling, aggregation, equality at the boundary, and relevant exclusions. The [current guide sections 5.1–5.2](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/reporting-guide.html) are a starting point; check the corresponding [2025–2027 Notice](https://gazette.gc.ca/rp-pr/p1/2025/2025-03-08/html/sup1-eng.html) and amendments. A pending concentration interpretation must remain pending, including an SDS range that crosses a decision boundary. This task does not implement all Part 1A cases by using one comparison.

Acceptance cases for this slice:

1. A reviewed supported case reproduces the manually accepted assessment quantity and comparison.
2. Separate activities contributing to the same assessment are aggregated once.
3. An excluded contribution appears with the applicable decision and source.
4. Missing required facts produce actionable requirements rather than an authoritative negative result.
5. Missing year-specific rules and unsupported branches return explicit unresolved states.
6. Below, equal, and above boundary cases follow the reviewed comparator.
7. A concentration range spanning a relevant boundary requires an explicit resolution policy.
8. A changed input produces a new draft calculation trace without modifying an approved snapshot.

Use the isolated test database for integration tests. Pure decision functions should also be testable without a database or LLM.

## How to grow coverage without a giant design exercise

For each manual lookup, capture the narrow question, facts used, source section, conclusion, and one worked example. Turn that into a decision table; ask JADA to review the interpretation and expected result, not to design classes. Implement and test it before adding another branch. Record unresolved contradictions explicitly.

Follow the first threshold slice with one supported welding emission method. Add its factor records, required facts, calculation, and trace. Start with a JADA-confirmed method assignment while method-selection automation matures. This manual step remains part of the recorded workflow.

Track coverage in a small list: implemented, manual-supported, or unsupported, with known limitations and tests. Unsupported relevant activities block facility completeness but need not block independent calculations. Progress means increasing this explicit coverage, not claiming that a passing sample validates the entire facility report.

## Checks for this planning run

Read-only inspection of the listed backend files and existing threshold tests; official web guidance checked on 2026-11-03. Application code and database were not changed. No application tests run. Documentation whitespace checked with `git diff --check`.
