#!/usr/bin/env bash
# =============================================================================
# FTL Grader — One script, all use cases
#
# Usage:
#   grade.sh <lab> <user|all> <module|all> <api-url> <admin-password>
#
# Single user, single module:
#   ./bin/run-grade.sh mcp-with-openshift user1 01 https://api.xxx:6443 MyPass
#
# Single user, all modules:
#   ./bin/run-grade.sh mcp-with-openshift user1 all https://api.xxx:6443 MyPass
#
# All users, single module (load test):
#   ./bin/run-grade.sh mcp-with-openshift all 01 https://api.xxx:6443 MyPass
#
# All users, all modules (full load test):
#   ./bin/run-grade.sh mcp-with-openshift all all https://api.xxx:6443 MyPass
#
# Requirements: oc CLI installed
# =============================================================================

set -euo pipefail

# ── Interactive mode when no args provided ────────────────────────────────────
if [ $# -eq 0 ]; then
  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║         FTL Grader — Interactive         ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""
  read -rp "OCP API URL (e.g. https://api.cluster-xxx.example.com:6443): " API_URL
  read -rsp "Admin password: " ADMIN_PASSWORD; echo ""
  echo ""
  echo "What do you want to do?"
  echo "  1. Grade a specific user + module"
  echo "  2. Grade all modules for a user"
  echo "  3. Load test — grade all users (single module)"
  echo "  4. Load test — grade all users (all modules)"
  read -rp "Choice [1-4]: " CHOICE

  case "$CHOICE" in
    1)
      read -rp "Lab name (e.g. mcp-with-openshift): " LAB_NAME
      read -rp "User (e.g. user1): " TARGET_USER
      read -rp "Module (e.g. 01): " MODULE
      ;;
    2)
      read -rp "Lab name (e.g. mcp-with-openshift): " LAB_NAME
      read -rp "User (e.g. user1): " TARGET_USER
      MODULE="all"
      ;;
    3)
      read -rp "Lab name (e.g. mcp-with-openshift): " LAB_NAME
      TARGET_USER="all"
      read -rp "Module (e.g. 01): " MODULE
      ;;
    4)
      read -rp "Lab name (e.g. mcp-with-openshift): " LAB_NAME
      TARGET_USER="all"
      MODULE="all"
      ;;
    *)
      echo "Invalid choice"; exit 1 ;;
  esac
  echo ""
else
  LAB_NAME="${1:?Usage: $0 <lab> <user|all> <module|all> <api-url> <admin-password>}"
  TARGET_USER="${2:?User (e.g. user1) or 'all' for load test}"
  MODULE="${3:?Module (e.g. 01) or 'all'}"
  API_URL="${4:?OCP API URL (e.g. https://api.cluster-xxx.example.com:6443)}"
  ADMIN_PASSWORD="${5:?Admin password}"
fi

ADMIN_USER="${ADMIN_USER:-admin}"
FTL_IMAGE="${FTL_IMAGE:-quay.io/rhpds/ftl-grader:latest}"
FTL_REPO="${FTL_REPO:-https://github.com/rhpds/ftl.git}"
FTL_REF="${FTL_REF:-main}"
PARALLEL="${PARALLEL:-true}"   # Run all-user jobs in parallel
JOB_ID=$(date +%s)

# ── Login ─────────────────────────────────────────────────────────────────────
echo "Logging in as $ADMIN_USER..."
oc login "$API_URL" -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" \
  --insecure-skip-tls-verify=true -q
echo "Cluster: $(oc whoami --show-server)"
echo ""

# ── Discover ingress domain ───────────────────────────────────────────────────
INGRESS=$(oc get ingresses.config.openshift.io cluster \
  -o jsonpath='{.spec.domain}' 2>/dev/null || \
  echo "$API_URL" | sed 's|https://api\.|apps.|;s|:6443||')
GITEA_URL="https://gitea.${INGRESS}"
echo "Cluster domain: $INGRESS"
echo ""

# ── Setup ftl-grading namespace + RBAC once ───────────────────────────────────
oc get namespace ftl-grading &>/dev/null || oc new-project ftl-grading -q
oc apply -f "$(dirname "$0")/../deploy/serviceaccount.yaml" -q 2>/dev/null || true

# ── Discover available users ──────────────────────────────────────────────────
discover_users() {
  oc get namespaces --no-headers -o name 2>/dev/null | \
    grep "^namespace/showroom" | cut -d/ -f2 | \
    grep -oP '(?<=showroom-[^-]+-\d+-)(user\d+)$' | sort -u || true
}

# ── Discover modules for a lab ────────────────────────────────────────────────
discover_modules() {
  # Check local repo first, fall back to listing via git ls-remote
  local local_labs
  local_labs="$(dirname "$0")/../labs/$LAB_NAME"
  if [ -d "$local_labs" ]; then
    ls "$local_labs"/grade_module_*.yml 2>/dev/null | \
      grep -oP 'grade_module_\K\d+' | sort
  else
    # Clone temporarily to list modules
    local tmp_dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch "$FTL_REF" "$FTL_REPO" "$tmp_dir" -q 2>/dev/null
    ls "$tmp_dir/labs/$LAB_NAME"/grade_module_*.yml 2>/dev/null | \
      grep -oP 'grade_module_\K\d+' | sort
    rm -rf "$tmp_dir"
  fi
}

# ── Get per-user password from Showroom ConfigMap ─────────────────────────────
get_user_password() {
  local user="$1"
  local ns
  ns=$(oc get namespaces --no-headers -o name 2>/dev/null | \
    grep "showroom" | grep "$user" | head -1 | cut -d/ -f2 || true)
  [ -z "$ns" ] && { echo "$ADMIN_PASSWORD"; return; }
  oc get configmap showroom-userdata -n "$ns" \
    -o jsonpath='{.data.user_data\.yml}' 2>/dev/null | \
    python3 -c "import sys,json; d=json.loads(sys.stdin.read()); \
      print(d.get('password', '$ADMIN_PASSWORD'))" 2>/dev/null || echo "$ADMIN_PASSWORD"
}

# ── Create and run a single grading Job ──────────────────────────────────────
run_job() {
  local user="$1"
  local mod="$2"
  local user_pass
  user_pass=$(get_user_password "$user")

  local safe_lab="${LAB_NAME//[^a-zA-Z0-9]/-}"
  local job_name="ftl-grade-${safe_lab}-m${mod}-${user}-${JOB_ID}"

  echo "  → Job: $LAB_NAME | module $mod | $user"

  # Store user password in Secret (avoid passing in env directly)
  local secret_name="ftl-creds-${user}-${JOB_ID}"
  oc create secret generic "$secret_name" -n ftl-grading \
    --from-literal=password="$user_pass" -q --dry-run=client -o yaml | \
    oc apply -f - -q

  oc apply -q -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: ${job_name}
  namespace: ftl-grading
  labels:
    app: ftl-grader
    lab: ${LAB_NAME}
    module: "${mod}"
    user: ${user}
    job-id: "${JOB_ID}"
spec:
  ttlSecondsAfterFinished: 7200
  backoffLimit: 0
  template:
    spec:
      serviceAccountName: ftl-grader
      restartPolicy: Never
      containers:
      - name: grader
        image: ${FTL_IMAGE}
        command: ["/usr/local/bin/ftl-entrypoint",
                  "/runner/ftl/labs/${LAB_NAME}/grade_module_${mod}.yml"]
        env:
        - name: LAB_USER
          value: "${user}"
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${secret_name}
              key: password
        - name: OPENSHIFT_CLUSTER_INGRESS_DOMAIN
          value: "${INGRESS}"
        - name: GITEA_URL
          value: "${GITEA_URL}"
        - name: FTL_REPO
          value: "${FTL_REPO}"
        - name: FTL_REF
          value: "${FTL_REF}"
        - name: ANSIBLE_FORCE_COLOR
          value: "true"
        resources:
          requests: {memory: 256Mi, cpu: 100m}
          limits:  {memory: 512Mi, cpu: 500m}
EOF

  echo "$job_name"
}

# ── Wait for a job and print results ─────────────────────────────────────────
wait_and_show() {
  local job_name="$1"
  local label="${2:-}"

  echo -n "  Waiting for $job_name"
  until oc get job "$job_name" -n ftl-grading \
      -o jsonpath='{.status.conditions[*].type}' 2>/dev/null | \
      grep -qE "Complete|Failed"; do
    echo -n "."; sleep 3
  done
  echo ""

  local status
  status=$(oc get job "$job_name" -n ftl-grading \
    -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' 2>/dev/null)

  echo "  ─── $label ───"
  oc logs "job/$job_name" -n ftl-grading 2>/dev/null | \
    grep -E "PASS|FAIL|ERROR|ok=|failed=|unreachable=|Exercise|Module" | head -40 || true
  echo ""
}

# ── Build job list ────────────────────────────────────────────────────────────
USERS=()
if [ "$TARGET_USER" = "all" ]; then
  mapfile -t USERS < <(discover_users)
  [ ${#USERS[@]} -eq 0 ] && { echo "ERROR: No users found on cluster"; exit 1; }
  echo "Found users: ${USERS[*]}"
else
  USERS=("$TARGET_USER")
fi

MODULES=()
if [ "$MODULE" = "all" ]; then
  mapfile -t MODULES < <(discover_modules)
  [ ${#MODULES[@]} -eq 0 ] && { echo "ERROR: No modules found for $LAB_NAME"; exit 1; }
  echo "Found modules: ${MODULES[*]}"
else
  MODULES=("$MODULE")
fi

echo ""
echo "Running: ${#USERS[@]} user(s) × ${#MODULES[@]} module(s) = $((${#USERS[@]} * ${#MODULES[@]})) job(s)"
echo ""

# ── Submit all jobs (parallel or serial) ─────────────────────────────────────
declare -A JOB_LABELS=()

for user in "${USERS[@]}"; do
  for mod in "${MODULES[@]}"; do
    job=$(run_job "$user" "$mod")
    JOB_LABELS["$job"]="${user} / module ${mod}"
  done
done

echo ""
echo "All jobs submitted. Collecting results..."
echo ""

# ── Collect results ───────────────────────────────────────────────────────────
for job in "${!JOB_LABELS[@]}"; do
  wait_and_show "$job" "${JOB_LABELS[$job]}"
done

echo "═══════════════════════════════════════"
echo "All grading complete."
echo "Jobs: oc get jobs -n ftl-grading -l job-id=${JOB_ID}"
echo "═══════════════════════════════════════"
