#!/bin/bash
# FTL Load Test - Grade All Users in Parallel
# Tests all 3 users from the deployment simultaneously

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${LAB_DIR}/.venv"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Deployment configuration
GUID="j7kml"
CLUSTER_DOMAIN="apps.cluster-${GUID}.dynamic.redhatworkshops.io"
COMMON_PASSWORD="MjUxMzcw"
NUM_USERS=3

# Results directory
RESULTS_DIR="/tmp/ftl_load_test"
mkdir -p "${RESULTS_DIR}"

echo "========================================="
echo "FTL Load Test - All Users"
echo "========================================="
echo "GUID: ${GUID}"
echo "Users: ${NUM_USERS}"
echo "Results: ${RESULTS_DIR}"
echo ""

# Check if venv exists
if [[ ! -d "${VENV_DIR}" ]]; then
    echo -e "${RED}❌ Virtual environment not found${NC}"
    echo "Run ./setup_ftl_environment.sh first"
    exit 1
fi

# Function to grade a single user
grade_user() {
    local USER_NUM=$1
    local USER="user${USER_NUM}"
    local LOG_FILE="${RESULTS_DIR}/grade_${USER}.log"

    echo -e "${BLUE}Starting ${USER}...${NC}"

    # Set environment for this user
    export AAP_CONTROLLER_URL="https://${USER}-aap-${USER}-aap.${CLUSTER_DOMAIN}"
    export AAP_ADMIN_USERNAME="admin"
    export AAP_ADMIN_PASSWORD="${COMMON_PASSWORD}"
    export SELF_SERVICE_PORTAL_URL="https://self-service-rhaap-portal-${USER}-aap-ssap.${CLUSTER_DOMAIN}"

    # Activate venv
    source "${VENV_DIR}/bin/activate"

    # Change to lab directory
    cd "${LAB_DIR}"

    # Record start time
    local START_TIME=$(date +%s)

    # Run grading playbook
    ansible-playbook -i localhost, grade_lab.yml \
        -e "aap_controller_url=${AAP_CONTROLLER_URL}" \
        -e "aap_admin_password=${AAP_ADMIN_PASSWORD}" \
        -e "self_service_portal_url=${SELF_SERVICE_PORTAL_URL}" \
        > "${LOG_FILE}" 2>&1

    local RESULT=$?
    local END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))

    # Deactivate venv
    deactivate

    # Record result
    echo "${USER},${RESULT},${DURATION}" >> "${RESULTS_DIR}/results.csv"

    # Display result
    if [[ ${RESULT} -eq 0 ]]; then
        echo -e "${GREEN}✅ ${USER} - PASSED (${DURATION}s)${NC}"
    else
        echo -e "${RED}❌ ${USER} - FAILED (${DURATION}s)${NC}"
    fi

    # Copy grading report if exists
    if [[ -f /tmp/grading_dir/grading_report.txt ]]; then
        cp /tmp/grading_dir/grading_report.txt "${RESULTS_DIR}/report_${USER}.txt"
    fi

    return ${RESULT}
}

# Initialize results file
echo "user,exit_code,duration_seconds" > "${RESULTS_DIR}/results.csv"

# Record overall start time
OVERALL_START=$(date +%s)

echo ""
echo "========================================="
echo "Running Graders in Parallel"
echo "========================================="
echo ""

# Grade all users in parallel
for i in $(seq 1 ${NUM_USERS}); do
    grade_user ${i} &
done

# Wait for all background jobs to complete
wait

# Calculate overall duration
OVERALL_END=$(date +%s)
OVERALL_DURATION=$((OVERALL_END - OVERALL_START))

# Display summary
echo ""
echo "========================================="
echo "Load Test Complete"
echo "========================================="
echo "Total Duration: ${OVERALL_DURATION} seconds"
echo ""

# Analyze results
TOTAL=0
PASSED=0
FAILED=0

while IFS=, read -r user exit_code duration; do
    if [[ "${user}" == "user" ]]; then
        continue  # Skip header
    fi
    TOTAL=$((TOTAL + 1))
    if [[ ${exit_code} -eq 0 ]]; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done < "${RESULTS_DIR}/results.csv"

echo "Results Summary:"
echo "  Total Users: ${TOTAL}"
echo -e "  ${GREEN}Passed: ${PASSED}${NC}"
echo -e "  ${RED}Failed: ${FAILED}${NC}"
echo ""

# Display results table
echo "Detailed Results:"
echo "----------------------------------------"
printf "%-10s %-12s %-10s\n" "User" "Status" "Duration"
echo "----------------------------------------"

while IFS=, read -r user exit_code duration; do
    if [[ "${user}" == "user" ]]; then
        continue  # Skip header
    fi

    if [[ ${exit_code} -eq 0 ]]; then
        STATUS="${GREEN}PASSED${NC}"
    else
        STATUS="${RED}FAILED${NC}"
    fi

    printf "%-10s " "${user}"
    echo -ne "${STATUS}"
    printf "%12s\n" " ${duration}s"
done < "${RESULTS_DIR}/results.csv"

echo "----------------------------------------"
echo ""

# Show file locations
echo "Files Generated:"
echo "  Results CSV: ${RESULTS_DIR}/results.csv"
echo "  User logs: ${RESULTS_DIR}/grade_user*.log"
echo "  Reports: ${RESULTS_DIR}/report_user*.txt"
echo ""

# Exit with failure if any user failed
if [[ ${FAILED} -gt 0 ]]; then
    echo -e "${RED}❌ Load test FAILED - ${FAILED} user(s) did not pass${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Load test PASSED - All users passed!${NC}"
    exit 0
fi
