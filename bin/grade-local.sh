#!/usr/bin/env bash
# =============================================================================
# FTL Grade Runner — Local (laptop)
#
# Usage:
#   ./bin/grade-local.sh <lab> <module|all> <user> <password> <api-url>
#
# Example:
#   ./bin/grade-local.sh mcp-with-openshift 01 user1 MyPass https://api.cluster-xxx.example.com:6443
#   ./bin/grade-local.sh mcp-with-openshift all user1 MyPass https://api.cluster-xxx.example.com:6443
#
# Requirements: podman or docker installed
# =============================================================================

set -euo pipefail

LAB_NAME="${1:?Usage: $0 <lab> <module|all> <user> <password> <api-url>}"
MODULE="${2:?Module (e.g. 01) or 'all'}"
LAB_USER="${3:?OCP username (e.g. user1)}"
PASSWORD="${4:?OCP password}"
API_URL="${5:?OCP API URL (e.g. https://api.cluster-xxx.example.com:6443)}"

EE_IMAGE="${EE_IMAGE:-quay.io/agnosticd/ee-multicloud:chained-2026-02-16}"
FTL_REPO="${FTL_REPO:-https://github.com/rhpds/ftl.git}"
FTL_REF="${FTL_REF:-main}"

# Detect runtime
if command -v podman &>/dev/null; then RUNTIME="podman"
elif command -v docker &>/dev/null; then RUNTIME="docker"
else echo "ERROR: podman or docker required"; exit 1; fi

echo "Logging in as admin to discover cluster data..."
# Login as admin to read showroom ConfigMap (admin creds come from env or default)
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-$PASSWORD}"

oc login "$API_URL" -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" --insecure-skip-tls-verify=true -q 2>/dev/null || \
oc login "$API_URL" -u "$LAB_USER" -p "$PASSWORD" --insecure-skip-tls-verify=true -q 2>/dev/null

# Find showroom ConfigMap for this user
echo "Discovering cluster data from Showroom ConfigMap for $LAB_USER..."
SHOWROOM_NS=$(oc get namespaces --no-headers -o name 2>/dev/null | \
  grep "showroom" | grep "$LAB_USER" | head -1 | cut -d/ -f2)

if [ -n "$SHOWROOM_NS" ]; then
  USER_DATA=$(oc get configmap showroom-userdata -n "$SHOWROOM_NS" \
    -o jsonpath='{.data.user_data\.yml}' 2>/dev/null || echo "")
fi

if [ -n "${USER_DATA:-}" ]; then
  INGRESS=$(echo "$USER_DATA" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('openshift_cluster_ingress_domain',''))")
  GITEA_URL=$(echo "$USER_DATA" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('gitea_console_url',''))")
  echo "Found: domain=$INGRESS  gitea=$GITEA_URL"
else
  # Derive from API URL
  INGRESS=$(echo "$API_URL" | sed 's|https://api\.|apps.|;s|:6443||')
  GITEA_URL="https://gitea.${INGRESS}"
  echo "Derived: domain=$INGRESS  gitea=$GITEA_URL"
fi

# Write a temp kubeconfig for the student user
TMP_KUBECONFIG=$(mktemp)
KUBECONFIG="$TMP_KUBECONFIG" oc login "$API_URL" \
  -u "$LAB_USER" -p "$PASSWORD" --insecure-skip-tls-verify=true -q 2>/dev/null
trap "rm -f $TMP_KUBECONFIG" EXIT

echo ""

run_module() {
  local mod="$1"
  echo "=== Grading: $LAB_NAME / Module $mod / $LAB_USER ==="

  $RUNTIME run --rm \
    -v "$TMP_KUBECONFIG:/home/runner/.kube/config:ro,z" \
    -e LAB_USER="$LAB_USER" \
    -e PASSWORD="$PASSWORD" \
    -e OPENSHIFT_CLUSTER_INGRESS_DOMAIN="$INGRESS" \
    -e GITEA_URL="$GITEA_URL" \
    -e API_URL="$API_URL" \
    -e FTL_REPO="$FTL_REPO" \
    -e FTL_REF="$FTL_REF" \
    -e LAB_NAME="$LAB_NAME" \
    -e MODULE="$mod" \
    -e ANSIBLE_FORCE_COLOR=true \
    "$EE_IMAGE" \
    /usr/local/bin/ftl-entrypoint \
    "/runner/ftl/labs/${LAB_NAME}/grade_module_${mod}.yml"

  echo ""
}

if [ "$MODULE" = "all" ]; then
  # Discover modules by pulling the repo once and listing
  TMP_DIR=$(mktemp -d)
  git clone --depth 1 --branch "$FTL_REF" "$FTL_REPO" "$TMP_DIR" -q 2>/dev/null
  for f in "$TMP_DIR/labs/$LAB_NAME"/grade_module_*.yml; do
    mod=$(basename "$f" .yml | grep -oP '\d+')
    run_module "$mod"
  done
  rm -rf "$TMP_DIR"
else
  run_module "$MODULE"
fi
