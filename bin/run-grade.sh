#!/usr/bin/env bash
# =============================================================================
# FTL Grader — Run from laptop via podman
#
# Usage:
#   ./bin/run-grade.sh <lab> <api-url> <admin-password> [--local | --git]
#
#   --local  Mount local FTL repo (fast, uses your working copy)
#   --git    Clone from GitHub at runtime (default, always latest)
#
# Example:
#   ./bin/run-grade.sh ocp4-getting-started https://api.cluster-xxx:6443 MyPass
#   ./bin/run-grade.sh ocp4-getting-started https://api.cluster-xxx:6443 MyPass --local
#
# Requirements: podman, oc CLI
# =============================================================================

set -euo pipefail

LAB_NAME="${1:?Usage: $0 <lab> <api-url> <admin-password> [--local|--git]}"
API_URL="${2:?API URL required}"
ADMIN_PASSWORD="${3:?Admin password required}"
FTL_MODE="${4:---git}"   # --local or --git

ADMIN_USER="${ADMIN_USER:-admin}"
FTL_IMAGE="${FTL_IMAGE:-quay.io/rhpds/ftl:latest}"
FTL_REPO="${FTL_REPO:-https://github.com/rhpds/ftl.git}"
FTL_REF="${FTL_REF:-main}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Validate FTL mode
case "$FTL_MODE" in
  --local)
    [ -d "$SCRIPT_DIR/labs/$LAB_NAME" ] || \
      { echo "ERROR: $SCRIPT_DIR/labs/$LAB_NAME not found"; exit 1; }
    echo "FTL source: local ($SCRIPT_DIR) — mounts over /ftl in container"
    ;;
  --git)
    echo "FTL source: cloned at runtime from GitHub (always latest)"
    ;;
  *)
    echo "ERROR: Unknown option $FTL_MODE (use --local or --git)"; exit 1 ;;
esac

# ── Step 1: Login as admin ────────────────────────────────────────────────────
echo ""
echo "Logging in as $ADMIN_USER..."
oc login "$API_URL" -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" \
  --insecure-skip-tls-verify=true 2>&1 | grep -v "^WARNING" || true

INGRESS=$(oc get ingresses.config.openshift.io cluster \
  -o jsonpath='{.spec.domain}')
echo "Cluster domain: $INGRESS"

# ── Step 2: Discover users (macOS-compatible) ─────────────────────────────────
echo ""
ALL_USERS=()
while IFS= read -r ns; do
  # macOS sed: extract trailing userN from namespace name
  u=$(echo "$ns" | sed 's/.*-\(user[0-9]*\)$/\1/' | grep '^user' || true)
  [ -n "$u" ] && ALL_USERS+=("$u")
done < <(oc get namespaces --no-headers -o name \
  | grep "showroom" | cut -d/ -f2 | grep 'user[0-9]*$')

if [ ${#ALL_USERS[@]} -eq 0 ]; then
  echo "ERROR: No showroom user namespaces found. Are Showroom pods deployed?"
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
    MODULES=()
    ;;
  3)
    read -rp "Which module (e.g. 01): " TARGET_MODULE
    USERS=("${ALL_USERS[@]}")
    MODULES=("$TARGET_MODULE")
    ;;
  4)
    USERS=("${ALL_USERS[@]}")
    MODULES=()
    ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

# ── Step 4: Discover modules if needed ───────────────────────────────────────
if [ ${#MODULES[@]} -eq 0 ]; then
  echo ""
  echo "Discovering modules for $LAB_NAME..."
  if [ "$FTL_MODE" = "--local" ]; then
    SRC_DIR="$SCRIPT_DIR"
  else
    SRC_DIR=$(mktemp -d)
    git clone --depth 1 --branch "$FTL_REF" "$FTL_REPO" "$SRC_DIR" --quiet 2>/dev/null
    trap "rm -rf $SRC_DIR" EXIT
  fi
  while IFS= read -r f; do
    mod=$(basename "$f" .yml | sed 's/grade_module_//')
    MODULES+=("$mod")
  done < <(ls "$SRC_DIR/labs/$LAB_NAME"/grade_module_*.yml 2>/dev/null | sort)
  echo "Modules: ${MODULES[*]}"
fi

echo ""
echo "Running: ${#USERS[@]} user(s) × ${#MODULES[@]} module(s)"
echo "═══════════════════════════════════════════════════════"

# ── Step 5: Grade function ────────────────────────────────────────────────────
grade_user_module() {
  local user="$1"
  local mod="$2"

  # Get user password from Showroom ConfigMap
  local showroom_ns user_pass
  showroom_ns=$(oc get namespaces --no-headers -o name \
    | grep "showroom" | grep "${user}$" | head -1 | cut -d/ -f2 || true)

  user_pass="$ADMIN_PASSWORD"
  if [ -n "$showroom_ns" ]; then
    user_pass=$(oc get configmap showroom-userdata -n "$showroom_ns" \
      -o jsonpath='{.data.user_data\.yml}' 2>/dev/null | \
      python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    print(d.get('password', ''))
except: pass
" 2>/dev/null || true)
    [ -z "$user_pass" ] && user_pass="$ADMIN_PASSWORD"
  fi

  # Use admin kubeconfig — works for SSO users (rhsso/keycloak) too
  # Grader checks resources as admin but uses LAB_USER for namespace targeting
  local admin_kube
  admin_kube=$(mktemp)
  cp ~/.kube/config "$admin_kube" 2>/dev/null || \
    { KUBECONFIG="$admin_kube" oc login "$API_URL" \
        -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" \
        --insecure-skip-tls-verify=true 2>/dev/null || true; }
  trap "rm -f $admin_kube" RETURN

  echo ""
  echo "▶ $LAB_NAME / module $mod / $user"

  if [ "$FTL_MODE" = "--local" ]; then
    # Mount local repo over /ftl — overrides baked-in content
    VOLUME_ARGS="-v $SCRIPT_DIR:/ftl:ro"
  else
    # Use FTL content baked into image at build time — nothing extra needed
    VOLUME_ARGS=""
  fi
  PLAYBOOK="/ftl/labs/${LAB_NAME}/grade_module_${mod}.yml"

  # Our image uses ansible-playbook directly as entrypoint — no override needed
  podman run --rm \
    -v "$admin_kube:/home/runner/.kube/config:ro" \
    ${VOLUME_ARGS:+$VOLUME_ARGS} \
    -e LAB_USER="$user" \
    -e PASSWORD="$user_pass" \
    -e OPENSHIFT_CLUSTER_INGRESS_DOMAIN="$INGRESS" \
    -e ANSIBLE_FORCE_COLOR=true \
    "$FTL_IMAGE" \
    "$PLAYBOOK"
}

# ── Step 6: Run ───────────────────────────────────────────────────────────────
for user in "${USERS[@]}"; do
  for mod in "${MODULES[@]}"; do
    grade_user_module "$user" "$mod"
  done
done

echo ""
echo "═══════════════════════════════════════════════════════"
echo "Grading complete."
