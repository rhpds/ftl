#!/bin/bash
# FTL Solve Lab - AAP Self-Service Portal Introduction
# Wrapper script that activates venv and runs solve_lab.yml

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${LAB_DIR}/.venv"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "FTL Solve Lab - AAP Self-Service Portal"
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
echo "  Admin User: admin"
echo ""

# Activate virtual environment
echo "Activating FTL environment..."
source "${VENV_DIR}/bin/activate"

# Change to lab directory
cd "${LAB_DIR}"

# Run solving playbook
echo ""
echo "========================================="
echo "Running FTL Solver"
echo "========================================="
echo ""

START_TIME=$(date +%s)

ansible-playbook -i inventory solve_lab.yml \
    -e "aap_controller_url=${AAP_CONTROLLER_URL}" \
    -e "aap_admin_password=${AAP_ADMIN_PASSWORD}" \
    -e "self_service_portal_url=${SELF_SERVICE_PORTAL_URL}" \
    "$@"

RESULT=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Display results
echo ""
echo "========================================="
if [[ ${RESULT} -eq 0 ]]; then
    echo -e "${GREEN}✅ Solving Complete - SUCCESS${NC}"
else
    echo -e "${RED}❌ Solving Complete - FAILED${NC}"
fi
echo "========================================="
echo "Duration: ${DURATION} seconds"
echo ""

# Deactivate venv
deactivate

exit ${RESULT}
