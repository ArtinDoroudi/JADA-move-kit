# Process catalogue for welding and fabrication facilities

Prepared: 2026-11-04. All implementation priorities, input schemas and client questions are proposed. Source references support process discovery or candidate methods; they do not establish that a particular client's substances are reportable.

Use this with the [development cycles](README.md#development-cycles) and [questionnaire](questionnaire.md). The 28 families group variants that share useful software concepts. They are not 28 independent emission sources: a physical operation can touch several families, so assign activity/source IDs and prevent duplicate contributions.

“Screen” means ask whether the operation occurred in 2026. A confirmed “no” suppresses detail. “Unknown” requires follow-up. “Manual” means a named JADA task with method, evidence, calculation and review, not an omitted result. Every family is screened from C01.

## Coverage index

| ID | Family and examples | First calculation cycle | Beta recommendation |
|---|---|---|---|
| P01 | Consumable arc welding: stick, MIG/MAG, flux-core, submerged arc | C04 | Automate approved process/electrode combinations |
| P02 | TIG and plasma arc welding, with or without added filler | C04 | Automate approved variants; distinguish filler conditions |
| P03 | Resistance/spot/seam, laser/electron beam, friction and other joining | C10 | Manual method initially |
| P04 | Oxy-fuel welding, brazing, soldering | C10/C08 | Manual joining method; separate fuel contribution |
| P05 | Thermal cutting and gouging: oxy, plasma, laser, air-carbon arc | C05 | Automate supported cutting methods |
| P06 | Mechanical/cold cutting: saws, shears, press cutting, waterjet | C05/C06 | Supported subtype only; remainder manual |
| P07 | Grinding, sanding, polishing, deburring, tumbling, peening | C06 | Manual initially; automate a validated dry subtype first |
| P08 | Abrasive blasting: sand/grit/shot/bead, dry/wet, cabinet/outdoor | C06 | Early priority; validate each configuration |
| P09 | Thermal spraying/metallizing, distinct from spray painting | C05 | Automate supported spray/feedstock combinations |
| P10 | Machining and metalworking fluids: turning, milling, drilling, CNC, EDM | C06/C10 | Shared material/waste tracking; emissions manual initially |
| P11 | Forming and shaping: bending, rolling, pressing, stamping, forging | C06/C10 | Screen; evaluate releases and supporting products |
| P12 | Solvent and aqueous cleaning: wipe, wash, vapour, ultrasonic | C07 | Bounded solvent balance first; other methods manual |
| P13 | Liquid coatings: primer, paint, dip, brush, spray, touch-up, electrocoat | C07 | Bounded coating methods first |
| P14 | Powder coating, powder recovery and curing | C07/C10 | Separate validation before automatic calculation |
| P15 | Coating removal: chemical, mechanical or thermal stripping | C07/C10 | Route by method; thermal specialist initially |
| P16 | Pickling, passivation, etching, conversion coating and chemical milling | C10 | Specialist manual |
| P17 | Electroplating, electroless plating, anodizing, electropolishing | C10 | Specialist manual |
| P18 | Hot-dip galvanizing, tinning and other molten-metal coating | C10 | Specialist manual |
| P19 | Preheat, stress relief, heat treatment, furnaces, quenching | C08/C10 | Separate heat source from treatment chemistry |
| P20 | Fuel-burning heaters, boilers, ovens, generators and stationary engines | C08 | Named equipment/fuel methods only |
| P21 | Assembly chemicals, sealants, inks, anti-spatter, penetrant inspection | C07/C10 | Shared product methods where applicable |
| P22 | Bulk storage, liquid transfer, gases and handling losses | C09 | Screen; tank-specific manual methods initially |
| P23 | Scrap, dust, slag, filters, spent media, solvents and other wastes | C03/C11 | Required shared ledger, manual-supported from beta A |
| P24 | Process water, rinse water, scrubbers, wastewater and stormwater | C03/C11 | Required discovery; verified concentration/volume methods later |
| P25 | Unpaved roads, outdoor handling, piles and fugitive dust | C09 | Road method before general pile/handling methods |
| P26 | Melting, casting, smelting, additive manufacturing, recovery, incineration | C10 | Specialist manual or outside automatic beta |
| P27 | Maintenance chemicals, refrigeration, batteries, foams and incidents | C09/C10 | Shared inventory plus incident/manual assessments |
| P28 | Outsourced, contractor, mobile and temporary-site work | C01/C10 | Boundary/allocation decisions; not its own emission factor |

The common fabrication grouping is supported by [S19](sources-and-decisions.md#s19). The broader surface-treatment and specialist screening is informed by [S16](sources-and-decisions.md#s16) and [S17](sources-and-decisions.md#s17). Do not import US industrial classifications, exemptions or thresholds into Canadian reporting.

## How to use the process cards

Each card supplies: discovery scope; candidate substances/destinations; inputs and evidence; method/factor decision; an implementation run; and a failure test. Pollutants listed are candidates for investigation. Screen against the current substance definitions and actual materials, rather than making a fixed “welding chemicals” list.

All cards also use the shared controls/outlets and waste/water questions. References to a candidate method mean its applicability and units must be approved before execution. Where no standard method was established in this research, that absence is stated rather than filled with a guessed factor.

Consumable allocations and sequential processing are different: a shared stock batch can pass through cutting, grinding and welding. Preserve its lineage and apply each rule's counting basis. Do not divide the batch between those sequential operations as though it were a consumable, or add each passage as a new purchase.

### P01 — Consumable arc welding

**Scope:** SMAW/stick, GMAW/MIG/MAG, FCAW and SAW; include robotic work and welding-based hardfacing as variants of the actual process. Candidate outputs include relevant metals and particulate fractions, plus residues.

**Inputs:** process/electrode classification, annual rod/wire use, composition, workpiece/coatings, separate fluxes/shielding gases, stations and controls. Evidence: packaging, SDS/TDS, consumable logs, opening/closing stock and job records. Request detailed operating settings only where method conditions need them. Factor keys include electrode class, process, substance, method and mass basis; an invoice product name is not enough.

**Run C04:** identify method and aliases → allocate consumables → evaluate contribution treatment → calculate supported outputs → attach controls/residues → compare an independent example. Start with one known electrode combination. Add unknown-electrode alternatives only with their conditions. Test an unmapped electrode, missing factor and one wire split between processes. Questions: P01 in the questionnaire. Sources: [S04](sources-and-decisions.md#s04), [S05](sources-and-decisions.md#s05), [S06](sources-and-decisions.md#s06).

Internal method gate: the cited “Other” options are conditional, including availability of site-specific methods. The composition-based alternative needs reliable fractions and a reason the averaged method is unsuitable. Do not choose an alternative solely because it yields a number.

### P02 — TIG and plasma arc welding

**Scope:** GTAW/TIG and PAW welding. Keep autogenous/no-filler work visible. Candidate outputs cannot be inferred solely from purchased filler.

**Inputs:** actual process, filler use or confirmed absence, filler classification/quantity/composition, workpiece/coatings, operating records and ventilation. Confirm that the chosen method covers the actual filler condition; absence of an applicable consumable-factor path is not zero emissions.

**Run C04:** classify filler condition → select supported method or manual task → collect its inputs → calculate and review destinations. Test a no-filler station alongside a filler station: the first must not disappear when there is no matching purchase line. Source/conditions: [S04](sources-and-decisions.md#s04), [S05](sources-and-decisions.md#s05).

### P03 — Other joining methods

**Scope:** resistance spot/seam/projection, laser/electron beam, friction/stir, ultrasonic, diffusion or other specialist joining. Record coatings, oils or adhesives involved. This catalogue does not establish emission factors for these variants.

**Inputs:** equipment and joining description, materials and surface condition, consumables if any, production/time records, existing measurements and exhaust. Candidate assessment covers actual substances and generated emissions, not an assumed arc-welding factor.

**Run C10:** classify the equipment → investigate applicable method → JADA records calculation or justified treatment → integrate outputs. Test that selecting “other welding” produces a specific review requirement rather than the generic arc-welding default. Discovery context: [S17](sources-and-decisions.md#s17); approved method remains a case-specific work item.

### P04 — Oxy-fuel joining, brazing and soldering

**Scope:** flame welding, brazing, silver brazing and soldering. Inspect filler, flux, cleaning and fuel separately. Candidate outputs depend on the actual metals/fluxes and combustion conditions.

**Inputs:** filler/flux identities and use, joint/workpiece materials, fuel consumption or supported allocation, process temperature/method where needed, ventilation, slag and spent cleaning materials.

**Run C10/C08:** establish joining-specific method → assess filler/flux and generated substances → connect fuel once to its combustion source → reconcile waste. No generic filler emission coefficient is approved here. Test shared fuel bills and solder that never appears in the arc-welding factor list. Sources: [S04](sources-and-decisions.md#s04), [S17](sources-and-decisions.md#s17).

### P05 — Thermal cutting and gouging

**Scope:** oxy-fuel, plasma, laser and air-carbon arc cutting/gouging. Distinguish cutting from welding even on the same machine. Candidate outputs include metals/particulate and relevant fuel-related contributions.

**Inputs:** cutting family, material grades/coatings, quantities relevant to assessment, active cutting time and composition by operating interval, fuel/electrodes, extraction and dross. Machine availability is not necessarily active cutting time.

**Run C05:** map material/time segments → evaluate material treatment → calculate supported method → aggregate source contributions. Factor basis and weighting must follow the selected method. Test two alloys with unequal cutting times, mixed units and a record giving only paid shift hours. Sources: [S04](sources-and-decisions.md#s04), [S05](sources-and-decisions.md#s05).

### P06 — Mechanical cutting and waterjet

**Scope:** reciprocating/band/circular/abrasive saws, shears, punching/press cutting, waterjet and abrasive waterjet. An abrasive cutting wheel may overlap P07; assign one operation ID.

**Inputs:** exact equipment, wet/dry method, base material and coatings, cutting activity records, abrasive/coolant, chip/sludge collection and discharge route. Do not select a thermal-cutting method merely because the process removes metal.

**Run C05/C06:** check whether the exact subtype is supported → apply its contribution treatment → use supported calculation or manual method → route chips/slurry. Test shearing and waterjet as unsupported alternatives to a supported saw, and ensure their materials remain inventoried. Sources: [S04](sources-and-decisions.md#s04), [S05](sources-and-decisions.md#s05), [S17](sources-and-decisions.md#s17).

Add a contribution-treatment regression that distinguishes welded/sprayed base metal from cut base metal, including the guidance's reciprocating-saw exception. The existence of a release factor does not settle threshold inclusion.

### P07 — Grinding and mechanical finishing

**Scope:** grinding, sanding, polishing, buffing, deburring, vibratory/barrel finishing, burnishing and peening. Record whether the purpose is cutting, finishing or stripping a coating.

**Inputs:** operation/machine, wet/dry configuration, material removed, coatings, abrasives/compounds, activity measure needed by the selected method, collector and waste. Candidate concerns include particulate and relevant material constituents. No universal grinding factor is established here.

**Run C06:** separate operation roles → select method with compatible basis → attach capture and wastes → check overlap with P05/P06/P08/P15. Test a grinder used for both cutting and polishing without assigning the full annual operating time twice. Sources: [S19](sources-and-decisions.md#s19), [S17](sources-and-decisions.md#s17).

### P08 — Abrasive blasting

**Scope:** sand, grit, shot, slag, glass bead and other media; dry/wet/vapour, cabinet/room/outdoor, pressure and wheel machines. Candidate outputs include particulate, relevant media/substrate/coating substances, spent media and slurry.

**Inputs:** media and substrate/coating identification, throughput definition, fresh/reused media, setup, operating record, controls and waste. Outdoor wind-dependent defaults must not be silently reused for all enclosed/recycled machines.

**Run C06:** choose a supported configuration → resolve abrasive-use basis and factor conditions → estimate air outputs → review metals → reconcile captured dust and spent media. Test a recycled-shot cabinet, wet blast and painted substrate as separate cases. Request new testing only after method/evidence assessment. Sources: [S07](sources-and-decisions.md#s07); metals/waste methods may remain manual.

### P09 — Thermal spraying and metallizing

**Scope:** plasma, flame-wire/powder, electric arc and HVOF spray. This is different from paint spraying. Do not count welding hardfacing again as thermal spray unless that is the actual process.

**Inputs:** spray family, feedstock form/use/composition, allocations, controls, overspray/recovery and disposal. Use factor bases, composition weighting and particulate relationships from the accepted method.

**Run C05:** identify feedstock/method → reconcile usage and reuse → calculate metals/particulate → attach control and residue streams. Test a mixed feedstock year and the method's particulate-versus-metals consistency behavior. Sources: [S04](sources-and-decisions.md#s04), [S05](sources-and-decisions.md#s05).

### P10 — Machining and metalworking fluids

**Scope:** turning, milling, drilling, boring, CNC, EDM and wet/dry machining. Include fluid mixing, sumps and cleanouts. Candidate substances come from stock, additives, coatings and process fluids; evaluate mist/dust, chips and spent fluids as appropriate.

**Inputs:** machine and process, fluid concentrate/SDS, dilution and makeup, stock changes, fluid replacement, mist collection, material grades and waste records. Litres of diluted coolant are not litres of concentrate.

**Run C06/C10:** establish material and fluid balances → identify a valid emission method → evaluate chips/sludge/spent-fluid destinations → integrate. Emission methods are manual until validated. Test concentrate dilution, repeated circulation and disposal without counting reused fluid as newly consumed each cycle. Sources: [S21](sources-and-decisions.md#s21), [S17](sources-and-decisions.md#s17).

### P11 — Forming, pressing and forging

**Scope:** bending, rolling, stamping, drawing, punching and cold/hot forging. “Only changing shape” is an observation to evaluate, not a universal reporting exemption.

**Inputs:** cold/hot process, lubricants/release agents, workpiece coatings, furnace/heat source, scale/dust and wastes. Candidate method may address product chemicals and heat rather than a generic forming emission rate.

**Run C06/C10:** distinguish cold/hot and chemical use → assess material treatment → connect lubricant/combustion/waste modules → record any justified exclusion. Test a cold press with lubricant against hot forging with scale and a fuel-fired furnace. No standalone forming factor was validated in this research. Sources: [S17](sources-and-decisions.md#s17), [S19](sources-and-decisions.md#s19).

### P12 — Cleaning and degreasing

**Scope:** wipes, sprays, parts washers, immersion, vapour degreasing, aqueous/alkaline, pressure and ultrasonic washing. Candidate outputs include product constituents, air loss, dirty water, spent solvent and sludge.

**Inputs:** product/component identities, actual use and inventory, dilution, open/closed/heated equipment, regeneration/reuse, residual solvent in waste, water route and existing test data. Supplier composition may be needed beyond an SDS.

**Run C07:** select bounded mass-balance or other supported method → reconcile solvent in products/waste/recovery → calculate air and other outputs → apply substance/group rules. Test a closed parts washer with solvent-bearing waste; do not automatically treat all purchases as evaporated. Sources: [S09](sources-and-decisions.md#s09), [S02](sources-and-decisions.md#s02), [S25](sources-and-decisions.md#s25).

### P13 — Liquid coating

**Scope:** primer, paint, protective coatings, brush/roller/dip/spray, touch-up and electrophoretic liquid coatings. Candidate outputs include VOCs, listed individual ingredients, pigment-bearing overspray and coating waste.

**Inputs:** coating/hardener/thinner components and mixing ratios, use, density, volatile/solid composition, application/curing, controls and waste. Track equipment-cleaning products separately, but allocate shared purchases once.

**Run C07:** establish as-applied mixtures → assign constituent treatment and method → calculate volatility/retention and overspray where justified → route air/waste and fuel for curing. Test two-component paint, thinners and a booth filter: particulate collection must not automatically become VOC removal. Sources: [S08](sources-and-decisions.md#s08), [S22](sources-and-decisions.md#s22).

### P14 — Powder coating and curing

**Scope:** powder application, reclamation/reuse, pretreatment and curing. Assess powder losses and formulation-dependent emissions; link oven fuel separately. Do not assume zero because no liquid solvent is added.

**Inputs:** powder identity and supplier composition/curing data, virgin/reclaimed/reused/discarded quantities, booth/filters, production/cure settings, oven energy and waste. Reclaimed powder circulating internally is not new annual input each time.

**Run C07/C10:** close powder flow balance → select supported application/curing methods → attach control/waste → add heat source once. Manual until applicable methods are validated. Test full reuse versus discarded overspray and formulation with unknown curing emissions. Source: [S22](sources-and-decisions.md#s22).

### P15 — Coating removal

**Scope:** chemical stripping, mechanical removal and thermal burn-off. These activate different modules and may involve unknown legacy coating composition.

**Inputs:** removed coating identity, stripping chemistry, amount/area treated as the method requires, bath/replacement records, heat source, residues, capture and discharge. Mechanical removal can map to blasting or grinding; count it there once.

**Run C07/C10:** classify removal method → route mechanical work to P07/P08, chemical work to its balance, thermal work to specialist review → investigate residues → integrate. Test unknown old paint and thermal stripping without assuming a standard paint evaporation method covers decomposition. Sources: [S17](sources-and-decisions.md#s17), [S08](sources-and-decisions.md#s08).

### P16 — Chemical surface preparation

**Scope:** acid pickling, stainless passivation, phosphating/chromating, chemical etching/milling and descaling. Candidates depend on bath ingredients and dissolved workpiece material.

**Inputs:** bath chemistry/SDS, additions and inventories, temperature, use/throughput, rinses, air extraction, neutralization/treatment, spent baths and sludge. A process can generate substances absent from the incoming product list.

**Run C10:** specialist identifies reactions and method boundaries → build bath/rinse balance or accepted measurement method → calculate air/water/waste contributions → check substance-specific rules. Test a dissolved metal and a neutralized chemical so inputs are not blindly reported as unchanged outputs. Source: [S16](sources-and-decisions.md#s16); no universal bath factors approved here.

### P17 — Plating and anodizing

**Scope:** electroplating, electroless plating, anodizing, reverse etching and electropolishing. Chromium-related operations need a specific applicability review; do not infer their treatment from ordinary welding.

**Inputs:** bath/metal identity, suppressants and additives, process/electrical records where method-relevant, temperature, rinse quantities, capture, scrubbers, tests and sludge. Investigate unknown surfactant composition rather than assuming it contains or lacks PFAS.

**Run C10:** specialty rule screen → assign bath-specific method → collect required process and monitoring facts → reconcile air/water/sludge → JADA review. Test a chrome bath, non-chrome bath and unknown suppressant separately. Sources: [S16](sources-and-decisions.md#s16), [S18](sources-and-decisions.md#s18), [S01](sources-and-decisions.md#s01).

### P18 — Hot-dip metallic coating

**Scope:** onsite molten zinc/tin or other metal baths, associated pickling/fluxing and dross. Working with purchased galvanized steel does not establish that this process exists onsite.

**Inputs:** bath metal additions/inventory, flux/pickle composition, throughput, temperature, extraction, dross/ash, waste and fuel. Candidate metal/chemical pathways extend beyond the finished coating.

**Run C10:** confirm actual bath operation → combine preparation, bath, combustion and residue methods → review totals and destinations. Specialist manual initially. Test “weld galvanized parts” versus “operate galvanizing line” to prevent routing errors. Sources: [S11](sources-and-decisions.md#s11), [S16](sources-and-decisions.md#s16).

### P19 — Heat treatment and quenching

**Scope:** pre/post-weld heating, stress relief, annealing, hardening, furnaces, salt baths and oil/water/gas quenching. Candidate contributions include heat-source emissions, bath/quench chemicals and residues.

**Inputs:** treatment method, electrical/fuel heat, operating records, quench/bath composition, replacements, ventilation, treated coatings/oils and follow-on cleaning. Electric heating removes a fuel source but does not prove the process has no releases.

**Run C08/C10:** split energy from treatment chemistry → assign each method → calculate/review residues and exhaust. Test an electric oven with organic surface residues and an oil quench followed by degreasing. Source: [S10](sources-and-decisions.md#s10).

### P20 — Combustion equipment

**Scope:** space heaters, boilers, process/curing ovens, dryers, stationary engines/generators, engine-driven pumps/compressors. Distinguish these from mobile vehicles and process fuels used for other purposes.

**Inputs:** equipment ID/type, rated capacity, fuel/type and quantity, operating period/load where required, sulfur/heating value if the method requires them, controls and measurements. Allocate a shared utility bill with evidence and preserve unallocated quantity.

**Run C08:** apply equipment/facility rules → select compatible fuel/equipment factors → check units and emissions basis → aggregate across units. Test a gas heater and a diesel backup engine; neither “backup” nor low fuel use is an automatic exclusion. Sources: [S12](sources-and-decisions.md#s12), [S13](sources-and-decisions.md#s13).

### P21 — Assembly, inspection and miscellaneous process products

**Scope:** adhesives, sealants, anti-spatter, marking ink, penetrant/developer inspection chemicals, corrosion protectants and leak-test chemicals. Include process products missed by a purchasing category labelled welding supplies.

**Inputs:** product/SDS/TDS, annual use, application/curing/recovery, wipes/containers and ventilation. Identify whether chemistry reacts, remains in the product, evaporates or leaves in waste.

**Run C07/C10:** add to product inventory → map to the actual use/activity → reuse an applicable accepted method or create manual task → reconcile destinations. Test a solvent cleaner used for inspection and assembly so the shared product is counted once. Discovery extension based on [S17](sources-and-decisions.md#s17); no generic emission fraction is prescribed.

### P22 — Storage and transfer

**Scope:** bulk fuel, solvent or process-liquid tanks; filling/emptying; venting/leaks; gas handling. Small containers and compressed gases should be classified before choosing a tank model.

**Inputs:** contents, tank/container type, capacity/geometry, throughput, temperature, vapour properties, vent/control design and losses as the method requires. Confirm whether upstream use calculations already include the same loss.

**Run C09:** classify storage → select compatible method and inputs → estimate losses → reconcile with delivered/consumed/transferred inventory. Tank methods manual initially; the existence of a tank does not establish a particular reporting obligation. Test one fuel delivery feeding storage and combustion without counting the fuel mass as both air losses and burned fuel. Source: [S15](sources-and-decisions.md#s15).

### P23 — Waste, recycling and retained residues

**Scope:** scrap/offcuts, stubs, slag, collected dust, filters, spent abrasive, slurry, solvent/paint/oily waste, packaging and onsite stockpiles. Waste weight is not the weight of each NPRI substance in it.

**Inputs:** stream ID/source, annual mass/stock change, composition or supported estimate, recipient/site, purpose/treatment and documents. Scrapyard, recycler and disposal contractor names alone may not establish the correct destination category.

**Run C03/C11:** map process residues → reconcile stream weights → determine constituent quantities and classification → attach receiving-site information → cross-check process balances. Test a collected dust stream receiving two processes and a shipment recorded in both invoice and manifest. Source: [S02](sources-and-decisions.md#s02); exact output categories must be mapped to current filing requirements.

### P24 — Water and wastewater

**Scope:** parts wash, rinses, waterjet/blasting water, wet collectors, cooling-water chemicals, floor wash, process treatment and exposed stormwater. Distinguish recirculation, direct environmental discharge, sewer and offsite treatment.

**Inputs:** flow/volume and period, concentration/speciation and sampling basis where available, treatment/removal, sludge quantities, reuse, recipient or receiving environment. Sampling representativeness and detection limits require explicit review.

**Run C03/C11:** map each water route → select measurement/balance/manual method → calculate water and sludge contributions separately → verify destination. Test recycled water with periodic purge and sludge removal; do not multiply one grab sample by annual flow without justification. Sources: [S02](sources-and-decisions.md#s02), [S16](sources-and-decisions.md#s16), [S17](sources-and-decisions.md#s17).

### P25 — Yard traffic and outdoor dust

**Scope:** unpaved routes, loose grit/fines/powders, dusty stockpiles, loading/unloading and housekeeping. Vehicle exhaust, road dust, blasting and material-handling dust are different sources.

**Inputs:** road segments, trips/distance, vehicle weights and access, surface/silt/weather/suppression as required; for piles/handling, material properties and operation-specific activity. Do not force non-road dust into a road formula.

**Run C09:** screen road applicability → calculate supported segments → separately review pile/handling sources → aggregate particulate by fraction. Test annual vehicle distance at the rule boundary and shared routes used by contractors. Source: [S14](sources-and-decisions.md#s14); general outdoor-material methods remain case-specific.

### P26 — Specialist manufacturing and treatment

**Scope:** melting/casting/smelting, foundries, metal powders/additive manufacture, sintering, vacuum/sputter coatings, chemical manufacture, solvent recovery, waste burning/incineration and unlisted operations. This is an explicit expansion screen, not a claim these are typical welding activities.

**Inputs:** process description, feedstocks/products, equipment, temperatures/reactions, throughput, fuel, permits/tests and all output streams. Some operations activate additional rule families.

**Run C10:** JADA classifies the real operation → screens special applicability → develops case-specific method/evidence plan → records reviewed contributions or excludes the client from automatic beta service. Test an ordinary arc welder against a steelmaking electric arc furnace: names must not trigger the same branch. Sources: [S01](sources-and-decisions.md#s01), [S17](sources-and-decisions.md#s17), [S19](sources-and-decisions.md#s19).

### P27 — Maintenance and unusual events

**Scope:** maintenance chemicals, lubricants, refrigeration servicing, battery/equipment handling, firefighting foams, spills, leaks, fires and accidental releases. Not every maintenance product or refrigerant is an NPRI substance; screen identities and applicable exclusions.

**Inputs:** material identity, activity, amounts, stock changes/service records, event date, released/recovered quantity and destinations. Include intermittent work and events even if absent from normal production logs.

**Run C09/C10:** classify routine use versus event → check substance/rule treatment → account for release and recovery → record uncertainties. Test a spill partly recovered into waste, and foam with unknown composition. Sources: [S18](sources-and-decisions.md#s18), [S02](sources-and-decisions.md#s02).

### P28 — Outsourced, contractor and mobile work

**Scope:** parts sent to another site, contractors operating on this property, work at customers' premises and temporary/mobile operations. This controls allocation and responsibility; it has no independent emission coefficient.

**Inputs:** where/when work happened, owner/operator, equipment and material use, records held by each party, existing facility IDs and reporting responsibility. A contractor doing onsite blasting must not vanish because the shop did not buy the abrasive directly.

**Run C01/C10:** resolve facility boundary and operation ownership → assign records and emissions to the correct case → activate relevant process cards → prevent duplicate or omitted reporting. Test offsite painting versus onsite contractor painting. Sources: [S01](sources-and-decisions.md#s01), [S02](sources-and-decisions.md#s02).

## Shared controls and outlets

### Method and factor input matrix

This is a lookup/data-design map, not a library of approved coefficients. Source units below describe specific candidate methods; other valid methods may use different bases. Always read the selected table's conditions and footnotes.

| Process/method family | Factor or parameter to resolve | Activity/input basis | What stops automatic calculation |
|---|---|---|---|
| Arc welding, listed factors | Process/electrode/substance emission factor; particulate/chemical basis | S05 includes g emitted per kg consumable | Unknown classification, unsupported condition or missing factor |
| Composition-based welding alternative | Process coefficient and accepted elemental mass fractions | Consumable mass and composition, per selected alternative | Alternative not justified or composition unreliable |
| Supported cutting | Process/substance time factor and composition weighting | S05 includes g/min; input records can be active hours with explicit conversion | Only shift hours known, wrong subtype or unresolved composition weighting |
| Thermal spray | Feedstock/process/substance factor and method-specific particulate relation | S05 particulate factors include g/kg feedstock; metal factors include g/kg of constituent, multiplied by feedstock composition | Feedstock or method assumptions incompatible; composition omitted or applied twice |
| Dry blasting candidate | Media/configuration/PM factor and required environmental basis | S07 uses kg/tonne abrasive in its default method | Throughput/reuse meaning unresolved or configuration outside factor evidence |
| Grinding/machining | Process-specific accepted factor or measurement/balance model | Defined by the selected method; none is universal here | No validated method; never borrow a welding factor by convenience |
| Coating/solvent balance | Density, constituent fraction, retained/recovered/waste amounts; justified losses | As-used component masses/volumes and consistent fractions | Unknown formulation, waste composition or unsupported evaporation assumptions |
| Powder coating | Application/recovery balance and formulation-specific curing method | Powder flows and cure data | Reuse counted repeatedly or curing outputs unknown |
| External combustion | Fuel/equipment-specific emission factors, heating value/sulfur where required | Source-specific fuel mass, standard volume or energy basis | Wrong fuel/equipment, volume conditions or unit scale |
| Engines | Engine/fuel/load-specific factors or appropriate measurements | Metered fuel or source-defined energy/load/time basis | Heater factor substituted for engine; missing load/basis |
| Bath/chemical treatment | Reaction/speciation, measurement or validated bath-balance parameters | Bath additions, process conditions, discharge and residue data | Unsupported chemical transformations or representative-data gaps |
| Water/waste | Representative concentration, mass fraction, flow/mass and moisture basis | Compatible annual volume/mass; analytical basis retained | Nonrepresentative sampling or unknown stream destination/composition |
| Road dust | Segment-specific dust-method parameters and PM fraction | Vehicle-distance plus required road/vehicle/weather/control inputs | Applicability unresolved or non-road dust forced into road method |
| Tanks | Model-specific vapour, contents, geometry and operating parameters | Storage/throughput/temperature data as required | Wrong tank/product model or duplicate loss accounting |
| Controls | Source capture, pollutant removal, operating coverage and routing | Relevant source/time segments | Filter rating used as whole-source capture/removal, or double control credit |

### Source to outlet mapping

Every active process needs a release-path decision: open/fugitive, captured and vented, captured and filtered, recirculated, or another documented route. Link each source to equipment and outlets; shared collectors need allocations. Record capture, pollutant-specific removal, bypass/downtime and destination separately. A particulate filter is not automatically effective for gases/VOCs. [S20](sources-and-decisions.md#s20) explains the capture concept; actual credit requires process-specific evidence.

Record stack/vent geometry and operating facts only as the applicability/method requires them. Keep the basic outlet inventory even for outlets not meeting individual-stack reporting criteria. Resolve source conflicts listed in the [issue register](sources-and-decisions.md#issues-to-resolve-before-implementation).

## Per-process completion checklist

An active card closes only when its presence/scope, materials, method eligibility, inputs, factors/units, controls, outputs and destinations are resolved; a reviewer can follow the trace; and cross-process aggregation is tested. If an activity is absent, retain who confirmed it and when. If its calculation is manual, retain the work and review rather than only its final number.
