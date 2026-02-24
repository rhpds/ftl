#!/usr/bin/env bash
# FTL container entrypoint
# Clones FTL from GitHub at runtime, then routes grade/solve/list commands
# or falls through to ansible-playbook for direct playbook execution.
#
# Usage:
#   grade <lab> [user] [module]   Grade a lab
#   solve <lab> [user] [module]   Solve a lab
#   list                          List available labs
#   ansible-playbook ...          Run playbook directly

set -euo pipefail

FTL_REPO="${FTL_REPO:-https://github.com/rhpds/ftl.git}"
FTL_REF="${FTL_REF:-main}"

# Clone FTL if not already present (--local mount or prior clone)
if [ -d "/ftl/labs" ]; then
  echo "FTL: using content at /ftl"
else
  echo "FTL: cloning ${FTL_REPO}@${FTL_REF}..."
  git clone --depth 1 --branch "$FTL_REF" "$FTL_REPO" /ftl --quiet
  echo "FTL: $(git -C /ftl log --oneline -1)"
fi

export ANSIBLE_ROLES_PATH=/usr/share/ansible/roles:/ftl/roles
export ANSIBLE_COLLECTIONS_PATH=/home/runner/.ansible/collections:/usr/share/ansible/collections

COMMAND="${1:-}"

# ── Route grade/solve/list commands ──────────────────────────────────────────
case "$COMMAND" in
  grade|solve)
    shift
    LAB_NAME="${1:?Lab name required (e.g. mcp-with-openshift)}"
    shift || true

    # Smart arg parsing: if next arg is a number → module; else → user then module
    USER_OVERRIDE=""
    MODULE_NUM=""
    for arg in "$@"; do
      if [[ "$arg" =~ ^[0-9]+$ ]]; then
        MODULE_NUM=$(printf "%02d" "$arg")
      else
        USER_OVERRIDE="$arg"
      fi
    done

    [ -n "$USER_OVERRIDE" ] && export LAB_USER="$USER_OVERRIDE"
    export LAB_USER="${LAB_USER:-student}"
    export GUID="${GUID:-ftl-container}"

    PLAYBOOK_PREFIX="grade"
    [ "$COMMAND" = "solve" ] && PLAYBOOK_PREFIX="solve"

    if [ -n "$MODULE_NUM" ]; then
      PLAYBOOK="/ftl/labs/${LAB_NAME}/${PLAYBOOK_PREFIX}_module_${MODULE_NUM}.yml"
      [ -f "$PLAYBOOK" ] || { echo "ERROR: $PLAYBOOK not found"; exit 1; }
      exec ansible-playbook "$PLAYBOOK"
    else
      # Run all modules in order
      for f in $(ls /ftl/labs/"${LAB_NAME}"/"${PLAYBOOK_PREFIX}"_module_*.yml 2>/dev/null | sort); do
        echo ""
        echo "─── $(basename "$f") ───"
        ansible-playbook "$f"
      done
    fi
    ;;

  list)
    echo "Available labs:"
    ls /ftl/labs/ 2>/dev/null | grep -v "lab-template" | sed 's/^/  /'
    ;;

  --help|-h)
    cat <<'EOF'
FTL (Finish The Labs) — Container Mode

Usage:
  grade <lab> [user] [module]   Grade a lab
  solve <lab> [user] [module]   Solve a lab
  list                          List available labs

Examples:
  grade mcp-with-openshift user1 1
  grade automating-ripu-with-ansible 01
  solve mcp-with-openshift user1
  solve automating-ripu-with-ansible

Environment variables:
  LAB_USER    Student username (default: student)
  PASSWORD    OCP/app password
  AAP_HOSTNAME    AAP controller URL (AAP labs)
  AAP_PASSWORD    AAP password
  OPENSHIFT_CLUSTER_INGRESS_DOMAIN    OCP cluster domain
EOF
    ;;

  *)
    # Fall through to ansible-playbook for direct invocation
    exec ansible-playbook "$@"
    ;;
esac
