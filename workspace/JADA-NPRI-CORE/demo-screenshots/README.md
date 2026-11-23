# NPRI Core demo screenshots

Screenshots of the local demo (synthetic "North Bay fabrication shop", made-up data only).
Taken headlessly with the demo reviewer account. No client data.

## 2026-11-17-f1-first-version
First version of the admin case summary (commit F1). Kept for before/after comparison.

## 2026-11-17-f1b-demo-ready
Readable version (backend d94ff12, frontend 0fb6b03).

| File | What it shows |
|---|---|
| 01-summary-top | Case summary header: decision counts, open-item groups, run info |
| 02-summary-full-page | The whole summary page in one image |
| 03-run-technical-details-open | Run versions with technical details expanded |
| 04-threshold-decisions | Threshold decisions table (metals: decision open) |
| 05-part3-dioxins-row | Part 3 collapsed to one row (none of the 18 activities) |
| 06-trace-pm10(-full) | PM10 calculation: 1,200 kg × 3.2 g/kg = 3.84 kg, workbook cell D40 |
| 07-trace-chromium(-full) | Chromium calculation steps (cutting time × factor × composition) |
| 08-trace-hexavalent-chromium(-full) | Cr(VI) calculation, including "not estimated by method" for cutting |
| 09-trace-total-particulate | Total particulate matter trace |
| 10-trace-pfas | PFAS (Part 1C): not robust until the product review is done |
| 11-open-items-client / 12-open-items-jada | Open items grouped by who acts |
| 13-holds-defaults-coverage | Practitioner holds, defaults used, coverage gaps |
| 14/15-client-questions | Client question screen (Q1–Q18 examples) |
| 16-examples-tab-* | Control gallery tab |
| 20/21-mobile-summary | Summary at phone width (375px) |
| 22-mobile-trace-pm10 | PM10 trace on a phone |
| 23-mobile-client-questions | Client questions on a phone |

## 2026-11-17-f2-workbook
Calculation workbook (backend cea3d2e, frontend 1437762), including a full live edit:
GMAW wire 1,200 → 2,000 kg, then the second-staff review, then the reset.

| File | What it shows |
|---|---|
| 30 / 31-* | Workbook tabs: welding, cutting, spraying |
| 32-workbook-cell-history | Activity history panel |
| 33 / 34 | Edit form, empty and filled (2,000 kg + reason) |
| 35-after-save | Right after saving: source needs re-confirmation, totals temporarily drop (95.64 → 91.8 kg) |
| 36 / 37 | Re-confirming the source as in scope, then awaiting independent review |
| 38 / 39 | Second staff account opens the review dialog |
| 40-after-review-accepted | After the second person accepts |
| 41-comparison-original-vs-edited-full | Before/after totals: PM10 95.64 → 98.2 kg (+2.56 kg = 800 kg × 3.2 g/kg) |
| 42-after-reset-workbook | After the guarded reset: back to 1,200 kg |
| 43-summary-top-sorted | Summary sorted by importance (PM2.5 23%, PM10 19% first) |
| 44-mobile-summary-cards-full | Summary at phone width as cards |
| 45-mobile-workbook | Workbook at phone width |

## 2026-11-17-f2b-live-edit
Demo-ready live edit (backend 738467f, frontend 3fae4a6). One account, one edit, totals update at once.

| File | What it shows |
|---|---|
| 50 / 51-workbook-grid-* | Workbook as a grid: inputs, where each came from, per-activity PM10, chromium, nickel, manganese, totals |
| 52 / 52b / 53 | Click the kg cell, type 2,000, give a reason |
| 54 / 55-after-save | Immediately after saving: row shows 6.4 kg PM10; comparison PM10 95.64 → 98.2 kg (+2.56 kg) |
| 56-cell-history-after-edit | The change in the cell history |
| 57 / 58-summary | Case summary after the edit (edit listed as awaiting second check) |
| 59 / 60 | Optional: second staff member confirms the edit |
| 61-after-reset | After reset: back to 1,200 kg |
| 62-mobile-workbook-cards | Phone layout keeps cards |

## 2026-11-17-edmonton-test
The user's own test submission ("Edmonton Coating Plants"), connected to the NPRI engine by hand in
the demo database for testing (year changed 2025 → 2026; facility answers and two welding wires mapped
as staff edits with notes). Numbers show Unknown until a JADA reviewer accepts the facility answers.

| File | What it shows |
|---|---|
| 1-summary-top / 1-summary-full | Case summary after the run: page loads, open items listed, values Unknown |
| 2-workbook-top / 2-workbook-full | Workbook: Lincoln MC-6 (2,079.93 kg, Other GMAW) and Arctec FC171 (27.22 kg, Other FCAW) |
