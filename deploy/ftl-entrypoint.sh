#!/usr/bin/env bash
# FTL container entrypoint
# Clones the FTL repo at runtime then runs the requested playbook.
# If /runner/ftl is already mounted (laptop dev), skips cloning.

set -euo pipefail

FTL_REPO="${FTL_REPO:-https://github.com/rhpds/ftl.git}"
FTL_REF="${FTL_REF:-main}"
FTL_DIR="/runner/ftl"

# Clone only if the labs/ directory is not already there (e.g. volume mounted)
if [ ! -d "$FTL_DIR/labs" ]; then
  echo "Cloning FTL repo: $FTL_REPO@$FTL_REF"
  git clone --depth 1 --branch "$FTL_REF" "$FTL_REPO" "$FTL_DIR"
else
  echo "FTL content already available at $FTL_DIR (mounted or pre-cloned)"
fi

export ANSIBLE_ROLES_PATH="$FTL_DIR/roles:/usr/share/ansible/roles"
export ANSIBLE_COLLECTIONS_PATH="/usr/share/ansible/collections"

exec ansible-playbook "$@"
