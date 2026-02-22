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

LAB_NAME="${1:?Usage: $0 <lab> <api-url-or-aap-url> <admin-password> [--local|--git]}"
API_URL="${2:?API/AAP URL required}"
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

# ── Step 0.5: Ask lab infrastructure type ────────────────────────────────────
echo ""
echo "What type of infrastructure does this lab use?"
echo "  1. OpenShift  (OCP cluster — MCP, ocp4-getting-started, etc.)"
echo "  2. AAP + SSH  (Ansible Automation Platform + RHEL bastion — RIPU etc.)"
echo "  3. RHEL / SSH only  (no OCP, no AAP)"
read -rp "Lab type [1/2/3]: " LAB_TYPE

LAB_SSH_HOST=""
LAB_SSH_USER="lab-user"
LAB_AAP_HOSTNAME=""
LAB_AAP_PASSWORD=""

case "$LAB_TYPE" in
  2)
    read -rp "AAP Controller URL (e.g. https://controller-xxx.apps.example.com): " LAB_AAP_HOSTNAME
    read -rsp "AAP password: " LAB_AAP_PASSWORD; echo ""
    read -rp "Bastion SSH host (or press Enter to skip): " LAB_SSH_HOST
    [ -n "$LAB_SSH_HOST" ] && read -rp "SSH user [lab-user]: " input_user && LAB_SSH_USER="${input_user:-lab-user}"
    ;;
  3)
    read -rp "Bastion SSH host (e.g. bastion.xxx.example.com): " LAB_SSH_HOST
    read -rp "SSH user [lab-user]: " input_user && LAB_SSH_USER="${input_user:-lab-user}"
    ;;
esac

# ── Step 1: Login as admin (OCP) ─────────────────────────────────────────────
echo ""
OCP_OK=false
if [ "$LAB_TYPE" = "1" ]; then
  echo "Logging in as $ADMIN_USER..."
fi
if oc login "$API_URL" -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" \
  --insecure-skip-tls-verify=true 2>&1 | grep -v "^WARNING"; then
  OCP_OK=true
fi

INGRESS=""
if $OCP_OK; then
  INGRESS=$(oc get ingresses.config.openshift.io cluster \
    -o jsonpath='{.spec.domain}' 2>/dev/null || true)
  [ -n "$INGRESS" ] && echo "Cluster domain: $INGRESS"
else
  echo "OCP login failed — continuing for non-OCP lab (e.g. RIPU/AAP)"
fi

# ── Step 2: Detect lab type and users ────────────────────────────────────────
echo ""
ALL_USERS=()
SHOWROOM_NS=""
SINGLE_USER=false

if $OCP_OK; then
  # Try multi-user: showroom namespaces ending in userN
  while IFS= read -r ns; do
    u=$(echo "$ns" | sed 's/.*-\(user[0-9]*\)$/\1/' | grep '^' || true)
    [[ "$u" =~ ^user[0-9]+$ ]] && ALL_USERS+=("$u")
  done < <(oc get namespaces --no-headers -o name \
    | grep "showroom" | cut -d/ -f2 | grep 'user[0-9]*$')

  # If no multi-user namespaces found — single-user lab (RIPU etc.)
  if [ ${#ALL_USERS[@]} -eq 0 ]; then
    SHOWROOM_NS=$(oc get namespaces --no-headers -o name \
      | grep "showroom" | head -1 | cut -d/ -f2 || true)
    SINGLE_USER=true
    ALL_USERS=("student")
    [ -n "$SHOWROOM_NS" ] && echo "Single-user lab — showroom namespace: $SHOWROOM_NS" || echo "Single-user lab (no showroom namespace)"
  else
    echo "Multi-user lab — found users: ${ALL_USERS[*]}"
  fi
else
  # No OCP — single user, no discovery possible
  SINGLE_USER=true
  ALL_USERS=("student")
  echo "Non-OCP lab — single user: student"
fi

# ── Step 3: Interactive menu ──────────────────────────────────────────────────
echo ""
if $SINGLE_USER; then
  # Single-user lab (RIPU, AAP-only, etc.)
  echo "What do you want to grade?"
  echo "  1. Single module"
  echo "  2. All modules"
  read -rp "Choice [1/2]: " CHOICE
  USERS=("student")
  case "$CHOICE" in
    1) read -rp "Which module (e.g. 01): " TARGET_MODULE; MODULES=("$TARGET_MODULE") ;;
    2) MODULES=() ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
else
  # Multi-user lab (MCP, ocp4-getting-started, etc.)
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
fi

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
TOTAL_JOBS=$(( ${#USERS[@]} * ${#MODULES[@]} ))
if [ ${#USERS[@]} -eq 1 ]; then
  echo "Mode:    Grading as ${USERS[0]}"
else
  echo "Mode:    Load test — grading ${#USERS[@]} users in parallel (running as admin)"
fi
echo "Running: ${#USERS[@]} user(s) × ${#MODULES[@]} module(s) = ${TOTAL_JOBS} job(s)"
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
  local gitea_admin_user="mcpadmin"
  local gitea_admin_pass="$ADMIN_PASSWORD"
  local aap_hostname=""
  local aap_password=""

  if [ -n "$showroom_ns" ]; then
    local raw_data
    raw_data=$(oc get configmap showroom-userdata -n "$showroom_ns" \
      -o jsonpath='{.data.user_data\.yml}' 2>/dev/null || true)

    if [ -n "$raw_data" ]; then
      # ConfigMap uses "key": "value" format per line — grep+sed is more reliable than JSON parsing
      extract_field() {
        local key="$1"
        echo "$raw_data" | grep "\"${key}\":" | head -1 | \
          sed 's/.*"'"$key"'": *"\([^"]*\)".*/\1/' | tr -d '\r\n'
      }

      local extracted_pass extracted_gitea_admin_user extracted_gitea_admin_pass \
            extracted_aap_hostname extracted_aap_password
      extracted_pass=$(extract_field "password")
      extracted_gitea_admin_user=$(extract_field "gitea_admin_username")
      extracted_gitea_admin_pass=$(extract_field "gitea_admin_password")
      # AAP labs (RIPU etc.) — controller_url maps to AAP_HOSTNAME
      extracted_aap_hostname=$(extract_field "controller_url")
      extracted_aap_password=$(extract_field "controller_password")

      [ -n "$extracted_pass" ] && user_pass="$extracted_pass"
      [ -n "$extracted_gitea_admin_user" ] && gitea_admin_user="$extracted_gitea_admin_user"
      [ -n "$extracted_gitea_admin_pass" ] && gitea_admin_pass="$extracted_gitea_admin_pass"
      [ -n "$extracted_aap_hostname" ] && aap_hostname="$extracted_aap_hostname"
      [ -n "$extracted_aap_password" ] && aap_password="$extracted_aap_password"
    fi
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

  local context_msg
  if [ ${#USERS[@]} -eq 1 ]; then
    context_msg="grading as $user"
  else
    context_msg="load test — user $user (admin credentials)"
  fi
  echo ""
  echo "▶ $LAB_NAME / module $mod / $user  ($context_msg)"

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
    -e GITEA_ADMIN_USER="$gitea_admin_user" \
    -e GITEA_ADMIN_PASSWORD="$gitea_admin_pass" \
    ${aap_hostname:+-e AAP_HOSTNAME="$aap_hostname"} \
    ${aap_password:+-e AAP_PASSWORD="$aap_password"} \
    ${LAB_AAP_HOSTNAME:+-e AAP_HOSTNAME="$LAB_AAP_HOSTNAME"} \
    ${LAB_AAP_PASSWORD:+-e AAP_PASSWORD="$LAB_AAP_PASSWORD"} \
    ${LAB_SSH_HOST:+-e BASTION_HOST="$LAB_SSH_HOST"} \
    ${LAB_SSH_USER:+-e BASTION_USER="$LAB_SSH_USER"} \
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
