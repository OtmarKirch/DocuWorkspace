# DocuWorkspace

DocuWorkspace is my personal setup to store, manage and produce data and an appropriate text processing for scientific work of MINT subjects. Jupyter Notebook is used for the analysis of data and Latex for the actual documentation.
This project grows and changes steadily, according to my current needs.

## Requirements

In order to build the Latex project, you need to install the required Tex and packages first.

If you want to utilize the jupyter notebook, your IDE needs to able to process .ipynb files. For compiling an adequate Python distribution is required.

## Project Structure

This repository is organized into three main work areas:

- `Data/`: all collected material (raw files, pictures, tables, processed datasets)
- `Analysis/`: Jupyter notebooks and exported analysis outputs
- `Documentation/`: LaTeX report and bibliography

### Recommended Conventions

- Keep original files in `Data/raw/`
- Keep cleaned/generated datasets in `Data/processed/`
- Export notebook plots to `Analysis/exports/figures/`
- Export notebook tables (CSV/LaTeX) to `Analysis/exports/tables/`
- Reference exported figures directly from LaTeX via `\graphicspath`

### Build LaTeX

From `Documentation/`:

```bash
latexmk -xelatex main.tex
```

Generated artifacts are written to `Documentation/build/` (configured in `latexmkrc`).

To clean the build folder and rebuild from scratch in one step, use:

```bash
./clean-build.sh
```

This removes the contents of `Documentation/build/` and then runs `latexmk -xelatex main.tex` again.

### Build Workflow

When you build the project for `Documentation/main.tex`, this is the effective flow:

1. `latexmk` starts and reads `Documentation/latexmkrc`.
2. `xelatex` runs first pass and writes intermediate files into `Documentation/build/`.
3. If bibliography state changed, `biber` runs on `build/main.bcf` and writes `build/main.bbl`.
4. `xelatex` runs again (often multiple passes) to resolve references, TOC, and bibliography.
5. `xdvipdfmx` creates `Documentation/build/main.pdf`.
6. `latexmk` checks whether another pass is required; if not, build ends as up-to-date.

Flow summary:

Build -> latexmk -> xelatex -> (optional biber) -> xelatex pass(es) -> xdvipdfmx -> main.pdf
