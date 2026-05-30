# DocuWorkspace

DocuWorkspace is my personal setup to store, manage and produce data and an appropriate text processing for scientific work of MINT subjects. Jupyter Notebook is used for the analysis of data and Latex for the actual documentation.
This project grows and changes steadily, according to my current needs.

## Requirements

In order to build the Latex project, you need to install the required Tex and packages first.

If you want to utilize the jupyter notebook, your IDE needs to able to process .ipynb files. For compiling an adequate Python distribution is required.

## Project Structure

This repository is organized into three main work areas:

- `Data/`: all collected material (raw files, pictures, tables, processed datasets, literature)
- `Analysis/`: Jupyter notebooks and exported analysis outputs
- `Documentation/`: LaTeX report and bibliography

### Recommended Conventions

- Keep original files in `Data/raw/`
- Keep cleaned/generated datasets in `Data/processed/`
- Export notebook plots to `Analysis/exports/figures/`
- Export notebook tables (CSV/LaTeX) to `Analysis/exports/tables/`
- Reference exported figures directly from LaTeX via `\graphicspath`

### VS Code or Codium

If you are using VS Code or Codium you can use the setup suggestion in `/01_setup_suggestion/vscode`. Create a folder `.vscode`at the Workspace root level and copy the files to that folder.

With the `task.json` file, you can use your default build shortcut (Cmd+Shift+b on Mac) to build the project in the build folder with a nice clean up beforehand, all automated for your convenience. Otherwise, use the build cli command as described below in [Build Latex](#build-latex)

### Setup Python Virtual Environment

To use the Jupyter notebook, it is required to have Python3 installed. It is recommended to use a virtual environment and install the required packages there. You can run the the script in `/01_setup_suggestion/python_venv/setup-python.sh` to have a fully automated installation of the virtual environment or do it manually. Run the script at the root of your workspace. If you do it manually, make sure as well to put the `.venv` folder at the root of the workspace. For full functionality in the notebook, install the following:

- Python3
- virtual environment (.venv)
- numpy
- sympy
- Matplotlib
- pandas
- Jinja2

Each time you start your workplace, activate the virtual environment with `source .venv/bin/activate`

When you run the notebook, your IDE will ask you which Python to use. Select the virtual environment if you have it installed.

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
