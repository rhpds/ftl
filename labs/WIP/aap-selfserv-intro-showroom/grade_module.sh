#!/bin/bash
# FTL Grade Single Module - AAP Self-Service Portal Introduction
# Wrapper script for grading individual modules
# Usage: ./grade_module.sh 01

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${LAB_DIR}/.venv"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse module number
MODULE_NUM="${1}"

if [[ -z "${MODULE_NUM}" ]]; then
    echo "Usage: $0 <module_number>"
    echo ""
    echo "Available modules:"
    echo "  01 - Verify Pre-Configured AAP Environment"
    echo "  02 - User Persona Testing"
    echo "  03 - Surveys and Custom Templates"
    echo ""
    echo "Example: $0 01"
    exit 1
fi

# Validate module number
if [[ ! -f "${LAB_DIR}/grade_module_${MODULE_NUM}.yml" ]]; then
    echo -e "${RED}❌ Module ${MODULE_NUM} not found${NC}"
    echo "Available modules:"
    for module in "${LAB_DIR}"/grade_module_*.yml; do
        if [[ -f "${module}" ]]; then
            basename "${module}" .yml | sed 's/grade_module_/  /'
        fi
    done
    exit 1
fi

echo "========================================="
echo "FTL Grade Module ${MODULE_NUM}"
echo "========================================="
echo ""

# Check if venv exists
if [[ ! -d "${VENV_DIR}" ]]; then
    echo -e "${RED}❌ Virtual environment not found${NC}"
    echo "Run ./setup_ftl_environment.sh first"
    exit 1
fi

# Check required environment variables
MISSING_VARS=()
if [[ -z "${AAP_CONTROLLER_URL}" ]]; then
    MISSING_VARS+=("AAP_CONTROLLER_URL")
fi
if [[ -z "${AAP_ADMIN_PASSWORD}" ]]; then
    MISSING_VARS+=("AAP_ADMIN_PASSWORD")
fi
if [[ -z "${SELF_SERVICE_PORTAL_URL}" ]]; then
    MISSING_VARS+=("SELF_SERVICE_PORTAL_URL")
fi

if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Missing required environment variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - ${var}"
    done
    echo ""
    echo "Example:"
    echo "  export AAP_CONTROLLER_URL='https://user1-aap-user1-aap.apps.cluster.example.com'"
    echo "  export AAP_ADMIN_PASSWORD='your-password'"
    echo "  export SELF_SERVICE_PORTAL_URL='https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster.example.com'"
    exit 1
fi

# Display environment info
echo -e "${GREEN}Environment:${NC}"
echo "  AAP Controller: ${AAP_CONTROLLER_URL}"
echo "  Portal: ${SELF_SERVICE_PORTAL_URL}"
echo "  Module: ${MODULE_NUM}"
echo ""

# Activate virtual environment
echo "Activating FTL environment..."
source "${VENV_DIR}/bin/activate"

# Change to lab directory
cd "${LAB_DIR}"

# Run module grading playbook
echo ""
echo "========================================="
echo "Running Module ${MODULE_NUM} Grader"
echo "========================================="
echo ""

START_TIME=$(date +%s)

ansible-playbook -i inventory "grade_module_${MODULE_NUM}.yml" \
    -e "aap_controller_url=${AAP_CONTROLLER_URL}" \
    -e "aap_admin_password=${AAP_ADMIN_PASSWORD}" \
    -e "self_service_portal_url=${SELF_SERVICE_PORTAL_URL}" \
    "${@:2}"  # Pass remaining arguments to ansible-playbook

RESULT=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Display results
echo ""
echo "========================================="
if [[ ${RESULT} -eq 0 ]]; then
    echo -e "${GREEN}✅ Module ${MODULE_NUM} Grading - PASSED${NC}"
else
    echo -e "${RED}❌ Module ${MODULE_NUM} Grading - FAILED${NC}"
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
    echo ""
fi

# Deactivate venv
deactivate

exit ${RESULT}
