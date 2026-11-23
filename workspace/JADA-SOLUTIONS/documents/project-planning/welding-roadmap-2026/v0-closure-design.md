# Whole-facility closure for welding NPRI v0

Prepared 2026-11-04. Status: proposed implementation contract, based on read-only inspection of the isolated v0 application. This supplements the [implementation plan](v0-implementation-plan.md), including all C1–C12 gates; it does not narrow its method or process scope. Regulatory branch details remain governed by the sourced [regulatory inventory](v0-regulatory-inventory.md) and reviewed 2026 registry. This is an application design, not practitioner approval of a facility or a new regulatory interpretation.

## Decision

Keep the existing workspace, resolution, manifest, contribution and revision architecture. Add a bounded, typed inventory of sources and expected outputs. Derive completeness from that inventory, accepted outputs and reconciliations. A staff resolution may determine source scope, identity, applicability, or an evidenced quantity; it cannot set `complete`, `can_approve` or `can_file`.

The evaluator must perform, in order: annual discovery → source inventory → source/substance scope → method outputs → destination reconciliation → facility aggregation → all rule-family decisions → required reporting outputs → filing metadata/actions → calculation readiness. No generic formula language, executable client rules, graph service, or replacement calculation architecture is needed.

Current verified gaps are concrete: present P01–P28 records remain pending regardless of outputs; Part 1 and welding helpers pass `contribution_set_complete=False`; rule families can close only as not applicable; all mapped filing fields remain `pending_review`; the evaluator and service enforce a global incomplete-engine gate. Existing threshold helpers, method helpers and lifecycle endpoints should be reused. The source files are changing concurrently, so implementation should locate functions by name rather than these observations' line numbers.

## 1. Two reviewed records, with a server-derived minimum inventory

Add two explicit resolution kinds and payloads in `app/schemas/workspace.py`. Store them in the existing immutable resolution JSONB; inspect database constraints before deciding whether a migration is needed. Do not overload the unrestricted text `MethodAssignmentResolutionPayload.output_scope` as proof of completeness.

| Record | Fields and validation |
|---|---|
| `SourceInventoryResolutionPayload` | `payload_type=source_inventory`, `inventory_version`, `scope_refs[]`, `record_dispositions[]`, `evidence_ids[]`, `reasoning`. Each disposition names an existing activity/material/stream/outlet/control/incident or imported candidate and one of `in_scope`, `linked_to_source`, `outside_boundary`, `unused_in_year`, `duplicate_alias`, `unresolved`; exclusion/alias rows require exact reviewed decision/target references. The record has no completion boolean. |
| `SourceScopeResolutionPayload` | `payload_type=source_scope`, `scope_key`, `source_kind`, `physical_operation_id?`, `activity_ids[]`, `material_ids[]`, `stream_ids[]`, `outlet_ids[]`, `control_ids[]`, `incident_ids[]`, `period_start/end`, `source_class`, `family_screening[7]`, `expected_outputs[]`, `reconciliations[]`, `evidence_ids[]`, `reasoning`. IDs and periods must match the frozen case. |
| `FamilySourceScreen` | Exactly one per `part1A`, `part1B`, `part1C`, `part2`, `part3`, `part4`, `part5`: `state=candidates_identified|evidenced_absent|out_of_scope|unresolved`, `candidate_substance_ids[]`, `rule_id/version`, `basis`, `evidence_ids[]`, and any bounded qualifier facts needed by that rule. `evidenced_absent` is a technical determination, distinct from an annual process absence. |
| `ExpectedOutput` | Stable `slot_id`, owning `scope_key`, `substance_id`, `chemical_basis`, `role=threshold_quantity|reporting_output|internal_balance`, `quantity_kind`, `assessment_source_kind?`, `route`, `outlet_id?`, `stream_id?`, `period_start/end`, `quantity_origin_key`, permitted `method_ids/versions`, `rule_refs[]`. Allowed routes and roles are checked enums, not free text. |

`source_kind` is a small enum: physical operation, material assessment, shared waste/water stream, incident. One physical operation can have several process labels; inventory maps those labels to the same source. Source class distinguishes process emissions, stationary external combustion, stationary engine, road dust, other outdoor dust, water, waste and incident. This is necessary for the existing Part 4/5 facility-case helpers.

The evaluator constructs its minimum inventory from all activities, material use, allocations, material flows, controls, outlets, streams, incidents and annual screen answers. The accepted inventory must account for that exact record set, including relevant imported candidates; it cannot choose a convenient subset. A nonempty present family without sources, an unassigned activity, a positive G17 without classification, an unlinked waste shipment, or unknown contractor responsibility remains blocking. P28 maps responsibility to actual operating sources; it does not create duplicate emissions. An accepted outside-boundary determination preserves the source and reasons in the package.

Source scopes must partition overlapping quantities and time periods explicitly. Reject overlapping owners for the same output slot; do not silently pick the newest proposal. A shared downstream stream owns its final disposal/recycling/water output once, with upstream generation quantities retained as internal balance rows. Inventory review requires retained evidence and a different staff reviewer, using the existing independent-review mechanism.

### Candidate floor: omission is not absence

Build the minimum candidate set as the union of:

- accepted composition identities, qualifiers and groups for every linked material and stream;
- every output identity declared by the assigned method's released output catalogue, including generated species not present in the feedstock SDS;
- process-specific screening for incidental manufacture, Part 2 PAHs, Part 3 named activities, PFAS, coating/solvent VOCs, combustion species, substrate/media contaminants, incidents and unlisted work;
- the frozen 2026 substance/group registry and its relevant screening domains.

Preserve unknown composition domains, including undisclosed PFAS and legacy coatings, as unresolved candidates. An empty SDS disclosure does not close a domain. A reviewer can document why a specific identity/domain is absent or excluded, with a scoped rule and evidence; the evaluator retains the exclusion decision. They cannot submit an empty `expected_outputs` list while a candidate floor is nonempty. Catalogue output requirements are a minimum: case evidence can add candidates. Candidate identity mapping and group membership must be resolved before deriving slots.

All seven family screens are mandatory per source. Broad absence can be evidenced at a coherent source/domain level; entering thousands of individual negative rows is unnecessary. It must still account for all positively identified candidates and cannot contradict any material, process, method or incident record. The catalogue exposes the required screen domains so UI and engine use the same contract.

## 2. Output slots, zeros and automatic/manual parity

The server derives `slot_id` deterministically from source, period, identity, role, basis and route/stream/outlet. The material/stream identity is part of the slot where needed to distinguish independent quantities. Staff may add required slots; a reviewed scoped applicability decision is needed to remove a derived obligation. Automatic/manual collisions on one slot are blocking until one method is explicitly superseded or excluded. An arbitrary caller-supplied `aggregation_key` cannot make overlapping estimates additive.

Extend `ContributionOut` and the manual payload with `output_slot_id`, `quantity_origin_key`, `source_class`, typed threshold metadata and route references. Preserve existing trace, method, evidence and inclusion fields. Threshold metadata includes the existing helper's source kind, concentration/bounds/basis, accepted range policy, qualifier and exclusion facts; do not infer these from prose `assessment_basis` strings. Method builders return outputs and issues; they do not independently finalize facility assessments.

Each expected slot ends in exactly one state:

| State | Meaning |
|---|---|
| quantified | One current accepted method result, including a supported range. |
| evidenced zero | Numeric zero with an explicit method/basis and accepted evidence. Use the existing manual zero path or an automatic zero result whose required inputs are known. |
| not applicable | A current scoped applicability decision identifies the exact slot and rule; not a zero row. |
| permitted no information | Only where the released rule explicitly permits that reporting state, such as the applicable Part 3 reporting path. Preserve it as a typed reporting status with null quantity and evidence of the determination; never feed it into arithmetic as zero. |
| pending/unsupported | Missing quantity, unresolved applicability/identity, stale result, missing method or unavailable data without an allowed reporting status. |

For permitted no-information output, add a separate typed `ReportingStatusOut` collection rather than weakening all contribution quantities to nullable. A corresponding bounded reviewed manual reporting-status payload carries the slot, rule, method/search basis and evidence. It cannot satisfy a threshold-quantity slot or a nonpermitted reporting rule.

A positive process family becomes `complete` only when every in-scope source linked to its activities has closed scope, required question/fact decisions, valid method outputs and reconciliations. A family may reference an already counted physical source without producing another contribution. `not_present` remains reserved for confirmed annual absence; `unsupported` identifies a missing implementation; unknown evidence is `pending`. G17 can close as complete after an accepted mapping to actual supported/manual sources, not only by answering No.

Two-pass slot expansion avoids needless work: first derive threshold and source-balance slots; once criteria are established, derive every required reporting output. Part 1 threshold exclusion does not automatically exclude that material's releases from reporting when the substance is reportable facility-wide. A threshold already proven met with partial lower bounds remains `met`, but source/output completeness and approval remain blocked until the outstanding slots close.

## 3. Quantity identity: stock lineage differs from splits

Keep `allocations` for consumable/fuel splits and `material_flows` for sequential workpiece lineage.

For 1,000 kg of the same stock cut, ground and welded, material assessment has one canonical origin for the legally relevant stock quantity. The three operations reference its lineage; they do not each create another 1,000 kg MPO row. Distinct generated emissions or by-products from cutting, grinding and welding are separate origins and may all contribute. Physical transformation, newly manufactured material and rule-specific assessment treatment need explicit reviewed classification; a universal material-ID deduplication would also be wrong.

For 100 kg of welding wire used by two independent operations, allocations of 60 kg and 40 kg partition the same accepted annual use. Both method calculations use their own shares; the 100 kg parent is not also added as another emission or threshold quantity. Repeated purchase lines, aliases, rework, returned stock and recycled material need traceable origin/partition decisions.

`quantity_origin_key` identifies a physical assessed quantity or emitted/generated amount. `aggregation_key` identifies a destination total such as facility/substance/Part/basis. Many origins may share one aggregation key. One origin can legitimately appear in separate statutory assessments (for example a VOC under Parts 1 and 5), but at most once within an assessment and reporting category. Keep chromium species/total and VOC component/total relationships explicit; neither global deduplication nor adding group totals to their constituents is correct.

Derive `quantity_origin_key` server-side from the canonical immutable source/material-flow lineage, accepted batch/quantity partition, period and quantity role. If a client or staff payload supplies a key, validate it against that derivation. Detect overlaps using the underlying source IDs, lineage, partition quantities and dates, not just key equality. Creating a different key or slot ID for the same physical amount must fail; creating multiple material records for the same imported purchase/source likewise requires explicit alias/reconciliation treatment. The reviewed lineage decision establishes identity where evidence requires interpretation, but an arbitrary label cannot establish independent quantities.

## 4. Reconciliation without invented universal balances

Add a small `ReconciliationSpec` union implemented with existing `balances.py`: material-use split, sequential stock loss, control/output routing, shared waste generation/storage/shipping, water recirculation/purge/sludge, and outlet air-total reconciliation. Each names input/output slot or fact IDs, mass/volume/constituent basis, period, method/rule version, and any supported conversion and tolerance. It is not a user-authored equation.

Control reconciliation distinguishes capture, removal, fugitive release, outlet release, bypass, operating segments and collected residue. Indoor recirculation cannot be assumed to be zero environmental release. A collected dust quantity is not also counted as an atmospheric release. Gross waste mass cannot satisfy constituent-mass slots without accepted composition or measurement. Generation into a shared drum plus the drum's final shipment are internal transfer and final output, not two disposal contributions. Storage changes and retained residues remain visible.

Water recycling is an internal flow; purge to sewer, direct discharge, sludge and retained inventory are separate destinations. Stack totals must reconcile with facility air releases and residual non-stack/fugitive amounts. Required stack geometry and eligibility decisions follow the actual regulatory branch.

Tolerance belongs to the method, measurement basis and uncertainty evidence. Exact synthetic Decimal balances use zero tolerance; real measurements may use a justified, reviewed method-specific tolerance. Do not introduce a global 1%, 5%, or rounding tolerance. Chemistry can add oxygen or otherwise change mass basis; do not require gross feedstock mass to equal all chemical outputs without an applicable balance model. Unexplained residuals remain blocking, not automatically assigned to air or waste.

## 5. One facility aggregation stage for all rule families

Create `app/services/npri_v0/aggregation.py` as a bounded adapter from accepted contributions and scope coverage into existing `ThresholdContribution` helpers. Give each assessment its actual contributing/excluded/pending origins, exact Decimal basis/unit and derived `contribution_set_complete`. Never hardcode completeness true or false.

| Family | Closure obligations |
|---|---|
| Part 1A | Facility category and employee/exception branch; candidate identities/qualifiers; canonical MPO and other applicable source kinds; concentration treatment; threshold; all required release/disposal/recycling outputs when met. |
| Part 1B | Same structure with row-specific thresholds, concentration, group membership and special overrides from the released registry. |
| Part 1C | Separate assessments for each listed PFAS; no combined PFAS threshold; unresolved product/domain composition blocks the relevant scope. |
| Part 2 | Named process/source eligibility and employee/exception branch; aggregate listed PAH trigger with correctly scoped incidental/tailings outputs; independent creosote branch; individual/unspeciated reporting without double counting. |
| Part 3 | Exact named activity and applicable employee branch; no invented mass trigger; known congener/TEQ/HCB reporting or permitted typed no-information status; source/activity exclusions retained. |
| Part 4 | `resolve_part45_case` source scope, CAC air aggregation and applicable special branches; supported external-combustion exemption uses complete equipment/fuel/source evidence; threshold source set may differ from report output source set. |
| Part 5 | Per-identity/group air aggregation and distinct applicability/source-scope/exemption logic; overlap rules and special benzene branches; do not require total VOC threshold as a universal prerequisite. |

Employee-hours logic is per Part, never one shared eligibility boolean. Distinguish known low hours from unresolved categories. Evaluate parts even when another Part is not applicable. Facility-family coverage is `complete` when all required assessments and output obligations close, or `not_present` only through a valid applicable-scope N/A determination. An applicable family with all thresholds not met is **complete**, not absent. No source may escape because its method produced no row.

Use `rules.py`, `identity.py`, `composition.py`, `thresholds.py` and `facility_cases.py` as authoritative code/data adapters. Existing `_build_part1_material_assessments` and `_build_arc_e310_outputs` should emit normalized rows/issues; move their final assessments into the one aggregation stage. Connect blasting, thermal cutting, named eligible welding, solvent/coating balances and external combustion through the same interface as they are promoted. Stationary engines and specialist P01–P28 branches use scoped, evidenced manual calculations until their exact automatic variants are released. This closure work does not waive the common automatic-module deliverables or any C4 gate in the implementation plan.

## 6. Filing fields and annual actions are independent gates

Replace `filing_fields.py`'s unconditional `pending_review` with deterministic validation. Keep the JSON mapping as a declarative list of field IDs, source locators, allowed values and **named** applicability/validator IDs. Implement those IDs as ordinary Python functions; do not evaluate arbitrary predicate strings. Unknown applicability is a blocker. Results are `valid|invalid|unknown|not_applicable` with field paths and requirement IDs.

Validate structured facility/owner/operator/parent identifiers and contacts, annual coverage and schedule, prior filing, ownership changes, shutdowns, prevention fields and all conditional substance/destination/recipient/water/stack/monthly/change-reason records. An existing nonempty collection does not validate its members. Quantity reporting units and method/basis must match the family map. Missing schema fields must be added explicitly, not hidden in a free-text note. Metadata validation runs in the real evaluator and again from the frozen package before approval. Certification evidence and actual receipts are lifecycle-stage requirements, not prerequisites that would make initial evaluation impossible.

Replace selection of `workflow_resolutions[-1]` with an `AnnualActionPlanOut` set. Each action has stable `action_id`, type, scope, required status, predicate/rule, accepted resolution and reason. Permit compatible actions together, such as ownership notification plus substance report. Reject incompatible same-scope actions. Derive minimum required actions from completed assessments, prior history and ownership facts; staff can add a justified voluntary action, not remove an obligatory one.

Extend existing workflow resolutions with `action_id` and scope; `_resolution_slot` keys on action rather than the whole annual workflow. Filing events reference approved action IDs and validate action type/scope, frozen revision, date and evidence. The first recorded filing does not make the revision terminal when other actions remain. Derive statuses `certified`, `partially_recorded`, `completed` from the action set, with `filed` reserved for a completed actual filing path if compatibility requires that label. A `no_filing_determination` is completed by an evidenced internal determination event and must not require or invent a government receipt. Actual external actions require their own references/evidence. Completion freezes the evidence for every action, not just the most recent event.

## 7. Freshness and authoritative readiness

Use existing version checks, row locks, immutable accepted resolutions and manifests. Source inventory must depend on the full relevant collections, annual screens/G17, facility boundary, period and upstream candidate set, so newly added entities invalidate it. Each source scope binds its source entities, linked materials/composition, flow/control/outlet/stream records, accepted facts and method/rule/output-catalogue versions. Evidence additions only affect decisions actually using that content, unless they change the accepted scope.

The present dependency implementation hashes inputs/evidence/upstream records but not accepted resolution identities. Add a narrowly typed `accepted_resolution` dependency for downstream source/slot/output decisions. Resolve it only to a current accepted, nonsuperseded record, including immutable payload and dependency digest; reject cycles and forward references. This is a fixed decision chain, not a general dependency graph product. Replacing an accepted composition, scope or inclusion decision must stale its downstream outputs even when raw client inputs do not change. Source-inventory payloads list stable scope keys, not downstream accepted-resolution digests, to avoid an inventory/scope cycle. Include current accepted resolution identity/version in the full run manifest as today.

At evaluate, review request, revision creation/approval, certification and each annual action, rebuild and compare current source/rule/method/evidence manifest. Do not accept the stored run's green booleans after a source change. Recheck server gates transactionally; preserve immutable historical revisions and content. A previously filed history remains history while current changes require a new revision/action plan.

### Frozen calculation data and replay

Extend `FrozenManifest` with `engine_contract_version`, `engine_artifact_digest` and a typed `catalogue_snapshot`. Its bounded bundle contains schema/year/ruleset identifiers; source documents with edition, locator, digest and retained content reference; complete substance rules with exact Decimal values and raw statutory threshold text; rule constants for facility/employee/activity/source-scope/stack branches; method identity/version/implementation key, eligibility, required inputs and declared outputs; exact factor values or explicit nulls, units, basis, selectors and source rows; identity/group membership and conversions; and the filing-field map. Freeze the full small 2026 catalogues for v0, including records needed to establish negative scope, rather than retaining only positive factors used by a run.

Hash the actual bundle canonically and incorporate it into the source digest. All references must resolve within that frozen bundle with compatible year/version. The evaluator, metadata builder and export builder consume an immutable in-memory view of these records; they must not reload current repository catalogues during replay. A hash or prose factor name alone is not a reproducible snapshot.

Python formulas still require their exact versioned implementation. Preserve a supported engine-version dispatch and retained release artifact/source digest; do not pretend frozen coefficients can reproduce arbitrarily changed code. A missing historical implementation yields an explicit unsupported-replay result, never a fallback to today's engine. Test replay after repository loaders are changed or made to raise: old calculation/data/export content stays stable with its supported historical implementation, while a new evaluation has the changed catalogue digest and invalidates current approval. Ignore only newly generated transport identifiers/timestamps in deterministic replay comparison; original frozen run/export identities remain unchanged.

`can_request_review` means no blocking client tasks; visible JADA tasks may remain. `can_approve` requires complete discovery/source/output/reconciliation/family/action-plan/metadata results and no blocking requirements. For compatibility, pure evaluation `can_file` means calculation/package eligibility only and equals `can_approve`; it does not authorize a filing event. `allowed_actions` from the service additionally requires current approved revision, certification, appropriate actor and an outstanding approved action. UI labels must not imply approval or filing before those lifecycle stages. Keep the pending adapter always blocked.

## 8. Bounded implementation slices

Backend owns schema and catalogue contract before frontend implementation. Coordinate shared-file edits explicitly.

| Slice | Exact application surfaces | Deliverable |
|---|---|---|
| A — Contract and freshness | `app/schemas/workspace.py`; `app/services/workspace/service.py` resolution proposal/review/dependency/slot functions; `digests.py`; catalogue DTO/registry | New typed inventories/scopes/slots/statuses/action IDs, reference authorization, independent review, supersession, required dependencies and frozen manifests. Tests in schema/digest/API suites. |
| B — Pure source closure | New `app/services/npri_v0/coverage.py`; `evaluator.py`; `balances.py` adapters | Derive minimum inventory/candidates/slots; validate assignments/aliases/periods, source coverage, unknowns and reconciliations. No DB or I/O in engine. |
| C — Aggregation and method adapters | New `aggregation.py`; `evaluator.py` builders; `thresholds.py`, `facility_cases.py`, `identity.py`, `composition.py`, `methods.py` only as needed | Uniform outputs; all seven family closures; complete-set derivation; common automatic integrations retained; manual parity. Remove method-local facility sums. |
| D — Metadata and actions | `app/services/workspace/filing_fields.py`, `filing_fields_2026.json`; service revision/certify/file/status functions; API DTOs | Real conditional metadata validation, multiple action plan, per-action events and completion; no-filing internal completion; safe frozen exports. |
| E — UI | `src/lib/workspace-api.ts`, `src/components/workspace/model.ts`, `lifecycle.ts`, `src/routes/_client.workspace.tsx`, `src/routes/admin.workspace.tsx`, package export component | Client source links and reconciliation tasks; staff named-source scope/candidate/expected-output review, method/manual editor, slot results and precise blockers; filing field errors/action checklist; persisted forms and server-driven allowed actions. |
| F — Integration proof | `tests/test_npri_v0_evaluator.py`, methods/thresholds/balances/identity suites, `tests/test_workspace_api.py`; synthetic seed and browser workflow | Full real-evaluator positive package, negative mutations, retained evidence/export tests and C1–C12 ledger. Never monkeypatch the evaluator to readiness=true in the acceptance proof. |

The UI should show human source/material/stream names and explain missing facts; clients do not enter scope JSON, registry IDs, coefficients or regulatory family declarations. Staff see a finite checklist of derived outputs with sources and candidate exclusions, not a single “mark complete” action. Existing forms and APIs remain the persistence boundary.

## 9. Gating tests and removal of the global gate

Keep the global engine gate during implementation. Remove it in the evaluator and `_apply_engine_incomplete_gate` together only after the following are demonstrated and recorded:

1. Real frozen 2026 mixed facility: welding, cutting, blasting, coating, cleaning solvent, heater and stationary engine; shared stock, consumable splits, collector/waste, water purge/sludge, manual specialist output, all seven rule-family decisions, full metadata and at least one compatible multi-action plan. Its complete evaluator result has no unexplained blockers and correct independently derived totals. Include a separate positive Part 3 case exercising permitted no-information reporting.
2. Real API lifecycle using the real evaluator and two staff identities: evaluate → client handoff → return/correct → fresh revision → independent approval → certification → first action → remaining action → completed history. Every export contains the frozen source/slot/assessment/metadata/action trace. No-filing completion has no fabricated external reference.
3. Omission/mutation suite: drop any minimum candidate or expected slot; add an undisclosed source; leave PFAS/domain unknown; conflict a process screen; omit a stream or outlet; change a source decision while raw input is unchanged; remove evidence; change upstream records through original APIs; change a rule/method version. Each produces targeted blockers and rejects stale approval/filing.
4. Quantity suite: same stock sequentially worked counts once for its assessment; consumable splits reconcile; distinct emissions remain additive; duplicate aliases and automatic/manual overlap block; shared waste is counted once; chromium and VOC groups aggregate correctly within each family; met partial lower bound does not approve incomplete reporting; below/equal/above and straddling ranges use exact Decimal comparisons.
5. Destination suite: capture versus removal and bypass; indoor versus outdoor routes; constituent versus gross waste; generation/storage/shipping; recirculation/purge/sludge; stack/source disagreement; method-specific tolerance acceptance and unexplained residual rejection.
6. Regulatory/metadata suite: per-Part employee/facility branches, Part 2 aggregate/individual distinction, positive/negative Part 3 activity, separate PFAS identities, Part 4/5 source-scope/exemption cases, zero required outputs, required recipients/water/stack/monthly fields, prior-reporter and ownership actions. The unconnected adapter still cannot approve/file.
7. C1–C12 remain individually evidenced: released source/method manifests and common automatic variants; all 28 discovery/manual paths; migration and tenant/security regression checks; frontend build/lint and desktop/mobile client/staff journeys; reproducible synthetic seed/start/test instructions. A narrow all-manual green fixture is necessary evidence of manual support but not a substitute for C4 or C7.

After these pass, replace the blanket gate with an engine contract/version check and case-specific developer requirements for unsupported methods/rules. Unknown engine/contract versions fail closed. Set an actual released engine version on runs instead of `pending-threshold-method-integration-v1`. The service should validate required result coverage and metadata structures and trust only the registered real evaluator, not require that an incomplete-engine requirement always exist. Negative cases must continue failing after gate removal.

## Review evidence and limits

Read root/application instructions, implementation and regulatory plans, current evaluator/schema/service, threshold/facility helpers, filing map, digest code and frontend file inventory. Ran `python3 scripts/bootstrap.py --check` from the original workspace: both original application checkouts reported existing `main`, clean and unchanged. No application code was edited, no database or private client material was accessed, and no tests were run for this design. Numerical/source promotion, all implementation checks and practitioner review remain explicit implementation/release gates.
