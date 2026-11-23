# Sources, guideline coverage and unresolved decisions

Checked: 2026-11-04. This register distinguishes source evidence from proposed software design. Links and sections identify what to inspect when implementing a rule; they are not a claim that every cited source has been converted into validated code.

## Authority and editions

The 2026 pilot uses the 2025–2027 NPRI Notice and applicable amendments. Guidance explains the Notice; sector calculators supply methods within their stated scope. EPA, UK and occupational sources below help discover processes and engineering considerations. Their legal exemptions, limits and obligations are not Canadian NPRI rules.

The official [Gazette notices index](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/legal-requirements-gazette-notices.html) lists the March 8, 2025 notice for 2025–2027. No separately listed applicable amendment was found in the index and targeted searches in this run. This is not proof of an exhaustive amendment audit. Recheck the index and Gazette before freezing rule data and before filing; record retrieval date and source digest.

## Source register

### S01

[Canada Gazette Notice for 2025, 2026 and 2027](https://gazette.gc.ca/rp-pr/p1/2025/2025-03-08/html/sup1-eng.html). Controlling starting source. Schedule 1: substances/qualifiers; Schedule 2: definitions; Schedule 3: applicability and thresholds; Schedule 4: outputs and methods. Use current identity/qualifiers, not historical sector examples.

Implementation locators: Schedule 3 sections 1–5 (general), 6–7 (Part 1), 8–9 (Part 2), 10 (Part 3), 11–14 (Part 4), 15–17 (Part 5); Schedule 4 sections 20–25 for air/stack fields. Check the opening provisions for prior-reporter notifications and retention. Internal JADA review and authorized certification are distinct.

### S02

[Guide for reporting to the NPRI 2025–2027](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/reporting-guide.html). General interpretive source. Sections 3.4–3.6 cover facilities, exclusions and estimation; 4 covers report information; 5–9 substance families; glossary and appendices define categories and examples. Source conflicts below must be resolved with the Notice prevailing.

### S03

[Supplied 2025–2027 substance workbook](<../../guidelines/official/substance-lists/2025-2027 NPRI Substance List_Liste des substances INRP 2025-2027 (10-04-2026) (1).xlsx>). Read-only inspection found `Notes` (42×4) and `2025-2027` (494×20). English A:J and French K:T are independently ordered; do not join by row position. Fields include NPRI identifiers, groups, textual thresholds, reporting units and substance flags. Part 1C is present. Reconcile rows and notes to S01 before import.

SHA256: `3f59b956b92c0040b86ce579cd8268acec345042ac290ff3b9f8eb97126e2dd8`. Metadata modified 2026-06-04; the filename date is ambiguous. Neither metadata nor filename proves amendment completeness. Official list entry point: [NPRI substance list](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/substances-list.html).

### S04

[ECCC arc welding, cutting and spraying guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/arc-welding-cutting-spraying-calculator.html). Page dated 2023-03-01. Inspect process categories, threshold notes, “Other” methods, active cutting hours, chromium handling and footnotes. The current link does not make every embedded classification a 2026 rule. Keep use of the guide for method discovery separate from current substance-rule adoption.

### S05

[Official linked welding/cutting/spraying calculator](https://www.canada.ca/content/dam/eccc/documents/xlsx/inrp-npri/2023/Electric%20Arc%20Welding%2C%20Cutting%20and%20Spraying%20Calculator_2022_10_26.xlsx). Read-only inspection, not recalculation or numerical validation. Useful cell locators:

- `Input Arc Welding Information!A4:C7`: process/electrode and alternative-method routing.
- `Input Arc Welding Information!A10:E86`: classifications and usage.
- `Input Arc Welding (Method 2)!A6:L106`: composition-based inputs.
- `Input Cutting Information!A5:K16`: cutting input basis and unsupported cold-cutting note.
- `Input Spraying Information !A5:K13`: feedstock inputs.
- `Part 4 Releases!C10:H12`, `L10:Q12`, `U10:Z12`: factor units; welding/spraying mass basis versus cutting time basis.
- `Part 1 Releases!AA17` and `AE19` versus `Part 4 Releases!V10`: spray metal factors can use constituent mass while particulate factors use feedstock mass; preserve that distinction when applying composition.
- `Part 4 Releases!Y12:Y17`: method-specific spray particulate/metal relationship.
- `Instructions!A58:A64`: particulate and control assumptions.
- `Parts 2 - 3 Releases!B7`, `Part 5 Releases !B5`: unavailable information, not proof of absence.
- `Changelog!A1:B14`: historical references.

The workbook is a method reference and benchmark candidate. Its old thresholds and incomplete output families must not determine facility completeness.

### S06

[EPA AP-42 section 12.19, electric arc welding](https://www.epa.gov/sites/default/files/2020-11/documents/c12s19.pdf). Engineering context for process-specific factors and controls; section 12.19.2.2 distinguishes fume capture from collection. Reconcile factor editions, units and covered electrode classes with S05; do not infer a universal factor for all joining processes.

### S07

[ECCC abrasive blasting guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/fugitive-dust-emissions-abrasive-blasting.html). Supports blasting as a distinct source. Default air factors are uncontrolled and tied to abrasive activity; TPM factors vary with wind conditions. Media and abraded surfaces can introduce metals. This does not supply a complete waste or wet/enclosed/recycled-media model. Read its linked AP-42 13.2.6 and calculator before implementing a subtype.

### S08

[EPA surface-coating emissions estimation material](https://nepis.epa.gov/Exe/ZyPURL.cgi?Dockey=P101GJ20.txt), chapter 7. Engineering starting point for coating, added solvent and other ingredients. Use to develop and validate a bounded coating method; Canadian substance definitions, applicability and output categories remain separate.

### S09

[ECCC solvent degreasing sector](https://www.canada.ca/en/environment-climate-change/services/management-toxic-substances/sources/solvent-degreasing-sector.html). Supports discovering degreasing across manufacturing/repair activities. It is not the NPRI threshold specification. Combine method selection with S02 and actual equipment/product/waste evidence.

### S10

[CCOHS heat treating](https://www.ccohs.ca/oshanswers/safety_haz/metalworking/heat_treating.html). Process discovery: heating/cooling, quench media and related cleaning. Occupational guidance is not an environmental emission factor or NPRI exemption.

### S11

[UK government hot-dip galvanizing process guidance](https://www.gov.uk/government/publications/hot-dip-galvanizing-processes-process-guidance-note-202). Specialist process/engineering reference. Use for discovery and method investigation only; do not import UK permit limits into NPRI.

### S12

[ECCC boilers and heaters calculator guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/tools-calculating-emissions/boiler-heaters-emissions-calculator.html). Describes oil-fired equipment and factor dependencies including sulfur/heating value. It is not a general natural-gas or engine calculator. Resolve the displayed unit-conversion concern below before porting equations.

### S13

[EPA AP-42 external combustion chapter](https://www.epa.gov/air-emissions-factors-and-quantification/ap-42-fifth-edition-volume-i-chapter-1-external-0) and [stationary internal combustion chapter](https://www.epa.gov/air-emissions-factors-and-quantification/ap-42-fifth-edition-volume-i-chapter-3-stationary-0). Method-source catalogue, not fully extracted factor tables. The index lists natural-gas section 1.4 corrected October 2026, LPG section 1.5 updated May 2025, and separate engine sections. Select and archive the applicable section/edition deliberately; do not assume a historic NPRI spreadsheet has the newest factors or that a newer edition is automatically applicable to every case.

### S14

[ECCC unpaved road dust guide](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/sector-specific-tools-calculate-emissions/road-dust-unpaved-surfaces-guide.html). Separate applicability and segment calculations. Relevant inputs include vehicle travel, road conditions, vehicle weight, weather and suppression. Road-dust eligibility is not itself proof that a facility-wide particulate threshold is met. It is not a stockpile-dust or vehicle-exhaust method.

### S15

[ECCC storage-tank guidance publication](https://publications.gc.ca/site/eng/9.929296/publication.html?wbdisable=true). Catalogue and scope reviewed; full tiered method not extracted. A method-selection follow-up is required for actual tank contents, configuration and losses. Do not assume an oil/gas flashing-product method suits every workshop container.

### S16

[EPA metal finishing overview](https://www.epa.gov/eg/metal-finishing-effluent-guidelines). Supports identifying plating, anodizing, conversion coating, etching and related wastewater operations. Useful for specialist discovery; US discharge rules do not govern the NPRI calculation. Provides context for investigating certain surface-treatment additives.

### S17

[EPA metal finishing development document](https://nepis.epa.gov/Exe/ZyPURL.cgi?Dockey=40000SGR.TXT), Table 3-1, and [fabricated metal products stormwater fact sheet](https://nepis.epa.gov/Exe/ZyPURL.cgi?Dockey=P1007BXU.TXT). Historical process-discovery references broaden the catalogue to forming, machining, specialty treatment, assembly and water pathways. They are not evidence that any specific client operates those processes and not a current NPRI ruleset.

### S18

[ECCC PFAS reporting guidance](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/pfas.html). Part 1C starts with the 2025 reporting year; relevant products and firefighting foams need screening. Missing SDS disclosure is not a reliable universal absence test. Use current listed identities and product/supplier evidence, then apply the specific thresholds and qualifiers; do not assume every fluorinated product is a listed PFAS.

### S19

[EPA metal fabrication and finishing source categories](https://www.epa.gov/stationary-sources-air-pollution/metal-fabrication-and-finishing-source-categories-national) and its [process fact sheet](https://www.epa.gov/sites/production/files/2016-01/documents/9metal_fab_fs.pdf). Supports the common fabrication cluster: welding, blasting, machining, grinding/polishing and coating. Used for taxonomy, not Canadian legal applicability or numerical limits.

### S20

[EPA capture-systems explanation](https://www.epa.gov/air-emissions-monitoring-knowledge-base/monitoring-control-technique-capture-systems). Capture describes the fraction routed to a control device. Design inference: retain capture, removal, bypass and discharge route separately; a filter's rated removal efficiency alone does not substantiate whole-source emission reduction. Do not import a US enclosure presumption without verifying the applicable method and evidence.

### S21

[UK HSE metalworking-fluid guidance](https://www.hse.gov.uk/coshh/essentials/direct-advice/metalworking-fluids.htm). Supports distinguishing wet machining, mist and sump work in discovery. Occupational exposure/control advice does not establish environmental emissions or an NPRI factor.

### S22

[EPA miscellaneous metal and plastic parts coating CTG, 2008](https://nepis.epa.gov/Exe/ZyPURL.cgi?Dockey=P1001JAL.TXT), sections IV.A–B, especially the powder-coating discussion on printed page 13. Engineering context for coating/cleaning and powder application/curing. Powder formulation and recovery matter; a blanket zero-emission branch is not supported. Method applicability, factor values and Canadian definitions require separate validation. The EPA text edition was verified after the older PDF endpoint returned HTTP 403.

### S23

[ECCC legal notices index](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/legal-requirements-gazette-notices.html) and [deadlines/changes](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/deadlines-changes.html). Version-monitoring starting points. Check again at rule release and filing rather than treating this research date as permanent.

### S24

[Supplied historical PDF, workspace copy](<../../guidelines/official/NPRI Guide (1).pdf>). The attached Downloads file `En81-1-2022-eng.pdf` and this file are byte-identical: SHA256 `68b0b91d390823c014e8166621630af4226fdf3631a26f0d882071d994cf0ba9`. Both are the 2022–2024 guide, 155 PDF pages. This corrects the earlier workspace note that its original location had not been verified.

Used for structure, historical examples and the distinction between assessment, methods and outputs. Relevant map: sections 3–4, 5–9, glossary, Appendix B examples, C conversions, D stacks and E VOC group details. The PDF text was extracted locally; contents and selected complete pages were inspected in this conversation, not every rule independently validated. Current requirements were checked using S01/S02 and the other sources above.

### S25

[Supplied internal VOC note](<../../guidelines/internal/Steps to Report VOCs for NPRI (2).docx>). Read and visually inspected. Authorship/authority remain unverified. It describes use × VOC content and an evaporation adjustment, but does not substantiate a universal evaporation fraction or complete applicability/destination treatment. Keep as an internal example to improve, not executable authority. Its malformed repeated formula text should not be ingested as a formula specification.

## Guideline coverage map

This maps the full rule-family structure into the roadmap. It does not omit a chapter because “welding probably does not use it.” Detailed code coverage remains a future cycle output.

| Guideline area | Required product behavior | Proposed handling |
|---|---|---|
| Reporting year, deadlines, changes | Select applicable source version and annual filing workflow | Always; C00/C12 |
| Facility/employee/activity definitions | Resolve boundary and applicable paths from facts | Always; C01/C03 |
| Exemptions/exclusions | Record scope-specific decisions, not deleted evidence | C03; uncertain/special cases manual |
| Estimation and reasonable information access | Choose justified method; use relevant required measurements; track gaps | Every active method; C03 onward |
| Facility/contact/prevention/comment information | Collect and map required output fields | C01/C12 |
| Part 1A/1B | Material/substance/group assessment plus outputs; specific qualifiers | C03, extend tested coverage by pilot materials |
| Part 1C | Current PFAS candidate screening and applicable decisions | Screen from C00/C01; manual assessment until supported |
| Part 2 | Relevant PAH paths; do not assume welding calculator covers them | Candidate/activity screen; manual when relevant |
| Part 3 | Specified-activity screen; ordinary welding not automatically a trigger | P26 and specialist review; no general beta engine required |
| Part 4 | Applicable air-contaminant paths and source aggregation | Welding/blasting/combustion and other methods; C03/C11 |
| Part 5 | Individual VOC/group assessment separate from total VOC | C07/C11; no universal total-VOC prerequisite |
| Definitions and chemical qualifiers | Typed identities, units, group and output semantics | Shared data/rule layer |
| Example calculations | Independent benchmarks with scope checked | Per-method cycle; not substitute for governing rule |
| Conversion factors | Explicit source/target units and basis | Shared unit validation; C02 onward |
| Individual stacks | Basic outlet discovery plus conditional detailed assessment | Manual initially; C11 with source conflicts resolved |
| VOC and other substance lists/appendices | Identity/group membership and year-specific parameters | C00/C03; preserve non-CAS IDs |
| Certification, retention, prior-report notifications | Separate review, certification, filing and retained snapshot | C12/C13 |

For Part 3 screening, check S01 Schedule 3 section 10 rather than presenting every welding customer with a chemical questionnaire. Specialist positives can include qualifying incineration, smelting, secondary-metal production or steelmaking furnace operations. Other enumerated sectors need a follow-up if the site's business description indicates mixed operations. A copper workpiece or chlorinated cleaner alone does not establish the specified industrial activity.

## Issues to resolve before implementation

| ID | Evidence/problem | Implementation response | Cycle |
|---|---|---|---|
| I01 | Historical PDF and welding calculator contain older reporting text | Separate regulatory rules from calculator methods; reconcile each adopted rule to 2026 | C00 |
| I02 | S04 background calls cobalt a Part 1A example; S03 and S01 place it in Part 1B | Use current authority and identity record; add regression case for stale sector classifications | C00/C03 |
| I03 | S02 Appendix D Table 18 gives a different NOx stack threshold than S01 Schedule 4 Table 4 | Record discrepancy; use controlling Notice; obtain interpretation/clarification where needed before automatic stack assessment | C00/C11 |
| I04 | S02 D.1 temperature wording differs from S01 Schedule 4 sections 20/23, especially unmeasured/equality cases | No guessed reconciliation; manual branch with exact citations until approved implementation | C00/C11 |
| I05 | S12 displayed conversion uses a factor expressed per thousand US gallons; scale must be checked dimensionally | Inspect actual calculator and source table; benchmark conversions before adoption | C08 |
| I06 | S05 has unavailable information for some substance parts | Missing method coverage is not zero or inapplicability; activate independent screening/manual work | C03/C11 |
| I07 | S25 suggests an evaporation adjustment without a complete method | Develop a bounded balance with residual/recovered/waste quantities and accepted assumptions | C07 |
| I08 | S03 languages are independently ordered and identifiers include substance groups | Import by stable identity and language; parse notes/qualifiers; do not rely only on CAS or row order | C00/C02 |
| I09 | SDS can give ranges or omit non-disclosed ingredients; process-generated species may not be listed | Preserve ranges/unknowns; supplement with supplier/process evidence; record threshold uncertainty | C02/C03 |
| I10 | Control specification can describe filter efficiency rather than full-source performance | Separate capture/removal/operating coverage; no unsupported reduction credit | C03 onward |
| I11 | Generic dry-blast factors may not represent closed/recycled/wet equipment | Approve configuration-specific scope; manual method where unsupported | C06 |
| I12 | Existing backend has shared threshold constants and CAS-oriented matching | Replace incrementally with tested year/identity/rule-specific decisions; retain unresolved coverage | C00/C03 |

These are bounded research/implementation tasks, not reasons to delay unrelated discovery or supported calculations. They do block claims that the affected branch is automatically correct.

## Verification performed and limits

- Read workspace instructions and planning context; `python3 scripts/bootstrap.py --check` passed and reported existing clean backend/frontend checkouts.
- Used three research subagents for current authority, welding methods/calculator, and ancillary shop processes. Their findings were integrated with direct source inspection.
- Compared the two supplied PDF files by SHA256; extracted historical PDF text and reviewed its structure/relevant selected sections. Existing extracts remain search aids, not independent authority.
- Read and rendered the internal VOC note. Inspected the supplied substance workbook and official linked welding calculator read-only; did not recalculate either workbook or validate every factor/row.
- Reviewed current web sources and specific rule/method locations. Storage-tank and AP-42 chapter indexes identify further method work; they are not claimed as fully modeled.
- Inspected the current threshold model/calculator to anchor the implementation sequence. No database contents, private client records or application behavior were tested.
- Deliverables are planning Markdown. No application code, database, deployment, email or filing changes were made.
- Full row-by-row 2026 legal reconciliation, validated process coefficients, real-client pilot calibration and approved report-field mapping are future implementation gates. They are explicitly outside the claim that this roadmap is complete as a planning deliverable.

## Planning deliverable audit

| Requested outcome | Evidence in this set |
|---|---|
| Review supplied documents and online guidance | S01–S25; PDF identity check; workbook inspection; internal note review; exact source limitations recorded |
| Broad map of possible welding-shop activities | 28 catalogue cards and variants, including blasting and specialist/other work; no claim every shop uses them |
| Factors, methods and decisions | Method/factor input matrix; per-card method gates; factor record contract and selection outcomes; issue register |
| What to ask clients and what evidence to collect | 17 common questions, shared material/outlet questions and 28 conditional process branches; JADA-only decisions separated |
| Detailed cycles for each process | C00–C13 dependencies/exit gates; each catalogue card has a specific run and failure case; six-run method development pattern |
| Complete annual report workflow | R01–R10, facility reconciliation, metadata, certification/filing and retained revisions |
| Year-one/beta exclusions and deferrals | Explicit automated/manual/absent/pending states; specialist automation deferral; outlet screening retained |

Three subagent reviews checked regulatory coverage, core methods and ancillary processes. Corrections incorporated include sequential material flow versus consumable splitting, workpiece/flux/gas evidence, mandatory internal exceptional-activity reconciliation, and zero-output versus no-report distinctions. Structural verification confirmed all 28 catalogue cards have questionnaire branches, cycle references, inputs, source links and failure tests. Local Markdown links/anchors and `git diff --check` passed. These checks verify the roadmap's structure and scope, not an implemented calculation engine.
