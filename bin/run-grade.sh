#!/usr/bin/env bash
# =============================================================================
# FTL Grade Runner
# Reads user credentials from Showroom ConfigMap and runs grader as a Pod
#
# Usage:
#   ./bin/run-grade.sh <lab-name> <module> <lab-user> <showroom-namespace>
#
# Example:
#   ./bin/run-grade.sh mcp-with-openshift 01 user1 showroom-zz94q-1-user1
#   ./bin/run-grade.sh mcp-with-openshift all user1 showroom-zz94q-1-user1
# =============================================================================

set -euo pipefail

LAB_NAME="${1:?Usage: $0 <lab-name> <module|all> <lab-user> <showroom-namespace>}"
MODULE="${2:?Module number required (e.g. 01) or 'all'}"
LAB_USER="${3:?Lab user required (e.g. user1)}"
SHOWROOM_NS="${4:?Showroom namespace required (e.g. showroom-zz94q-1-user1)}"

# Read credentials from Showroom ConfigMap
echo "Reading credentials from ConfigMap showroom-userdata in $SHOWROOM_NS..."
USER_DATA=$(oc get configmap showroom-userdata -n "$SHOWROOM_NS" \
  -o jsonpath='{.data.user_data\.yml}' 2>/dev/null)

if [ -z "$USER_DATA" ]; then
  echo "ERROR: Could not read showroom-userdata ConfigMap from $SHOWROOM_NS"
  exit 1
fi

# Extract values using python
PASSWORD=$(echo "$USER_DATA" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('password',''))")
INGRESS=$(echo "$USER_DATA" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('openshift_cluster_ingress_domain',''))")
GITEA_URL=$(echo "$USER_DATA" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('gitea_console_url',''))")

echo "User:    $LAB_USER"
echo "Domain:  $INGRESS"
echo "Gitea:   $GITEA_URL"
echo ""

# Ensure ftl-grading namespace exists
oc get namespace ftl-grading &>/dev/null || {
  echo "Creating ftl-grading namespace..."
  oc new-project ftl-grading
}

# Apply RBAC if needed
oc apply -f "$(dirname "$0")/../deploy/serviceaccount.yaml" &>/dev/null

JOB_ID=$(date +%s)

run_module() {
  local mod="$1"
  local job_name="ftl-grade-$(echo "$LAB_NAME" | tr '_' '-')-mod${mod}-${LAB_USER}-${JOB_ID}"

  echo "=== Grading Module $mod for $LAB_USER ==="

  # Create Job
  cat <<EOF | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: ${job_name}
  namespace: ftl-grading
  labels:
    app: ftl-grader
    lab: ${LAB_NAME}
    module: "${mod}"
    user: ${LAB_USER}
spec:
  ttlSecondsAfterFinished: 3600
  backoffLimit: 0
  template:
    spec:
      serviceAccountName: ftl-grader
      restartPolicy: Never
      containers:
      - name: grader
        image: quay.io/rhpds/ftl-grader:latest
        command:
        - ansible-playbook
        - /runner/labs/${LAB_NAME}/grade_module_${mod}.yml
        env:
        - name: LAB_USER
          value: "${LAB_USER}"
        - name: PASSWORD
          value: "${PASSWORD}"
        - name: OPENSHIFT_CLUSTER_INGRESS_DOMAIN
          value: "${INGRESS}"
        - name: GITEA_URL
          value: "${GITEA_URL}"
        - name: ANSIBLE_FORCE_COLOR
          value: "true"
        resources:
          requests:
            memory: 256Mi
            cpu: 100m
          limits:
            memory: 512Mi
            cpu: 500m
EOF

  # Wait for completion
  echo "Waiting for grader to complete..."
  oc wait --for=condition=complete job/"$job_name" -n ftl-grading --timeout=300s 2>/dev/null || \
  oc wait --for=condition=failed job/"$job_name" -n ftl-grading --timeout=300s 2>/dev/null || true

  # Show results
  echo ""
  echo "=== Grading Report: Module $mod for $LAB_USER ==="
  oc logs job/"$job_name" -n ftl-grading 2>/dev/null | grep -E "PASS|FAIL|ERROR|SUCCESS|Module|Exercise|====" || \
    oc logs job/"$job_name" -n ftl-grading 2>/dev/null | tail -30
  echo ""
}

if [ "$MODULE" = "all" ]; then
  for f in ~/work/code/experiment/ftl/labs/"$LAB_NAME"/grade_module_*.yml; do
    mod=$(basename "$f" | grep -oP '\d+')
    run_module "$mod"
  done
else
  run_module "$MODULE"
fi
