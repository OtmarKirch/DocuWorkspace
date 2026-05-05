#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# Remove all generated files from the build directory, then rebuild from scratch.
mkdir -p build
find build -mindepth 1 -maxdepth 1 -exec rm -rf {} +
mkdir -p build/sections

latexmk -xelatex main.tex
