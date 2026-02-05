#!/bin/bash
# Deploy FTL to Bastion and Run Tests
# Usage: ./deploy_to_bastion.sh

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
BASTION_PASSWORD="FZRNyvUPbkCZ"

# Local directory
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remote paths
REMOTE_TEMP="/tmp/ftl-aap-selfserv"
REMOTE_FINAL="/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom"

echo "========================================="
echo "FTL Deployment to Bastion"
echo "========================================="
echo "Local:  ${LOCAL_DIR}"
echo "Bastion: ${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}"
echo "Remote: ${REMOTE_FINAL}"
echo ""

# Check if sshpass is available (for non-interactive password)
if command -v sshpass &> /dev/null; then
    SSH_CMD="sshpass -p ${BASTION_PASSWORD} ssh -p ${BASTION_PORT} -o StrictHostKeyChecking=no"
    SCP_CMD="sshpass -p ${BASTION_PASSWORD} scp -P ${BASTION_PORT} -o StrictHostKeyChecking=no"
    RSYNC_CMD="sshpass -p ${BASTION_PASSWORD} rsync -avz -e 'ssh -p ${BASTION_PORT} -o StrictHostKeyChecking=no'"
else
    echo -e "${YELLOW}Note: sshpass not found - you'll need to enter password manually${NC}"
    echo "Install sshpass for non-interactive deployment: brew install hudochenkov/sshpass/sshpass"
    echo ""
    SSH_CMD="ssh -p ${BASTION_PORT}"
    SCP_CMD="scp -P ${BASTION_PORT}"
    RSYNC_CMD="rsync -avz -e 'ssh -p ${BASTION_PORT}'"
fi

# Step 1: Test connection
echo -e "${BLUE}Step 1/5: Testing bastion connection...${NC}"
if ${SSH_CMD} ${BASTION_USER}@${BASTION_HOST} "echo 'Connected successfully'" 2>/dev/null; then
    echo -e "${GREEN}✅ Connection successful${NC}"
else
    echo -e "${RED}❌ Cannot connect to bastion${NC}"
    echo "Please verify credentials and network access"
    exit 1
fi
echo ""

# Step 2: Copy files to bastion
echo -e "${BLUE}Step 2/5: Copying FTL files to bastion...${NC}"
echo "This may take 30-60 seconds..."

# Use rsync if available (faster), otherwise scp
if command -v rsync &> /dev/null; then
    eval ${RSYNC_CMD} \
        --exclude='.venv' \
        --exclude='*.pyc' \
        --exclude='.git' \
        --exclude='__pycache__' \
        "${LOCAL_DIR}/" \
        "${BASTION_USER}@${BASTION_HOST}:${REMOTE_TEMP}/"
else
    # Fallback to scp (recursive copy)
    ${SCP_CMD} -r "${LOCAL_DIR}" "${BASTION_USER}@${BASTION_HOST}:${REMOTE_TEMP}"
fi

echo -e "${GREEN}✅ Files copied to ${REMOTE_TEMP}${NC}"
echo ""

# Step 3: Setup FTL on bastion
echo -e "${BLUE}Step 3/5: Setting up FTL on bastion...${NC}"

${SSH_CMD} ${BASTION_USER}@${BASTION_HOST} << 'ENDSSH'
# Create FTL directory structure
sudo mkdir -p /opt/rhdp/ftl/labs/

# Remove old installation if exists
if [ -d "/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom" ]; then
    echo "Removing old installation..."
    sudo rm -rf /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
fi

# Move from temp to final location
echo "Moving to /opt/rhdp/ftl/labs/..."
sudo mv /tmp/ftl-aap-selfserv /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Make scripts executable
echo "Making scripts executable..."
sudo chmod +x /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/*.sh

# Change ownership to lab-user
echo "Setting ownership..."
sudo chown -R lab-user:users /opt/rhdp/ftl/

echo "✅ FTL setup complete"
ENDSSH

echo -e "${GREEN}✅ FTL installed at ${REMOTE_FINAL}${NC}"
echo ""

# Step 4: Install dependencies
echo -e "${BLUE}Step 4/5: Installing dependencies on bastion...${NC}"
echo "This will take 2-3 minutes..."

${SSH_CMD} ${BASTION_USER}@${BASTION_HOST} << 'ENDSSH'
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Run setup script
./setup_ftl_environment.sh

echo "✅ Dependencies installed"
ENDSSH

echo -e "${GREEN}✅ Virtual environment created and dependencies installed${NC}"
echo ""

# Step 5: Run quick test
echo -e "${BLUE}Step 5/5: Running quick test (user1, module 01)...${NC}"

${SSH_CMD} ${BASTION_USER}@${BASTION_HOST} << 'ENDSSH'
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Run quick test
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

# Display next steps
if [ ${TEST_RESULT} -eq 0 ]; then
    echo "🎉 FTL is deployed and working!"
    echo ""
    echo "Next steps:"
    echo "  1. SSH to bastion:"
    echo "     ssh -p ${BASTION_PORT} ${BASTION_USER}@${BASTION_HOST}"
    echo ""
    echo "  2. Run load test:"
    echo "     cd ${REMOTE_FINAL}"
    echo "     ./load_test_all_users.sh"
    echo ""
    echo "  3. View results:"
    echo "     cat /tmp/ftl_load_test/results.csv"
else
    echo "⚠️  Test failed - manual investigation needed"
    echo ""
    echo "Connect to bastion and check:"
    echo "  ssh -p ${BASTION_PORT} ${BASTION_USER}@${BASTION_HOST}"
    echo "  cd ${REMOTE_FINAL}"
    echo "  ./quick_test.sh 1 01"
fi
echo ""

exit ${TEST_RESULT}
