#!/bin/bash
# FTL Quick Test - Test Single User's Lab
# Usage: ./quick_test.sh [user_number] [module_number]
# Examples:
#   ./quick_test.sh 1       # Grade all modules for user1
#   ./quick_test.sh 2 01    # Grade module 01 for user2

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${LAB_DIR}/.venv"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
USER_NUM="${1:-1}"  # Default to user1
MODULE_NUM="${2}"   # Optional - if not provided, grade all modules

# Deployment configuration
GUID="j7kml"
CLUSTER_DOMAIN="apps.cluster-${GUID}.dynamic.redhatworkshops.io"
COMMON_PASSWORD="MjUxMzcw"

echo "========================================="
echo "FTL Quick Test"
echo "========================================="
echo "User: user${USER_NUM}"
if [[ -n "${MODULE_NUM}" ]]; then
    echo "Module: ${MODULE_NUM}"
else
    echo "Modules: All"
fi
echo ""

# Check if venv exists
if [[ ! -d "${VENV_DIR}" ]]; then
    echo -e "${RED}❌ Virtual environment not found${NC}"
    echo "Run ./setup_ftl_environment.sh first"
    exit 1
fi

# Set environment variables for this user
export AAP_CONTROLLER_URL="https://user${USER_NUM}-aap-user${USER_NUM}-aap.${CLUSTER_DOMAIN}"
export AAP_ADMIN_USERNAME="admin"
export AAP_ADMIN_PASSWORD="${COMMON_PASSWORD}"
export SELF_SERVICE_PORTAL_URL="https://self-service-rhaap-portal-user${USER_NUM}-aap-ssap.${CLUSTER_DOMAIN}"

echo -e "${GREEN}Environment:${NC}"
echo "  AAP Controller: ${AAP_CONTROLLER_URL}"
echo "  Admin: ${AAP_ADMIN_USERNAME}"
echo "  Portal: ${SELF_SERVICE_PORTAL_URL}"
echo ""

# Activate virtual environment
echo "Activating FTL environment..."
source "${VENV_DIR}/bin/activate"

# Change to lab directory
cd "${LAB_DIR}"

# Run grading
echo ""
echo "========================================="
echo "Running FTL Grader"
echo "========================================="
echo ""

START_TIME=$(date +%s)

if [[ -z "${MODULE_NUM}" ]]; then
    # Grade all modules
    ansible-playbook -i inventory grade_lab.yml \
        -e "aap_controller_url=${AAP_CONTROLLER_URL}" \
        -e "aap_admin_password=${AAP_ADMIN_PASSWORD}" \
        -e "self_service_portal_url=${SELF_SERVICE_PORTAL_URL}"
else
    # Grade specific module
    ansible-playbook -i inventory "grade_module_${MODULE_NUM}.yml" \
        -e "aap_controller_url=${AAP_CONTROLLER_URL}" \
        -e "aap_admin_password=${AAP_ADMIN_PASSWORD}" \
        -e "self_service_portal_url=${SELF_SERVICE_PORTAL_URL}"
fi

RESULT=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Deactivate venv
deactivate

# Display results
echo ""
echo "========================================="
if [[ ${RESULT} -eq 0 ]]; then
    echo -e "${GREEN}✅ Grading Complete - PASSED${NC}"
else
    echo -e "${RED}❌ Grading Complete - FAILED${NC}"
fi
echo "========================================="
echo "Duration: ${DURATION} seconds"
echo ""

# Show grading report if it exists
if [[ -f /tmp/grading_dir/grading_report.txt ]]; then
    echo "Grading Report:"
    echo "----------------------------------------"
    cat /tmp/grading_dir/grading_report.txt
    echo "----------------------------------------"
    echo ""
    echo "Full report: /tmp/grading_dir/grading_report.txt"
fi

exit ${RESULT}
