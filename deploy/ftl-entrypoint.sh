#!/usr/bin/env bash
# FTL container entrypoint
# Clones latest FTL from GitHub at runtime then runs ansible-playbook.
# If /ftl/labs already exists (--local mount), skips clone and uses local.

set -euo pipefail

FTL_REPO="${FTL_REPO:-https://github.com/rhpds/ftl.git}"
FTL_REF="${FTL_REF:-main}"

if [ -d "/ftl/labs" ]; then
  echo "FTL: using mounted local content at /ftl"
else
  echo "FTL: cloning ${FTL_REPO}@${FTL_REF}..."
  git clone --depth 1 --branch "$FTL_REF" "$FTL_REPO" /ftl --quiet
  echo "FTL: $(git -C /ftl log --oneline -1)"
fi

export ANSIBLE_ROLES_PATH=/ftl/roles
export ANSIBLE_COLLECTIONS_PATH=/home/runner/.ansible/collections:/usr/share/ansible/collections

exec ansible-playbook "$@"
