#!/usr/bin/env bash
set -euo pipefail

# Source roots inside the container (mounted from host)
SOURCE_DIRS=(
  "/mnt/extra-addons/custom"
  "/mnt/extra-addons/enterprise"
  "/mnt/extra-addons/community"
)

# Destination directory for flattened symlinks
AUTO_DIR="/mnt/extra-addons/auto"

mkdir -p "${AUTO_DIR}"

# Remove old/broken links only, leave regular directories/files untouched
find "${AUTO_DIR}" -maxdepth 1 -type l -exec rm -f {} + || true

is_module_dir() {
  local dir="$1"
  [[ -f "${dir}/__manifest__.py" || -f "${dir}/__openerp__.py" ]]
}

# Recursively find module directories and link them into AUTO_DIR
for root in "${SOURCE_DIRS[@]}"; do
  [[ -d "${root}" ]] || continue
  # Find all directories that look like Odoo modules
  while IFS= read -r -d '' module_path; do
    module_name="$(basename "${module_path}")"
    target_link="${AUTO_DIR}/${module_name}"
    # If a link with same name already exists, prefer the first found (custom > enterprise > community by path order)
    if [[ -L "${target_link}" || -e "${target_link}" ]]; then
      continue
    fi
    ln -s "${module_path}" "${target_link}"
  done < <(find "${root}" -type d -print0 | while IFS= read -r -d '' d; do
    if is_module_dir "${d}"; then printf '%s\0' "$d"; fi
  done)
done

echo "Prepared symlinks in ${AUTO_DIR}" >&2

# Install Python dependencies declared by modules
# - requirements.txt in module root
# - external_dependencies['python'] in __manifest__.py / __openerp__.py

pip_install_if_present() {
  local requirements_file="$1"
  if [[ -f "${requirements_file}" ]]; then
    echo "Checking Python requirements from ${requirements_file}" >&2
    # Check if requirements are already satisfied
    if python3 -m pip check -r "${requirements_file}" >/dev/null 2>&1; then
      echo "Requirements from ${requirements_file} already satisfied, skipping installation" >&2
    else
      echo "Installing Python requirements from ${requirements_file}" >&2
      python3 -m pip install --no-cache-dir --break-system-packages -r "${requirements_file}" || {
        echo "WARNING: Failed to install requirements from ${requirements_file}" >&2
      }
    fi
  fi
}

pip_install_from_manifest() {
  local manifest_path="$1"
  [[ -f "${manifest_path}" ]] || return 0
  # Use Python to safely parse the manifest (no exec), extract external_dependencies['python'] as list of names
  python3 - "$manifest_path" <<'PY'
import ast, sys, json
mp = sys.argv[1]
with open(mp, 'rb') as f:
    tree = ast.parse(f.read(), filename=mp, mode='exec')
manifest = {}
for node in tree.body:
    if isinstance(node, ast.Assign):
        for tgt in node.targets:
            if isinstance(tgt, ast.Name) and tgt.id in {'{MANIFEST}', 'manifest'}:
                try:
                    manifest = ast.literal_eval(node.value)
                except Exception:
                    manifest = {}
            elif isinstance(tgt, ast.Name) and tgt.id in {'__manifest__', '__openerp__'}:
                try:
                    manifest = ast.literal_eval(node.value)
                except Exception:
                    manifest = {}
    elif isinstance(node, ast.Expr) and isinstance(node.value, ast.Dict):
        try:
            manifest = ast.literal_eval(node.value)
        except Exception:
            manifest = {}
deps = []
ext = manifest.get('external_dependencies') or {}
py = ext.get('python')
if isinstance(py, (list, tuple)):
    deps = [str(x) for x in py]
elif isinstance(py, dict):
    # some modules map names -> version spec or booleans
    deps = [str(k) + (str(v) if isinstance(v, str) and v.strip() else '') for k, v in py.items()]
elif isinstance(py, str):
    deps = [py]
print('\n'.join(deps))
PY
}

# Walk discovered modules and install their python deps
while IFS= read -r -d '' link; do
  # Resolve symlink to real module dir
  module_dir="$(readlink -f "$link")"
  [[ -d "$module_dir" ]] || continue
  pip_install_if_present "${module_dir}/requirements.txt"
  # Try __manifest__.py then legacy __openerp__.py
  while IFS= read -r dep; do
    [[ -n "$dep" ]] || continue
    # Extract package name (remove version specifiers)
    package_name=$(echo "$dep" | sed 's/[<>=!].*//')
    if python3 -c "import $package_name" 2>/dev/null; then
      echo "Python package '$package_name' already installed, skipping" >&2
    else
      echo "Installing Python package: $dep (from manifest in $module_dir)" >&2
      python3 -m pip install --no-cache-dir --break-system-packages "$dep" || {
        echo "WARNING: Failed to install Python package '$dep' from manifest in $module_dir" >&2
      }
    fi
  done < <(pip_install_from_manifest "${module_dir}/__manifest__.py")
  while IFS= read -r dep; do
    [[ -n "$dep" ]] || continue
    # Extract package name (remove version specifiers)
    package_name=$(echo "$dep" | sed 's/[<>=!].*//')
    if python3 -c "import $package_name" 2>/dev/null; then
      echo "Python package '$package_name' already installed, skipping" >&2
    else
      echo "Installing Python package: $dep (from legacy manifest in $module_dir)" >&2
      python3 -m pip install --no-cache-dir --break-system-packages "$dep" || {
        echo "WARNING: Failed to install Python package '$dep' from legacy manifest in $module_dir" >&2
      }
    fi
  done < <(pip_install_from_manifest "${module_dir}/__openerp__.py")
done < <(find "${AUTO_DIR}" -maxdepth 1 -type l -print0)