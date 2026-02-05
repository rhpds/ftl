#!/bin/bash
# Simple script to copy FTL files to bastion
# After copying, SSH to bastion and run setup there

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Bastion configuration
BASTION_HOST="ssh.ocpv08.rhdp.net"
BASTION_PORT="31422"
BASTION_USER="lab-user"

# Local directories
FTL_ROOT="/Users/psrivast/work/code/experiment/ftl"
LAB_DIR="${FTL_ROOT}/labs/aap-selfserv-intro-showroom"

echo "========================================="
echo "Copy FTL Files to Bastion"
echo "========================================="
echo "Local FTL Root: ${FTL_ROOT}"
echo "Bastion: ${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}"
echo ""
echo -e "${YELLOW}Password: FZRNyvUPbkCZ${NC}"
echo ""

# Step 1: Copy FTL roles
echo -e "${BLUE}Step 1/2: Copying FTL roles...${NC}"
rsync -avz --progress \
    -e "ssh -p ${BASTION_PORT}" \
    --exclude='.venv' \
    --exclude='*.pyc' \
    --exclude='__pycache__' \
    "${FTL_ROOT}/roles/" \
    "${BASTION_USER}@${BASTION_HOST}:/tmp/ftl-roles/"

echo -e "${GREEN}✅ Roles copied${NC}"
echo ""

# Step 2: Copy lab files
echo -e "${BLUE}Step 2/2: Copying lab files...${NC}"
rsync -avz --progress \
    -e "ssh -p ${BASTION_PORT}" \
    --exclude='.venv' \
    --exclude='*.pyc' \
    --exclude='__pycache__' \
    "${LAB_DIR}/" \
    "${BASTION_USER}@${BASTION_HOST}:/tmp/ftl-lab/"

echo -e "${GREEN}✅ Lab files copied${NC}"
echo ""

echo "========================================="
echo -e "${GREEN}✅ Files copied successfully!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. SSH to bastion:"
echo "   ssh -p ${BASTION_PORT} ${BASTION_USER}@${BASTION_HOST}"
echo ""
echo "2. Run the setup script on bastion:"
echo "   sudo bash /tmp/ftl-lab/setup_on_bastion.sh"
echo ""
echo "3. Run the test:"
echo "   cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom"
echo "   ./quick_test.sh 1 01"
echo ""
