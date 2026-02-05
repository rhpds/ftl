#!/bin/bash
# Deploy Complete FTL Collection to Bastion
# This includes the roles directory needed by the graders

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Bastion configuration
BASTION_HOST="ssh.ocpv08.rhdp.net"
BASTION_PORT="31422"
BASTION_USER="lab-user"

# Local directories
FTL_ROOT="/Users/psrivast/work/code/experiment/ftl"
LAB_DIR="${FTL_ROOT}/labs/aap-selfserv-intro-showroom"

# Remote paths
REMOTE_COLLECTION="/opt/rhdp/ftl"
REMOTE_LAB="${REMOTE_COLLECTION}/labs/aap-selfserv-intro-showroom"

echo "========================================="
echo "FTL Collection Deployment to Bastion"
echo "========================================="
echo "Local FTL Root: ${FTL_ROOT}"
echo "Bastion: ${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}"
echo "Remote: ${REMOTE_COLLECTION}"
echo ""

# Check if sshpass is available
if command -v sshpass &> /dev/null; then
    SSH_CMD="sshpass -p FZRNyvUPbkCZ ssh -p ${BASTION_PORT} -o StrictHostKeyChecking=no"
    RSYNC_CMD="sshpass -p FZRNyvUPbkCZ rsync -avz -e 'ssh -p ${BASTION_PORT} -o StrictHostKeyChecking=no'"
else
    echo -e "${YELLOW}Note: Enter password 'FZRNyvUPbkCZ' when prompted${NC}"
    SSH_CMD="ssh -p ${BASTION_PORT}"
    RSYNC_CMD="rsync -avz -e 'ssh -p ${BASTION_PORT}'"
fi

# Step 1: Copy FTL roles to bastion
echo -e "${BLUE}Step 1/4: Copying FTL collection roles...${NC}"

if command -v rsync &> /dev/null; then
    eval ${RSYNC_CMD} \
        --exclude='.venv' \
        --exclude='*.pyc' \
        --exclude='__pycache__' \
        "${FTL_ROOT}/roles/" \
        "${BASTION_USER}@${BASTION_HOST}:/tmp/ftl-roles/"
else
    scp -P ${BASTION_PORT} -r "${FTL_ROOT}/roles" "${BASTION_USER}@${BASTION_HOST}:/tmp/ftl-roles"
fi

echo -e "${GREEN}✅ Roles copied${NC}"
echo ""

# Step 2: Copy lab files
echo -e "${BLUE}Step 2/4: Copying lab files...${NC}"

if command -v rsync &> /dev/null; then
    eval ${RSYNC_CMD} \
        --exclude='.venv' \
        --exclude='*.pyc' \
        --exclude='__pycache__' \
        "${LAB_DIR}/" \
        "${BASTION_USER}@${BASTION_HOST}:/tmp/ftl-lab/"
else
    scp -P ${BASTION_PORT} -r "${LAB_DIR}" "${BASTION_USER}@${BASTION_HOST}:/tmp/ftl-lab"
fi

echo -e "${GREEN}✅ Lab files copied${NC}"
echo ""

# Step 3: Setup on bastion
echo -e "${BLUE}Step 3/4: Setting up FTL on bastion...${NC}"

${SSH_CMD} ${BASTION_USER}@${BASTION_HOST} << 'ENDSSH'
# Create FTL collection structure
sudo mkdir -p /opt/rhdp/ftl/roles
sudo mkdir -p /opt/rhdp/ftl/labs

# Remove old installation if exists
if [ -d "/opt/rhdp/ftl/roles" ]; then
    sudo rm -rf /opt/rhdp/ftl/roles/*
fi
if [ -d "/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom" ]; then
    sudo rm -rf /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
fi

# Move roles
echo "Installing FTL roles..."
sudo mv /tmp/ftl-roles/* /opt/rhdp/ftl/roles/

# Move lab
echo "Installing lab..."
sudo mv /tmp/ftl-lab /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Clean up temp directories
sudo rmdir /tmp/ftl-roles 2>/dev/null || true

# Make scripts executable
sudo chmod +x /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/*.sh

# Set ownership
sudo chown -R lab-user:users /opt/rhdp/ftl/

echo "✅ FTL collection installed"
ENDSSH

echo -e "${GREEN}✅ FTL collection structure created${NC}"
echo ""

# Step 4: Install dependencies and test
echo -e "${BLUE}Step 4/4: Installing dependencies and testing...${NC}"

${SSH_CMD} ${BASTION_USER}@${BASTION_HOST} << 'ENDSSH'
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Run setup
./setup_ftl_environment.sh

# Run quick test
echo ""
echo "Running quick test..."
./quick_test.sh 1 01
ENDSSH

TEST_RESULT=$?

echo ""
echo "========================================="
if [ ${TEST_RESULT} -eq 0 ]; then
    echo -e "${GREEN}✅ Deployment and Test SUCCESSFUL${NC}"
else
    echo -e "${RED}❌ Test FAILED${NC}"
fi
echo "========================================="
echo ""

if [ ${TEST_RESULT} -eq 0 ]; then
    echo "🎉 FTL is fully deployed and working!"
    echo ""
    echo "FTL Collection installed at:"
    echo "  Roles: ${REMOTE_COLLECTION}/roles/"
    echo "  Lab:   ${REMOTE_LAB}/"
    echo ""
    echo "Next steps:"
    echo "  1. SSH to bastion:"
    echo "     ssh -p ${BASTION_PORT} ${BASTION_USER}@${BASTION_HOST}"
    echo ""
    echo "  2. Run load test:"
    echo "     cd ${REMOTE_LAB}"
    echo "     ./load_test_all_users.sh"
    echo ""
    echo "  3. View results:"
    echo "     cat /tmp/ftl_load_test/results.csv"
else
    echo "⚠️  Test failed - check logs above"
    echo ""
    echo "Connect to bastion for debugging:"
    echo "  ssh -p ${BASTION_PORT} ${BASTION_USER}@${BASTION_HOST}"
    echo "  cd ${REMOTE_LAB}"
fi
echo ""

exit ${TEST_RESULT}
