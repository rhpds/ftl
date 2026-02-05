#!/bin/bash
# Setup FTL Environment on Bastion
# Creates Python virtual environment and installs all dependencies needed for FTL grading/solving
# Run this once after deploying the lab

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${LAB_DIR}/.venv"

echo "========================================="
echo "FTL Environment Setup"
echo "========================================="
echo "Lab Directory: ${LAB_DIR}"
echo "Virtual Environment: ${VENV_DIR}"
echo ""

# Check if running on bastion (optional check)
if [[ ! -f /etc/redhat-release ]]; then
    echo "WARNING: This script is intended for RHEL-based bastion hosts"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install system dependencies
echo "Step 1/5: Installing system dependencies..."
if ! command -v jq &> /dev/null; then
    echo "  Installing jq..."
    sudo dnf install -y jq
else
    echo "  jq already installed"
fi

if ! command -v curl &> /dev/null; then
    echo "  Installing curl..."
    sudo dnf install -y curl
else
    echo "  curl already installed"
fi

if ! command -v python3 &> /dev/null; then
    echo "  Installing Python 3..."
    sudo dnf install -y python3 python3-pip
else
    echo "  Python 3 already installed ($(python3 --version))"
fi

# Create virtual environment
echo ""
echo "Step 2/5: Creating Python virtual environment..."
if [[ -d "${VENV_DIR}" ]]; then
    echo "  Virtual environment already exists, removing old one..."
    rm -rf "${VENV_DIR}"
fi

python3 -m venv "${VENV_DIR}"
echo "  Virtual environment created at ${VENV_DIR}"

# Activate virtual environment
echo ""
echo "Step 3/5: Activating virtual environment..."
source "${VENV_DIR}/bin/activate"
echo "  Virtual environment activated"

# Upgrade pip
echo ""
echo "Step 4/5: Upgrading pip..."
pip install --upgrade pip wheel setuptools

# Install Python dependencies
echo ""
echo "Step 5/5: Installing Python dependencies..."
echo "  Installing ansible..."
pip install ansible>=2.14

echo "  Installing awxkit (awx CLI)..."
pip install awxkit

echo "  FTL roles already available at /opt/rhdp/ftl/roles/"
echo "  (ansible.cfg points to this directory)"

# Deactivate for now
deactivate

# Create activation helper script
cat > "${LAB_DIR}/activate_ftl" <<'EOF'
#!/bin/bash
# Source this file to activate FTL environment
# Usage: source activate_ftl

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${LAB_DIR}/.venv"

if [[ -d "${VENV_DIR}" ]]; then
    source "${VENV_DIR}/bin/activate"
    echo "✅ FTL environment activated"
    echo "Python: $(which python3)"
    echo "Ansible: $(ansible --version | head -n1)"
    echo "AWX CLI: $(which awx)"
else
    echo "❌ Virtual environment not found at ${VENV_DIR}"
    echo "Run ./setup_ftl_environment.sh first"
    return 1
fi
EOF

chmod +x "${LAB_DIR}/activate_ftl"

# Display completion message
echo ""
echo "========================================="
echo "✅ FTL Environment Setup Complete"
echo "========================================="
echo ""
echo "Virtual environment created at: ${VENV_DIR}"
echo ""
echo "Python packages installed:"
pip list | grep -E "ansible|awxkit"
echo ""
echo "To activate the environment:"
echo "  source ${LAB_DIR}/activate_ftl"
echo ""
echo "Or use the wrapper scripts:"
echo "  ./grade_lab.sh      # Grade all modules"
echo "  ./solve_lab.sh      # Solve all modules"
echo "  ./grade_module.sh 01  # Grade specific module"
echo ""
echo "Environment variables needed:"
echo "  export AAP_CONTROLLER_URL='https://...'"
echo "  export AAP_ADMIN_PASSWORD='...'"
echo "  export SELF_SERVICE_PORTAL_URL='https://...'"
echo ""
