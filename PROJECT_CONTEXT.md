# Project context — DYNAE TD6

## Purpose

This project supports the experimental modal analysis (EMA) and validation of a free-boundary rectangular steel plate. Its goal is to identify the plate's natural frequencies, damping and mode shapes from measured frequency-response functions (FRFs), then compare the experimental results with a finite-element (FE) model.

The accompanying report is *Rapport DYNAE.docx* (French), titled *Analyse modale d'une plaque rectangulaire*. It presents a pre-test, the experimental modal analysis, and a post-test validation using MAC, COMAC and eCOMAC.

## Repository contents

| Path | Role |
| --- | --- |
| `Versions code/main_EMA_R.m` | Earlier single-reference-oriented MATLAB implementation. It includes an intermediate and final FRF synthesis inside the EMA branch. |
| `Versions code/main_EMA_TD4_3.m` | Multi-reference EMA revision. It adds debug `flag` messages, conjugate-pole/residual fitting, and complex-mode averaging across references; after the method branch it calculates Auto-MAC, animates modes, and saves `PhiExp_<Method>.mat`. |
| `Rapport DYNAE.docx` | Main project report and interpretation of the experimental campaign. |
| `SUPPORTING_NOTES_SUMMARY.txt` | Consolidated code- and experiment-relevant content from the supporting working notes removed during portfolio preparation. |

> The measured UFF/UNV data files named by the scripts (`fram_frf.uff` and `fram_geo.unv`) are not present in this repository. The analysis cannot be run end-to-end without them.

## Experimental setup and key findings

- The plate is tested in free boundary conditions.
- The reported experimental mesh uses 27 response sensors and 3 shakers, producing 81 FRFs (27 responses × 3 references).
- FRFs associated with the third shaker are excluded from the EMA pole-identification step. The report says that shaker is on a modal nodal line for some modes, which degrades the data; therefore only the first 54 FRFs, corresponding to shakers/nodes `0` and `21`, are used for identification.
- The pre-test establishes that sensor and exciter placement matters: avoid nodal lines, and place response sensors in regions with measurable motion. The report concludes that at least 2 shakers and 8 sensors are needed for a reliable measurement of this plate.
- Closely spaced modes are expected around 280 Hz. The report notes that multiple exciters are important for separating such modes in a real experiment.
- Reported qualitative checks are successful: colocated FRFs show expected antiresonances and phase rotations, and reciprocal FRFs are symmetric. The FE and experimental resonance frequencies are described as globally well correlated.

## MATLAB workflow

Both scripts are MATLAB scripts, not standalone functions. They require the custom/toolbox functions `uffread` and `lsce` to be available on the MATLAB path.

1. **Read measured FRFs.** `uffread(Data_File,58,4)` reads the UFF dataset 58 data and metadata: `H`, frequency increment, locations, type, units and frequency vector.
2. **Normalise sign and units.** Measurement-direction signs are applied from `loc`; displacement or acceleration receptances are converted to velocity/force mobility, `Hv`, in `m/s/N`.
3. **Read and display geometry.** `uffread(Model_File,15)` reads the UNV geometry/connectivity. The script plots the wireframe plus response points (blue) and reference/excitation points (red).
4. **Check FRFs.** It plots all FRF magnitudes/phases, then colocated FRFs (to inspect antiresonances and phase) and reciprocal FRFs (to inspect linearity/reciprocity).
5. **Locate candidate resonances.** A multivariate mode-indicator function (MvMIF) is computed from the real and imaginary parts of the reshaped FRF matrix. Local minima below `0.75` become candidate modal frequencies.
6. **Choose modal-analysis method.** Set `Method` near the start of the script to `ODS`, `Appropriation`, or `EMA`.
   - `ODS`: uses response mobility at candidate resonance frequencies for the first excitation.
   - `Appropriation`: computes a numerical excitation pattern from a generalized eigenvalue problem and uses it to form operating deflection shapes.
   - `EMA` (default): runs `lsce` on `Hv(1:54,:)` to estimate poles/frequencies and damping. The code turns frequencies and damping into damped poles, then fits FRF residues by least squares.
7. **Derive and inspect modes.** The scripts synthesize fitted FRFs for comparison to measurements. The multi-reference revision derives complex modes from residues, averages them across references, rotates them into real normal modes, calculates Auto-MAC, displays mode complexity, animates the plate, and saves the measured out-of-plane modes as `PhiExp_EMA.mat` when `Method = 'EMA'`.

## Important variables

| Variable | Meaning |
| --- | --- |
| `H` | Measured FRFs as read from UFF. |
| `Hv` | Sign-corrected velocity/force mobility FRFs. |
| `freq`, `W` | Frequency in Hz and angular frequency in rad/s. |
| `loc`, `kresp`, `kref` | FRF location metadata, unique response degrees of freedom, and unique reference degrees of freedom. |
| `MvMIF` | Multivariate mode indicator function used to select candidate resonances. |
| `freq_modes`, `xir`, `lbdr` | Identified modal frequencies, damping ratios and complex damped poles. |
| `A`, `R` | Modal residues and residual terms used for FRF synthesis. |
| `Psi`, `Phi` | Complex and real/normal mode-shape estimates. |
| `MAC` | Auto-modal-assurance matrix, used to assess modal independence. |

## Version notes and cautions

- For the reported three-shaker experiment, start from `Versions code/main_EMA_TD4_3.m`: unlike `main_EMA_R.m`, it constructs a complex mode for each reference and then averages the result. The shared post-processing after its `end` performs the complex-to-real rotation, Auto-MAC, animation and `PhiExp` export.
- `main_EMA_R.m` allocates `A` for all FRFs but, in its EMA branch, assigns all of `A(:,rmod)` to a `Psi(:,rmod)` vector sized only for responses. With the reported 81-FRF/27-response setup, that is dimensionally inconsistent; it must be corrected or restricted to one reference before use.
- `main_EMA_TD4_3.m` fits both conjugate poles and a residual term, and averages complex modes obtained from references. Its `flag1`, `flag2` and `flag3:EMA` outputs appear to be debugging markers.
- The scripts are interactive: several `pause` calls deliberately stop execution between diagnostics. They also open many figures.
- The hard-coded `Hv(1:54,:)` selection assumes a particular FRF ordering (the first two references are the usable shakers). Verify this ordering against `loc` whenever a different data set is used.
- Although pole identification uses only `Hv(1:54,:)`, `main_EMA_TD4_3.m` subsequently fits residues for all `nfunc` FRFs and averages all `nref` reference-derived modes. Thus, as written, it still reintroduces the third shaker during mode-shape construction; change those loops/reference indices if the report's 54-FRF exclusion is intended to apply throughout EMA.
- The code assumes FRFs can be reshaped as `nresp × nref`; this depends on the UFF record ordering.
- The scripts use hard-coded residue-fit frequency ranges (`1:350` Hz in `main_EMA_R.m`; `1:300` Hz in `main_EMA_TD4_3.m`). These should be checked against the actual measurement bandwidth and selected modes.
- The report notes that high-frequency residual effects are not included. Adding upper residual terms is a potential improvement to the model fit.

## Validation interpretation

Validation should combine several views rather than rely on a single score:

- **FRF overlay:** compare measured and synthesized resonance locations, amplitudes and antiresonances.
- **Auto-MAC:** expect values near 1 on the diagonal and low off-diagonal values for distinct modes.
- **Experimental vs FE modes:** use MAC for global mode-pair correlation; use COMAC/eCOMAC to locate coordinate-level discrepancies. The report cautions that a poor coordinate correlation does not by itself prove that the underlying modeling error originates at that coordinate.
- **Frequency comparison:** compare the ordered experimental and FE natural frequencies; the report finds their overall trend consistent.

## How to resume work

1. Obtain/place `fram_frf.uff` and `fram_geo.unv` in the MATLAB working directory, or update `Data_File` and `Model_File` in the selected script.
2. Add the implementation/toolbox providing `uffread` and `lsce` to the MATLAB path.
3. Confirm FRF ordering and the usable reference channels from `loc` before retaining the hard-coded 54-FRF EMA subset.
4. Run `main_EMA_TD4_3.m` with `Method = 'EMA'`; first make the 54-FRF reference selection consistent through pole fitting, residue fitting and reference averaging. Progress through the interactive plots and compare synthesized against measured FRFs.
5. Use the generated `PhiExp_EMA.mat` together with the FE mode data for MAC/COMAC/eCOMAC post-test validation.

## Sources used for this context

- `Rapport DYNAE.docx`
- `Versions code/main_EMA_R.m`
- `Versions code/main_EMA_TD4_3.m`
