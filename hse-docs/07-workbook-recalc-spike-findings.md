# S01 workbook recalculation spike

Status: bounded technical spike only. This does not import the full workbook, establish parity for every factor row, or approve any emissions method for production.

## Result

Pycel 1.0b30 recalculates the official ECCC workbook on Python 3.13.3 from an input-modified temporary copy. The script reads the workbook's Part 1 substance summary and Part 4 particulate summaries after recalculation. It handles the Method 2 `SUMPRODUCT` array formulas in the tested branch.

The workbook source is `../../../../JADA-SOLUTIONS/documents/guidelines/official/Electric Arc Welding, Cutting and Spraying Calculator_2022_10_26.xlsx`. SHA256 before the spike and after the 20-case run was:

```text
4c3e6f6a0fc1acd8038ab5ccd6e82cf65cd65e5d6bc69a7372b0a2a23dddaa93
```

Each case gets a new temporary copy. The source file is opened read-only for class labels and copied before any input changes. Inputs are written to the copy, Pycel recalculates from formulas, and output values are read from Pycel. The source hash is checked again before returning. The 20 distinct inputs are in [cases.json](cases.json); literal factors and arithmetic notes are embedded there and exercised by [test_spike.py](test_spike.py).

## Input mapping

Inputs used by the spike are these workbook cells:

| Input | Workbook cells | Interpretation |
|---|---|---|
| Arc welding method questions | `Input Arc Welding Information!C4:C6` | Yes/No responses and Method 1 or Method 2 selection |
| Named welding material usage | `Input Arc Welding Information!C11:C69` | Annual kg at the row selected by process family and exact material label |
| Method 2 material and usage | `Input Arc Welding (Method 2)!A7`, `C7` | Method label and annual kg for the tested single Table B row |
| Method 2 composition | `Input Arc Welding (Method 2)!D7:L7` | Chromium, cobalt, nickel, manganese, lead, zinc, copper, silver, antimony mass fractions, in that order |
| Cutting method and active time | `Input Cutting Information!A6:A13`, `B6:B13` | Exact process label and annual active hours; the script does not convert kg to hours |
| Cutting composition | `Input Cutting Information!C6:K13` | The nine element fractions in the order listed above |
| Spraying method and material mass | `Input Spraying Information !A6:A11`, `B6:B11` | Exact process label and annual kg sprayed |
| Spraying composition | `Input Spraying Information !C6:K11` | The nine element fractions in the order listed above |

The script clears or initializes these activity-input ranges before every case so a template value cannot leak into a result: `Input Arc Welding Information!C4:C6` is initialized to No/No/Method 1; `C11:C69` is set to numeric zero; Method 2 `A7:B106` is blanked and `C7:L106` set to numeric zero; cutting `B6:K13` and spraying `B6:K11` are set to numeric zero. The selected row is then overwritten with that case's explicit values. Every supplied composition must contain all nine element keys; missing or unknown values fail validation instead of becoming zero.

`process` selects one of welding, cutting, or spraying. `class` must exactly match a workbook row label. Welding additionally requires `welding_process` and an explicit `method`. `kg` is accepted for welding and spraying; cutting rejects it and requires `actual_time_hours` plus composition. Control efficiency is mandatory for every case.

The corpus covers four concrete formula paths with literal independent factors: SMAW E308 Method 1, SMAW Other Method 2, Oxy1 cutting and Plasma Spray. In the cutting path, Part 1 releases use `S19`, `S28`, `S37`, `S46`, `S55`, `S64`, `S73`, `S82`, `S91` and `S100` for chromium through antimony. The workbook's CrVI cutting input is `NA`, and `S55` uses `IFERROR(...,0)`. The resulting zero reproduces this workbook fallback; it is not confirmation that chromium VI is absent or that zero is a valid regulatory conclusion.

## Output mapping

The script returns all 13 numeric workbook summary outputs, including zeros. The first 10 are kilograms from `Part 1 Releases`; the last 3 are tonnes from `Part 4 Releases`.

| Sheet cell | Workbook label | Unit |
|---|---|---|
| `Part 1 Releases!B5` | Chromium and its compounds | kg |
| `Part 1 Releases!B6` | Cobalt and its compounds | kg |
| `Part 1 Releases!B7` | Nickel and its compounds | kg |
| `Part 1 Releases!B8` | Manganese and its compounds | kg |
| `Part 1 Releases!B9` | Hexavalent Chromium compounds | kg |
| `Part 1 Releases!B10` | Lead and its compounds (except tetraethyl lead) | kg |
| `Part 1 Releases!B12` | Zinc and its compounds | kg |
| `Part 1 Releases!B13` | Copper (and its compounds) | kg |
| `Part 1 Releases!B14` | Silver (and its compounds) | kg |
| `Part 1 Releases!B15` | Antimony (and its compounds) | kg |
| `Part 4 Releases!B5` | Particulate Matter less than or equal to 10 µm (PM10) | tonnes |
| `Part 4 Releases!B6` | Total Particulate Matter (TPM) | tonnes |
| `Part 4 Releases!B7` | Particulate Matter less than or equal to 2.5 µm (PM2.5) | tonnes |

The script fails on an error, text, Boolean, or non-finite value in any summary output. It never converts a workbook error to zero.

## Control efficiency

The workbook says at `Instructions!A63:A64` that controlled emissions equal uncontrolled emissions multiplied by `(100 - control efficiency) / 100`. It has no control-efficiency input cells. The script returns raw workbook output and a separate controlled result after applying that documented multiplier. It does not write control values into an invented workbook cell. A 100% control case produces exact numeric zeros; a 0% case returns the raw value unchanged.

## Formula engine compatibility

The primary engine is pinned to `pycel==1.0b30`. A bounded Method 2 probe wrote one `Other SMAW` row (10 kg, 12% chromium) to a temporary copy. Pycel recalculated `Input Arc Welding (Method 2)!R8` to 0.12 and `Part 1 Releases!B5` to 0.006876 kg. The hand arithmetic is `D40 = 20 × 0.2865 × 0.12 = 0.6876 g/kg`, then `0.6876 × 10 / 1000 = 0.006876 kg`. `D284 = 20 × 0.2865 × 0.63 × 0.12 = 0.433188 g/kg`, yielding 0.00433188 kg of hexavalent chromium compounds. The Method 2 Part 4 factors are 20 g/kg for PM10 and TPM, with PM2.5 at 75% of PM10.

`formulas==1.3.2` was also probed. Its workbook calculation returned zero for Method 2 `R8` on the same composition input, so it is not the runtime engine. Pycel did recalculate that array formula correctly. The source formula functions observed on tested paths are `IF`, `SUMIF`, `OR`, `SUM`, `NOT`, `SUMPRODUCT`, `AND` and `IFERROR`; no unsupported function was observed in those paths. This is a bounded path result, not an exhaustive function-coverage claim for every workbook cell.

Openpyxl emits a warning while saving the temporary copy: its reader does not preserve the workbook's conditional-formatting extension. The source workbook is untouched. This spike evaluates numeric workbook formulas only; it makes no claim that a saved copy preserves visual or non-calculation workbook features.

## Verification and boundaries

- Setup from `backend/`: `python3.13 -m venv spikes/s01_workbook_recalc/.venv`, then `spikes/s01_workbook_recalc/.venv/bin/python -m pip install -r spikes/s01_workbook_recalc/requirements.txt`.
- Reproduce the spike tests from `backend/` with `spikes/s01_workbook_recalc/.venv/bin/python -m unittest spikes/s01_workbook_recalc/test_spike.py -v`. The latest local run passed all 4 tests in 21.632 seconds.
- The independent test compared 260 raw outputs and 260 controlled outputs (20 cases × 13 values × 2) using relative tolerance `1e-9`; expected zero requires exact zero.
- The latest root-run recalculation-only run completed 20/20 cases and returned 13 numeric outputs per case in 17.323 seconds total (0.811–0.958 seconds per case; median 0.847 seconds). This measures copy creation, input writes, recalculation, and summary reads.
- The CLI accepts one process and case at a time; for example: `spikes/s01_workbook_recalc/.venv/bin/python spikes/s01_workbook_recalc/recalc.py --process welding --welding-process SMAW --class E7018 --kg 2 --method 1 --control-percent 50`.
- Numerical comparisons use relative tolerance `1e-9`; when the expected value is zero, the allowed absolute difference is zero.
- The pinned spike dependencies are isolated in this directory's `.venv`; no application dependencies were installed. LibreOffice was not installed or used.
- No database, application service, migration, or application test was run for S01.
- Tested factor labels are E308 Method 1, Other SMAW Method 2, Oxy1 cutting, and Plasma Spray. The remaining cases vary quantity, composition and control for those selected paths. This is not parity across all workbook rows and labels; it is not S12 parity acceptance.
