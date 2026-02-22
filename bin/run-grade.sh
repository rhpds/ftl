#!/usr/bin/env bash
# =============================================================================
# FTL Grader — Run from laptop via podman
#
# Interactive usage (prompted):
#   ./bin/run-grade.sh <lab> <api-url> <admin-password>
#
# Non-interactive usage (all flags):
#   ./bin/run-grade.sh <lab> <api-url> <admin-password> [flags]
#
# Flags:
#   --lab-type ocp|aap|rhel      Lab infrastructure type
#   --user <user>|all            Target user (default: interactive)
#   --module <01>|all            Module number or all (default: interactive)
#   --aap-url <url>              AAP controller URL (type: aap)
#   --aap-password <pass>        AAP admin password (type: aap)
#   --ssh-host <host>            Bastion SSH host (type: aap or rhel)
#   --ssh-user <user>            Bastion SSH user (default: lab-user)
#   --local                      Mount local FTL repo instead of cloning
#   --git                        Clone FTL from GitHub at runtime (default)
#
# Examples:
#   # OCP lab — single user, single module
#   ./bin/run-grade.sh mcp-with-openshift https://api.xxx:6443 pass \
#     --lab-type ocp --user user1 --module 01
#
#   # OCP lab — load test all users, all modules
#   ./bin/run-grade.sh mcp-with-openshift https://api.xxx:6443 pass \
#     --lab-type ocp --user all --module all
#
#   # AAP lab — single user (RIPU)
#   ./bin/run-grade.sh automating-ripu-with-ansible https://api.xxx:6443 pass \
#     --lab-type aap \
#     --aap-url https://controller-xxx.apps.example.com \
#     --aap-password MyPass \
#     --module 01
#
#   # RHEL/SSH only lab
#   ./bin/run-grade.sh my-rhel-lab https://api.xxx:6443 pass \
#     --lab-type rhel --ssh-host bastion.xxx.example.com
#
# Requirements: podman, oc CLI
# =============================================================================

set -euo pipefail

LAB_NAME="${1:?Usage: $0 <lab> <api-url> <admin-password> [flags]}"
API_URL="${2:?API URL required}"
ADMIN_PASSWORD="${3:?Admin password required}"
shift 3

# ── Parse flags ───────────────────────────────────────────────────────────────
FTL_MODE="--git"
LAB_TYPE=""
ARG_USER=""
ARG_MODULE=""
LAB_AAP_HOSTNAME=""
LAB_AAP_PASSWORD=""
LAB_SSH_HOST=""
LAB_SSH_USER="lab-user"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)          FTL_MODE="--local" ;;
    --git)            FTL_MODE="--git" ;;
    --lab-type)       LAB_TYPE="$2"; shift ;;
    --user)           ARG_USER="$2"; shift ;;
    --module)         ARG_MODULE="$2"; shift ;;
    --aap-url)        LAB_AAP_HOSTNAME="$2"; shift ;;
    --aap-password)   LAB_AAP_PASSWORD="$2"; shift ;;
    --ssh-host)       LAB_SSH_HOST="$2"; shift ;;
    --ssh-user)       LAB_SSH_USER="$2"; shift ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
  shift
done

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
    echo "FTL source: local ($SCRIPT_DIR)"
    ;;
  --git)
    echo "FTL source: cloned at runtime from GitHub (always latest)"
    ;;
esac

# ── Step 0.5: Lab infrastructure type ────────────────────────────────────────
if [ -z "$LAB_TYPE" ]; then
  echo ""
  echo "What type of infrastructure does this lab use?"
  echo "  1. OpenShift  (OCP cluster — MCP, ocp4-getting-started, etc.)"
  echo "  2. AAP + SSH  (Ansible Automation Platform + RHEL bastion — RIPU etc.)"
  echo "  3. RHEL / SSH only  (no OCP, no AAP)"
  read -rp "Lab type [1/2/3]: " LAB_TYPE_NUM
  case "$LAB_TYPE_NUM" in
    1) LAB_TYPE="ocp" ;;
    2) LAB_TYPE="aap" ;;
    3) LAB_TYPE="rhel" ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
fi

case "$LAB_TYPE" in
  ocp) ;;
  aap)
    if [ -z "$LAB_AAP_HOSTNAME" ]; then
      read -rp "AAP Controller URL (e.g. https://controller-xxx.apps.example.com): " LAB_AAP_HOSTNAME
    fi
    if [ -z "$LAB_AAP_PASSWORD" ]; then
      read -rsp "AAP password: " LAB_AAP_PASSWORD; echo ""
    fi
    if [ -z "$LAB_SSH_HOST" ]; then
      read -rp "Bastion SSH host (or Enter to skip): " LAB_SSH_HOST
      [ -n "$LAB_SSH_HOST" ] && read -rp "SSH user [lab-user]: " _u && LAB_SSH_USER="${_u:-lab-user}"
    fi
    ;;
  rhel)
    if [ -z "$LAB_SSH_HOST" ]; then
      read -rp "Bastion SSH host: " LAB_SSH_HOST
      read -rp "SSH user [lab-user]: " _u && LAB_SSH_USER="${_u:-lab-user}"
    fi
    ;;
  *) echo "ERROR: --lab-type must be ocp, aap, or rhel"; exit 1 ;;
esac

# ── Step 1: Login as admin (OCP) ─────────────────────────────────────────────
echo ""
OCP_OK=false
if [ "$LAB_TYPE" = "ocp" ]; then
  echo "Logging in as $ADMIN_USER..."
  if oc login "$API_URL" -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" \
    --insecure-skip-tls-verify=true 2>&1 | grep -v "^WARNING"; then
    OCP_OK=true
  fi
fi

INGRESS=""
if $OCP_OK; then
  INGRESS=$(oc get ingresses.config.openshift.io cluster \
    -o jsonpath='{.spec.domain}' 2>/dev/null || true)
  [ -n "$INGRESS" ] && echo "Cluster domain: $INGRESS"
elif [ "$LAB_TYPE" = "ocp" ]; then
  echo "OCP login failed"
fi

# ── Step 2: Detect users ──────────────────────────────────────────────────────
echo ""
ALL_USERS=()
SHOWROOM_NS=""
SINGLE_USER=false

if $OCP_OK; then
  while IFS= read -r ns; do
    u=$(echo "$ns" | sed 's/.*-\(user[0-9]*\)$/\1/' | grep '^user' || true)
    [[ "$u" =~ ^user[0-9]+$ ]] && ALL_USERS+=("$u")
  done < <(oc get namespaces --no-headers -o name \
    | grep "showroom" | cut -d/ -f2 | grep 'user[0-9]*$')

  if [ ${#ALL_USERS[@]} -eq 0 ]; then
    SHOWROOM_NS=$(oc get namespaces --no-headers -o name \
      | grep "showroom" | head -1 | cut -d/ -f2 || true)
    SINGLE_USER=true
    ALL_USERS=("student")
    [ -n "$SHOWROOM_NS" ] && echo "Single-user lab (namespace: $SHOWROOM_NS)" || echo "Single-user lab"
  else
    echo "Found users: ${ALL_USERS[*]}"
  fi
else
  SINGLE_USER=true
  ALL_USERS=("student")
  [ "$LAB_TYPE" != "ocp" ] && echo "Non-OCP lab — single user: student"
fi

# ── Step 3: Resolve user/module selection ─────────────────────────────────────
USERS=()
MODULES=()

# Resolve users
if [ -n "$ARG_USER" ]; then
  if [ "$ARG_USER" = "all" ]; then
    USERS=("${ALL_USERS[@]}")
  else
    USERS=("$ARG_USER")
  fi
fi

# Resolve modules
if [ -n "$ARG_MODULE" ]; then
  if [ "$ARG_MODULE" = "all" ]; then
    MODULES=()  # discover below
  else
    MODULES=("$ARG_MODULE")
  fi
fi

# Interactive prompts only for what's still missing
if $SINGLE_USER; then
  # Single-user lab
  if [ ${#USERS[@]} -eq 0 ]; then
    USERS=("student")
  fi
  if [ -z "$ARG_MODULE" ]; then
    echo "What do you want to grade?"
    echo "  1. Single module"
    echo "  2. All modules"
    read -rp "Choice [1/2]: " CHOICE
    case "$CHOICE" in
      1) read -rp "Which module (e.g. 01): " M; MODULES=("$M") ;;
      2) MODULES=() ;;
      *) echo "Invalid"; exit 1 ;;
    esac
  fi
else
  # Multi-user lab
  if [ ${#USERS[@]} -eq 0 ] && [ -z "$ARG_MODULE" ]; then
    # Fully interactive
    echo "What do you want to grade?"
    echo "  1. Single user, single module"
    echo "  2. Single user, all modules"
    echo "  3. All users, single module  (load test)"
    echo "  4. All users, all modules    (full load test)"
    read -rp "Choice [1-4]: " CHOICE
    case "$CHOICE" in
      1) echo "Users: ${ALL_USERS[*]}"; read -rp "Which user: " U; read -rp "Which module (e.g. 01): " M; USERS=("$U"); MODULES=("$M") ;;
      2) echo "Users: ${ALL_USERS[*]}"; read -rp "Which user: " U; USERS=("$U") ;;
      3) read -rp "Which module (e.g. 01): " M; USERS=("${ALL_USERS[@]}"); MODULES=("$M") ;;
      4) USERS=("${ALL_USERS[@]}") ;;
      *) echo "Invalid"; exit 1 ;;
    esac
  elif [ ${#USERS[@]} -eq 0 ]; then
    # Module given but not user — ask
    echo "Users: ${ALL_USERS[*]}"
    read -rp "Which user (or 'all'): " U
    [ "$U" = "all" ] && USERS=("${ALL_USERS[@]}") || USERS=("$U")
  elif [ -z "$ARG_MODULE" ] && [ ${#MODULES[@]} -eq 0 ]; then
    # User given but not module — ask
    read -rp "Which module (e.g. 01, or 'all'): " M
    [ "$M" = "all" ] || MODULES=("$M")
  fi
fi

# ── Step 4: Discover modules if needed ───────────────────────────────────────
if [ ${#MODULES[@]} -eq 0 ] && [ "$ARG_MODULE" != "01" ]; then
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
if $SINGLE_USER; then
  echo "Mode:    Single-user lab (${LAB_TYPE^^})"
elif [ ${#USERS[@]} -eq 1 ]; then
  echo "Mode:    Grading as ${USERS[0]}"
else
  echo "Mode:    Load test — grading ${#USERS[@]} users (running as admin)"
fi
echo "Running: ${#USERS[@]} user(s) × ${#MODULES[@]} module(s) = ${TOTAL_JOBS} job(s)"
echo "═══════════════════════════════════════════════════════"

# ── Step 5: Grade function ────────────────────────────────────────────────────
grade_user_module() {
  local user="$1"
  local mod="$2"

  local showroom_ns user_pass
  local gitea_admin_user="mcpadmin"
  local gitea_admin_pass="$ADMIN_PASSWORD"
  local aap_hostname="$LAB_AAP_HOSTNAME"
  local aap_password="$LAB_AAP_PASSWORD"

  # Find showroom namespace for this user
  if $OCP_OK; then
    if $SINGLE_USER && [ -n "$SHOWROOM_NS" ]; then
      showroom_ns="$SHOWROOM_NS"
    else
      showroom_ns=$(oc get namespaces --no-headers -o name \
        | grep "showroom" | grep "${user}$" | head -1 | cut -d/ -f2 || true)
    fi
  else
    showroom_ns=""
  fi

  user_pass="$ADMIN_PASSWORD"

  if [ -n "$showroom_ns" ]; then
    local raw_data
    raw_data=$(oc get configmap showroom-userdata -n "$showroom_ns" \
      -o jsonpath='{.data.user_data\.yml}' 2>/dev/null || true)

    if [ -n "$raw_data" ]; then
      extract_field() {
        local key="$1"
        echo "$raw_data" | grep "\"${key}\":" | head -1 | \
          sed 's/.*"'"$key"'": *"\([^"]*\)".*/\1/' | tr -d '\r\n'
      }

      local ep eg_user eg_pass e_aap_host e_aap_pass
      ep=$(extract_field "password")
      eg_user=$(extract_field "gitea_admin_username")
      eg_pass=$(extract_field "gitea_admin_password")
      e_aap_host=$(extract_field "controller_url")
      e_aap_pass=$(extract_field "controller_password")

      [ -n "$ep" ] && user_pass="$ep"
      [ -n "$eg_user" ] && gitea_admin_user="$eg_user"
      [ -n "$eg_pass" ] && gitea_admin_pass="$eg_pass"
      # Only use ConfigMap AAP creds if not explicitly provided via flags
      [ -z "$aap_hostname" ] && [ -n "$e_aap_host" ] && aap_hostname="$e_aap_host"
      [ -z "$aap_password" ] && [ -n "$e_aap_pass" ] && aap_password="$e_aap_pass"
    fi
  fi

  # Use admin kubeconfig
  local admin_kube
  admin_kube=$(mktemp)
  cp ~/.kube/config "$admin_kube" 2>/dev/null || \
    { KUBECONFIG="$admin_kube" oc login "$API_URL" \
        -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" \
        --insecure-skip-tls-verify=true 2>/dev/null || true; }
  trap "rm -f $admin_kube" RETURN

  local context_msg
  if $SINGLE_USER; then
    context_msg="${LAB_TYPE} lab"
  elif [ ${#USERS[@]} -eq 1 ]; then
    context_msg="grading as $user"
  else
    context_msg="load test — admin credentials"
  fi
  echo ""
  echo "▶ $LAB_NAME / module $mod / $user  ($context_msg)"

  if [ "$FTL_MODE" = "--local" ]; then
    VOLUME_ARGS="-v $SCRIPT_DIR:/ftl:ro"
  else
    VOLUME_ARGS=""
  fi
  PLAYBOOK="/ftl/labs/${LAB_NAME}/grade_module_${mod}.yml"

  podman run --rm \
    -v "$admin_kube:/home/runner/.kube/config:ro" \
    ${VOLUME_ARGS:+$VOLUME_ARGS} \
    -e LAB_USER="$user" \
    -e PASSWORD="$user_pass" \
    -e OPENSHIFT_CLUSTER_INGRESS_DOMAIN="$INGRESS" \
    -e GITEA_ADMIN_USER="$gitea_admin_user" \
    -e GITEA_ADMIN_PASSWORD="$gitea_admin_pass" \
    ${aap_hostname:+-e AAP_HOSTNAME="$aap_hostname"} \
    ${aap_password:+-e AAP_PASSWORD="$aap_password"} \
    ${LAB_SSH_HOST:+-e BASTION_HOST="$LAB_SSH_HOST"} \
    ${LAB_SSH_USER:+-e BASTION_USER="$LAB_SSH_USER"} \
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
