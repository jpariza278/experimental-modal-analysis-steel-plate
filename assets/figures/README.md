# Figure asset guide

Add the figures below to this folder using the listed filenames. The repository
README already contains a visible placeholder and caption for each one; replace
each placeholder with the corresponding Markdown image link after adding it.

The source mapping refers to the embedded media inside `Rapport DYNAE.docx`.
It is included to make the original figure easy to locate; the source images
are deliberately not copied into this repository yet.

| Filename to add | Report source | What it should show | README section |
| --- | --- | --- | --- |
| `01-experimental-mesh.png` | `word/media/image12.png` | The 27 sensor locations (blue) and three shaker locations (red). | Experimental setup |
| `02-mvmif.png` | `word/media/image2.png` | Multivariate MIF over the measured frequency range, including the close resonances near 280 Hz. | Resonance identification |
| `03-colocated-frfs.png` | `word/media/image17.png` | Colocated FRF magnitude and phase traces, showing resonance/antiresonance behavior. | FRF quality checks |
| `04-frf-model-comparison.png` | `word/media/image5.png` | Measured versus model/FE FRFs at representative response/reference pairs. | FRF quality checks |
| `05-representative-mode-shape.png` | `word/media/image20.png` | A representative extracted mode shape (the report shows mode 4 at 99.2 Hz). A composite of several modes is also acceptable. | Identified mode shapes |
| `06-mac-experimental-vs-fe.png` | `word/media/image19.png` | Experimental-versus-FE MAC matrix. | FE validation |
| `07-comac.png` | `word/media/image18.png` | COMAC map over the FE mesh. | FE validation |
| `08-ecomac.png` | `word/media/image21.png` | eCOMAC map over the FE mesh. | FE validation |
| `09-frequency-comparison.png` | `word/media/image23.png` | Experimental and numerical natural-frequency comparison. | FE validation |

## Preparing images

- Export/crop each figure from the report at readable resolution; PNG is
  preferred for plots and linework.
- Keep axis labels, legends and colour bars readable at GitHub page width.
- Use the exact filenames above so the README links can be added without
  changing the project structure.
- Do not add the report cover/logo, intermediate mesh-numbering screenshots,
  or duplicated MvMIF plots unless they add context not covered by the list.

