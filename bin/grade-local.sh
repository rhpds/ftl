#!/usr/bin/env bash
# =============================================================================
# FTL Grade Runner — Local (laptop) version
# Runs grader inside the multicloud EE container using podman/docker.
# Mounts your local FTL repo + kubeconfig so no image build needed.
#
# Usage:
#   ./bin/grade-local.sh <lab-name> <module> <lab-user> <showroom-namespace>
#
# Examples:
#   ./bin/grade-local.sh mcp-with-openshift 01 user1 showroom-zz94q-1-user1
#   ./bin/grade-local.sh ocp4-getting-started all user1 showroom-zz94q-1-user1
#
# Requirements:
#   - podman (or docker) installed
#   - oc logged in to the cluster (kubeconfig at ~/.kube/config)
# =============================================================================

set -euo pipefail

LAB_NAME="${1:?Usage: $0 <lab-name> <module|all> <lab-user> <showroom-namespace>}"
MODULE="${2:?Module number (e.g. 01) or 'all'}"
LAB_USER="${3:?Lab user (e.g. user1)}"
SHOWROOM_NS="${4:?Showroom namespace (e.g. showroom-zz94q-1-user1)}"

EE_IMAGE="${EE_IMAGE:-quay.io/agnosticd/ee-multicloud:chained-2026-02-16}"
FTL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# Detect podman or docker
RUNTIME=""
if command -v podman &>/dev/null; then RUNTIME="podman"
elif command -v docker &>/dev/null; then RUNTIME="docker"
else echo "ERROR: podman or docker required"; exit 1; fi

echo "Using: $RUNTIME"
echo "EE:    $EE_IMAGE"
echo "FTL:   $FTL_DIR"
echo ""

# Read credentials from Showroom ConfigMap
echo "Reading credentials from $SHOWROOM_NS/showroom-userdata..."
USER_DATA=$(oc get configmap showroom-userdata -n "$SHOWROOM_NS" \
  -o jsonpath='{.data.user_data\.yml}' 2>/dev/null || echo "")

if [ -z "$USER_DATA" ]; then
  echo "WARNING: Could not read showroom-userdata — using env vars if set"
  PASSWORD="${PASSWORD:-}"
  INGRESS="${OPENSHIFT_CLUSTER_INGRESS_DOMAIN:-}"
  GITEA_URL="${GITEA_URL:-}"
else
  PASSWORD=$(echo "$USER_DATA" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('password',''))")
  INGRESS=$(echo "$USER_DATA" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('openshift_cluster_ingress_domain',''))")
  GITEA_URL=$(echo "$USER_DATA" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('gitea_console_url',''))")
fi

echo "User:    $LAB_USER"
echo "Domain:  $INGRESS"
echo ""

run_module() {
  local mod="$1"
  local playbook="/runner/ftl/labs/${LAB_NAME}/grade_module_${mod}.yml"

  echo "=== Grading Module $mod for $LAB_USER ==="

  $RUNTIME run --rm \
    -v "$FTL_DIR:/runner/ftl:ro,z" \
    -v "$KUBECONFIG:/home/runner/.kube/config:ro,z" \
    -e LAB_USER="$LAB_USER" \
    -e PASSWORD="$PASSWORD" \
    -e OPENSHIFT_CLUSTER_INGRESS_DOMAIN="$INGRESS" \
    -e GITEA_URL="$GITEA_URL" \
    -e ANSIBLE_ROLES_PATH="/runner/ftl/roles:/usr/share/ansible/roles" \
    -e ANSIBLE_COLLECTIONS_PATH="/usr/share/ansible/collections" \
    -e ANSIBLE_FORCE_COLOR=true \
    "$EE_IMAGE" \
    ansible-playbook "$playbook"

  echo ""
}

if [ "$MODULE" = "all" ]; then
  for f in "$FTL_DIR/labs/$LAB_NAME"/grade_module_*.yml; do
    mod=$(basename "$f" .yml | grep -oP '\d+')
    run_module "$mod"
  done
else
  run_module "$MODULE"
fi
