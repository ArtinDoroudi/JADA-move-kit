# Metal fabrication defaults review for S13

**Due 11 December 2026**
**Practitioner** ____________________
**Signature and date** ____________________

Every candidate in the [default library](defaults.yaml) is pending approval. Record Approve, Change or Reject for each row under policy `metal_fab-policy@1`. Attach the decision rationale and replacement evidence for any change. For an approval, record the practitioner’s name, date and the approved policy version in the pack.

**S05** is the ECCC welding workbook identified in the [import manifest](import/eccc-welding-2022-10-26.manifest.yaml). **G** refers to its calculation guide. **Plan 00** is the automation-first plan. **Spec 16** covers workbook reproduction and activity derivation.

**Part 4 PM** facility-wide annual air release thresholds are TPM 20 t, PM10 0.5 t and PM2.5 0.3 t (Schedule 3, Table 2). Minimum releases from applicable individual stacks are TPM 25 t, PM10 0.5 t and PM2.5 0.25 t. Stack eligibility and reporting conditions are set out in Schedule 4, paragraph 20(1)(d), subsection 20(2), and Table 4. **Part 1 MPO** refers to the applicable substance-specific mass and concentration thresholds. **Part 2 PAH** refers to source coverage relevant to the 50 kg aggregate criterion and the conditional 5 kg individual reporting quantity. [2025–2027 NPRI Notice](https://gazette.gc.ca/rp-pr/p1/2025/2025-03-08/html/sup1-eng.html), [NPRI Reporting Guide, Table 6](https://www.canada.ca/en/environment-climate-change/services/national-pollutant-release-inventory/report/reporting-guide.html)

The welding input, facility-wide method selection and source-screening entries can take effect after approval and only when the recorded facts satisfy their scope. Proposal rows document existing workbook factors, policy choices or deferred strategies. Approving a proposal leaves any pending rate, grade, eligibility evidence or implementation work outstanding. The derivation and classification work supplies the missing input handling. Logged runtime, documented stock change and billed energy data take precedence where available.

| Default | Target | Proposed value, interval or method | Source | Thresholds or reporting affected | Approve / Change / Reject |
| --- | --- | --- | --- | --- | --- |
| `welding_arc.class_unknown.fcaw_method1` | `P01-2.class` | Other FCAW | S05 Instructions!A68:A86, Table A Other usage rows | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.class_unknown.gmaw_method1` | `P01-2.class` | Other GMAW | S05 Instructions!A68:A86, Table A Other usage rows | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.class_unknown.gtaw_method1` | `P01-2.class` | Other GTAW | S05 Instructions!A68:A86, Table A Other usage rows | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.class_unknown.paw_method1` | `P01-2.class` | Other PAW | S05 Instructions!A68:A86, Table A Other usage rows | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.class_unknown.saw_method1` | `P01-2.class` | Other SAW | S05 Instructions!A68:A86, Table A Other usage rows | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.class_unknown.smaw_method1` | `P01-2.class` | Other SMAW | S05 Instructions!A68:A86, Table A Other usage rows | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.class_unknown.other_method1` | `P01-2.class` | Other Welding Methods, with accepted mass if both selectors are unresolved | S05 Instructions!A68:A86, Table A Other Welding Methods row | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.process_unknown.method1` | `P01-2.process` | Other Welding Methods, with accepted mass if both selectors are unresolved | S05 Instructions!A68:A86, Table A Other Welding Methods row | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.other.method1` | `other_welding_method` | Workbook Other Method 1 starting point, with practitioner review of threshold disagreements | S05 Instructions!A79:A83 | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.particulate.pm25` | `welding.particulate.pm25_over_pm10` | 0.75 × PM10 | S05 Instructions!A61, G §§5.2, 7.3 | Part 4 PM | __________ |
| `welding_arc.particulate.tpm` | `welding.particulate.tpm_over_pm10` | Equal to PM10 | S05 Instructions!A60, G §§5.2, 7.3 | Part 4 PM | __________ |
| `welding_arc.stock_uncertainty` | `stock_uncertainty` | ±25% of recorded annual purchases, proposed | plan-00 §6.3 annual use, spec 16 §6.2 | Part 1 MPO and metal releases, Part 4 PM | __________ |
| `welding_arc.annual_use.purchases` | `P01-2.mass` | Documented packs × pack mass, adjusted for known stock change or the stock uncertainty proposal | spec-16 §6.2 | Part 1 MPO and metal releases, Part 4 PM | __________ |
| `welding_arc.composition.sds_range` | `P01-2.fraction` | Supplier range with a midpoint central estimate | plan-00 §6.3 SDS ranges, spec 16 §7 | Metal air-release estimates and any applicable Part 1 MPO assessment | __________ |
| `welding_arc.composition.unknown_bound` | `P01-2.fraction` | Documented whole material mass as a single-substance upper bound | plan-00 §§6.3–6.4, spec 16 §7 | Metal air-release estimates and any applicable Part 1 MPO assessment | __________ |
| `thermal_spray.stock_uncertainty` | `stock_uncertainty` | ±25% of recorded annual purchases, proposed | plan-00 §6.3 annual use, spec 16 §6.2 | Part 1 MPO and metal releases, Part 4 PM | __________ |
| `thermal_spray.annual_use.purchases` | `P09-2.mass` | Documented packs × pack mass, adjusted for known stock change or the stock uncertainty proposal | spec-16 §6.2 | Part 1 MPO and metal releases, Part 4 PM | __________ |
| `thermal_spray.composition.sds_range` | `P09-3.fraction` | Supplier range with a midpoint central estimate | plan-00 §6.3 SDS ranges, spec 16 §7 | Metal air-release estimates and any applicable Part 1 MPO assessment | __________ |
| `thermal_spray.composition.unknown_bound` | `P09-3.fraction` | Documented whole material mass as a single-substance upper bound | plan-00 §§6.3–6.4, spec 16 §7 | Metal air-release estimates and any applicable Part 1 MPO assessment | __________ |
| `welding_arc.capture.unknown` | `activity.capture_or_control` | Uncontrolled factor with no control credit | S05 Instructions!A63:A64, G §11.1 | Metal air-release estimates and Part 4 PM | __________ |
| `welding_arc.outlet.unknown` | `activity.air_outlet` | General building exhaust, subject to separate assessment of evidenced stacks | plan-00 §§6.3, 6.5 | Part 4 stack reporting where applicable | __________ |
| `thermal_cutting.capture.unknown` | `activity.capture_or_control` | Uncontrolled factor with no control credit | S05 Instructions!A63:A64, G §11.1 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.outlet.unknown` | `activity.air_outlet` | General building exhaust, subject to separate assessment of evidenced stacks | plan-00 §§6.3, 6.5 | Part 4 stack reporting where applicable | __________ |
| `thermal_spray.capture.unknown` | `activity.capture_or_control` | Uncontrolled factor with no control credit | S05 Instructions!A63:A64, G §11.1 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_spray.outlet.unknown` | `activity.air_outlet` | General building exhaust, subject to separate assessment of evidenced stacks | plan-00 §§6.3, 6.5 | Part 4 stack reporting where applicable | __________ |
| `thermal_cutting.hours.grinder` | `P05-3.hours` | Disc count × approved active life by class. Source interval required | spec-16 §6.2 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.hours.plasma` | `P05-3.hours` | Electrode count × approved arc-on life by class. Source interval required | spec-16 §6.2 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.hours.oxy_fuel` | `P05-3.hours` | Recorded fuel gas volume × approved cutting share ÷ torch rate. Source intervals required | spec-16 §6.2 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.hours.gouging` | `P05-3.hours` | Carbon count × approved burn life by diameter. Source interval required | spec-16 §6.2 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.hours.laser` | `P05-3.hours` | Assist-gas volume ÷ approved flow rate. Source interval required | spec-16 §6.2 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.hours.arc_saw` | `P05-3.hours` | Blade count × approved life by class. Source interval required | spec-16 §6.2 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.hours.reciprocating_saw` | `P05-3.hours` | Blade count × approved life by class. Source interval required | spec-16 §6.2 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.hours.grinder_125mm_disc_life` | `grinding.disc_125mm` | 15 / 25 / 40 min per 125 mm disc, illustrative only. Source interval required | spec-16 §6.3, D13 | Metal air-release estimates and Part 4 PM | __________ |
| `thermal_cutting.composition.grade` | `P05-2.fraction` | Reviewed stock-grade interval. Grade standards and substance coverage required | spec-16 §7, G §3.4 | Metal air-release estimates and any applicable Part 1 MPO assessment | __________ |
| `thermal_cutting.composition.highest_alloy` | `P05-2.fraction` | Highest alloy grade documented for the shop. Confirm relevance by substance | spec-16 §7 | Metal air-release estimates and any applicable Part 1 MPO assessment | __________ |
| `thermal_cutting.composition.stock_share` | `cutting.base_metal_time_share` | Documented stock mass share as a proposed proxy for time share | spec-16 §7, G §3.4 | Metal air-release estimates and any applicable Part 1 MPO assessment | __________ |
| `welding_arc.pah_screen` | `part2_pah` | Resolve only this documented source domain when both accepted scope flags are true | notice_2025_2027 Schedule 1 Part 2, Schedule 3 §§8–9 and Schedule 4 §§12–13, module screening proposal | Part 2 PAH | __________ |
| `thermal_cutting.pah_screen` | `part2_pah` | Resolve only this documented source domain when both accepted scope flags are true | notice_2025_2027 Schedule 1 Part 2, Schedule 3 §§8–9 and Schedule 4 §§12–13, module screening proposal | Part 2 PAH | __________ |
| `thermal_spray.pah_screen` | `part2_pah` | Resolve only this documented source domain when both accepted scope flags are true | notice_2025_2027 Schedule 1 Part 2, Schedule 3 §§8–9 and Schedule 4 §§12–13, module screening proposal | Part 2 PAH | __________ |
| `metal_fab.employee_hours.headcount` | `G05.employee_hours` | 1,800 / 2,080 / 2,300 h per annual full-time equivalent, proposed | plan-00 §6.3 employee hours from headcount | 20,000 h employee criterion where applicable | __________ |
| `metal_fab.natural_gas.hhv` | `natural_gas.hhv` | Bill energy first, then proposed 950 / 1,020 / 1,050 Btu/scf with matched reference conditions | [EPA AP-42 §1.4.1, October 2026](https://gaftp.epa.gov/ap42/ch01/s04/final/c1s4_10_2026.pdf) | Applicable Part 4 combustion air-release thresholds | __________ |

## PAH source screening

Review the three `*.pah_screen` candidates separately for arc welding, workbook-listed cutting and thermal spraying. Their scope is the documented activity and reporting period. The Notice Schedule 1 Part 2, Schedule 3 §§8–9 and Schedule 4 §§12–13 provide the regulatory context. The welding workbook’s outputs cover metals and particulate matter.

An applicable candidate requires accepted evidence for both staff-reviewed facts. Review the uncoated inorganic feedstock and substrates together with any coatings, residues, oils, binders, fuel and other process materials. Affirm that the documented operation has no organic thermal decomposition. Unknown composition, unverified process fuel, a known organic component or conflicting evidence leaves screening unresolved. Retain separately evidenced PAH identities and independently assess other activities and facility-wide reporting obligations.
