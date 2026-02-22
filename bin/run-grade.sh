#!/usr/bin/env bash
# =============================================================================
# FTL Grader — Run from laptop
#
# User provides: lab, api-url, admin-password
# Script does everything else automatically.
#
# Usage:
#   ./bin/run-grade.sh <lab> <api-url> <admin-password>
#   ./bin/run-grade.sh ocp4-getting-started https://api.cluster-xxx.example.com:6443 MyPass
#
# Requirements: podman installed, oc CLI installed
# =============================================================================

set -euo pipefail

LAB_NAME="${1:?Usage: $0 <lab> <api-url> <admin-password>}"
API_URL="${2:?API URL required (e.g. https://api.cluster-xxx.example.com:6443)}"
ADMIN_PASSWORD="${3:?Admin password required}"

ADMIN_USER="${ADMIN_USER:-admin}"
EE_IMAGE="${EE_IMAGE:-quay.io/agnosticd/ee-multicloud:chained-2026-02-16}"
FTL_REPO="${FTL_REPO:-https://github.com/rhpds/ftl.git}"
FTL_REF="${FTL_REF:-main}"

# ── Step 1: Login as admin ────────────────────────────────────────────────────
echo ""
echo "Logging in as $ADMIN_USER..."
oc login "$API_URL" -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" \
  --insecure-skip-tls-verify=true 2>&1 | grep -v "^WARNING"

INGRESS=$(oc get ingresses.config.openshift.io cluster \
  -o jsonpath='{.spec.domain}')
echo "Cluster domain: $INGRESS"

# ── Step 2: Discover users ────────────────────────────────────────────────────
echo ""
ALL_USERS=()
while IFS= read -r ns; do
  u=$(echo "$ns" | grep -oP 'user\d+$' || true)
  [ -n "$u" ] && ALL_USERS+=("$u")
done < <(oc get namespaces --no-headers -o name | grep "showroom" | cut -d/ -f2)

if [ ${#ALL_USERS[@]} -eq 0 ]; then
  echo "ERROR: No showroom user namespaces found on cluster"
  exit 1
fi
echo "Found users: ${ALL_USERS[*]}"

# ── Step 3: Interactive menu ──────────────────────────────────────────────────
echo ""
echo "What do you want to grade?"
echo "  1. Single user, single module"
echo "  2. Single user, all modules"
echo "  3. All users, single module  (load test)"
echo "  4. All users, all modules    (full load test)"
read -rp "Choice [1-4]: " CHOICE

case "$CHOICE" in
  1)
    echo "Users: ${ALL_USERS[*]}"
    read -rp "Which user: " TARGET_USER
    read -rp "Which module (e.g. 01): " TARGET_MODULE
    USERS=("$TARGET_USER")
    MODULES=("$TARGET_MODULE")
    ;;
  2)
    echo "Users: ${ALL_USERS[*]}"
    read -rp "Which user: " TARGET_USER
    USERS=("$TARGET_USER")
    MODULES=()  # discover below
    ;;
  3)
    read -rp "Which module (e.g. 01): " TARGET_MODULE
    USERS=("${ALL_USERS[@]}")
    MODULES=("$TARGET_MODULE")
    ;;
  4)
    USERS=("${ALL_USERS[@]}")
    MODULES=()  # discover below
    ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

# ── Step 4: Discover modules if needed ───────────────────────────────────────
if [ ${#MODULES[@]} -eq 0 ]; then
  echo ""
  echo "Discovering modules for $LAB_NAME..."
  TMP_CLONE=$(mktemp -d)
  git clone --depth 1 --branch "$FTL_REF" "$FTL_REPO" "$TMP_CLONE" \
    --quiet 2>/dev/null
  while IFS= read -r f; do
    mod=$(basename "$f" .yml | grep -oP '\d+')
    MODULES+=("$mod")
  done < <(ls "$TMP_CLONE/labs/$LAB_NAME"/grade_module_*.yml 2>/dev/null | sort)
  rm -rf "$TMP_CLONE"
  echo "Modules: ${MODULES[*]}"
fi

echo ""
echo "Running: ${#USERS[@]} user(s) × ${#MODULES[@]} module(s)"
echo "═══════════════════════════════════════════════════════"

# ── Step 5: Grade each user+module ───────────────────────────────────────────
grade_user_module() {
  local user="$1"
  local mod="$2"

  # Get user password from Showroom ConfigMap
  local showroom_ns
  showroom_ns=$(oc get namespaces --no-headers -o name \
    | grep "showroom.*${user}$" | head -1 | cut -d/ -f2 || true)

  local user_pass="$ADMIN_PASSWORD"
  if [ -n "$showroom_ns" ]; then
    user_pass=$(oc get configmap showroom-userdata -n "$showroom_ns" \
      -o jsonpath='{.data.user_data\.yml}' 2>/dev/null | \
      python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    print(d.get('password', ''))
except:
    pass
" || echo "$ADMIN_PASSWORD")
    [ -z "$user_pass" ] && user_pass="$ADMIN_PASSWORD"
  fi

  # Write user kubeconfig to temp file
  local tmp_kube
  tmp_kube=$(mktemp)
  KUBECONFIG="$tmp_kube" oc login "$API_URL" \
    -u "$user" -p "$user_pass" \
    --insecure-skip-tls-verify=true 2>&1 | grep -v "^WARNING" || true

  echo ""
  echo "▶ $LAB_NAME / module $mod / $user"

  podman run --rm \
    -v "$tmp_kube:/home/runner/.kube/config:ro" \
    -e LAB_USER="$user" \
    -e PASSWORD="$user_pass" \
    -e OPENSHIFT_CLUSTER_INGRESS_DOMAIN="$INGRESS" \
    -e ANSIBLE_ROLES_PATH="/runner/ftl/roles:/usr/share/ansible/roles" \
    -e ANSIBLE_COLLECTIONS_PATH="/usr/share/ansible/collections" \
    -e ANSIBLE_FORCE_COLOR=true \
    -e FTL_REPO="$FTL_REPO" \
    -e FTL_REF="$FTL_REF" \
    "$EE_IMAGE" \
    /bin/bash -c "
      git clone --depth 1 --branch \$FTL_REF \$FTL_REPO /runner/ftl --quiet 2>/dev/null
      export ANSIBLE_ROLES_PATH=/runner/ftl/roles:/usr/share/ansible/roles
      ansible-playbook /runner/ftl/labs/${LAB_NAME}/grade_module_${mod}.yml
    "

  rm -f "$tmp_kube"
}

for user in "${USERS[@]}"; do
  for mod in "${MODULES[@]}"; do
    grade_user_module "$user" "$mod"
  done
done

echo ""
echo "═══════════════════════════════════════════════════════"
echo "Grading complete."
