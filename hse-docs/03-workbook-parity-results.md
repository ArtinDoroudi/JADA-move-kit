# Welding workbook parity

Official workbook SHA-256 verified against S01 `4c3e6f6a0fc1acd8038ab5ccd6e82cf65cd65e5d6bc69a7372b0a2a23dddaa93`.
Pycel recalculated a single temporary workbook copy. Stages 1–4 used the same scenario inputs.
The tolerance is relative 1e-9, with exact zero required. Absolute differences use each cell’s native unit.

| Check | Result |
|---|---:|
| Scenarios passed | 393/393 |
| cutting scenarios | 40 |
| edge scenarios | 8 |
| guide scenarios | 7 |
| listed scenarios | 230 |
| method1 scenarios | 35 |
| method2 scenarios | 35 |
| routing scenarios | 8 |
| spraying scenarios | 30 |
| Cell comparisons | 536,446 |
| Guide literal checks | 112 |
| Maximum absolute difference | 1e-11 |
| Maximum relative difference | 4.16630e-16 |
| Run time | 7.37 s |

## Scope

The 74 workbook categories ran at five quantity profiles covering zero, small, typical, large and an interval with a 34-significant-digit center. Each scenario compares 1,357 release formulas across details, activity subtotals and annual summaries, plus eight activity-reference probes. The combined worked example adds a separate control-adjusted PM10 comparison from Instructions A63:A64.

The parity adapter translates the sheet gates and selector into eligible typed facts and a reviewed method choice. The calculation and reconciliation stages produce the releases. Cutting Cr(VI) retains its `not_estimated_by_method` status alongside the workbook's numeric zero.

## Discrepancies investigated

- **FCAW nickel, Part 1 F181/G181.** In a mixed FCAW and GMAW case, the engine used 210 kg across two E309 rows and produced 0.01953 kg. The workbook reads only Table A C50, which held 10 kg of FCAW E309 and produced 0.00093 kg. The engine now resolves the process as well as the label, including when a shared process fact has a per-row override.
- **Other Arc Welding Methods, Part 1 G77.** At 1,000 kg, the parity adapter initially wrote the normalized class name to Table B and got 0 kg from the workbook versus 9 kg from the engine. Table B's Q14 formula matches the exact label `Other Arc Welding Methods`. With that workbook label the release was 9 kg on both sides.

Coverage sign-off remains open while the importer manifest is `published_unreviewed` and applicable defaults await approval.
