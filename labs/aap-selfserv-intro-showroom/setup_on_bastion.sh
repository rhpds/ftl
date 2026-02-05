#!/bin/bash
# Setup script to run ON the bastion after copying files
# This installs FTL collection and sets up the environment

set -e

echo "========================================="
echo "FTL Collection Setup (on bastion)"
echo "========================================="

# Step 1: Create directory structure
echo "Step 1/4: Creating FTL directory structure..."
mkdir -p /opt/rhdp/ftl/roles
mkdir -p /opt/rhdp/ftl/labs

# Remove old installation if exists
if [ -d "/opt/rhdp/ftl/roles" ]; then
    rm -rf /opt/rhdp/ftl/roles/*
fi
if [ -d "/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom" ]; then
    rm -rf /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
fi

echo "✅ Directories created"
echo ""

# Step 2: Move roles
echo "Step 2/4: Installing FTL roles..."
mv /tmp/ftl-roles/* /opt/rhdp/ftl/roles/
rmdir /tmp/ftl-roles 2>/dev/null || true

echo "✅ Roles installed"
echo ""

# Step 3: Move lab
echo "Step 3/4: Installing lab files..."
mv /tmp/ftl-lab /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

echo "✅ Lab files installed"
echo ""

# Step 4: Set permissions and make scripts executable
echo "Step 4/4: Setting permissions..."
chmod +x /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/*.sh
chown -R lab-user:users /opt/rhdp/ftl/

echo "✅ Permissions set"
echo ""

echo "========================================="
echo "✅ FTL Collection Installed"
echo "========================================="
echo ""
echo "Installation location:"
echo "  Roles: /opt/rhdp/ftl/roles/"
echo "  Lab:   /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/"
echo ""
echo "Next steps:"
echo ""
echo "1. Install dependencies:"
echo "   cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom"
echo "   ./setup_ftl_environment.sh"
echo ""
echo "2. Run test:"
echo "   ./quick_test.sh 1 01"
echo ""
