# Documents for HSE review

Open **index.html** in a browser (double-click it). Each document is here twice: as a web page (`.html`, easiest to read and print) and as the original Markdown (`.md`).

1. **Reverse engineering of the ECCC Excel calculator**: `01-workbook-calculation-guide.html`. Every calculation path, input, default factor, coefficient and output in the 2022-10-26 welding, cutting and spraying workbook, with cell references and the workbook’s inconsistencies. Start here.
2. **How the app reproduces the workbook**: `02-workbook-reproduction-spec.html`. How the workbook becomes app data, and how inputs clients don’t know (grinding hours, electrode kg) are derived from purchases.
3. **Proof: app = Excel (393/393)**: `03-workbook-parity-results.html`. Results of running 393 scenarios through both the app and the official workbook. Every result matched.
4. **Defaults that need HSE approval (due 11 Dec 2026)**: `04-defaults-for-hse-approval.html`. The default values the app proposes when a client doesn’t know an input. An HSE practitioner needs to approve, change or reject each one.
5. **Open questions for practitioners**: `05-decisions-risks-open-questions.html`. Interpretation questions where the Notice, the Guide and the workbook disagree or are silent, such as the stack NOx threshold and the Cr(VI) basis.
6. **Substance list crosscheck (2025–2027 Notice)**: `06-regulation-crosscheck.html`. Check of the app’s NPRI substance and threshold list against the official workbook.
7. **Technical appendix: first workbook recalculation test**: `07-workbook-recalc-spike-findings.html`. How the workbook was first recalculated outside Excel to prove it could be checked automatically. Technical.

`source/` holds the official ECCC workbook and the Canada.ca reporting guide that were analysed.
