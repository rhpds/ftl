#!/bin/bash
# Install kubernetes Python library in venv for k8s_info module

set -e

echo "=========================================="
echo "Installing Kubernetes Python Library"
echo "=========================================="

# Activate venv if it exists
if [ -f .venv/bin/activate ]; then
    echo "Activating virtual environment..."
    source .venv/bin/activate
else
    echo "❌ Error: .venv not found"
    echo "Run this from labs/aap-selfserv-intro-showroom/"
    exit 1
fi

# Install kubernetes library
echo "Installing kubernetes Python library..."
pip install kubernetes

echo ""
echo "✅ Installation complete!"
echo ""
echo "Now you can run:"
echo "  ./test_oauth_client.sh 1"
