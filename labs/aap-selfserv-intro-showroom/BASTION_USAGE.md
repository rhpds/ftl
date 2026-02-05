# FTL Bastion Usage Guide - AAP Self-Service Portal Lab

This guide explains how to use the FTL wrapper scripts on the bastion host for grading and solving the AAP Self-Service Portal lab.

---

## 🚀 Quick Start

### 1. One-Time Setup

Run the setup script to create a Python virtual environment and install all dependencies:

```bash
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
./setup_ftl_environment.sh
```

**What this does:**
- ✅ Installs system dependencies (jq, curl, python3)
- ✅ Creates Python virtual environment at `.venv/`
- ✅ Installs Ansible and awxkit (awx CLI)
- ✅ Installs ansible.controller collection
- ✅ Installs rhdp.ftl collection
- ✅ Creates `activate_ftl` helper script

**Duration:** ~2-3 minutes

---

### 2. Set Environment Variables

Before running graders/solvers, export the required environment variables:

```bash
# Required for all operations
export AAP_CONTROLLER_URL='https://user1-aap-user1-aap.apps.cluster-abc123.example.com'
export AAP_ADMIN_PASSWORD='Xy8aB2cD'
export SELF_SERVICE_PORTAL_URL='https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster-abc123.example.com'
```

**Where to find these values:**
- From AgnosticV userdata: `agnosticd_user_data` lookup
- From deployment output (check `/tmp/output_dir/`)
- From instructor/workshop admin

**Tip:** Add these to a file and source it:
```bash
# Save to env.sh
cat > env.sh <<EOF
export AAP_CONTROLLER_URL='https://...'
export AAP_ADMIN_PASSWORD='...'
export SELF_SERVICE_PORTAL_URL='https://...'
EOF

# Source it
source env.sh
```

---

### 3. Run Grader or Solver

#### Grade All Modules
```bash
./grade_lab.sh
```

#### Solve All Modules
```bash
./solve_lab.sh
```

#### Grade Specific Module
```bash
./grade_module.sh 01  # Module 1: Verify Pre-Configured Environment
./grade_module.sh 02  # Module 2: User Persona Testing
./grade_module.sh 03  # Module 3: Surveys and Custom Templates
```

#### Solve Specific Module
```bash
./solve_module.sh 01  # Module 1: Validate environment (no-op)
./solve_module.sh 02  # Module 2: Execute jobs as personas
./solve_module.sh 03  # Module 3: Modify surveys and import templates
```

---

## 📁 Wrapper Scripts Overview

### `setup_ftl_environment.sh`
**Purpose:** One-time setup of Python virtual environment and dependencies

**What it installs:**
- System packages: jq, curl, python3, python3-pip
- Python packages: ansible, awxkit
- Ansible collections: ansible.controller, rhdp.ftl

**Output:**
- Virtual environment at `.venv/`
- Activation helper at `activate_ftl`

---

### `grade_lab.sh`
**Purpose:** Grade all modules (runs `grade_lab.yml`)

**What it does:**
1. ✅ Checks virtual environment exists
2. ✅ Validates required environment variables
3. ✅ Activates virtual environment
4. ✅ Runs `ansible-playbook grade_lab.yml`
5. ✅ Displays grading report from `/tmp/grading_dir/grading_report.txt`
6. ✅ Deactivates virtual environment

**Exit codes:**
- `0` - All modules passed
- `non-zero` - One or more modules failed

**Example output:**
```
=========================================
FTL Grade Lab - AAP Self-Service Portal
=========================================

Environment:
  AAP Controller: https://user1-aap-user1-aap.apps...
  Portal: https://self-service-rhaap-portal...
  Admin User: admin

Activating FTL environment...

=========================================
Running FTL Grader
=========================================

[Ansible playbook output...]

=========================================
✅ Grading Complete - PASSED
=========================================
Duration: 45 seconds

Grading Report:
----------------------------------------
PASS: Demo user 'clouduser1' exists in AAP
PASS: Demo user 'networkuser1' exists in AAP
...
SUCCESS 0 Errors
SHA256: a3d5f8e9c2b1a4f7...
----------------------------------------
```

---

### `solve_lab.sh`
**Purpose:** Solve all modules (runs `solve_lab.yml`)

**What it does:**
1. ✅ Checks virtual environment exists
2. ✅ Validates required environment variables
3. ✅ Activates virtual environment
4. ✅ Runs `ansible-playbook solve_lab.yml`
5. ✅ Deactivates virtual environment

**Exit codes:**
- `0` - All modules solved successfully
- `non-zero` - One or more modules failed to solve

---

### `grade_module.sh <module_number>`
**Purpose:** Grade a specific module

**Usage:**
```bash
./grade_module.sh 01  # Grade Module 1 only
./grade_module.sh 02  # Grade Module 2 only
./grade_module.sh 03  # Grade Module 3 only
```

**Modules:**
- `01` - Verify Pre-Configured AAP Environment (13 checkpoints)
- `02` - User Persona Testing (7 checkpoints)
- `03` - Surveys and Custom Templates (9 checkpoints)

**Passing extra arguments:**
```bash
# Run with verbose output
./grade_module.sh 01 -v

# Run with extra variables
./grade_module.sh 02 -e "debug_mode=true"
```

---

### `solve_module.sh <module_number>`
**Purpose:** Solve a specific module

**Usage:**
```bash
./solve_module.sh 01  # Validate environment (no-op)
./solve_module.sh 02  # Execute jobs as user personas
./solve_module.sh 03  # Modify surveys and import templates
```

**What each module does:**
- **Module 01:** Validates pre-configured environment (read-only, no changes)
- **Module 02:** Executes job templates as clouduser1, networkuser1, rheluser1
- **Module 03:** Modifies surveys in AAP, imports custom templates to Portal

---

## 🔧 Manual Virtual Environment Activation

If you want to run Ansible playbooks manually without the wrapper scripts:

```bash
# Activate virtual environment
source activate_ftl

# Now you can run ansible-playbook directly
ansible-playbook grade_module_01.yml \
    -e "aap_controller_url=${AAP_CONTROLLER_URL}" \
    -e "aap_admin_password=${AAP_ADMIN_PASSWORD}" \
    -e "self_service_portal_url=${SELF_SERVICE_PORTAL_URL}"

# Or use awx CLI directly
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username admin \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    users list

# Deactivate when done
deactivate
```

---

## 🧪 Testing FTL Before Event

### Test Sequence

1. **Setup environment** (one-time):
   ```bash
   ./setup_ftl_environment.sh
   ```

2. **Set environment variables:**
   ```bash
   source env.sh  # or export manually
   ```

3. **Test Module 1** (validates pre-configured content):
   ```bash
   ./grade_module.sh 01
   ```
   **Expected:** All 13 checkpoints should pass (users, inventories, job templates exist)

4. **Solve Module 2** (execute jobs):
   ```bash
   ./solve_module.sh 02
   ```
   **Expected:** Jobs executed as clouduser1, networkuser1, rheluser1

5. **Grade Module 2** (verify job execution):
   ```bash
   ./grade_module.sh 02
   ```
   **Expected:** All job execution checkpoints pass

6. **Grade entire lab:**
   ```bash
   ./grade_lab.sh
   ```
   **Expected:** All modules pass, report generated at `/tmp/grading_dir/grading_report.txt`

---

## 🚀 Load Testing Multiple Users

For load testing with multiple users (e.g., before a 30-student event):

```bash
# Create load test script
cat > load_test.sh <<'EOF'
#!/bin/bash

# Read AAP instances from AgnosticD userdata
AAP_INSTANCES=$(cat /tmp/aap_instances.json | jq -r '.[]')

# Grade each user's lab in parallel
for instance in ${AAP_INSTANCES}; do
    USER=$(echo ${instance} | jq -r '.user')
    AAP_URL=$(echo ${instance} | jq -r '.route')
    PASSWORD=$(echo ${instance} | jq -r '.password')

    echo "Testing ${USER}..."

    (
        export AAP_CONTROLLER_URL="https://${AAP_URL}"
        export AAP_ADMIN_PASSWORD="${PASSWORD}"
        export SELF_SERVICE_PORTAL_URL="https://self-service-rhaap-portal-${USER}-aap-ssap.apps..."

        ./grade_lab.sh > /tmp/ftl_load_test/grade_${USER}.log 2>&1
        echo "${USER},$?,$SECONDS" >> /tmp/ftl_load_test/results.csv
    ) &
done

# Wait for all background jobs
wait

echo "Load test complete. Results in /tmp/ftl_load_test/results.csv"
EOF

chmod +x load_test.sh
```

---

## 📊 Grading Report

After running `grade_lab.sh`, the grading report is saved to:
```
/tmp/grading_dir/grading_report.txt
```

**Report format:**
```
================================================================================
FTL Grading Report
================================================================================
Lab:      Introduction to Ansible Automation Platform Self-Service Portal
Date:     2026-02-04 15:30:00 UTC
Student:  user1
GUID:     abc123

================================================================================
Results
================================================================================

PASS: Demo user 'clouduser1' exists in AAP
PASS: Demo user 'networkuser1' exists in AAP
PASS: Demo user 'rheluser1' exists in AAP
PASS: AWS Inventory exists in AAP
PASS: Network Inventory exists in AAP
PASS: RHEL Inventory exists in AAP
PASS: Project 'SelfService Demo playbooks' exists and is synced
PASS: At least 5 Cloud/AWS job templates exist
PASS: At least 4 Network job templates exist
PASS: At least 6 Linux/RHEL job templates exist
PASS: Self-Service Portal is accessible
PASS: Portal OAuth application configured in AAP Gateway
PASS: clouduser1 can login to Portal (user exists in system)

================================================================================
Summary
================================================================================

SUCCESS 0 Errors

SHA256: a3d5f8e9c2b1a4f7e6d8c9b2a1f5e8d7c6b9a2f1e5d8c7b6a9f2e1d5c8b7a6f9
================================================================================
```

---

## ⚠️ Troubleshooting

### Error: Virtual environment not found
```
❌ Virtual environment not found
Run ./setup_ftl_environment.sh first
```
**Solution:** Run `./setup_ftl_environment.sh`

---

### Error: Missing required environment variables
```
❌ Missing required environment variables:
  - AAP_CONTROLLER_URL
  - AAP_ADMIN_PASSWORD
```
**Solution:** Export the required variables (see section 2 above)

---

### Error: awx command not found
```
awx: command not found
```
**Solution:**
1. Virtual environment not activated - run `source activate_ftl`
2. Or awxkit not installed - re-run `./setup_ftl_environment.sh`

---

### Error: Connection refused to AAP Controller
```
Failed to connect to AAP Controller: Connection refused
```
**Solution:**
1. Check `AAP_CONTROLLER_URL` is correct
2. Verify AAP deployment is complete and running
3. Check network connectivity from bastion to AAP route

---

### Error: Authentication failed
```
HTTP 401: Unauthorized
```
**Solution:**
1. Verify `AAP_ADMIN_PASSWORD` is correct
2. Check admin user exists in AAP
3. Try login via AAP UI to confirm credentials

---

## 📂 File Structure

```
/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/
├── setup_ftl_environment.sh    # Setup script (run once)
├── activate_ftl                # Virtual env activation helper
├── grade_lab.sh                # Grade all modules
├── solve_lab.sh                # Solve all modules
├── grade_module.sh             # Grade single module
├── solve_module.sh             # Solve single module
├── .venv/                      # Python virtual environment (created by setup)
├── grade_lab.yml               # Main grading playbook
├── solve_lab.yml               # Main solving playbook
├── grade_module_01.yml         # Module 1 grader
├── grade_module_02.yml         # Module 2 grader
├── grade_module_03.yml         # Module 3 grader
├── solve_module_01.yml         # Module 1 solver
├── solve_module_02.yml         # Module 2 solver
├── solve_module_03.yml         # Module 3 solver
├── lab.yml                     # Lab metadata
└── README.md                   # Lab documentation
```

---

## 🎯 Summary

**Setup (once):**
```bash
./setup_ftl_environment.sh
```

**Set environment (each session):**
```bash
export AAP_CONTROLLER_URL='https://...'
export AAP_ADMIN_PASSWORD='...'
export SELF_SERVICE_PORTAL_URL='https://...'
```

**Grade lab:**
```bash
./grade_lab.sh
```

**Solve lab:**
```bash
./solve_lab.sh
```

**Test specific module:**
```bash
./grade_module.sh 01
./solve_module.sh 02
```

That's it! 🚀
