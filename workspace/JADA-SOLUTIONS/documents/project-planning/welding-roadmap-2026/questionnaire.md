# Conditional questionnaire for the 2026 welding facility pilot

Prepared: 2026-11-04. Proposed question bank and routing specification. This is not one long form to give every client. Show the common screen first, then only relevant branches and method-specific follow-ups. Exact statutory fields and final UI wording remain subject to implementation review.

## Answer and routing rules

For every activity screen, offer **Yes / No / Not sure / Done by someone else**. “Done by someone else” opens location/contractor questions; it does not automatically mean outside the facility. “Not sure” opens an identification task and allows equipment labels, photos or a description. Confirm an absent activity for this facility and reporting year, not for the company forever.

For quantities, store value, unit, period, basis (used/purchased/estimated), source and reviewer status. Permit “records unavailable” and a request for JADA help. Never default missing quantities to zero. Allow product evidence once and reuse it across branches; allocate quantities explicitly.

Each question below has a stable ID. Repeating equipment/material/stream groups receive instance IDs in software. Evidence examples are alternatives; clients do not have to provide every listed record if the selected method can be supported another way. A source-test report is an existing-evidence request, not an order to commission a new test.

| Answer/event | Software action | Resolution owner |
|---|---|---|
| Activity present | Create Activity instance; open its branch and shared material/control/destination questions | Client supplies facts; JADA resolves classifications |
| Activity absent | Store annual confirmation; suppress details | Client; reviewer follows up if records contradict it |
| Type unknown | Request description/equipment identification; do not select a default factor | JADA |
| Required fact unavailable | Show why needed and accepted evidence alternatives | Client and JADA |
| Method not implemented | Create ManualWork task, not another client question | JADA/developer |
| Sources conflict | Create Interpretation task with exact references | JADA, with ECCC clarification if needed |
| New material/process appears during review | Reopen relevant discovery and dependent results | System and JADA |

## Common questions for every facility

| ID | Client wording | Answer/evidence | What it controls |
|---|---|---|---|
| G01 | What is the name and address of the location we are reporting for? Include attached buildings and outdoor work/storage areas. | Address, site description/map, existing facility ID | Facility boundary |
| G02 | Is this report for all work at this location during January 1–December 31, 2026? Were there openings, closures or ownership changes? | Dates and explanation | Annual coverage and responsibility |
| G03 | Was an NPRI report filed for this location last year? Are corrections or closure/ownership notifications needed? | Prior report/ID and relevant correspondence | Filing workflow and reconciliation |
| G04 | What does this location make, repair or do? Include occasional work. | Plain-language description and product/service list | Activity discovery; JADA classifies industry |
| G05 | Provide 2026 employee hours worked, including overtime, plus paid vacation and sick-leave hours. Separately identify onsite owner hours not already counted, and contractors' onsite hours related to operations. | Payroll/contractor summaries; identify uncertainty and duplicate categories | Employee-hour calculation; JADA resolves boundaries |
| G06 | Which activities in the screen below happened here, even occasionally? | Yes/No/Not sure/Done by someone else for each family | Opens P01–P28 |
| G07 | Which equipment or activities were added, removed or changed during 2026? | Equipment list and effective dates | Annual operating segments |
| G08 | What materials and chemicals were used here, including supplies bought by contractors or customers? | Product lists, SDS/TDS, labels and supplier records | Complete material inventory |
| G09 | Do purchase quantities represent what was used during 2026? What was left in stock, returned, moved between sites or supplied by others? | Inventory and usage records, units | Purchase-to-use reconciliation |
| G10 | Where do fumes, dust and vapours go? Include roof/sidewall vents, booths, collectors and equipment that returns air indoors. | Simple drawing/photos and equipment descriptions | Source/control/outlet map |
| G11 | What leaves as scrap, dust, filters, spent grit, liquids, sludge or other waste? | Waste/recycling list and collector records | Opens P23; destination inventory |
| G12 | Is water used in any process or exposed to work materials outdoors? Where does it go? | Drain/water-route sketch, bills/records if useful | Opens P24 |
| G13 | Do any permits or other requirements call for measurements? What emission, water, waste or material test reports already exist? | Permits, source tests, lab/monitoring reports with dates | Existing measurement and method selection |
| G14 | Were there spills, leaks, fires, unusual releases, breakdowns or periods when filters/extraction were off? | Incident and maintenance records | P27 and operating/control adjustments |
| G15 | Was a pollution-prevention plan prepared or implemented? Which prevention/operating changes were made, and what explains changes from last year? | Plans, activities and dates, production context | Review explanations and applicable reporting fields |
| G16 | Who can answer operational questions, confirm this information and authorize certification/filing? | Contacts and roles | Client contact, JADA review and certification handoff |
| G17 | Is there any other work, equipment, chemical, waste or emission source we have not asked about? | Free description; Yes/No/Not sure | Mandatory catchall review |

G05 follows the categories in [S01](sources-and-decisions.md#s01), Schedule 2. Do not expand “vacation and sick leave” to every form of paid leave or apply employee leave treatment automatically to contractors. No automatic exemption should be inferred from headcount alone.

## Activity screen

Use ordinary labels first and technical aliases as help text. Do not ask clients whether “Part 1B applies” or whether an item legally qualifies as an “article.”

| Branch | Ask whether they do this |
|---|---|
| P01 | Stick, MIG/flux-core or submerged-arc welding using rods or wire |
| P02 | TIG or plasma welding, including jobs without added filler |
| P03 | Spot/resistance, laser, friction or other joining methods |
| P04 | Gas/flame welding, brazing or soldering |
| P05 | Plasma, laser, flame or air-carbon cutting/gouging |
| P06 | Sawing, shearing, punching, press cutting or waterjet cutting |
| P07 | Grinding, sanding, polishing, tumbling, deburring or peening |
| P08 | Sand/grit/shot/bead or wet blasting |
| P09 | Spraying molten metal or metallic coatings |
| P10 | Turning, milling, drilling, CNC or other machining |
| P11 | Bending, rolling, pressing, stamping or forging |
| P12 | Cleaning/degreasing parts or equipment with solvents or water-based products |
| P13 | Applying liquid paint, primer or protective coatings |
| P14 | Applying and curing powder coatings |
| P15 | Removing old paint, plating or coatings |
| P16 | Pickling, passivating, etching or chemically preparing metal surfaces |
| P17 | Plating, anodizing or electropolishing |
| P18 | Dipping parts in molten zinc, tin or another metal |
| P19 | Heating or heat-treating parts, stress relief or quenching |
| P20 | Burning fuel for heating, ovens, boilers, generators or stationary equipment |
| P21 | Using adhesives, sealants, inspection dyes, anti-spatter or other process chemicals |
| P22 | Bulk liquid storage, tank filling/emptying or gas handling |
| P23 | Producing, collecting, storing or sending away scrap or waste |
| P24 | Producing process water, wastewater or potentially contaminated runoff |
| P25 | Driving on unpaved areas or handling dusty materials outdoors |
| P26 | Melting/casting metal, making powders, recovering chemicals, burning waste or other specialist work |
| P27 | Maintenance chemical use, refrigeration service, firefighting foam or unusual release events |
| P28 | Outsourced, contractor, mobile or customer-site work |

## Shared follow-ups

### Materials and annual quantities

Ask for each relevant product/material, once across the case.

- **M01:** What is the product name, supplier and identifying code? Provide the label and SDS/TDS you have.
- **M02:** How much was used during 2026, in what unit? If only purchases are available, say so and provide starting/ending stock, supplier returns and transfers where known.
- **M03:** Which operations used it? For consumables supplied to different operations, provide the split or identify an unknown balance. For stock passing through successive operations, describe the sequence and identify the same batch rather than splitting it artificially.
- **M04:** Is it a concentrate, mixed product, diluted solution, wire/rod, powder or solid item? What was added or mixed with it?
- **M05:** Did composition, supplier or product formulation change during the year? When?
- **M06:** Were any relevant materials customer-supplied, contractor-supplied, reused or recovered onsite?
- **M07:** Are there supplier statements, material certificates or analyses beyond the SDS? Ask only where the selected decision needs them.
- **M08:** Are any quantities estimates? Describe how they were estimated and the records supporting them.

Internal checks: compatible units, concentration basis, ranges, year coverage, product changes, duplicate lines, allocation totals, group/element mapping and whether use is a defensible estimate. Do not ask the client to choose a convenient midpoint or a universal evaporation rate.

### Controls and air outlets

Ask once per system/outlet, then link the sources using it.

- **O01:** Which machines or work areas connect to this extractor, booth or collector?
- **O02:** Does it discharge outside, return air inside, or do both? Where is each outlet?
- **O03:** What equipment removes dust or vapour? Provide make/model, specifications and any performance reports.
- **O04:** Is every relevant operation captured, or only some stations/jobs? Describe any work outside the hood/booth.
- **O05:** When did the system operate, change, bypass or fail? Were there periods without control?
- **O06:** What happens to captured dust, liquid, filters or recovered product? Link a waste/reuse stream.
- **O07:** If needed for the applicable stack assessment: what are outlet height above ground, orientation, cap, dimensions, location, flow/velocity and temperature? Identify measured versus estimated values.
- **O08:** Are outlets shared between processes? Provide a drawing or let JADA help map them.

O07 is conditional; a client should not have to measure every roof vent merely to start. JADA determines applicable criteria and evidence needs. Unknown temperature or geometry goes to an explicit requirement/interpretation, not a guessed value. Keep capture and removal evidence distinct ([S20](sources-and-decisions.md#s20)).

## Detailed process branches

Each branch below inherits M01–M08 as relevant, O01–O08 where air pathways exist, and P23/P24 for residues. “Technical decision” belongs in JADA's view, not as a client multiple-choice question.

### P01 — Rod and wire arc welding

- **P01-1:** Which welding processes and machines use each rod/wire? If unsure, provide machine settings/nameplate and packaging.
- **P01-2:** What electrode/wire classifications appear on the packaging, and how much of each was used by each process?
- **P01-3:** Was welding performed inside, outside, in booths or robot cells? Which extraction systems served it?
- **P01-4:** What happened to unused stubs, slag, collected fume and scrap?
- **P01-5:** What metals and surface coatings are welded? Are separate fluxes or shielding gases used? Provide product information and available operating records.

Evidence: consumable labels, SDS/TDS, issue/usage records and stock reconciliation. Technical decision: exact factor match versus approved alternative; source basis; contribution treatment. Opens C04 calculation and residue tasks.

### P02 — TIG and plasma welding

- **P02-1:** Which jobs/processes add filler and which do not?
- **P02-2:** For added filler, which products and quantities belong to each process?
- **P02-3:** What metals or coated parts are joined, and what operating records exist for jobs without filler?

Technical decision: method applicability for filler/no-filler cases. If the selected method cannot represent the operation, create a manual method task rather than asking for nonexistent consumable purchases.

### P03 — Other joining

- **P03-1:** Describe the joining equipment and how it works; include spot/seam/resistance, laser, friction or other methods.
- **P03-2:** What materials, coatings, oils, adhesives or consumables are involved?
- **P03-3:** What production/time records or existing test data are available, and where do emissions/residues go?

Technical decision: specialist method and relevant substances; C10 manual until supported.

### P04 — Gas welding, brazing and soldering

- **P04-1:** Which process, filler/solder and flux are used on which materials?
- **P04-2:** How much filler, flux and fuel was used? Is fuel shared with cutting or heating?
- **P04-3:** How are joints cleaned, and what residues or used cleaning materials are collected?

Technical decision: joining method plus separate fuel/cleaning contributions; prevent overlap with P05/P12/P20.

### P05 — Thermal cutting and gouging

- **P05-1:** Which equipment performs flame, plasma, laser or air-carbon cutting/gouging?
- **P05-2:** Which metals, thicknesses and surface coatings were cut? What material certificates or composition records exist?
- **P05-3:** How many hours was each process actively cutting, by material if known? Distinguish actual cutting time from machine-on or shift hours.
- **P05-4:** What material quantities, fuel/electrode use, dross and dust records are available?

Technical decision: separate threshold material quantities from release method inputs; resolve time/composition basis. Evidence can include machine logs, job records and a documented estimate.

### P06 — Saws, shears and waterjet

- **P06-1:** What exact machine/cutting method is used? Is it dry, lubricated or water-based?
- **P06-2:** Which materials/coatings, abrasives or cutting fluids are involved?
- **P06-3:** What operation records exist, and what happens to chips, offcuts, water and sludge?

Technical decision: supported subtype, article/release treatment and method. Route waterjet to P24 and abrasive residues to P23; do not impose the arc-cutting calculator on every machine.

### P07 — Grinding and finishing

- **P07-1:** Is the tool cutting, removing a coating, or finishing the surface? Which machines do each?
- **P07-2:** Is the operation wet or dry, and what metals/coatings/abrasives/compounds are involved?
- **P07-3:** What quantities or operating records exist, and how are dust and residues collected?

Technical decision: role-specific method; exclude duplicate allocations across cutting, grinding and stripping.

### P08 — Sandblasting and other abrasive blasting

- **P08-1:** What media is used, and is blasting dry, wet or vapour-assisted?
- **P08-2:** Is it done in a cabinet/room or outdoors? What type of blasting equipment is used?
- **P08-3:** How much media was used? Is that new media purchased, media fed through the machine, or discarded media? How is it recycled?
- **P08-4:** What surfaces/coatings are removed, and what do you know about their composition?
- **P08-5:** Where do dust, spent media and dirty water go? What operating and waste records are available?

Technical decision: compatible factor and abrasive-use basis; conditional outdoor weather data; metals/waste review. Do not ask the client to select an emission factor. C06 must distinguish enclosed/recycled and wet cases from open dry blasting.

### P09 — Thermal metal spraying

- **P09-1:** Is the sprayed material molten metal/metal powder, or ordinary paint? What spray equipment is used?
- **P09-2:** Which feedstocks were used and how much by each process? Is overspray reclaimed and reused?
- **P09-3:** What composition records, collector details and waste records are available?

Technical decision: spray family/feedstock method and composition weighting; paint answers route to P13.

### P10 — Machining and fluids

- **P10-1:** Which machining operations and machines run dry or use coolant/cutting oil?
- **P10-2:** Which concentrates/additives and dilution ratios are used? How much fresh concentrate, makeup water and replacement fluid were added?
- **P10-3:** Are fluids recirculated or treated? What leaves in chips, sludge, mist collectors or spent-fluid collections?
- **P10-4:** What production, sump-change and waste records exist?

Technical decision: fluid basis, reuse, constituent treatment and supported mist/dust method. Do not treat diluted-fluid volume as undiluted product consumption.

### P11 — Forming and forging

- **P11-1:** What bending, pressing, rolling, stamping or forging occurs? Is the metal heated?
- **P11-2:** Which lubricants, release agents or coated materials are used?
- **P11-3:** What scale, dust, scrap or fluid waste results, and what records exist?

Technical decision: material/release treatment and links to P19/P20; avoid an automatic “forming means no emissions” response.

### P12 — Cleaning and degreasing

- **P12-1:** How are parts/tools cleaned: wiping, spraying, parts washer, immersion, vapour, pressure or ultrasonic washing?
- **P12-2:** Which products are used, are they diluted/heated, and are systems open or closed?
- **P12-3:** How much cleaner/solvent was used, recovered/reused, retained or sent away in waste? What records or waste analyses exist?
- **P12-4:** Where does used wash water go, and is cleaning performed by a contractor?

Technical decision: justified balance/measurement method and actual composition; evaporation is an output to substantiate, not a client guess. Open P24 when water routes exist.

### P13 — Liquid paint and protective coatings

- **P13-1:** Which products/components are applied, by spray, brush, roller, dip or another method?
- **P13-2:** What hardeners, thinners and additives are mixed in, at what ratios and annual quantities?
- **P13-3:** What supplier data show density, volatile content and ingredients? How are equipment and spray guns cleaned?
- **P13-4:** Are coatings air-dried or heated? What coating waste/overspray and recovered solvent are collected?

Technical decision: as-applied formulation, VOC definition/speciation, retained material and controls; route cleaning to P12 and fuel to P20 with shared allocations.

### P14 — Powder coating

- **P14-1:** What powder products are used, and can the supplier provide composition and curing-emission information?
- **P14-2:** How much powder is new, applied, reclaimed, reused and discarded?
- **P14-3:** How is the powder captured and cured? Which oven/fuel or electric system is used?

Technical decision: separate application, reuse, curing and combustion; unknown curing composition is a requirement, not zero VOC.

### P15 — Removing old coatings

- **P15-1:** How are coatings removed: chemicals, blasting/grinding, heat or another process?
- **P15-2:** What is known about the old coating, stripper and amount of work performed?
- **P15-3:** What happens to removed material, spent bath, fumes and waste?

Technical decision: route by removal method and avoid double counting P07/P08. Unknown legacy coating may require JADA/supplier/lab investigation appropriate to the selected method.

### P16 — Chemical surface preparation

- **P16-1:** Do you use baths or sprays for pickling, passivation, etching, descaling or conversion coating? Describe each.
- **P16-2:** What chemicals, bath volumes/additions, operating conditions and workpiece materials are involved?
- **P16-3:** How are baths changed, parts rinsed, air extracted, liquids treated and sludge removed?

Technical decision: specialist chemistry and method; request additional throughput or analytical records only after method selection.

### P17 — Plating and anodizing

- **P17-1:** Which plating/anodizing/etching/electropolishing processes occur onsite, and which metals are involved?
- **P17-2:** What bath chemicals and mist suppressants/surfactants are used? Are chromium-related permits or requirements applicable?
- **P17-3:** What production/electrical, testing, bath, rinse, scrubber and sludge records exist?

Technical decision: chromium-specific applicability and current substance screening, including relevant PFAS investigation. Do not ask a client to infer chemistry from a product's marketing name.

### P18 — Molten-metal dipping

- **P18-1:** Do you operate a molten zinc/tin/metal bath here, or only fabricate parts already coated elsewhere?
- **P18-2:** What bath additions, fluxes, acids, throughput and heating records exist?
- **P18-3:** How are fumes, dross/ash and spent preparation liquids handled?

Technical decision: onsite galvanizing method versus coated-workpiece treatment in another process.

### P19 — Heat treatment and quenching

- **P19-1:** What heating, stress relief, hardening or quenching occurs, and is it electric or fuel-fired?
- **P19-2:** What oils, salts, gases, water-based quench chemicals or coated parts are heated?
- **P19-3:** What operating, bath replacement, extraction and waste records exist? Is cleaning done afterward?

Technical decision: energy source and process chemistry are evaluated separately.

### P20 — Fuel-burning equipment

- **P20-1:** List every heater, boiler, oven, generator and stationary fuel-powered machine, including rarely used backup units.
- **P20-2:** What fuel, rated capacity and equipment type does each use? Provide nameplate/specification information.
- **P20-3:** How much fuel did each use? If bills are shared, what hours, meters or other records support allocation?
- **P20-4:** What controls, service/test records and operating loads exist? Supply fuel sulfur/heating value only if needed by the selected method.

Technical decision: equipment-specific method, rule exclusions and fuel allocation. Client does not decide that a small or emergency unit is exempt.

### P21 — Other process chemicals

- **P21-1:** List adhesives, sealants, anti-spatter, marking inks, penetrants/developers and other production/inspection sprays.
- **P21-2:** How are they applied, cured, cleaned up, recovered or retained in products?
- **P21-3:** What annual use and waste records exist?

Technical decision: reuse an approved product-use method only when its conditions match; otherwise manual evaluation.

### P22 — Tanks and handling

- **P22-1:** What liquids or gases are stored and transferred? Distinguish bulk tanks, drums, cylinders and process containers.
- **P22-2:** For relevant tanks, what capacity/type, contents, deliveries/withdrawals and venting/control information exists?
- **P22-3:** Are there measured or estimated transfer/vent/leak losses, and do another process's records already include them?

Technical decision: tank-method eligibility and targeted requests for geometry, temperature and vapour properties. Do not collect irrelevant tank-model fields for every container.

### P23 — Scrap and waste streams

- **P23-1:** Give each waste/recycling stream a name and list the processes contributing to it.
- **P23-2:** How much was generated, stored and shipped in 2026? Provide tickets/manifests and identify duplicate records.
- **P23-3:** What is known about its substance composition, moisture and representativeness? Are analyses or supplier information available?
- **P23-4:** Who received it, at which site, and for what recycling, treatment or disposal operation?

Technical decision: constituent quantity and current reporting category; unresolved destination becomes a targeted contractor-information task.

### P24 — Water and discharge

- **P24-1:** List each process/wash/rinse/scrubber/cooling water stream and any runoff exposed to work materials.
- **P24-2:** Is it reused, discharged to sewer/surface/ground, or collected by a contractor? Where exactly?
- **P24-3:** What flow/volume, sampling, laboratory and treatment records cover 2026? Include detection limits and sampling dates.
- **P24-4:** What sludge or separated material leaves treatment, and where does it go?

Technical decision: destination, suitable measurement/balance method, representative sampling and sludge reconciliation. A municipal sewer route is not automatically a direct release to surface water.

### P25 — Outdoor roads and dusty handling

- **P25-1:** Which unpaved routes are used inside the facility, by which vehicles and how many trips/distance per year?
- **P25-2:** What vehicle weights, road surface/silt, operating/weather and dust-suppression records exist?
- **P25-3:** Are dusty materials stored, moved or loaded outdoors? Identify material, quantity, handling and controls separately from road traffic.

Technical decision: road applicability and segment method, separate pile/handling methods. Weather/silt inputs are requested only for an applicable calculation path.

### P26 — Specialist and unlisted work

- **P26-1:** Do you melt/cast/smelt metals, make metal powders, use additive manufacturing, apply vacuum coatings, recover chemicals or burn waste? Describe each activity.
- **P26-2:** Are there foundry/steelmaking furnaces, special chemical production, waste-incineration or other operations beyond fabrication? Supply equipment/process descriptions and permits.
- **P26-3:** What feedstock, production, fuel, test and waste records exist?

Technical decision: JADA must reconcile the discovered operations against the full exceptional-activity lists in [S01](sources-and-decisions.md#s01), Schedule 3 sections 1(1)(a) and 10, recording present/absent/unknown. Use targeted follow-ups for any ambiguity, including specialist operations such as pentachlorophenol wood preservation or magnesium production. Ordinary arc welding is not automatically a steelmaking electric arc furnace. Positive/uncertain cases remain manual until a method is approved.

### P27 — Maintenance and incidents

- **P27-1:** Which maintenance chemicals, refrigerants, batteries or firefighting foams were used, replaced or handled?
- **P27-2:** For spills/leaks/fires, what substance and amount were involved, what was recovered, and where did the rest go?
- **P27-3:** What service reports, incident records and cleanup/waste records support the quantities?

Technical decision: actual listed substance and applicable exclusions, annual usage versus event releases, recovered waste, and uncertainty.

### P28 — Work done elsewhere or by others

- **P28-1:** What work is sent offsite, and what contractor work happens at this location?
- **P28-2:** Do your crews operate at customer/temporary sites? Which locations, periods, equipment and materials are involved?
- **P28-3:** Who owns/operates the relevant equipment and has the records? Has another party included the work in a report?

Technical decision: facility/responsibility boundary before material and source allocation; do not make the contractor's identity the reporting rule.

## JADA-only decision queue

The client supplies observable facts. The reviewer resolves:

1. Facility boundary, employee-hour categories, special activities and annual filing type.
2. Substance/group identities, composition gaps and year-specific qualifiers.
3. Whether a material quantity belongs in an assessment; do not delete excluded source evidence.
4. Method applicability and required measurement use; unsupported or conflicting sources.
5. Factor edition, units, process/material conditions and control basis.
6. Use of ranges, surrogate information or estimates, including the effect on thresholds.
7. Output destinations, overlaps, shared controls and source-to-stack allocation.
8. Full-facility completeness, final fields, approval and authorized certification.

Before closure, explicitly map Schedule 4 section 7 metadata: public/technical contacts, owner/operator/parent company, applicable identifiers, operating schedule and shutdowns, and pollution-prevention plans/activities. Choose the applicable annual filing/notification workflow separately from numeric results. Zero releases after a reporting threshold is met must not automatically become a no-filing determination.

Every resolved item records the inputs, source locator, reasoning and reviewer. Reopen it if a dependent fact changes.

## Worked routing examples

**Sandblasting discovered late:** G06/P08 becomes Yes → create activity → ask P08-1 through P08-5 → link M/O/P23/P24 facts → evaluate supported configuration → request only missing inputs → calculate or assign manual method → update facility particulate/metals and residue review. Previously approved totals become a new draft revision.

**No chimney reported:** G10 still asks about extractors/booths/heaters. If outlets are found, map them and assess relevance. If none is confirmed, retain that answer but assess fugitive releases from present activities. Do not infer no emissions from no tall stack.

**Unknown powder coating chemistry:** P14 is present and powder use is known; composition/curing data are absent → create supplier/JADA evidence task → any independent supported calculation can proceed → affected conclusions remain pending → complete package waits for resolution.

**Offsite painting:** P28 confirms painting occurs at a separately operated external site → JADA resolves boundary and documents the decision → onsite paint calculation may be inapplicable for this case, while transport/storage/waste facts are considered as relevant. Onsite contractor painting follows a different path.

## Question-bank validation before release

Test with a nontechnical operator and a JADA reviewer. Verify that aliases resolve to technical codes, “not sure” is usable, records can be reused, technical decisions do not leak into client wording, and each missing requirement names the affected calculation. Use the [process tests](process-catalogue.md) and [runtime scenarios](README.md#completion-tests-for-the-pilot) to check routing, not only whether fields can be submitted.
