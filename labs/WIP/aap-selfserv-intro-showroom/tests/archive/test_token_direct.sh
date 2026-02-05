#!/bin/bash
# Test AAP token from secret directly (skip OAuth flow)

set -e

# Source user environment
if [ ! -f set_user_env.sh ]; then
    echo "❌ Error: set_user_env.sh not found"
    exit 1
fi

USER_NUM="${1:-1}"
source set_user_env.sh "$USER_NUM"

echo "=========================================="
echo "Testing AAP Token Direct (No OAuth)"
echo "=========================================="
echo "User: user${USER_NUM}"
echo "Portal: ${SELF_SERVICE_PORTAL_URL}"
echo ""

# Check OC
if ! command -v oc &> /dev/null; then
    echo "❌ Error: 'oc' command not found"
    exit 1
fi

# Login to OpenShift
echo "🔐 Logging into OpenShift as system:admin..."
oc login -u system:admin > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ OpenShift login successful: $(oc whoami)"
else
    echo "❌ OpenShift login failed"
    exit 1
fi

echo ""
echo "🧪 Testing AAP token directly..."
echo ""

# Run the test
ansible-playbook test_aap_token_direct.yml

echo ""
echo "=========================================="
echo "Test complete!"
echo "=========================================="
