# Experimental Modal Analysis of a Free Steel Plate

MATLAB workflow and project report for identifying and validating the vibration modes of a free-boundary rectangular steel plate.

This was developed for the *Expérimentation et validation de modèles en dynamique des structures* course. It combines measured frequency-response functions (FRFs), experimental modal analysis (EMA), and comparison with a finite-element (FE) model.

## What the project demonstrates

- Pre-test design of sensor and shaker layouts, including the impact of nodal lines.
- MIMO experimental modal analysis using 27 response sensors and three excitation points.
- FRF quality checks: colocated antiresonances, phase rotations, and reciprocity.
- Identification of natural frequencies, damping ratios, poles, modal residues, and complex/real mode shapes.
- Experimental-to-FE validation using MAC, COMAC, eCOMAC, frequency comparison, and FRF overlays.

The report finds overall agreement between experimental and FE resonance frequencies. It also shows why exciter/sensor placement matters, especially for closely spaced modes around 280 Hz.

## Repository guide

| Path | Description |
| --- | --- |
| [`Versions code/main_EMA_TD4_3.m`](<Versions code/main_EMA_TD4_3.m>) | Multi-reference MATLAB EMA workflow; the best starting point for the reported three-shaker configuration. |
| [`Versions code/main_EMA_R.m`](<Versions code/main_EMA_R.m>) | Earlier, single-reference-oriented EMA variant. |
| [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) | Detailed project, code, input/output, and validation context. |
| `Rapport DYNAE.docx` | Main project report (French). |
| `PRE-TEST.docx` and notes | Supporting pre-test and implementation notes (French). |

## Method overview

```text
UFF FRFs + UNV geometry
          |
          v
sign/unit normalization -> mobility FRFs
          |
          v
FRF diagnostics + MvMIF resonance candidates
          |
          v
LSCE pole identification -> modal residues -> complex mode shapes
          |
          v
real mode extraction -> Auto-MAC / mode animation / FE comparison
```

The scripts can also run ODS (operating deflection shapes) and numerical modal appropriation. EMA is the default analysis path.

## Requirements

- MATLAB (the scripts use MATLAB plotting and linear-algebra functions).
- An implementation of `uffread` for UFF/UNV import.
- An implementation of `lsce` for least-squares complex-exponential pole identification.
- Measurement files referenced by the scripts: `fram_frf.uff` and `fram_geo.unv`.

The measurement files and the `uffread`/`lsce` implementations are not included here, so a complete run is not reproducible from this repository alone.

## Running the analysis

1. Add `uffread` and `lsce` to the MATLAB path.
2. Put the UFF/UNV measurement files in the working directory, or update `Data_File` and `Model_File` in the script.
3. Open `Versions code/main_EMA_TD4_3.m`, set `Method = 'EMA'`, and run it section by section.
4. Use the plotted FRFs and synthesized-FRF overlays to check the fit. The script pauses between diagnostics.
5. Use the saved `PhiExp_EMA.mat` with FE modes for MAC/COMAC/eCOMAC validation.

## Important implementation note

The report excludes the third shaker from modal identification because its position lies on nodal lines for some modes. `main_EMA_TD4_3.m` correctly limits LSCE pole identification to the first 54 FRFs, but its later residue/mode averaging loops still include all references. Before applying this code to the reported setup, make that exclusion consistent throughout the residue and mode-shape stages. See [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) for details.

## Project status

Course project / archival portfolio repository. The code is retained as an analysis record and includes its original interactive workflow. A future cleanup could package the script into functions, add the missing data/toolbox dependencies, parameterize channel selection, and include reproducible validation outputs.

## Documentation

The report and source code are primarily in French; this README and [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) provide an English entry point.
