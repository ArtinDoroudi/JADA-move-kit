# 2025–2027 NPRI workbook crosscheck

Read-only reconciliation of the copied 2026 JSON registry to the supplied official workbook. No source or JSON values were changed.

## Inputs and coverage

- Workbook: `2025-2027 NPRI Substance List_Liste des substances INRP 2025-2027 (10-04-2026) (1).xlsx`; sheet `2025-2027`; SHA-256 `3f59b956b92c0040b86ce579cd8268acec345042ac290ff3b9f8eb97126e2dd8`.
- JSON: `content/regulation/notice_2025_2027/substances_2026.json`; declared source SHA-256 `3f59b956b92c0040b86ce579cd8268acec345042ac290ff3b9f8eb97126e2dd8`; copied JSON SHA-256 `127967fdde1d59f46f5eb706d185d4a5e1b5b068dfcc5160def27f2cb9148e8d`; corrections are loaded from the JSON file's sibling `corrections.yaml` when present.
- Workbook records: 493; JSON records: 493.
- Reproduce from the backend root with `python scripts/crosscheck_npri_regulation.py --workbook PATH`; `openpyxl==3.1.5` is pinned in `requirements-npri.txt`. Exit status is nonzero for unexplained findings.
- Workbook bilingual layout: EN identity/part in C/D and FR identity/part in M/N; one row supplies the EN and FR values.
- Key: `(part, normalized identity)`; matching does not use workbook/JSON row positions. CAS is whitespace-normalized; NPRI identifiers are uppercased and `NA - n` spacing is canonicalized. Names/threshold text use Unicode NFKC plus collapsed whitespace; punctuation, accents, note numerals and wording remain significant.
- Numeric thresholds parse the leading quantity and mass unit independently from EN and FR source text. `tonnes` is converted to kg and `grams` to 0.001 kg for the derived `threshold_kg` comparison. `n/a` and French `s. o.` are treated as nonnumeric/null for concentration. Reporting unit vocabulary normalizes English/French kilogram, tonne and gram forms; `grams TEQ` and `grammes ET` are treated as equivalent labels for the same TEQ unit. Qualitative source threshold text is compared verbatim after whitespace normalization. The JSON's internal `threshold_kind` taxonomy has no equivalent workbook column and is not inferred from source prose.
- Workbook Notes sheet (rows 8–42) supplies numbered substance qualifiers. Numeric superscript references are read from English and French rich-text name runs. JSON group-member CAS values are compared with CAS RN values explicitly present in referenced notes; explicitly excluded CAS values are reported and checked separately. Footnotes with no explicit CAS do not independently establish a member list.

### Counts by part

| Part | Workbook | JSON |
|---|---:|---:|
| 1A | 177 | 177 |
| 1B | 33 | 33 |
| 1C | 163 | 163 |
| 2 | 32 | 32 |
| 3 | 19 | 19 |
| 4 | 7 | 7 |
| 5 | 62 | 62 |

### Identity+part coverage

| Check | Count |
|---|---:|
| matched identity+part keys | 493 |
| missing JSON keys | 0 |
| extra JSON keys | 0 |
| duplicate workbook keys | 0 |
| duplicate JSON keys | 0 |

## Mismatch counts by type

| Type | Count |
|---|---:|
| identity | 0 |
| identity_kind | 0 |
| part | 0 |
| bilingual_identity | 0 |
| bilingual_part | 0 |
| name_en | 0 |
| name_fr | 0 |
| threshold_text_en | 0 |
| threshold_text_fr | 0 |
| threshold_value | 0 |
| threshold_unit | 0 |
| threshold_value_fr | 0 |
| threshold_unit_fr | 0 |
| threshold_kg | 0 |
| concentration_en | 0 |
| concentration_fr | 0 |
| reporting_unit_en | 0 |
| reporting_unit_fr | 1 |
| flag_voc | 0 |
| flag_pah | 0 |
| flag_pfas | 0 |
| qualifier_note_numbers | 0 |
| qualifier_note_text | 0 |
| group_member_cas | 0 |
| excluded_cas | 0 |
| group_excluded_cas | 0 |
| missing_json | 0 |
| extra_json | 0 |
| duplicate_workbook | 0 |
| duplicate_json | 0 |

Total mismatch findings: **1**. Counts are finding counts, so one record can have multiple findings.

## Findings

### reporting_unit_fr (1)

- Excel row 201 (B201, C201, D201, L201, M201, N201) / JSON part1B:569-64-2: copied `kilograms`; workbook `tonnes (EN source unit: kilograms; FR source unit: tonnes)`.

## Workbook note-markup observation

Records where EN/FR superscript formatting differs: 1. This source-workbook formatting observation is not counted as a JSON content mismatch; the JSON note references use the superscripted language cell.

- Excel row 426 (B426, C426, D426, L426, M426, N426) / JSON part4:NA - M10: EN superscript refs: ∅; FR superscript refs: 25, 26.

## Group CAS inventory

Records with nonempty JSON `group_member_cas_rns`: 19; listed CAS values: 235.

- `part1A:NA - 16` (row 11): `14798-03-9, 7664-41-7`
- `part1A:1319-77-3` (row 54): `106-44-5, 108-39-4, 95-48-7`
- `part1A:41834-16-6` (row 96): `354-12-1, 354-15-4, 354-21-2`
- `part1A:34077-87-7` (row 97): `306-83-2, 354-23-4, 812-04-4, 90454-18-5`
- `part1A:63938-10-3` (row 98): `2837-89-0, 354-25-6, 374-07-2, 76-14-2`
- `part1A:NA - 21` (row 141): `140-66-9, 1806-26-4, 27193-28-8, 68987-90-6, 9002-93-1, 9036-19-5`
- `part1A:NA - M14` (row 167): `463-58-1, 624-92-0, 74-93-1, 75-15-0, 75-18-3, 7783-06-4`
- `part1A:1330-20-7` (row 177): `106-42-3, 108-38-3, 95-47-6`
- `part1B:NA - 46` (row 181): `12222-69-4, 16889-10-4, 20721-50-0, 21811-64-3, 2581-69-3, 27184-69-6, 2734-52-3, 2832-40-8, 2872-52-8, 31464-38-7, 31482-56-1, 3179-89-3, 3180-81-2, 40880-51-1, 43047-20-7, 4314-14-1, 6054-48-4, 6250-23-3, 6253-10-7, 6300-37-4, 6439-53-8, 65122-05-6, 6657-00-7, 69472-19-1, 730-40-5, 83249-52-9, 842-07-9`
- `part1B:NA - 50` (row 186): `102-77-2, 117920-00-0, 120-78-5, 149-30-4, 155-04-4, 21564-17-0, 22405-83-0, 2492-26-4, 32510-27-3, 3741-80-8, 38456-45-0, 4979-32-2, 65605-47-2, 65605-48-3, 68911-68-2, 7778-70-3, 95-29-4, 95-31-8, 95-32-9, 95-33-0`
- `part1B:NA - 39` (row 190): `106232-85-3`
- `part1B:NA - 38` (row 191): `85535-85-9`
- `part1B:NA - 49` (row 194): `13601-19-9, 13746-66-2, 13943-58-3, 13967-50-5, 14038-43-8, 143-33-9, 25869-00-5, 25869-98-1, 506-61-6`
- `part1B:NA - 48` (row 200): `10460-00-1, 1078712-76-1, 111-86-4, 112-18-5, 112-69-6, 112-75-4, 112-90-3, 112-99-2, 1120-24-7, 124-22-1, 124-28-7, 124-30-1, 125328-36-1, 125328-37-2, 125328-38-3, 125328-39-4, 125328-41-8, 125328-42-9, 125328-43-0, 125328-44-1, 125328-45-2, 125328-46-3, 13281-06-6, 143-27-1, 14676-61-0, 1613-17-8, 1838-08-0, 1920-05-4, 19855-61-9, 2016-56-0, 2016-57-1, 2190-04-7, 22020-14-0, 22023-23-0, 24287-35-2, 25324-14-5, 28061-69-0, 28701-67-9, 29317-52-0, 3007-31-6, 30113-45-2, 40165-68-2, 4455-26-9, 50291-24-2, 5538-95-4, 61788-45-2, 61788-46-3, 61788-62-3, 61788-63-4, 61788-91-8, 61788-93-0, 61788-95-2, 61789-76-2, 61789-79-5, 61790-18-9, 61790-33-8, 61790-57-6, 61790-59-8, 61790-60-1, 61791-55-7, 65059-85-0, 67700-98-5, 67700-99-6, 68037-91-2, 68037-92-3, 68037-95-6, 68037-98-9, 68130-68-7, 68155-38-4, 68439-70-3, 68479-04-9, 68513-50-8, 68603-64-5, 68603-65-6, 68610-26-4, 68610-68-4, 68783-23-3, 68783-24-4, 68783-25-5, 68784-38-3, 68814-69-7, 68855-63-0, 68909-95-5, 68955-53-3, 68955-54-4, 71011-01-3, 71011-03-5, 7173-62-8, 7378-99-6, 7396-58-9, 75444-69-8, 929-73-7`
- `part1B:NA - 20` (row 204): `104-35-8, 104-40-5, 127087-87-0, 1323-65-5, 20427-84-3, 25154-52-3, 26027-38-3, 26523-78-4, 27176-93-8, 27177-05-5, 27177-08-8, 27986-36-3, 28679-13-2, 28987-17-9, 37205-87-1, 37251-69-7, 37340-60-6, 51811-79-1, 51938-25-1, 68081-86-7, 68412-53-3, 68412-54-4, 68515-89-9, 68515-93-5, 7311-27-5, 84852-15-3, 9016-45-9, 9051-57-4`
- `part5:NA - 41` (row 438): `105-46-4, 110-19-0, 123-86-4`
- `part5:NA - 45` (row 471): `107-98-2, 109-59-1, 111-90-0, 112-07-2, 112-15-2, 112-25-4, 112-34-5, 124-17-4, 1569-01-3, 1569-02-4, 2807-30-9, 29911-27-1, 29911-28-2, 34590-94-8, 5131-66-8, 54839-24-6, 623-84-7, 88917-22-0`
- `part5:25551-13-7` (row 489): `108-67-8, 526-73-8`
- `part5:1330-20-7` (row 492): `106-42-3, 108-38-3, 95-47-6`

## Effective correction summary

The effective registry is loaded through `load_substance_registry`; its sibling [corrections.yaml](corrections.yaml) records the evidence and bilingual source quotations. The audit independently reconciles effective values against workbook cells and Notes, including member and excluded CAS separately.

Effective corrections: 15 substance records; full evidence and note text are in `corrections.yaml`.
- `part1A:NA - 17` (Excel row 135): qualifier_note_numbers `[]` → `[10]`; bilingual qualifier text reconciled
- `part1A:NA - 21` (Excel row 141): group_member_cas_rns `[]` → `['140-66-9', '1806-26-4', '27193-28-8', '68987-90-6', '9002-93-1', '9036-19-5']`; qualifier_note_numbers `[]` → `[11]`; bilingual qualifier text reconciled
- `part1A:NA - 22` (Excel row 146): group_member_cas_rns `['7723-14-0']` → `[]`; group_excluded_cas_rns `∅` → `['7723-14-0']`
- `part1B:NA - 46` (Excel row 181): group_member_cas_rns `[]` → `['12222-69-4', '16889-10-4', '20721-50-0', '21811-64-3', '2581-69-3', '27184-69-6', '2734-52-3', '2832-40-8', '2872-52-8', '31464-38-7', '31482-56-1', '3179-89-3', '3180-81-2', '40880-51-1', '43047-20-7', '4314-14-1', '6054-48-4', '6250-23-3', '6253-10-7', '6300-37-4', '6439-53-8', '65122-05-6', '6657-00-7', '69472-19-1', '730-40-5', '83249-52-9', '842-07-9']`; qualifier_note_numbers `[]` → `[16]`; bilingual qualifier text reconciled
- `part1B:2390-60-5` (Excel row 182): group_member_cas_rns `['306-83-2', '354-23-4', '812-04-4', '90454-18-5']` → `[]`; qualifier_note_numbers `[7]` → `[]`; bilingual qualifier text reconciled
- `part1B:548-62-9` (Excel row 183): qualifier_note_numbers `[3]` → `[]`; bilingual qualifier text reconciled
- `part1B:2390-59-2` (Excel row 184): qualifier_note_numbers `[4]` → `[]`; bilingual qualifier text reconciled
- `part1B:NA - 50` (Excel row 186): group_member_cas_rns `[]` → `['102-77-2', '117920-00-0', '120-78-5', '149-30-4', '155-04-4', '21564-17-0', '22405-83-0', '2492-26-4', '32510-27-3', '3741-80-8', '38456-45-0', '4979-32-2', '65605-47-2', '65605-48-3', '68911-68-2', '7778-70-3', '95-29-4', '95-31-8', '95-32-9', '95-33-0']`; qualifier_note_numbers `[]` → `[17]`; bilingual qualifier text reconciled
- `part1B:NA - 49` (Excel row 194): group_member_cas_rns `[]` → `['13601-19-9', '13746-66-2', '13943-58-3', '13967-50-5', '14038-43-8', '143-33-9', '25869-00-5', '25869-98-1', '506-61-6']`; qualifier_note_numbers `[]` → `[20]`; bilingual qualifier text reconciled
- `part1B:NA - 08` (Excel row 199): group_member_cas_rns `['78-00-2']` → `[]`; group_excluded_cas_rns `∅` → `['78-00-2']`; qualifier_exclusions `∅` → `[{'kind': 'alloy', 'materials_en': ['stainless steel', 'brass', 'bronze'], 'source_note_number': 21}]`
- `part1B:NA - 48` (Excel row 200): group_member_cas_rns `[]` → `['10460-00-1', '1078712-76-1', '111-86-4', '112-18-5', '112-69-6', '112-75-4', '112-90-3', '112-99-2', '1120-24-7', '124-22-1', '124-28-7', '124-30-1', '125328-36-1', '125328-37-2', '125328-38-3', '125328-39-4', '125328-41-8', '125328-42-9', '125328-43-0', '125328-44-1', '125328-45-2', '125328-46-3', '13281-06-6', '143-27-1', '14676-61-0', '1613-17-8', '1838-08-0', '1920-05-4', '19855-61-9', '2016-56-0', '2016-57-1', '2190-04-7', '22020-14-0', '22023-23-0', '24287-35-2', '25324-14-5', '28061-69-0', '28701-67-9', '29317-52-0', '3007-31-6', '30113-45-2', '40165-68-2', '4455-26-9', '50291-24-2', '5538-95-4', '61788-45-2', '61788-46-3', '61788-62-3', '61788-63-4', '61788-91-8', '61788-93-0', '61788-95-2', '61789-76-2', '61789-79-5', '61790-18-9', '61790-33-8', '61790-57-6', '61790-59-8', '61790-60-1', '61791-55-7', '65059-85-0', '67700-98-5', '67700-99-6', '68037-91-2', '68037-92-3', '68037-95-6', '68037-98-9', '68130-68-7', '68155-38-4', '68439-70-3', '68479-04-9', '68513-50-8', '68603-64-5', '68603-65-6', '68610-26-4', '68610-68-4', '68783-23-3', '68783-24-4', '68783-25-5', '68784-38-3', '68814-69-7', '68855-63-0', '68909-95-5', '68955-53-3', '68955-54-4', '71011-01-3', '71011-03-5', '7173-62-8', '7378-99-6', '7396-58-9', '75444-69-8', '929-73-7']`; qualifier_note_numbers `[]` → `[22]`; bilingual qualifier text reconciled
- `part1B:NA - 20` (Excel row 204): group_member_cas_rns `[]` → `['104-35-8', '104-40-5', '127087-87-0', '1323-65-5', '20427-84-3', '25154-52-3', '26027-38-3', '26523-78-4', '27176-93-8', '27177-05-5', '27177-08-8', '27986-36-3', '28679-13-2', '28987-17-9', '37205-87-1', '37251-69-7', '37340-60-6', '51811-79-1', '51938-25-1', '68081-86-7', '68412-53-3', '68412-54-4', '68515-89-9', '68515-93-5', '7311-27-5', '84852-15-3', '9016-45-9', '9051-57-4']`; qualifier_note_numbers `[]` → `[23]`; bilingual qualifier text reconciled
- `part5:NA - 41` (Excel row 438): group_member_cas_rns `['105-46-4', '110-19-0', '123-86-4', '540-88-5']` → `['105-46-4', '110-19-0', '123-86-4']`; group_excluded_cas_rns `∅` → `['540-88-5']`
- `part5:NA - 32` (Excel row 455): group_member_cas_rns `['110-54-3']` → `[]`; group_excluded_cas_rns `∅` → `['110-54-3']`
- `part5:25551-13-7` (Excel row 489): group_member_cas_rns `['108-67-8', '526-73-8', '95-63-6']` → `['108-67-8', '526-73-8']`; group_excluded_cas_rns `∅` → `['95-63-6']`

Explicit exclusion records: 5.
- `part1A:NA - 22` (Excel row 146): excluded CAS `7723-14-0`
- `part1B:NA - 08` (Excel row 199): excluded CAS `78-00-2`
  - Structured alloy exclusion: stainless steel, brass, bronze; source note 21
- `part5:NA - 41` (Excel row 438): excluded CAS `540-88-5`
- `part5:NA - 32` (Excel row 455): excluded CAS `110-54-3`
- `part5:25551-13-7` (Excel row 489): excluded CAS `95-63-6`

## Explicitly unresolved source conflicts

The following exact bilingual workbook discrepancy is retained as an open source conflict; it is never blanket-ignored:

- Excel row 201 (B201, C201, D201, L201, M201, N201) / JSON part1B:569-64-2: JSON `kilograms`; workbook `tonnes (EN source unit: kilograms; FR source unit: tonnes)`.

Unexplained finding count: **0**.
