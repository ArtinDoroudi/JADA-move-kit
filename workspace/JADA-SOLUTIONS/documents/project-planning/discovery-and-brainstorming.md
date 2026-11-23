# NPRI automation — discovery and brainstorming

Updated: 2026-11-03
Status: Working discovery document. Facility-level scope and JADA filing handoff are confirmed; detailed coverage, package format, and architecture remain open.

## Reset and purpose

We are stepping back to understand the reporting problem before committing to implementation. Earlier planning documents and prototypes are reference material, not approved requirements or architectural constraints. Existing software may be reused, rewritten, or replaced after discovery.

This document gathers confirmed direction, research, open questions, and design hypotheses. It will eventually support a clear product vision and an implementable first-year scope.

## Confirmed direction from Artin

- Automate NPRI reporting for JADA's clients, with reports intended to satisfy applicable requirements.
- Focus ONLY on the welding industry during the first year.
- First pilot reporting year: **2026**, confirmed on 2026-11-03.
- Design for later expansion to other industries and reporting processes.
- Clients may not understand HSE terminology. Ask understandable questions and guide them to the evidence needed.
- The system should identify missing information and explain the next action, including obtaining supporting documents or measurements when appropriate.
- Produce complete facility report packages for welding clients, including other relevant facility activities.
- JADA reviews the package and performs the final filing. Automated government submission is outside the agreed workflow.
- Package contents, format, and detailed workflow are still undecided.
- Existing code and documents can be rewritten. Clean architecture takes priority over preserving the prototype.

## Working product hypothesis — proposed

A guided reporting service that establishes what happens at a facility, determines the applicable reporting and calculation paths, collects sufficient evidence, calculates traceable results, and supports review and preparation of the agreed submission output.

The client experience should make the next useful action clear. Technical complexity lives in the rules, evidence requirements, and practitioner workspace. A completed questionnaire alone does not establish reporting completeness.

## Confirmed reporting boundary

“Welding industry” identifies the initial client group. The intended output covers the complete facility, not only its welding calculations.

Relevant additional activities must be discovered and addressed. Which activities can be calculated automatically in year one, and which require practitioner work, remains to be decided.

The system prepares a report package; JADA reviews and files it. This is the agreed product boundary, not a researched claim that submission automation is technically impossible.

Other activities must be detected even when their calculations are outside the automated scope. Unsupported activity must remain visible as an unresolved item or an assigned manual task.

## Initial official-source findings

Checked 2026-11-02. These are discovery findings, not a complete regulatory specification.

- ECCC's reporting guide states that the applicable Canada Gazette Notice prevails if the guide conflicts with it. Store the reporting year and authoritative source with each implemented rule. [Reporting guide](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/reporting-guide.html)
- Welding guidance distinguishes threshold assessment from subsequent release, recycling, and disposal calculations. It also requires consideration of relevant substances from other facility processes. A welding-only calculation cannot automatically establish facility completeness. [Welding guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/arc-welding-cutting-spraying-calculator.html)
- The current welding guidance covers arc welding, cutting, and spraying, with process-specific inputs and calculation options. Do not assume every client uses the same method or needs the same records. [Welding guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/arc-welding-cutting-spraying-calculator.html)

## Candidate reporting journey

Additional research findings:

- Stack testing is not a universal NPRI prerequisite. The reporting guide describes several estimation approaches and addresses use of measurements required under other applicable rules. Evidence requests must follow the relevant circumstances and method. [Reporting guide, sections 3.6.1–3.6.2](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/reporting-guide.html)
- Oil/gas and wastewater guidance illustrate different applicability and estimation paths. Architectural inference: share evidence and reporting infrastructure while keeping process-specific rules and methods independently versioned. These industries are research references, not first-year scope. [Oil/gas guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/sector-specific-tools-calculate-emissions/oil-gas-guide.html), [Wastewater guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/sector-specific-tools-calculate-emissions/reporting-guidance-wastewater-sector.html)

1. Establish the facility and reporting year.
2. Identify actual activities using plain-language questions, examples, and available records.
3. Determine applicable reporting checks and candidate estimation methods.
4. Generate an evidence checklist for those methods.
5. Collect records, extract information, and resolve gaps or ambiguity.
6. Complete applicability and threshold decisions using sufficient evidence.
7. Calculate required releases, disposals, and transfers using supported methods.
8. Review results, sources, assumptions, exclusions, and unresolved items.
9. Generate the agreed deliverable and complete the agreed filing workflow.

Confirmed handoff: JADA reviews the generated package, resolves outstanding issues, and files the report through its reporting process.

Proposed package contents: facility/year summary, activity coverage checklist, applicability decisions, reportable quantities, calculation details and methods, source references, and a review/exception record. These contents require validation against JADA's actual filing workflow. An incomplete package may be available for review but must not be represented as ready to file.

This is iterative: new evidence can change the activity classification or estimation method and require additional questions or recalculation.

## Client guidance principles — proposed

- Ask about recognizable work: equipment used, materials bought or consumed, work performed, waste collected, and available records.
- Offer “I don't know” and “I need help” without turning them into zero values or assumed answers.
- Explain why each requested document matters and show an example of acceptable evidence.
- Use conditional questions so clients see only relevant follow-ups.
- Permit a client to supply a label, document, or equipment detail for JADA to interpret.
- Distinguish missing evidence, uncertain interpretation, unsupported methods, and processing failures.
- Explain whether an unresolved item blocks calculation, review, or filing.
- Request a stack-test report or new measurement only when justified by the selected method and applicable requirements. The user's chimney-sample example is an illustration, not an established requirement.

Illustrative prompt: “What type of welding do you do? If you are unsure, provide the machine details or wire/rod packaging and ask JADA for help.” Exact prompts will be designed with real client examples.

## Architecture hypothesis — to test through discovery

Begin with clear module boundaries; separate services are not assumed necessary.

| Module | Responsibility |
|---|---|
| Facility and annual reporting record | Facility context, activities, reporting year, and reporting state |
| Guided questions | Plain-language prompts and conditional follow-ups |
| Evidence records | Original files, extracted facts, units, dates, provenance, and corrections |
| Applicability rules | Determine which requirements apply, with explanations and year-specific versions |
| Method selection and requirements | Identify supported estimation methods and their required evidence |
| Calculation modules | Deterministic, testable calculations for supported activities |
| Facility aggregation | Combine contributions without omissions or double counting |
| Expert review | Resolve uncertainty, record decisions, and manage unsupported cases |
| Report preparation | Assemble the agreed output and its supporting calculation/evidence record |

Keep industry-specific questions, methods, factors, and validation cases separate from shared facility, evidence, review, and reporting functions. Industry selection should help discover activities; it must not silently substitute for activity assessment.

AI may assist with extraction, document classification, and explanations. AI-generated facts require validation appropriate to their use. Regulatory rules and accepted calculations need explicit sources, versions, and reproducible execution. Final acceptance criteria and review boundaries remain open.

## Evidence and validation work needed

- Walk through at least one representative completed welding-client report with its source documents.
- Include a difficult case with missing information, an unusual process, or additional facility activities.
- Record how JADA currently decides which method and evidence are sufficient.
- Compare candidate calculations with the applicable official tools and practitioner-validated results.
- Define what an acceptable report means: covered activities, supported methods, traceable inputs, resolved exceptions, required review, and final output.
- Verify that real clients understand the questions before implementing a large questionnaire.

## Questions to answer together

1. Which additional facility activities must be automated in year one, and which can use a documented JADA manual workflow?
2. What package contents and format does JADA need to review and file efficiently?
3. Resolved on 2026-11-03: the first pilot covers reporting year **2026**.
4. Which welding processes and other activities appear in the initial clients?
5. What can clients reliably answer, and what documents do they usually have?
6. Which decisions must a JADA practitioner make or review?
7. What should happen when evidence is unavailable or a method is unsupported?
8. What single real case should we use to work through the entire proposed experience?

## Source collection

Place supplied material in `documents/guidelines/`. Useful material includes official notices and guides, calculators, JADA working instructions, completed reports, supporting records, and examples of difficult cases. Keep official requirements distinguishable from internal interpretations and examples. Record publication/reporting years; older documents may still help explain historical work.

## Decision log

| Date | Decision | Status |
|---|---|---|
| 2026-11-02 | First-year industry focus is welding | Confirmed by Artin |
| 2026-11-02 | Architecture should allow later expansion | Confirmed by Artin |
| 2026-11-02 | Existing code and documents may be replaced | Confirmed by Artin |
| 2026-11-02 | Complete facility report packages for welding clients | Confirmed by Artin |
| 2026-11-02 | JADA reviews packages and performs final filing | Confirmed by Artin |
| 2026-11-02 | Detailed activity coverage, package format, and implementation architecture | Open |
| 2026-11-03 | Pilot reporting year is 2026 | Confirmed by Artin |

## Next discovery step

Use the confirmed 2026 reporting year and select one real welding-client case. Trace all relevant facility activities from initial questions through evidence, method selection, calculations, JADA review, and package handoff. Use that case to test the architecture before turning this document into formal specifications.

## Guide review and modeling plan

Source supplied by Artin: `/Users/artindoroudi/Downloads/En81-1-2022-eng.pdf` — Guide for Reporting to the NPRI, 2022–2024, 155 PDF pages. Initial review covered the contents and selected detailed sections; this is not a complete rule extraction. Printed page numbers differ from PDF page positions.

Use this edition to understand structure and historical examples. Before implementing rules, reconcile each relevant rule with the Notice, amendments, guidance, and sector tools applicable to the confirmed 2026 pilot year.

Work in bounded passes with saved outputs:

| Pass | Focus | Durable output |
|---|---|---|
| 1 | Guide structure, source editions, definitions, and dependencies | Source register and coverage map |
| 2 | Facility boundary, employee/activity criteria, exemptions and exclusions | Applicability decision tables |
| 3 | Actual activities at representative welding clients | Activity inventory and supported/manual handling matrix |
| 4 | Relevant substance rules, including relationships between Parts 1–5 | Rule catalogue and dependency map |
| 5 | Estimation methods, required evidence, aggregation, and missing data | Calculation specifications and evidence requirements |
| 6 | Translate required facts into client questions and JADA tasks | Conditional intake and review workflows |
| 7 | Run complete historical cases through the proposed model | Validated examples, gaps, and architecture decisions |

Do not divide the document into arbitrary page chunks and treat each as independent. Definitions, exceptions, appendices, and cross-part dependencies must travel with each rule. Screen every rule family for relevance; record why a branch is excluded instead of assuming it cannot apply to welding clients.

For each modeled rule, capture: stable ID, source/version and exact section/page, applicability, required facts and units, conditions and exceptions, calculation or decision, output, dependencies, client evidence request, unknown-data behavior, worked examples, and practitioner review status.

Maintain a coverage register with statuses: unread, extracted, modeled, needs interpretation, practitioner-reviewed, and validated against cases. At the end of each run, save completed work, unresolved questions, and the next bounded task. A summary of a chapter does not mean its rules have been modeled or validated.

Initial examples of dependencies found in the supplied edition: section 3.4.3 distinguishes employee criteria and activity exceptions; section 3.6 distinguishes evidence availability and estimation approaches; section 5.1 distinguishes quantities used for threshold assessment from quantities reported; section 8 discusses VOC relationships across substance parts and conditional combustion exclusions. These examples demonstrate modeling complexity and must not be adopted as current-year rules without verification.
