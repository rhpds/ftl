#!/bin/bash
# Test RHDH Permission API using OAuth client credentials from OpenShift
# Extracts oauth-client-id and oauth-client-secret from Portal namespace

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
echo "Testing RHDH OAuth Client Authentication"
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

# Login to OpenShift as system:admin
echo "🔐 Logging into OpenShift as system:admin..."
oc login -u system:admin > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ OpenShift login successful: $(oc whoami)"
else
    echo "❌ OpenShift login failed"
    exit 1
fi

echo ""
echo "🧪 Running RHDH OAuth client test..."
echo ""

# Run the test
ansible-playbook test_portal_oauth_client.yml

echo ""
echo "=========================================="
echo "Test complete!"
echo "=========================================="
