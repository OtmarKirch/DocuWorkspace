#!/usr/bin/env bash
set -euo pipefail

DEFAULT_VENV=".venv"
# Determine script directory and repository root (parent of this script folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# If user provided no argument, create venv under the repository root.
# If an argument is provided and it's absolute, use it as given. If relative,
# treat it as relative to the repository root.
if [[ -z "${1:-}" ]]; then
	VENV_DIR="$REPO_ROOT/$DEFAULT_VENV"
else
	if [[ "${1:0:1}" == "/" ]]; then
		VENV_DIR="$1"
	else
		VENV_DIR="$REPO_ROOT/${1}"
	fi
fi

PYTHON_CMD="${PYTHON:-python3}"

usage() {
	cat <<EOF
Usage: $0 [venv-path]

Creates (or reuses) a Python virtual environment and installs packages
needed for the Jupyter notebook environment.

Arguments:
	venv-path   Path to virtual environment (default: .venv)

Installs: numpy, sympy, matplotlib, pandas, Jinja2, ipykernel
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
	exit 0
fi

if ! command -v "$PYTHON_CMD" >/dev/null 2>&1; then
	echo "Error: Python executable '$PYTHON_CMD' not found. Install Python 3 and retry." >&2
	exit 2
fi

# Check that venv module is available
if ! "$PYTHON_CMD" -m venv --help >/dev/null 2>&1; then
	echo "Error: this Python doesn't appear to support the 'venv' module." >&2
	echo "Install a Python 3 distribution that includes the 'venv' module." >&2
	exit 3
fi

echo "Using Python: $($PYTHON_CMD --version 2>&1)"
echo "Virtual environment path: $VENV_DIR"

if [[ -d "$VENV_DIR" && -f "$VENV_DIR/bin/activate" ]]; then
	echo "Found existing virtualenv at '$VENV_DIR' — reusing it."
else
	echo "Creating virtualenv at '$VENV_DIR'..."
	"$PYTHON_CMD" -m venv "$VENV_DIR"
fi

# Activate venv for the remainder of the script
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

echo "Upgrading pip in venv..."
pip install --upgrade pip setuptools wheel >/dev/null

PACKAGES=(numpy sympy matplotlib pandas Jinja2 ipykernel)

to_install=()
for pkg in "${PACKAGES[@]}"; do
	if pip show "$pkg" >/dev/null 2>&1; then
		echo "Package '$pkg' already installed — skipping."
	else
		to_install+=("$pkg")
	fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
	echo "Installing missing packages: ${to_install[*]}"
	pip install "${to_install[@]}"
else
	echo "All requested packages are already installed."
fi

# Register ipykernel so this venv is available in Jupyter
KERNEL_NAME=$(basename "$VENV_DIR" | sed 's/^\.//; s/[^a-zA-Z0-9_.-]/_/g')
if python -c "import ipykernel" >/dev/null 2>&1; then
	echo "Registering Jupyter kernel name '$KERNEL_NAME'..."
	python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "Python ($VENV_DIR)" >/dev/null
	echo "Kernel registered as name: $KERNEL_NAME"
else
	echo "ipykernel not available; skipping kernel registration." >&2
fi

echo "Setup complete. Activate the environment with: source $VENV_DIR/bin/activate"
echo "Then start Jupyter and select kernel 'Python ($VENV_DIR)'."

deactivate || true

