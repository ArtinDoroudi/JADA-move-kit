# NPRI project vision: temporary working plan

Updated: 2026-11-03
Status: Brainstorming. Confirmed scope is distinguished from proposed design. No implementation commitment or completed regulatory validation.

This is the working entry point for the next discovery runs. The [existing discovery notes](discovery-and-brainstorming.md) remain the detailed background. Earlier prototypes do not constrain the design.

2026-11-04 update: the [welding facility roadmap](welding-roadmap-2026/README.md) now develops this vision into a process catalogue, conditional questionnaire, implementation/runtime cycles and source register. Use that set for current coverage planning; the discussion below records the earlier hypotheses.

## What we are trying to build

### Clarification from Artin: implementation is the main uncertainty

JADA already knows the manual reporting process: collect purchase lists and SDS files, determine chemical quantities, apply process and threshold knowledge, and prepare the report. The immediate discovery task is to express that existing expertise as software contracts and worked examples. Broad regulatory research should support specific implementation questions rather than delay modeling the known workflow.

Further clarification: JADA consults the manual as cases arise; the decision logic is not already fully formalized. The [next calculation implementation brief](next-calculation-implementation.md) explains the terms, verified code gaps, and a bounded first coding task. Capture individual manual lookups as reviewable rules rather than asking the team to design the whole software model.

**Recommended approach: hybrid, with deterministic reporting logic.** AI assists with extraction, matching, and suggested classifications. Reviewed structured facts feed explicit Python rules and calculation methods. JADA resolves ambiguous inputs, unsupported methods, and final review. A general autonomous agent is not needed to run the reporting workflow.

Source inspection on 2026-11-03 found that `backend/app/services/mpo/threshold_calculator.py` multiplies normalized line masses by SDS composition ranges and aggregates by CAS/part. It uses shared 10,000 kg reporting and 1,000 kg review constants; it does not consume recorded process context. These describe the implementation, not validated regulatory thresholds. `backend/app/services/emissions/__init__.py` and `backend/app/services/reports/__init__.py` are empty. This was a targeted inspection, not an application audit.

The next useful implementation boundary is **material use within an annual process activity**:

| Proposed record | Purpose |
|---|---|
| Activity | A process at a facility during a reporting year, including relevant equipment and controls |
| Material use | Accepted quantity used by an activity, linked to product/SDS and supporting purchase or inventory records |
| Method assignment | Approved calculation method/version for an activity and output, with required inputs |
| Calculation contribution | Substance, quantity, unit, destination/category, inputs, and method provenance |
| Reporting decision | Applicable rule/version, aggregated assessment quantity, outcome, and explanation |
| Review issue | Missing fact, conflicting evidence, unsupported case, or decision requiring JADA |
| Report revision | Frozen inputs, results, decisions, and review state for a package |

Purchases are evidence for material use; do not require a one-to-one mapping. Several purchases may supply one activity, and one product may supply several activities. Preserve allocation totals and distinguish confirmed usage from an accepted purchase-based estimate. Contributions can also arise from activity data such as fuel use or process generation, without originating in an SDS ingredient row.

Keep method contracts small: `required_inputs(context)`, `validate(inputs)`, and `calculate(inputs)`. Return structured missing requirements and traceable contributions. Start with typed Python functions and versioned factor/configuration records; defer a generic rule language or visual workflow builder until real cases require one.

The next implementation slice should let JADA assign one supported welding activity, connect its materials, supply the chosen method's required facts, execute a reproducible calculation, and inspect a draft output. Use a known manual case as the expected result. Threshold assessment and release/disposal/recycling calculations remain separate outputs with explicit dependencies; the orchestration order may differ by rule family.

This clarification changes the next discovery step: first translate one known manual calculation into inputs, decisions, formulas, and expected outputs. Use source verification to resolve the specific rules in that slice. The larger review plan below remains a coverage checklist, not a prerequisite to beginning implementation modeling.

**Confirmed:** Prepare complete facility NPRI report packages for clients whose main business is welding. JADA reviews and files them. First-year industry scope is welding; the architecture should support other industries later. Clients should be able to participate without understanding HSE terminology.

**Proposed vision:** Turn what the client knows about their business and the records they can supply into a traceable annual reporting case. The system identifies missing facts, supports justified estimates, and gives JADA enough evidence to review every reporting decision.

“Complete facility” means discovering and resolving other relevant activities, not only welding. Painting, cleaning, cutting, combustion, waste handling, and other activities are candidates to investigate, not assumptions about every client. The automated coverage of each remains open. A JADA manual calculation can be part of a complete package if its method, inputs, sources, and review are recorded.

The desired result is a defensible package for the applicable reporting year. Generated output alone cannot establish legal compliance. Regulatory interpretation, facility completeness, evidence quality, and the appropriate approval process must all be addressed.

## What the supplied guide tells us about the work

The supplied `En81-1-2022-eng.pdf` is the 2022–2024 guide, with 155 PDF pages. It is currently in the user's Downloads folder; no copy has been made. The [existing text extract](../guidelines/extracted-text/npri-guide-2022-2024.txt) is a search aid. The PDF is the source for checking its tables and layout.

This run checked PDF metadata, visually inspected the first contents page, and read selected complete pages: printed pages 16–18, 34–35, and 116 (PDF positions 28–30, 46–47, and 128). The contents were also reviewed using the existing extract. This is structural discovery, not a full guide review.

Three examples explain why we need several passes:

- Section 3.6 distinguishes available information, measurement obligations, and estimation methods. A request for a new stack test needs a reason; it is not a default intake requirement.
- Section 5.1 distinguishes amounts used to assess a threshold from quantities ultimately reported. These need separate records and calculations.
- Appendix D adds conditional stack-level reporting and links back to facility-wide substance rules. Stack reporting and the need to commission sampling are different questions.

These are observations about this historical edition, not adopted pilot rules. The [current official guide](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/reporting-guide.html) covers 2025–2027. The applicable Gazette Notice prevails over guidance. The pilot reporting year is **Confirmed: 2026**, as selected by Artin on 2026-11-03. Model the 2026 calendar year using the 2025–2027 source set and applicable amendments; retain the supplied older guide as historical context.

Verified authority links: [2022–2024 Notice](https://gazette.gc.ca/rp-pr/p1/2022/2022-02-12/html/sup1-eng.html) and [2025–2027 Notice](https://gazette.gc.ca/rp-pr/p1/2025/2025-03-08/html/sup1-eng.html). Research found that the current guide's disclaimer link resolves to the older Notice, while its introduction links to the correct edition. Check the actual destination and reporting years when registering sources. An exhaustive amendment scan remains outstanding.

The [official welding guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/arc-welding-cutting-spraying-calculator.html) also distinguishes threshold calculations from release/disposal/recycling calculations and requires other facility processes to be considered where relevant. We must validate sector tools against the selected year's requirements before adopting their formulas or factors.

## How to break the work into manageable runs

Divide by decisions and dependencies, rather than an equal number of pages. Every rule travels with its definitions, exceptions, tables, and referenced sections.

| Run | Question to resolve | Saved deliverable | Completion condition |
|---|---|---|---|
| 1. Sources and coverage | Which sources govern the pilot, and what must be inspected? | Source register, guide map, amendment checklist | Every major rule family has an owner/status; year is explicit or blocked |
| 2. Facility applicability | What is the facility boundary, and when does reporting apply? | Decision tables for facility types, employee/activity criteria, exclusions | Each branch has source references and unknown-data behavior |
| 3. Welding-client activities | What actually happens at representative clients? | Activity inventory and automated/manual/unsupported matrix | Relevant secondary activities have a handling path |
| 4. Substance assessment | Which substances and rule families need assessment? | Substance rules, aggregation boundaries, dependencies | Threshold and reportable-quantity logic are distinct; exclusions are justified |
| 5. Methods and evidence | Which methods fit, and what facts do they need? | Method specifications and evidence request templates | Inputs, units, factors, assumptions, and gap handling are explicit |
| 6. Client and JADA workflow | How do nonexperts supply facts and experts resolve uncertainty? | Conditional questions, review tasks, draft package | A client can answer or ask for help without guessing technical classifications |
| 7. End-to-end validation | Does the whole model reproduce acceptable facility outcomes? | Worked cases, discrepancies, architecture decisions | JADA resolves differences and approves the acceptance criteria |

Start with one representative facility and then a difficult case with missing evidence or secondary activities. One successful welding calculation does not validate the facility workflow. Screen all rule families for relevance, even if a later decision excludes them.

At the end of each run, save the exact coverage, unresolved interpretations, decisions made, and next task. A summary is not a validated rule. Use statuses: unread, inspected, extracted, modeled, needs interpretation, practitioner-reviewed, tested.

## Proposed architecture to test against those cases

Start with a modular application. Separate services are a later operational choice, not a prerequisite for extensibility.

| Boundary | Owns | Key safeguard |
|---|---|---|
| Facility/year case | Facility identity, boundaries, annual activities, progress | Industry label cannot determine completeness |
| Evidence and facts | Original records, extracted values, units, date coverage, corrections | Each accepted fact points back to its evidence |
| Regulatory rules | Versioned applicability and substance decisions | Every rule has reporting years, authority, exceptions, and review status |
| Activity methods | Method selection, required facts, formulas, factors | Deterministic calculations with explicit method applicability |
| Facility aggregation | Contributions by substance and reporting category | Prevent omissions and double counting; preserve source contributions |
| Guided workflow | Client questions and JADA tasks | Unknown is distinct from zero or not applicable |
| Review and package | Findings, approvals, output mapping, frozen versions | Changed evidence invalidates affected results and approvals |

An industry configuration should select likely activities, terminology, and initial questions. Reusable activity modules then handle welding, coating, fuel use, and other supported processes. Adding another industry should reuse the facility, evidence, review, and package foundations while introducing only the rules and methods it needs.

Keep regulatory applicability separate from method selection. Missing data must not make a requirement disappear. Keep source measurements, derived values, and manually accepted estimates distinct.

AI can propose document classifications, extract candidate values, and explain requests. Accepted rules and calculations should run reproducibly. AI suggestions must retain their source and review status; they must not silently become approved regulatory decisions.

## A rule record we can actually review

Each modeled decision needs:

- Stable ID, title, reporting years, authoritative source and exact locator.
- Interpretation and its approval status, separately from the source text.
- Required facts, units, time period, and accepted evidence.
- Conditions, exceptions, dependencies, outputs, and aggregation boundary.
- Calculation and factor versions where relevant.
- What happens when information is unknown, contradictory, or unavailable.
- Plain-language client request and the corresponding JADA task.
- Normal, boundary, exception, and missing-data examples with expected outcomes.

Do not populate an executable rule from a chapter summary. Resolve ambiguous interpretations with JADA and, where needed, official clarification.

## Example client experience to prototype

1. Ask: “What work did you do at this location during the year?” Offer recognizable examples and an option to describe other work.
2. For welding: ask for process or equipment details, rod/wire product identification, and annual usage records. Let clients send labels or records when they do not know the terminology.
3. Explain each follow-up: “We need the product composition to identify which substances to assess.” A purchase record may need inventory adjustments before it can represent annual use.
4. For missing data: show the specific gap, why it matters, and an action such as providing another record or asking JADA to help select a justified method.
5. For measurements: distinguish providing an existing test report from commissioning a new test. JADA resolves the need for new measurements using the applicable requirements and circumstances.
6. Show clients understandable progress while JADA sees technical decisions and unresolved issues.

This is a workflow example, not a finalized questionnaire or universal evidence checklist.

## What makes a package ready for JADA's filing process?

Proposed acceptance criteria to validate with JADA:

- The facility boundary and reporting year are confirmed.
- Relevant activities and substance families are assessed or have a justified exclusion.
- Required calculations, including manual contributions, have traceable inputs and methods.
- Units, annual coverage, aggregation, and potential duplicate contributions are checked.
- Required output fields are mapped to the filing process.
- Blocking gaps and interpretations are resolved; required reviews are recorded.
- The reviewed package is frozen with its rule, factor, evidence, and calculation versions.

Draft packages can exist before these conditions are met. Distinguish draft, ready for review, approved for filing, and filed. Record filing confirmation separately; package generation is not submission. Confirm who provides the regulatory certification and what authority JADA has to file.

The 2025–2027 Notice, Schedule 4 sections 5–7, addresses certification, separate facility reports, and retention of supporting information for three years from the submission deadline. Proposed design consequence: retain the filed package and its supporting calculation/evidence history, and record the authorized certifier separately from an internal reviewer. Confirm the applicable year's requirements before finalizing retention policy.

## Open decisions and next step

1. Pilot reporting year: **2026 — confirmed**; source and amendment verification remains to be completed.
2. One representative welding-client case and a JADA practitioner to validate it.
3. Which secondary activities need automatic calculations in year one, and which can use reviewed manual work.
4. Exact package format and required filing fields.
5. Who resolves interpretations, approves evidence, and signs off on the report.

No new directory is necessary to begin. Put official sources in [guidelines/official](../guidelines/official/), with source/year metadata recorded separately. Keep private client examples in [clients](../clients/README.md), outside tracked planning documents. Internal instructions belong separately from official authority. Preserve supplied filenames.

Next bounded task: build the source and coverage register, then model facility applicability for the selected year. In parallel with that discovery, choose the representative case. Defer a rewrite until the cases establish the module boundaries and acceptance criteria.

## This run's verification

- Repository destination check passed with `python3 scripts/bootstrap.py --check`; backend and frontend were reported clean and left unchanged.
- PDF inspection scope is recorded above; no claim of full extraction or validation.
- Official general and welding guidance checked online on 2026-11-03.
- Only planning documentation changed. Application build and tests were not run because application code was not changed.
