#!/bin/bash
# Test RHDH backend secret authentication
# Ensures OCP login before testing

set -e

# Source user environment
if [ ! -f set_user_env.sh ]; then
    echo "❌ Error: set_user_env.sh not found"
    echo "Run this script from labs/aap-selfserv-intro-showroom/"
    exit 1
fi

USER_NUM="${1:-1}"
source set_user_env.sh "$USER_NUM"

echo "=========================================="
echo "Testing RHDH Backend Secret Authentication"
echo "=========================================="
echo "User: user${USER_NUM}"
echo "Portal: ${SELF_SERVICE_PORTAL_URL}"
echo ""

# Check if oc is installed
if ! command -v oc &> /dev/null; then
    echo "❌ Error: 'oc' command not found"
    echo "Please install OpenShift CLI"
    exit 1
fi

# Login to OpenShift as system:admin (lab-user has permission)
echo "🔐 Logging into OpenShift as system:admin..."
oc login -u system:admin > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ OpenShift login successful: $(oc whoami)"
else
    echo "❌ OpenShift login failed"
    exit 1
fi

echo ""
echo "🧪 Running RHDH backend secret test..."
echo ""

# Run the test
ansible-playbook test_rhdh_backend_secret.yml

echo ""
echo "=========================================="
echo "Test complete!"
echo "=========================================="
