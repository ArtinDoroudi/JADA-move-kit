# Electric arc welding, cutting and spraying calculator: complete calculation guide

**Document status:** Internal reverse engineering of the supplied workbook. This Markdown file is not an ECCC publication, even though it is stored beside the source in `official/` at the user's request.

**Source:** [Electric Arc Welding, Cutting and Spraying Calculator_2022_10_26.xlsx](Electric%20Arc%20Welding%2C%20Cutting%20and%20Spraying%20Calculator_2022_10_26.xlsx). The filename identifies the October 26, 2022 version. Analysis completed November 12, 2026.

**Source SHA-256:** `4c3e6f6a0fc1acd8038ab5ccd6e82cf65cd65e5d6bc69a7372b0a2a23dddaa93`.

This guide explains every calculation path, input category, default emission factor, method-dependent coefficient, output total, and material limitation found in that file. It distinguishes the equations from the workbook's actual cell references where those references are inconsistent. Reporting-part labels and instructions below describe this historical workbook; they do not establish current reporting requirements. The workbook was read without saving changes to it.

## Contents

1. [What the calculator calculates](#1-what-the-calculator-calculates)
2. [Workbook map and calculation order](#2-workbook-map-and-calculation-order)
3. [Inputs, units and preparation](#3-inputs-units-and-preparation)
4. [Welding method selection](#4-welding-method-selection)
5. [Listed-electrode welding calculations](#5-listed-electrode-welding-calculations)
6. [Other welding: Method 1](#6-other-welding-method-1)
7. [Other welding: Method 2](#7-other-welding-method-2)
8. [Cutting calculations](#8-cutting-calculations)
9. [Spraying calculations](#9-spraying-calculations)
10. [Output totals and exact cell map](#10-output-totals-and-exact-cell-map)
11. [Controls, overrides and rounding](#11-controls-overrides-and-rounding)
12. [Workbook defects and edge cases](#12-workbook-defects-and-edge-cases)
13. [Worked examples](#13-worked-examples)
14. [Reimplementation specification](#14-reimplementation-specification)
15. [Verification and limits](#15-verification-and-limits)

Appendices: [A. Listed-electrode factors](#appendix-a-listed-welding-electrodes-and-all-default-factors), [B. Other-welding factors and formulas](#appendix-b-other-welding-defaults-and-exact-factor-formulas), [C. Cutting and spraying factors](#appendix-c-all-cutting-and-spraying-factors), [D. Aliases and bibliography](#appendix-d-electrode-aliases-and-workbook-source-bibliography).

## 1. What the calculator calculates

The workbook estimates annual **uncontrolled air releases** from three activity groups:

| Activity | Activity measure | Metal calculation basis | Particulate calculation basis |
| --- | --- | --- | --- |
| Electric arc welding, listed electrodes | kg of electrode/filler used per year | Electrode-specific substance factor × electrode usage | Electrode-specific fume factor × electrode usage |
| Electric arc welding, other types, Method 1 | kg of electrode/filler used per year | Average substance factor × electrode usage | Average fume factor × electrode usage |
| Electric arc welding, other types, Method 2 | kg of electrode/filler used per year, grouped by process | Process coefficient × mass-weighted element fraction × electrode usage | Process fume factor × electrode usage |
| Cutting | Active cutting hours per year | Cutting TPM × time-weighted element fraction | Fume generation rate in g/min × active minutes |
| Spraying | kg of material sprayed per year | Substance-specific factor × mass-weighted element fraction × sprayed mass | Greater of base fume estimate and sum of nine element releases |

Part 1 calculates chromium (Cr), cobalt (Co), nickel (Ni), manganese (Mn), hexavalent chromium (Cr(VI)), lead (Pb), zinc (Zn), copper (Cu), silver (Ag), and antimony (Sb). “Chromium” in this guide means the workbook's **chromium and its compounds** output. Cr(VI) is a separate output calculated using chromium input where a composition-based method applies.

Part 4 calculates only PM10, total particulate matter (TPM), and PM2.5. It does not calculate the other criteria air contaminants. Parts 2–3 and Part 5 have headings and a “No information available” message, with no formulas. Their absence is not a calculated zero release.

The workbook does not calculate manufacture/process/otherwise-use quantities, reporting eligibility, facility-wide thresholds, water/land releases, waste transfers, capture efficiency, or controlled emissions. Its `Instructions!A13` says to combine these air estimates with other facility sources. This is an instruction to the operator, not an automatic calculation.

## 2. Workbook map and calculation order

### 2.1 All ten sheets

| Exact sheet name | Visibility | Role | Formula cells |
| --- | --- | --- | ---: |
| `Changelog` | Hidden | Historical review notes | 0 |
| `Instructions` | Visible | Instructions, assumptions and bibliography | 0 |
| `Input Arc Welding Information` | Visible | Table A, method selectors and conditional labels | 23 |
| `Input Arc Welding (Method 2)` | Visible | Table B and automatic process aggregates | 70 |
| `Input Cutting Information` | Visible | Cutting hours and material fractions | 0 |
| `Input Spraying Information ` | Visible | Sprayed mass and material fractions | 0 |
| `Part 1 Releases` | Visible | Welding, cutting and spraying metals; combined totals | 1,883 |
| `Parts 2 - 3 Releases` | Visible | No calculation implemented | 0 |
| `Part 4 Releases` | Visible | Welding, cutting and spraying particulate; combined totals | 375 |
| `Part 5 Releases ` | Visible | No calculation implemented | 0 |
| **Total** | | | **2,351** |

The spraying-input and Part 5 sheet names end with a space. Preserve that space in references or explicitly normalize it during import. Of the 70 Method 2 formulas, 63 are single-cell legacy array formulas for weighted fractions, and seven are `SUMIF` quantity totals.

The file has no workbook-defined names, macros, external-workbook links, query connections, or separate factor lookup sheets. Factors are stored directly in the release sheets or embedded as constants in formulas. The release “summary charts” are cell tables, not chart-driven calculations. There are no cell comments supplying additional factor provenance.

All visible sheets are protected. Input cells and many literal emission factors are unlocked; formulas and computed factors are generally locked. Protection is a user-interface guard, not an input-validity test.

### 2.2 Dependency order

```text
Table A listed electrode usage ────────────► welding metals and PM10/TPM
Table A other usage + Method 1 factors ────► other-welding metals and PM10/TPM
Table B quantities/compositions
  └─► process totals and weighted fractions
      └─► Method 2 factors and activity ───► other-welding metals and PM10/TPM

Cutting hours ─► cutting PM10 and TPM ─► cutting metals using composition

Spraying mass + composition ─► spraying metals
Spraying mass + base fume factor
  └─► compare with sum of spraying metals ─► spraying PM10 and TPM

Each activity's PM10 ─► PM2.5 = 0.75 × PM10
Activity subtotals ─► Part 1 and Part 4 summary tables
```

Although Part 1 and Part 4 reference one another, there is no circular calculation: cutting flows from Part 4 to Part 1, whereas spraying flows from Part 1 to Part 4.

## 3. Inputs, units and preparation

### 3.1 Units and notation

| Symbol | Meaning | Units |
| --- | --- | --- |
| `U` | Annual electrode/filler usage | kg/year |
| `M` | Annual material sprayed | kg/year |
| `H` | Annual active cutting time | hours/year |
| `f_s` | Mass fraction of element `s` in material | kg element/kg material, dimensionless |
| `EF_s` | Welding substance factor | g substance/kg electrode |
| `K_s` | Method 2 coefficient before multiplying by composition | g substance/kg electrode when `f_s = 1` |
| `EF_PM` | Welding or spraying base fume factor | g particulate/kg material |
| `R_PM` | Cutting fume rate | g particulate/minute |
| `E_kg`, `E_t` | Annual substance or particulate release | kg/year, tonnes/year |

Use `1 tonne = 1,000 kg = 1,000,000 g` and `1 hour = 60 minutes`. Output cells say “kg” or “tonnes”; the annual basis comes from the inputs.

**Enter 1 wt% as `0.01`, not `1`.** Enter 20 wt% as `0.20`. Fractions are numeric decimals; the workbook does not divide composition inputs by 100. An entered `1` means 100% and produces a result 100 times larger than a 1% input.

### 3.2 Table A: listed and other welding usage

Sheet: `Input Arc Welding Information`. Enter annual usage in column C. A process is identified by both its welding family and electrode name; identical electrode names in different families are separate categories.

| Family | Listed-electrode input rows | Method 1 “other” input | Listed count |
| --- | --- | --- | ---: |
| SMAW, shielded metal arc welding | `C11:C31` | `C32` | 21 |
| GMAW, gas metal arc welding, including MIG/MAG | `C34:C44` | `C45` | 11 |
| FCAW, flux cored arc welding | `C47:C53` | `C54` | 7 |
| SAW, submerged arc welding | `C56:C58` | `C59` | 3 |
| GTAW, gas tungsten arc welding, including TIG | `C61:C62` | `C63` | 2 |
| PAW, plasma arc welding | `C65:C66` | `C67` | 2 |
| Other arc welding methods | None | `C69` | 0 |

There are 46 listed categories and seven “other” categories. Appendix A identifies every electrode and its input cell. Appendix D records the workbook's electrode aliases. The workbook's notes restrict other GTAW and other PAW to use with filler materials. The SCC information is descriptive; SCC digits are not used by any calculation.

### 3.3 Table B: Method 2 detail records

Sheet: `Input Arc Welding (Method 2)`. Exactly **100 records**, rows **7–106**, are included in all helper formulas.

| Column | Entry |
| --- | --- |
| A | Process category from the dropdown |
| B | Optional electrode/filler name; not used in calculations |
| C | Annual electrode usage, kg/year |
| D | Chromium mass fraction |
| E | Cobalt mass fraction |
| F | Nickel mass fraction |
| G | Manganese mass fraction |
| H | Lead mass fraction |
| I | Zinc mass fraction |
| J | Copper mass fraction |
| K | Silver mass fraction |
| L | Antimony mass fraction |

Allowed category labels are `<Empty Raw>` (the source's spelling), `Other SMAW`, `Other GMAW`, `Other FCAW`, `Other SAW`, `Other GTAW`, `Other PAW`, and `Other Arc Welding Methods`. The validation list is `BM5:BM12`. All 100 source records initially use `<Empty Raw>`.

A name typed in column B does not select an emission factor. Only column A chooses a process group. A blank, `<Empty Raw>`, or unrecognized category is excluded from the seven groups even when quantity and composition are populated. Rows below 106 are not included automatically.

Excel's text comparisons in the selectors, `SUMIF` and category masks are case-insensitive. They do not explicitly trim leading/trailing spaces. Use the dropdown labels to avoid accidental unmatched categories.

### 3.4 Cutting inputs

Sheet: `Input Cutting Information`.

| Row | Process | Quantity input |
| --- | --- | --- |
| 6 | Oxy, including oxyacetylene and Oxy-Mapp | `B6` |
| 7 | Air carbon arc cutting, CAC-A | `B7` |
| 8 | Plasma arc cutting, PAC | `B8` |
| 9 | Laser | `B9` |
| 10 | Arc saw | `B10` |
| 11 | Grinder | `B11` |
| 12 | Reciprocating saw | `B12` |
| 13 | Other cutting methods | `B13` |

Column B contains active cutting hours/year, not material mass, shift length, or equipment availability. In each row, columns C–K contain Cr, Co, Ni, Mn, Pb, Zn, Cu, Ag, Sb fractions, in that order.

The sheet requests a **time-weighted average** for each process. If material/job `i` uses that process for `h_i` active hours and has fraction `f_i,s`, prepare the input as:

```text
H_process = Σ h_i
f_process,s = Σ(h_i × f_i,s) / Σ h_i
```

The workbook receives these totals and averages; it does not calculate them from individual cutting jobs. The equation above implements the sheet's averaging instruction. For a process with no activity, use zero hours. The workbook says “Other Cutting Methods” should not be used for unspecified mechanical/cold cutting methods such as press cutting; the explicitly listed grinder and saw categories remain available.

### 3.5 Spraying inputs

Sheet: `Input Spraying Information `, including the trailing space.

| Row | Process | Quantity input |
| --- | --- | --- |
| 6 | Plasma spray | `B6` |
| 7 | Flame spray, single wire | `B7` |
| 8 | Flame spray, other | `B8` |
| 9 | Electric arc spray, including twin wire | `B9` |
| 10 | High velocity oxy-fuel coating spray, HVOF | `B10` |
| 11 | Other spraying methods | `B11` |

Column B contains total material sprayed, kg/year. Columns C–K contain the same nine elements in the same order as cutting. The sheet requests a **mass-weighted average** for each process:

```text
M_process = Σ m_i
f_process,s = Σ(m_i × f_i,s) / Σ m_i
```

These averages must be prepared outside the spraying sheet. There is no separate Cr(VI) input. The Cr(VI) emission factor is applied to total chromium content.

## 4. Welding method selection

### 4.1 Controls and intended workflow

The controls are on `Input Arc Welding Information`:

| Cell | Meaning | Source default | Validation source |
| --- | --- | --- | --- |
| `C4` | Do you know the type and name of all processes and electrodes/fillers? | `Yes` | `BA3:BA4`: Yes/No |
| `C5` | Are all processes and electrodes/fillers listed in Table A? | `Yes` | `BA3:BA4`: Yes/No |
| `C6` | Method for unknown/unlisted types | `Method 1` | `BB3:BB4`: Method 1/Method 2 |

Known, listed electrodes remain in Table A under either method. If there are unknown or unlisted items, answer No to the applicable question and select the method for those items. The workbook recommends Method 1 by default and Method 2 when Method 1 does not provide a reasonable estimate and composition is known (`Instructions!A79:A83`). Do not enter the same usage in both listed and other categories.

### 4.2 Actual release gate

For every “other” welding release row, the gate is:

```text
other_enabled = (C4 = "No") OR (C5 = "No")
if NOT other_enabled:
    other_release = 0
else:
    other_release = selected_factor × selected_quantity / conversion
```

The method branch is separately:

```text
if C6 = "Method 1":
    use Table A other-category quantity and Method 1 factor
else:
    use Table B process aggregate and Method 2 factor
```

Consequences:

- With both answers Yes, all “other” releases are zero, even if Table A other cells or Table B contain quantities.
- With either answer No, “other” releases can calculate. The gate does not require the other question to have a valid answer.
- **Any value other than `Method 1` follows the Method 2 branch**, including a blank or invalid value. The formulas do not explicitly test for `Method 2`.
- Listed-electrode, cutting and spraying calculations are not gated by these answers.
- Table B aggregates calculate continuously. Its “active only if Method 2” note describes when downstream results use them, not whether helper formulas run.
- Changing the method does not erase quantities in the other table.

### 4.3 Conditional messages and labels

`A5` shows the second question only when C4 is Yes. C5 still exists and is still used by the release gate when the question text is blank.

`A6` first checks whether C4 or C5 is empty and displays “Please answer both questions above.” Otherwise it directs the user to choose a method if either answer is No, or to Table A if both are Yes. `A7` directs Method 1 users to Table A and Method 2 users to Table A for known electrodes plus Table B for other electrodes. Both message formulas use `IFERROR` for a generic download-a-fresh-copy message. **These messages do not stop release calculations.**

The other-category labels in B32, B45, B54 and B59, the label in A69/B69, and the related unit/SCC cells are conditionally displayed only when an answer is No and C6 is Method 1. B63 and B67 retain their other-GTAW/PAW labels even when those rows are inactive. Visual label visibility is not the calculation rule; the gate above is.

## 5. Listed-electrode welding calculations

### 5.1 Metals

For each listed process/electrode and each of the seven implemented listed-electrode substances:

```text
E_kg = EF_s [g/kg] × U [kg/year] / 1,000
E_t  = E_kg / 1,000
```

In `Part 1 Releases`, D holds the factor, E the rating, F the input quantity, G kg release, and I tonnes release. For example:

```excel
F21 = 'Input Arc Welding Information'!C13
G21 = (D21*F21)/1000
I21 = G21/1000
```

The example is SMAW E308 chromium: D21 is 0.59 g/kg. Ratings are metadata and do not alter the arithmetic. Zero factors are literal workbook defaults, not proof that an element is absent from the material.

No composition is requested for listed-electrode calculations. Do not multiply these substance-specific factors by another mass fraction. Cr(VI) uses its own stored factor; the listed-electrode Cr(VI) result is not calculated by applying a universal ratio to total chromium.

Copper, silver and antimony have no listed-electrode calculation rows. Their welding sections contain only the seven “other” process rows. With default Method 1 factors, those three welding totals are zero.

**Reference exceptions:** The normal process/electrode mapping is broken at `F181` and `F421:F427`. Section 12 lists the exact formulas required to reproduce the original workbook.

### 5.2 Particulate

For each listed electrode:

```text
PM10_t = EF_PM10 × U / 1,000,000
TPM_t  = EF_TPM  × U / 1,000,000
PM2.5_t = 0.75 × PM10_t
```

The stored PM10 and TPM factors are identical, but occupy separate literal cells for listed electrodes. PM2.5 references the PM10 release, not TPM. For SMAW E308:

```excel
'Part 4 Releases'!G14  = (F14*D14)/1000000
'Part 4 Releases'!G75  = (F75*D75)/1000000
'Part 4 Releases'!G136 = G14*0.75
```

D14 and D75 both contain 13.4 g/kg. Editing only one of these factors can make PM10 differ from TPM. There is no metal-sum floor for welding.

## 6. Other welding: Method 1

Method 1 uses the seven other-category quantities in Table A and the average factors in Appendix B.1. Once the other-release gate is enabled:

```text
Metal_kg = Method1_EF_s × U_other / 1,000
Metal_t  = Metal_kg / 1,000
PM10_t   = Method1_EF_PM × U_other / 1,000,000
TPM_t    = PM10_t                  [with unmodified linked factors]
PM2.5_t  = 0.75 × PM10_t
```

Method 1 ignores Table B composition and quantities. Each process has fixed defaults; there is no averaging of the user's listed-electrode mix. For example, Other SMAW chromium always uses 0.46 g/kg and PM10 uses 20.6 g/kg under Method 1. This can produce a nonzero metal estimate even when the user's particular electrode contains none of that metal, which is the workbook's stated motivation for Method 2.

## 7. Other welding: Method 2

### 7.1 Process totals and weighted fractions

On `Input Arc Welding (Method 2)`, the supporting table occupies P7:Z14:

| Helper row | Table B category | Q: total usage | R:Z fractions |
| --- | --- | --- | --- |
| 8 | Other SMAW | `Q8` | Cr, Co, Ni, Mn, Pb, Zn, Cu, Ag, Sb |
| 9 | Other GMAW | `Q9` | Same order |
| 10 | Other FCAW | `Q10` | Same order |
| 11 | Other SAW | `Q11` | Same order |
| 12 | Other GTAW | `Q12` | Same order |
| 13 | Other PAW | `Q13` | Same order |
| 14 | Other Arc Welding Methods | `Q14` | Same order |

For process `p`, using only matching records within rows 7–106:

```text
U_p = Σ U_i
if U_p = 0:
    f̄_p,s = 0
else:
    f̄_p,s = Σ(U_i × f_i,s) / U_p
```

Exact SMAW examples:

```excel
Q8 = SUMIF(A$7:A$106,"Other SMAW",C$7:C$106)

R8 = IF(SUMIF($A$7:$A$106,"Other SMAW",$C$7:$C$106)=0,0,
        SUMPRODUCT(--(A$7:A$106="Other SMAW"),$C$7:$C$106,D$7:D$106)
        /SUMIF($A$7:$A$106,"Other SMAW",$C$7:$C$106))
```

The other 62 fraction formulas use the corresponding category and composition column. They are legacy array formulas in the XLSX. The helper fraction display uses four decimals, but subsequent calculations use the unrounded value.

### 7.2 Metal factors

For each ordinary element, construct an effective factor from its weighted fraction:

```text
Effective_EF_p,s = K_p,s × f̄_p,s
Metal_kg_p,s = Effective_EF_p,s × U_p / 1,000
Metal_t_p,s = Metal_kg_p,s / 1,000
```

For Cr(VI), use the weighted **total chromium** fraction:

```text
Effective_EF_p,CrVI = K_p,CrVI × f̄_p,Cr
CrVI_kg_p = Effective_EF_p,CrVI × U_p / 1,000
```

All coefficients embedded in the Method 2 formulas are:

| Process | K for total Cr | K for Co, Ni, Mn, Pb, Zn, Cu, Ag, Sb | K for Cr(VI) | PM10/TPM factor, g/kg |
| --- | ---: | ---: | ---: | ---: |
| Other SMAW | `20 × 0.2865 = 5.73` | 5.73 | `20 × 0.2865 × 0.63 = 3.6099` | 20 |
| Other GMAW | `10 × 0.5464 = 5.464` | 5.464 | `10 × 0.5464 × 0.05 = 0.2732` | 10 |
| Other FCAW | `20 × 0.2865 = 5.73` | 5.73 | `20 × 0.2865 × 0.63 = 3.6099` | 20 |
| Other SAW | `0.0053 + 0.00902 = 0.01432` | 0.0143 | 0.00902 | 0.05 |
| Other GTAW | 2.9 | 2.9 | `2.9 × 0.1 = 0.29` | 2.9 |
| Other PAW | 0.4 | 0.4 | `0.4 × 0.1 = 0.04` | 0.4 |
| Other Arc Welding Methods | 50 | 50 | `50 × 0.1 = 5` | 50 |

The source does not explain the derivation of every embedded coefficient next to its formula. These are verified constants from the file, not newly derived physical parameters. In particular, preserve **0.01432 for SAW total chromium versus 0.0143 for the other ordinary elements** when reproducing the workbook.

For valid records with positive total usage, an equivalent implementation avoids explicit averaging for the final metal total:

```text
Metal_kg_p,s = K_p,s × Σ(U_i × f_i,s) / 1,000
```

The weighted-average form is still needed to reproduce the displayed helper table. The simplified identity should not replace the workbook's zero-total branch for invalid inputs containing offsetting positive and negative quantities.

### 7.3 Particulate factors and activity routing

Method 2 particulate depends on process and total usage, **not composition**:

```text
PM10_t_p = Method2_EF_PM,p × U_p / 1,000,000
TPM_t_p  = PM10_t_p
PM2.5_t_p = 0.75 × PM10_t_p
```

The first seven other-process activity formulas are `Part 1 Releases!F40,F53,F62,F67,F71,F75,F77`. They choose the corresponding Table A other quantity or Table B Q8:Q14. Later metal sections link to these activity cells. Part 4 makes the same selection in F33,F46,F55,F60,F64,F68,F70. Its other-process TPM factor and activity cells link back to the corresponding PM10 cells.

For example:

```excel
'Part 1 Releases'!D40 = IF('Input Arc Welding Information'!$C$6="Method 1",
                          0.46,20*0.2865*'Input Arc Welding (Method 2)'!R8)
'Part 1 Releases'!F40 = IF('Input Arc Welding Information'!$C$6="Method 1",
                          'Input Arc Welding Information'!C32,
                          'Input Arc Welding (Method 2)'!Q8)
'Part 1 Releases'!G40 = IF(NOT(OR('Input Arc Welding Information'!C$4="No",
                                 'Input Arc Welding Information'!C$5="No")),
                          0,(D40*F40)/1000)
```

## 8. Cutting calculations

### 8.1 Particulate from active hours

For each of the eight cutting processes:

```text
PM10_t = H × 60 × R_PM10 / 1,000,000
TPM_t  = H × 60 × R_TPM  / 1,000,000
PM2.5_t = 0.75 × PM10_t
```

Appendix C.1 gives all eight rates. PM10 and TPM have equal defaults in separate cells. For plasma cutting:

```excel
'Part 4 Releases'!O14 = 'Input Cutting Information'!B8
'Part 4 Releases'!P14 = (O14*60*M14)/1000000
'Part 4 Releases'!O23 = 'Input Cutting Information'!B8
'Part 4 Releases'!P23 = (O23*60*M23)/1000000
'Part 4 Releases'!P32 = 0.75*P14
```

M14 and M23 are 5.3 g/min. The `60` converts annual hours into annual minutes.

### 8.2 Metals from TPM

For Cr, Co, Ni, Mn, Pb, Zn, Cu, Ag and Sb:

```text
Metal_t = f_process,s × TPM_t,process
Metal_kg = Metal_t × 1,000
```

In `Part 1 Releases`, Q contains the input fraction, R references the matching cutting TPM result in `Part 4 Releases!P21:P28`, S calculates kg, and U calculates tonnes. For plasma-cutting chromium:

```excel
Q21 = 'Input Cutting Information'!C8
R21 = 'Part 4 Releases'!P23
S21 = (Q21*R21)*1000
U21 = Q21*R21
```

The “Emission Factor” column O is `NA` and is **not used** by these formulas. Entering a number into that column would not change the release. The controlling rate is the TPM rate in Part 4 column M. All nine ordinary element groups use the same process TPM basis.

### 8.3 Cutting Cr(VI) is not estimated

For the Cr(VI) section, `Part 1 Releases!Q55:Q62` contains literal text `NA`. The formulas are:

```excel
S55 = IFERROR((Q55*R55)*1000,0)
U55 = IFERROR(Q55*R55,0)
```

They repeat through row 62. Multiplication by `NA` errors and `IFERROR` returns zero. Thus **all default cutting Cr(VI) results are zero because the calculation is unavailable**, not because the workbook derives zero Cr(VI) from chromium content. The ordinary chromium fraction is not referenced in these eight rows.

## 9. Spraying calculations

### 9.1 Metals

For each spraying process and substance:

```text
Substance_in_sprayed_material_kg = M × f_s
Metal_kg = Spraying_EF_s × f_s × M / 1,000
Metal_t  = Spraying_EF_s × f_s × M / 1,000,000
```

The factor is **g released per kg of that substance in the sprayed material**. It is not g/kg of total feed. This distinction is stated in `Part 1 Releases!AA17` and `X90`.

In Part 1, AA holds the substance factor, AB its rating, AC the material fraction, AD annual sprayed mass, AE kg release, and AG tonnes release. Plasma-spray chromium illustrates the pattern:

```excel
AC19 = 'Input Spraying Information '!C6
AD19 = 'Input Spraying Information '!B6
AE19 = (AA19*AC19*AD19)/1000
AG19 = (AA19*AC19*AD19)/1000000
```

AA19 is 90.9 g/kg of chromium. Plasma-spray Cr(VI) uses AA47 = 11.8 with the **same chromium fraction** from C6. There is no separate speciation input and no post-calculation subtraction of Cr(VI) from the total chromium output.

All 60 spraying substance factors and their ratings are in Appendix C.2.

### 9.2 PM10 and TPM: base estimate with a metal-sum floor

For each process, calculate two candidates in tonnes:

```text
Base_PM10_t = M × EF_PM10 / 1,000,000
Base_TPM_t  = M × EF_TPM  / 1,000,000

Element_sum_t = Cr_t + Co_t + Ni_t + Mn_t + Pb_t + Zn_t + Cu_t + Ag_t + Sb_t

PM10_t = max(Base_PM10_t, Element_sum_t)
TPM_t  = max(Base_TPM_t, Element_sum_t)
PM2.5_t = 0.75 × PM10_t
```

**Cr(VI) is excluded from this sum.** The formula includes nine ordinary elements, not all ten Part 1 substance outputs. This avoids adding the separately calculated chromium subset to the sum containing total chromium.

The comparison is made **for each spraying process before summing the processes**. Do not replace `Σ max(base_p, metals_p)` with `max(Σ base_p, Σ metals_p)`; those expressions can differ.

For plasma spray, the element sum is:

```excel
SUM('Part 1 Releases'!AG19,'Part 1 Releases'!AG26,
    'Part 1 Releases'!AG33,'Part 1 Releases'!AG40,
    'Part 1 Releases'!AG54,'Part 1 Releases'!AG61,
    'Part 1 Releases'!AG68,'Part 1 Releases'!AG75,
    'Part 1 Releases'!AG82)
```

`Part 4 Releases!Y12` implements an `IF(base >= sum, base, sum)`, mathematically the maximum above. Y19 repeats it for TPM with its own base factor. Y26 is `0.75*Y12`. The following five process rows shift each Part 1 reference down by the matching process offset.

A zero base PM factor does not necessarily turn off spraying PM: the element sum can still control. Likewise, increasing a spraying metal factor can increase both its Part 1 release and the Part 4 PM floor. No corresponding floor exists for welding or cutting.

## 10. Output totals and exact cell map

### 10.1 Part 1 summary and activity blocks

All references in this table are on `Part 1 Releases`. Each activity's subtotal sums its complete block, including blank separator rows in the welding sections.

| Substance | Summary row | Welding detail rows | Welding kg / t total | Cutting detail rows | Cutting kg / t total | Spraying detail rows | Spraying kg / t total | Workbook reporting-unit label |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| Chromium | 5 | 19–77 | G78 / I78 | 19–26 | S27 / U27 | 19–24 | AE25 / AG25 | Part 1A, tonnes |
| Cobalt | 6 | 80–138 | G139 / I139 | 28–35 | S36 / U36 | 26–31 | AE32 / AG32 | Part 1B, kg |
| Nickel | 7 | 141–199 | G200 / I200 | 37–44 | S45 / U45 | 33–38 | AE39 / AG39 | Part 1A, tonnes |
| Manganese | 8 | 202–260 | G261 / I261 | 46–53 | S54 / U54 | 40–45 | AE46 / AG46 | Part 1A, tonnes |
| Cr(VI) | 9 | 263–321 | G322 / I322 | 55–62 | S63 / U63 | 47–52 | AE53 / AG53 | Part 1B, kg |
| Lead | 10 | 324–382 | G383 / I383 | 64–71 | S72 / U72 | 54–59 | AE60 / AG60 | Part 1B, kg |
| Zinc | 12 | 385–443 | G444 / I444 | 73–80 | S81 / U81 | 61–66 | AE67 / AG67 | Part 1A, tonnes |
| Copper | 13 | 446–458 | G459 / I459 | 82–89 | S90 / U90 | 68–73 | AE74 / AG74 | Part 1A, tonnes |
| Silver | 14 | 461–473 | G474 / I474 | 91–98 | S99 / U99 | 75–80 | AE81 / AG81 | Part 1A, tonnes |
| Antimony | 15 | 476–488 | G489 / I489 | 100–107 | S108 / U108 | 82–87 | AE88 / AG88 | Part 1A, tonnes |

For summary row `r`:

```text
B_r = welding kg subtotal + cutting kg subtotal + spraying kg subtotal
D_r = welding t subtotal  + cutting t subtotal  + spraying t subtotal
```

For chromium, the actual formulas are B5 `=G78+S27+AE25` and D5 `=I78+U27+AG25`. Row 11 is intentionally blank. The summary lists kg and tonnes for every substance; column F tells the reader which unit this workbook associates with reporting. No threshold comparison follows those formulas.

Every substance-group CAS field contains `*`, meaning no single CAS number applies; the workbook does not provide individual species-level CAS calculations.

### 10.2 Row offsets for the seven other-welding groups

Process order in this table is SMAW, GMAW, FCAW, SAW, GTAW, PAW, Other Arc Welding Methods.

| Substance | Part 1 process rows |
| --- | --- |
| Cr | 40, 53, 62, 67, 71, 75, 77 |
| Co | 101, 114, 123, 128, 132, 136, 138 |
| Ni | 162, 175, 184, 189, 193, 197, 199 |
| Mn | 223, 236, 245, 250, 254, 258, 260 |
| Cr(VI) | 284, 297, 306, 311, 315, 319, 321 |
| Pb | 345, 358, 367, 372, 376, 380, 382 |
| Zn | 406, 419, 428, 433, 437, 441, 443 |
| Cu | 446, 448, 450, 452, 454, 456, 458 |
| Ag | 461, 463, 465, 467, 469, 471, 473 |
| Sb | 476, 478, 480, 482, 484, 486, 488 |

For every row: D is the method-dependent factor, F the selected activity, G the gated kg release, and I is `G/1000`. Appendix B.2 records all 70 exact factor formulas. Later F cells link to the matching chromium-block F cell.

### 10.3 Part 4 totals

All references below are on `Part 4 Releases`, and all release values are tonnes/year.

| Output | Summary | Welding detail / total | Cutting detail / total | Spraying detail / total |
| --- | --- | --- | --- | --- |
| PM10 | `B5=G71+P20+Y18` | G12:G70 / G71 | P12:P19 / P20 | Y12:Y17 / Y18 |
| TPM | `B6=G132+P29+Y25` | G73:G131 / G132 | P21:P28 / P29 | Y19:Y24 / Y25 |
| PM2.5 | `B7=G193+P38+Y32` | G134:G192 / G193 | P30:P37 / P38 | Y26:Y31 / Y32 |

Welding PM10 process rows are the Part 1 chromium rows minus seven. The TPM block adds 61 to each PM10 row. The PM2.5 block adds 122. Its formula at row `r+122` is `=G_r*0.75`. Cutting PM2.5 row `r+18` is `=0.75*P_r`. Spraying PM2.5 row `r+14` is `=0.75*Y_r`.

With unmodified default factors and numeric inputs:

```text
Part4!B5 = Part4!B6
Part4!B7 = 0.75 × Part4!B5
Part1!B_r = 1,000 × Part1!D_r
```

These are useful reconciliation checks. PM10, TPM and PM2.5 are overlapping size categories; summing the three is not another particulate total.

## 11. Controls, overrides and rounding

### 11.1 Control efficiency is an external adjustment

`Instructions!A63:A64` gives:

```text
Controlled_emissions = Uncontrolled_emissions × (100 − control_efficiency_percent) / 100
```

No cell accepts control efficiency and no release formula applies it. For 90% control, multiply the relevant uncontrolled emission by 0.10. Apply any justified control outside this workbook, at the applicable process/substance level, before facility aggregation. Capture efficiency, bypass fractions, operating coverage and multiple control stages are not modeled by the source.

### 11.2 Site-specific emission factors

The instructions permit site-specific factor replacements if units are converted correctly. Literal factor cells are often unlocked, but the method-dependent “other” factors are protected formulas. Preserve an original copy and record any overrides when using a working copy.

| Factor location | Meaning and downstream effect |
| --- | --- |
| Part 1 D, listed welding rows | g substance/kg electrode; changes that substance's welding release |
| Part 1 D, other welding rows | Computed method switch; not an ordinary unlocked input |
| Part 1 O, cutting | `NA`, unused; does not control cutting releases |
| Part 1 AA, spraying | g substance/kg substance in sprayed material; may also change the Part 4 metal-sum floor |
| Part 4 D, listed PM10 and TPM rows | g particulate/kg electrode; separate PM10/TPM constants |
| Part 4 D, other rows | Method-selected PM10 factor; other TPM rows link back to it |
| Part 4 M, cutting PM10 and TPM rows | g/min; TPM rate also controls Part 1 cutting metals |
| Part 4 V, spraying PM10 and TPM rows | g particulate/kg total material; separate constants, each subject to the element-sum floor |
| PM2.5 factor columns | `NA`; PM2.5 comes from 0.75 × PM10 |

The generic instruction to zero a process factor must be interpreted against these dependencies. To represent an unused process, zero activity is the direct input control. Zeroing only one substance factor cannot suppress other substances; zeroing a spraying PM factor cannot suppress its metal-sum floor.

### 11.3 Display precision versus calculation precision

There are **no `ROUND` formulas**. Summary release values use the `0.000` number format. Method 2 weighted averages use `0.0000`. Part 1 detail releases mostly retain General format; Part 4 release cells use three-decimal formatting. Calculations and totals use underlying precision, not displayed text.

For example, 0.00059 tonnes can display as `0.001` tonnes while the linked kg result remains 0.59 kg. A small nonzero emission can display as `0.000`. Sum unrounded values, then format the final result. The instructions' reference to six decimals for dioxins/furans is generic text; this workbook has no dioxin/furan calculation.

## 12. Workbook defects and edge cases

### 12.1 Eight confirmed activity-reference inconsistencies

These are source formulas, not changes made by this analysis. “Matching input” below is inferred from the row's electrode label and the corresponding chromium/PM rows. It is the apparent intended mapping, not an approved amendment to the official calculator.

| Part 1 cell | Labeled electrode | Actual Table A input | Actual input's meaning | Matching input by label |
| --- | --- | --- | --- | --- |
| F181 | FCAW E316LT, nickel | C50 | FCAW E309 | C51 |
| F421 | FCAW E110, zinc | C44 | GMAW ERNiCu | C47 |
| F422 | FCAW E11018, zinc | C46 | Blank separator row | C48 |
| F423 | FCAW E308LT, zinc | C47 | FCAW E110 | C49 |
| F424 | FCAW E309, zinc | C48 | FCAW E11018 | C50 |
| F425 | FCAW E316LT, zinc | C48 | FCAW E11018 | C51 |
| F426 | FCAW E70T, zinc | C49 | FCAW E308LT | C52 |
| F427 | FCAW E71T, zinc | C51 | FCAW E316LT | C53 |

For example, F181 is literally `='Input Arc Welding Information'!C50`. Therefore 1,000 kg entered only for E316LT in C51 yields zero nickel from its labeled row; 1,000 kg entered only for E309 in C50 triggers the 0.093 g/kg factor stored at D181, yielding 0.093 kg nickel.

The zinc block's actual default result, in kg/year, simplifies to:

```text
FCAW-labeled listed zinc =
  (0 × C44 + 0 × C46 + 0.0056 × C47 + 0 × C48
   + 0.0056 × C48 + 0.01 × C49 + 0.01 × C51) / 1,000
```

Thus C52 and C53 do not drive their expected zinc rows. Some incorrect references currently multiply a zero factor, but become consequential if that factor is overridden. Appendix A records factors by the source's row labels; use this exception table as well when reproducing source behavior.

### 12.2 Unavailable values can look like zero

- Cutting Cr(VI) deliberately converts the error caused by `NA` into zero.
- Listed-electrode Cu, Ag and Sb are not modeled; Method 1 other-welding factors for these elements are zero.
- Many listed-electrode factors are zero. The workbook does not distinguish “unknown factor,” “not applicable” and “measured zero” with structured metadata.
- Empty numeric inputs commonly become zero through Excel references and arithmetic. A zero output does not demonstrate that every required input was supplied.

### 12.3 Validation limitations

The only data validations are the two selector lists on Table A and the process-category list on Table B. They allow blanks. There are no numeric validations for nonnegative quantity, fractions between 0 and 1, composition totals, annual time bounds, or required composition.

For Table B, blank/text composition cells are treated as zero by `SUMPRODUCT`, while numeric usage remains in the denominator. A missing composition can therefore dilute a process's weighted average. Text quantities in the referenced `SUMIF` sum range are not numeric usage. Store all quantities and fractions as numbers, not numeric-looking text. Text in a numeric field elsewhere may produce `#VALUE!`; Excel errors can propagate, except where `IFERROR` explicitly catches them. Negative numeric inputs and fractions over 1 are not rejected by the formulas. Canceling positive and negative quantities can force Method 2's weighted fraction to zero through its zero-total branch.

The workbook does not normalize the nine entered fractions to sum to 1. They may omit other elements, so their sum need not be 1 for a valid material. It also does not check whether their sum exceeds 1. Cr(VI) is not an additional fraction to include in that input sum.

### 12.4 Other source quirks

- Copper tonnes summary D13 contains `=U90+AG74++I459`. The extra unary plus is mathematically harmless; parsers must accept it or normalize it without changing the result.
- Five small literal-expression factors are `=0.001/2`, giving 0.0005: D52, D90, D91, D103 and D105 in Part 1. Do not mistake these for missing factors.
- The source has copied “except tetraethyl lead” wording in some non-lead subtotal labels. This text does not modify the substances or formulas.
- Part 4 uses “Arc SAW” for the cutting arc-saw label. This is a cutting process, distinct from submerged arc welding in Table A.
- The hidden changelog includes 2018 review notes and references to a 2009 predecessor and a 2016–2017 substance list. Its EF-source text and linked URL are not consistent descriptions of the same chapter. The active `Instructions!A27:A48` bibliography is recorded in Appendix D, but neither the changelog nor the filename proves present-day applicability.
- The workbook requests full recalculation on load. Its stored zero results describe the supplied blank template, not a completed facility calculation.

## 13. Worked examples

Each example starts from otherwise empty/zero activity inputs and the original factors. Values below retain calculation precision. They are illustrative inputs, not facility data.

### 13.1 Listed SMAW E308

Set Table A C13 to 1,000 kg/year. Leave C4/C5 as Yes.

```text
Cr = 0.59 × 1,000 / 1,000 = 0.59 kg = 0.00059 t
Co = 0.001 kg
Ni = 0.1 kg
Mn = 0.43 kg
Cr(VI) = 0.2 kg
Pb = 0.01 kg
Zn = 0.0056 kg
PM10 = TPM = 13.4 × 1,000 / 1,000,000 = 0.0134 t
PM2.5 = 0.75 × 0.0134 = 0.01005 t
```

The metal results flow through the seven welding subtotals into Part 1 B5:B12. The particulate results appear at Part 4 B5:B7.

### 13.2 Other SMAW, Method 1

Set Table A C4 to No, C5 to Yes, C6 to Method 1 and C32 to 1,000.

```text
Cr = 0.46 kg
Co = 0.001 kg
Ni = 0.255 kg
Mn = 1.963 kg
Cr(VI) = 0.179 kg
Pb = 0.043 kg
Zn = 1.305 kg
Cu = Ag = Sb = 0 kg
PM10 = TPM = 0.0206 t
PM2.5 = 0.01545 t
```

Changing C4 back to Yes, with C5 still Yes, suppresses all these other-category releases even though the quantity remains entered.

### 13.3 Other SMAW, Method 2 with two materials

Enable other welding and select Method 2. Enter:

| Table B row | Category | Usage, kg/year | Cr fraction | Ni fraction | Mn fraction |
| --- | --- | ---: | ---: | ---: | ---: |
| 7 | Other SMAW | 100 | 0.10 | 0.05 | 0.02 |
| 8 | Other SMAW | 300 | 0.20 | 0.10 | 0.04 |

Other element fractions are zero.

```text
Q8 = 100 + 300 = 400 kg/year
R8 (Cr) = (100×0.10 + 300×0.20)/400 = 0.175
T8 (Ni) = (100×0.05 + 300×0.10)/400 = 0.0875
U8 (Mn) = (100×0.02 + 300×0.04)/400 = 0.035

Cr effective factor = 5.73 × 0.175 = 1.00275 g/kg
Cr = 1.00275 × 400 / 1,000 = 0.4011 kg
Ni = 5.73 × 0.0875 × 400 / 1,000 = 0.20055 kg
Mn = 5.73 × 0.035 × 400 / 1,000 = 0.08022 kg
Cr(VI) = 3.6099 × 0.175 × 400 / 1,000 = 0.252693 kg
PM10 = TPM = 20 × 400 / 1,000,000 = 0.008 t
PM2.5 = 0.006 t
```

The mass-weighted Cr fraction is 0.175, not the unweighted average 0.15. Changing the composition changes metals but leaves Method 2 particulate unchanged for the same process and usage.

### 13.4 Plasma arc cutting

Set cutting B8 = 100 hours, C8 = 0.20 Cr, E8 = 0.10 Ni and F8 = 0.02 Mn. Other fractions are zero.

```text
PM10 = TPM = 100 × 60 × 5.3 / 1,000,000 = 0.0318 t = 31.8 kg
PM2.5 = 0.75 × 0.0318 = 0.02385 t
Cr = 0.20 × 31.8 = 6.36 kg
Ni = 0.10 × 31.8 = 3.18 kg
Mn = 0.02 × 31.8 = 0.636 kg
Cr(VI) = 0 in the workbook's unavailable-calculation branch
```

### 13.5 Plasma spraying: base particulate estimate controls

Set spraying B6 = 1,000 kg, C6 = 0.10 Cr and E6 = 0.10 Ni, with other fractions zero.

```text
Cr = 90.9 × 0.10 × 1,000 / 1,000 = 9.09 kg
Ni = 150 × 0.10 × 1,000 / 1,000 = 15 kg
Cr(VI) = 11.8 × 0.10 × 1,000 / 1,000 = 1.18 kg
Element sum excluding Cr(VI) = 24.09 kg = 0.02409 t
Base PM = 60 × 1,000 / 1,000,000 = 0.06 t
PM10 = TPM = max(0.06, 0.02409) = 0.06 t
PM2.5 = 0.045 t
```

### 13.6 Plasma spraying: metal sum controls

Use the same 1,000 kg, now with 0.50 Cr and 0.50 Ni:

```text
Cr = 45.45 kg
Ni = 75 kg
Cr(VI) = 5.9 kg
Element sum excluding Cr(VI) = 120.45 kg = 0.12045 t
Base PM = 0.06 t
PM10 = TPM = 0.12045 t
PM2.5 = 0.0903375 t
```

Adding Cr(VI) again would incorrectly produce 126.35 kg for the floor; the workbook does not do that.

### 13.7 Combined activities and an external control adjustment

Combine examples 13.1, 13.4 and 13.5, using only those activities:

```text
Total Cr = 0.59 + 6.36 + 9.09 = 16.04 kg = 0.01604 t
Total Ni = 0.1 + 3.18 + 15 = 18.28 kg = 0.01828 t
Total Cr(VI) = 0.2 + 0 + 1.18 = 1.38 kg
Total PM10 = TPM = 0.0134 + 0.0318 + 0.06 = 0.1052 t
Total PM2.5 = 0.01005 + 0.02385 + 0.045 = 0.0789 t
```

If a separately established 90% control efficiency applies to all of those PM10 releases, the external adjustment is `0.1052 × 0.10 = 0.01052 t`. The workbook summary itself remains the uncontrolled 0.1052 t.

## 14. Reimplementation specification

### 14.1 Separate faithful reproduction from corrections

A faithful implementation must reproduce the original factor precision, gates, unavailable-value behavior, and eight mismatched input references. A corrected implementation should identify and version its changes explicitly. Do not silently repair references while claiming numerical identity with this file.

Keep the source version/hash, factor units, ratings, factor cell addresses, input mapping, and overrides as provenance. Zero, unavailable, and not-implemented outputs should remain distinguishable in the application even if a compatibility output must reproduce the spreadsheet's zero.

### 14.2 Complete computation sequence

```text
1. Read the three Table A selector values.
2. Read the 46 listed quantities and seven Method 1 other quantities.
3. Group Table B rows 7–106 into seven process categories.
4. Compute each group's quantity and nine weighted fractions, with zero-total handling.
5. For every listed welding row:
     select its substance and PM factors;
     resolve its actual source quantity, including the Section 12 exceptions;
     calculate substance kg/t and PM10/TPM tonnes.
6. For each other-welding process:
     select Method 1 if C6 equals Method 1, otherwise Method 2;
     select the corresponding quantity and effective factors;
     apply the C4/C5 other-release gate;
     calculate all ten metals and PM10/TPM.
7. For each cutting process:
     calculate PM10 and TPM from active hours and g/min rates;
     multiply TPM by each of the nine ordinary element fractions;
     reproduce the unavailable Cr(VI) branch separately.
8. For each spraying process:
     calculate all ten substance releases from material mass and fractions;
     sum the nine ordinary element releases, excluding Cr(VI);
     apply that sum as the floor for PM10 and TPM, independently per process.
9. Calculate each process's PM2.5 as 75% of its PM10.
10. Sum process releases into each activity subtotal, then combine activities.
11. Preserve full precision and format summaries to three decimals.
12. Apply any external control/reporting workflow separately from workbook reproduction.
```

The formulas required are arithmetic, unary plus/minus, equality and `>=`, `IF`, `IFERROR`, `OR`, `AND`, `NOT`, `SUM`, `SUMIF`, and `SUMPRODUCT`. The double unary minus in Method 2 converts category-match booleans to 1/0. There is no lookup interpolation, hidden database, macro-generated calculation, or iterative solver.

### 14.3 Recommended validation for an application

These checks would improve an application but are **not enforced by the workbook**: require a valid method and process category, nonnegative activity, fractions in [0,1], and explicit handling of unknown composition; detect duplicate allocation of the same usage; reject or flag rows outside the supported category set; and flag a sum of ordinary element fractions above 1. Do not require the nine tracked elements to sum to 1, since materials can contain untracked elements.

Retain separate reporting outputs for total chromium and Cr(VI), and for TPM/PM10/PM2.5. Preserve a clear unavailable status for Parts 2–3, Part 5 and cutting Cr(VI) in any richer application model.

## 15. Verification and limits

The analysis inspected all ten worksheets, all populated cells, formulas and stored results, the hidden changelog, defined-name inventory, validation rules, protection settings, merged ranges, number formats, hyperlinks, and package relationships. No calculation-bearing hidden rows or columns were found; Instructions row 14 is hidden and empty. Far-right BA/BB and BM cells are dropdown support lists, not additional calculators.

All **2,351 formula cells** were independently evaluated with a small evaluator implementing the functions actually used by this workbook. Its baseline results matched every saved formula result. The evaluator traversed all formulas for each of **74 single-category scenarios**: 46 listed electrodes, seven Method 1 other processes, seven Method 2 other processes, eight cutting processes, and six spraying processes. Additional examples and boundary checks covered weighted mixtures, method gates, a blank method selector taking the Method 2 branch, row 106 inclusion, row 107 exclusion, both spraying-floor branches, and the nickel/zinc reference defects. **930 numerical assertions passed**, including kg/tonne reconciliation and default particulate relationships.

An independent spreadsheet engine, Artifact Tool, also imported the source and recalculated in-memory examples for listed welding, Method 2 weighted welding, cutting, both spraying-floor branches, and the reference defects. Its Method 1 handling of unused blank quantities selected through `IF` produced `#VALUE!`; using explicit numeric zeros for those unused quantities returned the expected 0.46 kg chromium and 0.0206 tonnes PM10 for the 1,000 kg Other SMAW example. This is an engine-compatibility limitation, not evidence that Excel rejects the source template. The mathematical checks above treat blank selected numeric references using Excel's zero semantics.

Microsoft Excel itself was not automated for this review. The source's original formatting and embedded images were not re-exported. The underlying scientific publications were not re-derived or reviewed to validate each factor, and present-day regulatory applicability was outside this reverse engineering. The eight mismatched activity references are confirmed by formula inspection and nonzero calculations; the proposed matching inputs are identified as inference. No backend/frontend code, factors, or source workbook cells were changed. Workspace destination validation (`python3 scripts/bootstrap.py --check`) passed.

## Appendix A. Listed welding electrodes and all default factors

Each factor is `value (rating)`, in g/kg of electrode consumed. A rating of `-` is the workbook’s unspecified rating, not a numerical adjustment. Zero is an actual stored default. Copper, silver and antimony have no listed-electrode rows. Values are transcribed from the source, with binary floating-point tails removed. The input map describes row labels; the eight actual-reference exceptions in Section 12 override it for faithful reproduction.

### A.1 Input and factor addresses

The P1 base row is chromium; add 61, 122, 183, 244, 305 or 366 for Co, Ni, Mn, Cr(VI), Pb or Zn. Factors are in D and ratings in E. The P4 base row is PM10; add 61 for TPM and 122 for PM2.5. P4 factors and ratings are also in D/E; PM2.5 has `NA` factors.

| Process | Electrode | Table A input | P1 base row | P4 base row | SCC suffix / note marker |
|---|---|---|---|---|---|
| SMAW | 14Mn-4Cr | C11 | 19 | 12 | (-04) |
| SMAW | E11018 | C12 | 20 | 13 | (-08)h |
| SMAW | E308 | C13 | 21 | 14 | (-12)i |
| SMAW | E309 | C14 | 22 | 15 | (-)j |
| SMAW | E310 | C15 | 23 | 16 | (-16)k |
| SMAW | E316 | C16 | 24 | 17 | (-20)m |
| SMAW | E410 | C17 | 25 | 18 | (-24)n |
| SMAW | E6010 | C18 | 26 | 19 | (-28) |
| SMAW | E6011 | C19 | 27 | 20 | (-32) |
| SMAW | E6012 | C20 | 28 | 21 | (-36) |
| SMAW | E6013 | C21 | 29 | 22 | (-40) |
| SMAW | E7018 | C22 | 30 | 23 | (-44) |
| SMAW | E7024 | C23 | 31 | 24 | (-48) |
| SMAW | E7028 | C24 | 32 | 25 | (-52) |
| SMAW | E8018 | C25 | 33 | 26 | (-56)p |
| SMAW | E9015 | C26 | 34 | 27 | (-60)q |
| SMAW | E9018 | C27 | 35 | 28 | (-64)r |
| SMAW | ECoCr | C28 | 36 | 29 | (-68)s |
| SMAW | ENi-Cl | C29 | 37 | 30 | (-72) |
| SMAW | ENiCrMo | C30 | 38 | 31 | (-76)t |
| SMAW | ENi-Cu | C31 | 39 | 32 | (-80)u |
| GMAW | E308L | C34 | 42 | 35 | (-12)v |
| GMAW | E309 | C35 | 43 | 36 | (-) |
| GMAW | E70S | C36 | 44 | 37 | (-54)w |
| GMAW | ER1260 | C37 | 45 | 38 | (-10) |
| GMAW | ER5154 | C38 | 46 | 39 | (-26) |
| GMAW | ER316 | C39 | 47 | 40 | (-20)x |
| GMAW | ER4043 | C40 | 48 | 41 | (-) |
| GMAW | ER5356 | C41 | 49 | 42 | (-) |
| GMAW | ERNiCr-3 | C42 | 50 | 43 | (-) |
| GMAW | ERNiCrMo | C43 | 51 | 44 | (-76)y |
| GMAW | ERNiCu | C44 | 52 | 45 | (-80)z |
| FCAW | E110 | C47 | 55 | 48 | (-06)aa |
| FCAW | E11018 | C48 | 56 | 49 | (-08) |
| FCAW | E308LT | C49 | 57 | 50 | (-12)bb |
| FCAW | E309 | C50 | 58 | 51 | (-)cc |
| FCAW | E316LT | C51 | 59 | 52 | (-20)dd |
| FCAW | E70T | C52 | 60 | 53 | (-54)ee |
| FCAW | E71T | C53 | 61 | 54 | (-55)ff |
| SAW | EM12K | C56 | 64 | 57 | (-10)gg |
| SAW | ER309 | C57 | 65 | 58 | (-)hh |
| SAW | ER316 | C58 | 66 | 59 | (-)ii |
| GTAW | ER2319 | C61 | 69 | 62 | (-) |
| GTAW | ER4043 | C62 | 70 | 63 | (-) |
| PAW | ER2319 | C65 | 73 | 66 | (-) |
| PAW | ER4043 | C66 | 74 | 67 | (-) |

### A.2 Substance factors

| Process / electrode | Cr | Co | Ni | Mn | Cr(VI) | Pb | Zn |
|---|---|---|---|---|---|---|---|
| SMAW / 14Mn-4Cr | 1.39 (C) | 0 (-) | 1.71 (C) | 23.2 (C) | 0 (-) | 0 (-) | 0 (-) |
| SMAW / E11018 | 0 (-) | 0 (-) | 0 (-) | 1.38 (C) | 0 (-) | 0 (-) | 0 (-) |
| SMAW / E308 | 0.59 (D) | 0.001 (D) | 0.1 (D) | 0.43 (D) | 0.2 (D) | 0.01 (D) | 0.0056 (D) |
| SMAW / E309 | 0.71 (D) | 0 (-) | 0.06 (D) | 0.4 (D) | 0.09 (D) | 0.01 (D) | 0 (-) |
| SMAW / E310 | 2.53 (C) | 0 (-) | 0.196 (C) | 2.2 (C) | 1.88 (C) | 0.024 (C) | 0 (-) |
| SMAW / E316 | 0.54 (D) | 0 (-) | 0.06 (D) | 0.54 (D) | 0.22 (D) | 0.01 (D) | 0.0056 (D) |
| SMAW / E410 | 0 (-) | 0 (-) | 0.014 (C) | 0.685 (C) | 0 (-) | 0 (-) | 0 (-) |
| SMAW / E6010 | 0.003 (B) | 0 (-) | 0.004 (B) | 0.991 (B) | 0.001 (B) | 0 (-) | 1.63 (D) |
| SMAW / E6011 | 0.005 (C) | 0.001 (C) | 0.005 (C) | 0.998 (C) | 0 (-) | 0 (-) | 1.63 (D) |
| SMAW / E6012 | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 1.63 (D) |
| SMAW / E6013 | 0.004 (B) | 0.0005 (-) | 0.002 (B) | 0.945 (B) | 0 (-) | 0 (-) | 1.63 (D) |
| SMAW / E7018 | 0.006 (C) | 0.0005 (-) | 0.051 (D) | 0.98 (C) | 0 (-) | 0 (-) | 1.63 (D) |
| SMAW / E7024 | 0.001 (C) | 0 (-) | 0 (-) | 0.629 (C) | 0 (-) | 0 (-) | 1.63 (D) |
| SMAW / E7028 | 0.013 (C) | 0 (-) | 0 (-) | 0.8461 (C) | 0 (-) | 0.162 (C) | 1.63 (D) |
| SMAW / E8018 | 0.017 (C) | 0 (-) | 0.051 (C) | 0.03 (C) | 0 (-) | 0 (-) | 1.63 (D) |
| SMAW / E9015 | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) |
| SMAW / E9018 | 0.212 (C) | 0 (-) | 0.013 (C) | 0.783 (C) | 0 (-) | 0 (-) | 0 (-) |
| SMAW / ECoCr | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) |
| SMAW / ENi-Cl | 0 (-) | 0 (-) | 0.89 (C) | 0.039 (C) | 0 (-) | 0 (-) | 0 (-) |
| SMAW / ENiCrMo | 0.42 (C) | 0 (-) | 0.247 (C) | 0.043 (C) | 0 (-) | 0 (-) | 0 (-) |
| SMAW / ENi-Cu | 0 (-) | 0 (-) | 0.423 (C) | 0.212 (C) | 0 (-) | 0 (-) | 0 (-) |
| GMAW / E308L | 0.19 (D) | 0.0005 (-) | 0.07 (D) | 0.16 (D) | 0.009 (D) | 0 (-) | 0.0056 (D) |
| GMAW / E309 | 4.6 (D) | 0 (-) | 0 (-) | 0 (-) | 0.0475 (D) | 0 (-) | 0 (-) |
| GMAW / E70S | 0.001 (A) | 0.0005 (-) | 0.03 (A) | 0.332 (A) | 0 (-) | 0.0003 (D) | 0.0081 (D) |
| GMAW / ER1260 | 0.004 (D) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) |
| GMAW / ER5154 | 0.01 (D) | 0 (-) | 0 (-) | 0.034 (D) | 0 (-) | 0 (-) | 0 (-) |
| GMAW / ER316 | 0.36 (D) | 0.002 (D) | 0.35 (D) | 0.3 (D) | 0.0173 (D) | 0 (-) | 0.0056 (D) |
| GMAW / ER4043 | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) |
| GMAW / ER5356 | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) |
| GMAW / ERNiCr-3 | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) |
| GMAW / ERNiCrMo | 0.353 (B) | 0 (-) | 1.25 (B) | 0.07 (B) | 0 (-) | 0 (-) | 0 (-) |
| GMAW / ERNiCu | 0.0005 (-) | 0 (-) | 0.451 (C) | 0.022 (C) | 0 (-) | 0 (-) | 0 (-) |
| FCAW / E110 | 0.002 (D) | 0 (-) | 0.112 (D) | 2.02 (D) | 0 (-) | 0 (-) | 0 (-) |
| FCAW / E11018 | 0.969 (C) | 0 (-) | 0.102 (C) | 0.704 (C) | 0 (-) | 0 (-) | 0 (-) |
| FCAW / E308LT | 0.24 (D) | 0 (-) | 0.07 (D) | 0.36 (D) | 0.02 (D) | 0 (-) | 0.0056 (D) |
| FCAW / E309 | 2.22 (D) | 0 (-) | 0 (-) | 0 (-) | 0.0146 (D) | 0 (-) | 0 (-) |
| FCAW / E316LT | 0.97 (B) | 0 (-) | 0.093 (B) | 0.59 (B) | 0.14 (B) | 0 (-) | 0.0056 (D) |
| FCAW / E70T | 0.004 (B) | 0 (-) | 0.005 (B) | 0.891 (B) | 0 (-) | 0 (-) | 0.01 (D) |
| FCAW / E71T | 0.002 (B) | 0.001 (B) | 0.012 (C) | 0.603 (B) | 0 (-) | 0 (-) | 0.01 (D) |
| SAW / EM12K | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) | 0 (-) |
| SAW / ER309 | 0.01 (D) | 0 (-) | 0.01 (D) | 0.09 (D) | 0 (-) | 0.01 (D) | 0 (-) |
| SAW / ER316 | 0.01 (D) | 0 (-) | 0 (-) | 0.07 (D) | 0 (-) | 0 (-) | 0 (-) |
| GTAW / ER2319 | 9.7e-05 (D) | 0 (-) | 0 (-) | 0.0002838 (D) | 0 (-) | 0.0001676 (D) | 0 (-) |
| GTAW / ER4043 | 4.28e-05 (D) | 0 (-) | 0 (-) | 4.22e-05 (D) | 0 (-) | 0.000233 (D) | 0 (-) |
| PAW / ER2319 | 0 (-) | 0 (-) | 0 (-) | 5.8e-06 (D) | 0 (-) | 4.4e-06 (D) | 0 (-) |
| PAW / ER4043 | 3.09e-05 (D) | 0 (-) | 0 (-) | 2.31e-05 (D) | 0 (-) | 7.6e-06 (D) | 0 (-) |

### A.3 Particulate factors

The same stored factor and rating apply to PM10 and TPM. PM2.5 uses 75% of the PM10 release.

| Process / electrode | PM10 / TPM factor (rating) |
|---|---|
| SMAW / 14Mn-4Cr | 81.6 (C) |
| SMAW / E11018 | 16.4 (C) |
| SMAW / E308 | 13.4 (C) |
| SMAW / E309 | 26.66 (D) |
| SMAW / E310 | 15.1 (C) |
| SMAW / E316 | 11.3 (C) |
| SMAW / E410 | 13.2 (D) |
| SMAW / E6010 | 25.6 (B) |
| SMAW / E6011 | 38.4 (C) |
| SMAW / E6012 | 8 (D) |
| SMAW / E6013 | 19.7 (B) |
| SMAW / E7018 | 18 (C) |
| SMAW / E7024 | 9.2 (C) |
| SMAW / E7028 | 18 (C) |
| SMAW / E8018 | 17.1 (C) |
| SMAW / E9015 | 17 (D) |
| SMAW / E9018 | 16.9 (C) |
| SMAW / ECoCr | 27.9 (C) |
| SMAW / ENi-Cl | 18.2 (C) |
| SMAW / ENiCrMo | 11.7 (C) |
| SMAW / ENi-Cu | 10.1 (C) |
| GMAW / E308L | 2.6 (D) |
| GMAW / E309 | 17.8 (-) |
| GMAW / E70S | 4.7 (A) |
| GMAW / ER1260 | 20.5 (D) |
| GMAW / ER5154 | 24.1 (D) |
| GMAW / ER316 | 3.2 (C) |
| GMAW / ER4043 | 7.78 (D) |
| GMAW / ER5356 | 106.69 (D) |
| GMAW / ERNiCr-3 | 2.6 (D) |
| GMAW / ERNiCrMo | 3.9 (C) |
| GMAW / ERNiCu | 2 (C) |
| FCAW / E110 | 20.8 (D) |
| FCAW / E11018 | 57 (D) |
| FCAW / E308LT | 5.5 (D) |
| FCAW / E309 | 19.5 (-) |
| FCAW / E316LT | 8.5 (B) |
| FCAW / E70T | 15.1 (B) |
| FCAW / E71T | 10.3 (B) |
| SAW / EM12K | 0.05 (C) |
| SAW / ER309 | 16.65 (D) |
| SAW / ER316 | 7.76 (D) |
| GTAW / ER2319 | 0.5489 (D) |
| GTAW / ER4043 | 5.2748 (D) |
| PAW / ER2319 | 0.3367 (D) |
| PAW / ER4043 | 0.4703 (D) |

## Appendix B. Other-welding defaults and exact factor formulas

### B.1 Method 1 constants

All values below are g/kg of electrode. All ratings are `-`. Copper, silver and antimony default to zero in Method 1.

| Process | P1 chromium row | Cr | Co | Ni | Mn | Cr(VI) | Pb | Zn | PM10 / TPM |
|---|---|---|---|---|---|---|---|---|---|
| Other SMAW | 40 | 0.46 | 0.001 | 0.255 | 1.963 | 0.179 | 0.043 | 1.305 | 20.6 |
| Other GMAW | 53 | 0.69 | 0.001 | 0.43 | 0.153 | 0.024 | 0.0003 | 0.006 | 17.8 |
| Other FCAW | 62 | 0.63 | 0.001 | 0.066 | 0.861 | 0.049 | 0 | 0.008 | 19.5 |
| Other SAW | 67 | 0.01 | 0 | 0.01 | 0.08 | 0 | 0.01 | 0 | 8.2 |
| Other GTAW | 71 | 6.99e-05 | 0 | 0 | 0.000163 | 0 | 0.0002003 | 0 | 2.9 |
| Other PAW | 75 | 3.09e-05 | 0 | 0 | 1.45e-05 | 0 | 6e-06 | 0 | 0.4 |
| Other Welding Methods | 77 | 0.298 | 0.001 | 0.19 | 0.51 | 0.05 | 0.011 | 0.44 | 11.6 |

### B.2 Every method-dependent welding factor

`A` means `Input Arc Welding Information`; `B` means `Input Arc Welding (Method 2)`. The formulas below replace only these sheet names for readability. Every factor is in `Part 1 Releases!D`; the final table covers `Part 4 Releases!D`. This preserves the exact constants, including the SAW chromium distinction.

#### Part 1

| Cell | Substance | Process | Formula |
|---|---|---|---|
| D40 | Cr | Other SMAW | `=IF(A!$C$6="Method 1",0.46,20*0.2865*B!R8)` |
| D53 | Cr | Other GMAW | `=IF(A!$C$6="Method 1",0.69,10*0.5464*B!R9)` |
| D62 | Cr | Other FCAW | `=IF(A!$C$6="Method 1",0.63,20*0.2865*B!R10)` |
| D67 | Cr | Other SAW | `=IF(A!$C$6="Method 1",0.01,(0.0053+0.00902)*B!R11)` |
| D71 | Cr | Other GTAW | `=IF(A!$C$6="Method 1",0.0000699,2.9*B!R12)` |
| D75 | Cr | Other PAW | `=IF(A!$C$6="Method 1",0.0000309,0.4*B!R13)` |
| D77 | Cr | Other Welding Methods | `=IF(A!$C$6="Method 1",0.298,50*B!R14)` |
| D101 | Co | Other SMAW | `=IF(A!$C$6="Method 1",0.001,20*0.2865*B!S8)` |
| D114 | Co | Other GMAW | `=IF(A!$C$6="Method 1",0.001,10*0.5464*B!S9)` |
| D123 | Co | Other FCAW | `=IF(A!$C$6="Method 1",0.001,20*0.2865*B!S10)` |
| D128 | Co | Other SAW | `=IF(A!$C$6="Method 1",0,0.0143*B!S11)` |
| D132 | Co | Other GTAW | `=IF(A!$C$6="Method 1",0,2.9*B!S12)` |
| D136 | Co | Other PAW | `=IF(A!$C$6="Method 1",0,0.4*B!S13)` |
| D138 | Co | Other Welding Methods | `=IF(A!$C$6="Method 1",0.001,50*B!S14)` |
| D162 | Ni | Other SMAW | `=IF(A!$C$6="Method 1",0.255,20*0.2865*B!T8)` |
| D175 | Ni | Other GMAW | `=IF(A!$C$6="Method 1",0.43,10*0.5464*B!T9)` |
| D184 | Ni | Other FCAW | `=IF(A!$C$6="Method 1",0.066,20*0.2865*B!T10)` |
| D189 | Ni | Other SAW | `=IF(A!$C$6="Method 1",0.01,0.0143*B!T11)` |
| D193 | Ni | Other GTAW | `=IF(A!$C$6="Method 1",0,2.9*B!T12)` |
| D197 | Ni | Other PAW | `=IF(A!$C$6="Method 1",0,0.4*B!T13)` |
| D199 | Ni | Other Welding Methods | `=IF(A!$C$6="Method 1",0.19,50*B!T14)` |
| D223 | Mn | Other SMAW | `=IF(A!$C$6="Method 1",1.963,20*0.2865*B!U8)` |
| D236 | Mn | Other GMAW | `=IF(A!$C$6="Method 1",0.153,10*0.5464*B!U9)` |
| D245 | Mn | Other FCAW | `=IF(A!$C$6="Method 1",0.861,20*0.2865*B!U10)` |
| D250 | Mn | Other SAW | `=IF(A!$C$6="Method 1",0.08,0.0143*B!U11)` |
| D254 | Mn | Other GTAW | `=IF(A!$C$6="Method 1",0.000163,2.9*B!U12)` |
| D258 | Mn | Other PAW | `=IF(A!$C$6="Method 1",0.0000145,0.4*B!U13)` |
| D260 | Mn | Other Welding Methods | `=IF(A!$C$6="Method 1",0.51,50*B!U14)` |
| D284 | Cr(VI) | Other SMAW | `=IF(A!$C$6="Method 1",0.179,20*0.2865*0.63*B!R8)` |
| D297 | Cr(VI) | Other GMAW | `=IF(A!$C$6="Method 1",0.024,10*0.5464*0.05*B!R9)` |
| D306 | Cr(VI) | Other FCAW | `=IF(A!$C$6="Method 1",0.049,20*0.2865*0.63*B!R10)` |
| D311 | Cr(VI) | Other SAW | `=IF(A!$C$6="Method 1",0,(0.00902)*B!R11)` |
| D315 | Cr(VI) | Other GTAW | `=IF(A!$C$6="Method 1",0,2.9*0.1*B!R12)` |
| D319 | Cr(VI) | Other PAW | `=IF(A!$C$6="Method 1",0,0.4*0.1*B!R13)` |
| D321 | Cr(VI) | Other Welding Methods | `=IF(A!$C$6="Method 1",0.05,50*0.1*B!R14)` |
| D345 | Pb | Other SMAW | `=IF(A!$C$6="Method 1",0.043,20*0.2865*B!V8)` |
| D358 | Pb | Other GMAW | `=IF(A!$C$6="Method 1",0.0003,10*0.5464*B!V9)` |
| D367 | Pb | Other FCAW | `=IF(A!$C$6="Method 1",0,20*0.2865*B!V10)` |
| D372 | Pb | Other SAW | `=IF(A!$C$6="Method 1",0.01,0.0143*B!V11)` |
| D376 | Pb | Other GTAW | `=IF(A!$C$6="Method 1",0.0002003,2.9*B!V12)` |
| D380 | Pb | Other PAW | `=IF(A!$C$6="Method 1",0.000006,0.4*B!V13)` |
| D382 | Pb | Other Welding Methods | `=IF(A!$C$6="Method 1",0.011,50*B!V14)` |
| D406 | Zn | Other SMAW | `=IF(A!$C$6="Method 1",1.305,20*0.2865*B!W8)` |
| D419 | Zn | Other GMAW | `=IF(A!$C$6="Method 1",0.006,10*0.5464*B!W9)` |
| D428 | Zn | Other FCAW | `=IF(A!$C$6="Method 1",0.008,20*0.2865*B!W10)` |
| D433 | Zn | Other SAW | `=IF(A!$C$6="Method 1",0,0.0143*B!W11)` |
| D437 | Zn | Other GTAW | `=IF(A!$C$6="Method 1",0,2.9*B!W12)` |
| D441 | Zn | Other PAW | `=IF(A!$C$6="Method 1",0,0.4*B!W13)` |
| D443 | Zn | Other Welding Methods | `=IF(A!$C$6="Method 1",0.44,50*B!W14)` |
| D446 | Cu | Other SMAW | `=IF(A!$C$6="Method 1",0,20*0.2865*B!X8)` |
| D448 | Cu | Other GMAW | `=IF(A!$C$6="Method 1",0,10*0.5464*B!X9)` |
| D450 | Cu | Other FCAW | `=IF(A!$C$6="Method 1",0,20*0.2865*B!X10)` |
| D452 | Cu | Other SAW | `=IF(A!$C$6="Method 1",0,0.0143*B!X11)` |
| D454 | Cu | Other GTAW | `=IF(A!$C$6="Method 1",0,2.9*B!X12)` |
| D456 | Cu | Other PAW | `=IF(A!$C$6="Method 1",0,0.4*B!X13)` |
| D458 | Cu | Other Welding Methods | `=IF(A!$C$6="Method 1",0,50*B!X14)` |
| D461 | Ag | Other SMAW | `=IF(A!$C$6="Method 1",0,20*0.2865*B!Y8)` |
| D463 | Ag | Other GMAW | `=IF(A!$C$6="Method 1",0,10*0.5464*B!Y9)` |
| D465 | Ag | Other FCAW | `=IF(A!$C$6="Method 1",0,20*0.2865*B!Y10)` |
| D467 | Ag | Other SAW | `=IF(A!$C$6="Method 1",0,0.0143*B!Y11)` |
| D469 | Ag | Other GTAW | `=IF(A!$C$6="Method 1",0,2.9*B!Y12)` |
| D471 | Ag | Other PAW | `=IF(A!$C$6="Method 1",0,0.4*B!Y13)` |
| D473 | Ag | Other Welding Methods | `=IF(A!$C$6="Method 1",0,50*B!Y14)` |
| D476 | Sb | Other SMAW | `=IF(A!$C$6="Method 1",0,20*0.2865*B!Z8)` |
| D478 | Sb | Other GMAW | `=IF(A!$C$6="Method 1",0,10*0.5464*B!Z9)` |
| D480 | Sb | Other FCAW | `=IF(A!$C$6="Method 1",0,20*0.2865*B!Z10)` |
| D482 | Sb | Other SAW | `=IF(A!$C$6="Method 1",0,0.0143*B!Z11)` |
| D484 | Sb | Other GTAW | `=IF(A!$C$6="Method 1",0,2.9*B!Z12)` |
| D486 | Sb | Other PAW | `=IF(A!$C$6="Method 1",0,0.4*B!Z13)` |
| D488 | Sb | Other Welding Methods | `=IF(A!$C$6="Method 1",0,50*B!Z14)` |

#### Part 4

| Cell | Substance | Process | Formula |
|---|---|---|---|
| D33 | PM10 | Other SMAW | `=IF(A!$C$6="Method 1",20.6,20)` |
| D46 | PM10 | Other GMAW | `=IF(A!$C$6="Method 1",17.8,10)` |
| D55 | PM10 | Other FCAW | `=IF(A!$C$6="Method 1",19.5,20)` |
| D60 | PM10 | Other SAW | `=IF(A!$C$6="Method 1",8.2,0.05)` |
| D64 | PM10 | Other GTAW | `=IF(A!$C$6="Method 1",2.9,2.9)` |
| D68 | PM10 | Other PAW | `=IF(A!$C$6="Method 1",0.4,0.4)` |
| D70 | PM10 | Other Arc Welding Methods | `=IF(A!$C$6="Method 1",11.6,50)` |

## Appendix C. All cutting and spraying factors

### C.1 Cutting

PM10 and TPM use identical stored defaults, in g/min. PM2.5 is calculated from PM10, with `NA` in its factor column. P4 rows below are PM10 rows; add 9 for TPM and 18 for PM2.5.

| Process | Cutting input row | P4 row | PM10 / TPM factor | Rating |
|---|---|---|---|---|
| Oxy | 6 | 12 | 0.38 | D |
| Air Carbon Arc Cutting (CAC-A) | 7 | 13 | 2 | D |
| Plasma Arc Cutting (PAC) | 8 | 14 | 5.3 | D |
| Laser | 9 | 15 | 0.26 | D |
| Arc SAW | 10 | 16 | 1.17 | D |
| Grinder | 11 | 17 | 0.39 | D |
| Reciprocating Saw | 12 | 18 | 0.00019 | D |
| Other Cutting Methods | 13 | 19 | 1.6 | - |

### C.2 Spraying metals

Factors are g of released substance per kg of that substance in sprayed material. Each entry is `value (rating)`. P1 base row identifies chromium; add 7, 14, 21, 28, 35, 42, 49, 56 or 63 for Co, Ni, Mn, Cr(VI), Pb, Zn, Cu, Ag or Sb.

| Process | Spraying input row | P1 base row | Cr | Co | Ni | Mn | Cr(VI) | Pb | Zn | Cu | Ag | Sb |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Plasma Spray | 6 | 19 | 90.9 (D) | 60 (-) | 150 (D) | 60 (-) | 11.8 (D) | 60 (-) | 60 (-) | 60 (-) | 60 (-) | 60 (-) |
| Flame Spray (Single-wire ) | 7 | 20 | 15.6 (D) | 16.6 (-) | 16.6 (-) | 16.6 (-) | 4.68 (D) | 16.6 (-) | 16.6 (-) | 16.6 (-) | 16.6 (-) | 16.6 (-) |
| Flame Spray (Other) | 8 | 21 | 44.9 (-) | 60 (-) | 110 (D) | 60 (-) | 6.2 (D) | 60 (-) | 60 (-) | 60 (-) | 60 (-) | 60 (-) |
| Electric Arc Spray | 9 | 22 | 23.2 (D) | 19.75 (-) | 6 (D) | 19.75 (-) | 6.96 (D) | 19.75 (-) | 19.75 (-) | 19.75 (-) | 19.75 (-) | 19.75 (-) |
| High velocity oxy-fuel coating spraying (HVOF) | 10 | 23 | 44.9 (-) | 60 (-) | 110 (D) | 60 (-) | 6.2 (D) | 60 (-) | 60 (-) | 60 (-) | 60 (-) | 60 (-) |
| Other Spraying Methods | 11 | 24 | 44.9 (D) | 60 (-) | 94 (D) | 60 (-) | 7.17 (D) | 60 (-) | 60 (-) | 60 (-) | 60 (-) | 60 (-) |

### C.3 Spraying particulate base factors

Factors are g/kg of total material sprayed, before the metal-sum floor. P4 rows below are PM10 rows; add 7 for TPM and 14 for PM2.5.

| Process | P4 row | PM10 / TPM base factor | Rating |
|---|---|---|---|
| Plasma Spray | 12 | 60 | - |
| Flame Spray (Single-wire ) | 13 | 16.6 | D |
| Flame Spray (Other) | 14 | 60 | - |
| Electric Arc Spray | 15 | 19.75 | D |
| High velocity oxy-fuel coating spraying (HVOF) | 16 | 60 | - |
| Other Spraying Methods | 17 | 60 | - |

## Appendix D. Electrode aliases and workbook source bibliography

### D.1 Electrode aliases and process notes

These are the workbook’s own notes, including its spelling. Match each letter marker to the SCC/note-marker column in Appendix A.1; the G-column row number is the note location, not the electrode input row. They document the grouping, without adding new equivalences. The SCC families are SMAW `309051xx`, GMAW `309052xx`, FCAW `309053xx`, and SAW `309054xx`. The workbook does not assign SCC family codes to GTAW, PAW or Other Arc Welding Methods.

| Cell in Table A sheet | Workbook note |
|---|---|
| G10 | Notes: |
| G11 | h. Includes E11018-M |
| G12 | i. Includes E308-16, E308L-15, E308L-16, E308-17, E308L-17, and E308H-17 |
| G13 | j. Includes E309-16, E309-17, and E309L-17 |
| G14 | k. Includes E310-16 |
| G15 | m. Includes E316-15, E316-16, and E316L-16 |
| G16 | n. Includes E410-16 |
| G17 | p. Includes E8018C3 |
| G18 | q. Includes E9015B3 |
| G19 | r. Includes E9018B3 and E9018G |
| G20 | s. Includes ECoCr-A |
| G21 | t. Includes ENiCrMo-4 |
| G22 | u. Includes ENi-Cu-2 |
| G23 | v. Includes E308LSi, and ER308L |
| G24 | w. Includes E70S-3, E70S-5, and E70S-6 |
| G25 | x. Includes ER316I-Si and ER316L-Si |
| G26 | y. Includes ENiCrMo-3 and ENi-CrMo-4 |
| G27 | z. Includes ERNiCu-7 |
| G28 | aa. Includes E110TS-K3 |
| G29 | bb. Includes E308LT-3, and E308LT0-1 |
| G30 | cc. Includes E309, and E309LT-1 |
| G31 | dd. Includes E316LT-3 |
| G32 | ee. Includes E70T-1, E70T-2, E70T-4, E70T-5, E70T-7, and E70T-G |
| G34 | ff. Includes E71T-1, E71T-11, E71T-1M, E71T-12MJ, and E71T-1C |
| G35 | gg. Includes EM12K1 and F72-EM12K2 |
| G36 | hh. Includes ER309 and ER309L |
| G37 | ii.Includes ER316 and ER316L |
| G42 | 1. This process includes Metal Inert Gas (MIG) and Metal Active Gas (MAG)  |
| G43 | 2. This process includes Tungsten Inert Gas (TIG) |
| G44 | 3. Only if filler materials are used |
| G45 | 4. Only if filler materials are used |

### D.2 Bibliography recorded by the workbook

These references are transcribed from `Instructions`; their underlying publications were not independently reviewed for this reverse engineering. The workbook does not supply a source-by-factor citation map.

| Instructions cell | Recorded source |
|---|---|
| A27 | Emission factors are from the US EPA's WebFIRE (version of December 2005) database. |
| A28 | AP-42 Chapter 12.19, Electric Arc Welding (version of January 1995) |
| A29 | Emission of Fume, Nitrogen Oxides and Noise in Plasma Cutting of Stainless and Mild Steel (1994) |
| A30 | Fume Generation Rates for Stainless Steel, Nickel and Aluminum Alloys (Pulsed GMAW) (1996) |
| A31 | Shipyard Welding Emission Factor Development (1999) |
| A32 | Development of Emission Inventory for Metal Welding, Cutting and Spraying Operations (2000)  |
| A33 | Fume Generation and Content of Total Chromium and Hexavalent Chromium in Flux-cored Arc Welding (2003) |
| A34 | Airborne Toxic Control Measure to Reduce Emissions of Hexavalent Chromium and Nickel from Thermal Spraying (2005) |
| A35 | Methodology for Estimating Hexavalent Chromium Emissions from Thermal Spraying (2005) |
| A36 | Emissions of Chromium (VI) from Arc Welding (2007) |
| A37 | Fume emissions during gas metal arc welding (2007) |
| A38 | Measurement of secondary emissions during laser cutting of steel equipments (2008) |
| A39 | Total Fume and Heavy Metals Emission Factors Applicable to Aluminum-Lithium Alloy Welding (2010) |
| A40 | Development of Welding Emission Factors for Cr and Cr(VI) with a Confidence Level (2012) |
| A41 | Profiling Mild Steel Welding Processes to Reduce Fume Emissions and Costs in the Workplace (2014) |
| A42 | Profiling stainless steel welding processes to reduce fume emissions, hexavalent chromium emissions and operating costs in the workplace (2016) |
| A43 | Factors Affecting the Capture Efficiency of a Fume Extraction Torch for Gas Metal Arc Welding (2016) |
| A44 | Characterization of Particulate Fume and Oxides Emission from Stainless Steel Plasma Cutting (2016) |
| A45 | Calculations Guidance Package Metal Spraying (2018) |
| A46 | Evaluation of Total Fume and Heavy Metal Emission Factors Applicable to Gas Metal Arc Welding (2019) |
| A47 | Total Fume Emissions and Emission Factors Applicable to Gas Metal Arc Welding (2019) |
| A48 | Air Pollution Control District of San Diego County, Welding Operations (1998) |

