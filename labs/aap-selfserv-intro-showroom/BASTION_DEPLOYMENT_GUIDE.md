# FTL Bastion Deployment Guide

**Bastion Access:** ssh.ocpv08.rhdp.net (port 31422)
**Username:** lab-user
**Password:** FZRNyvUPbkCZ
**Deployment:** j7kml (3 users)

---

## 🚀 Quick Deployment Steps

### Step 1: Connect to Bastion

```bash
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net
# Password: FZRNyvUPbkCZ
```

---

### Step 2: Copy FTL Scripts to Bastion

**From your local machine:**

```bash
# Navigate to FTL lab directory locally
cd /Users/psrivast/work/code/experiment/ftl/labs/aap-selfserv-intro-showroom

# Copy entire lab to bastion
scp -P 31422 -r . lab-user@ssh.ocpv08.rhdp.net:/tmp/ftl-aap-selfserv/

# Or use rsync for faster transfer
rsync -avz -e "ssh -p 31422" \
    --exclude='.venv' \
    --exclude='*.pyc' \
    --exclude='.git' \
    . lab-user@ssh.ocpv08.rhdp.net:/tmp/ftl-aap-selfserv/
```

---

### Step 3: Setup FTL on Bastion

**On bastion:**

```bash
# Create FTL directory structure
mkdir -p /opt/rhdp/ftl/labs/

# Move from temp to final location
sudo mv /tmp/ftl-aap-selfserv /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Make scripts executable
sudo chmod +x /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/*.sh

# Change ownership to lab-user
sudo chown -R lab-user:lab-user /opt/rhdp/ftl/

# Navigate to lab directory
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Run setup (creates venv, installs dependencies)
./setup_ftl_environment.sh
```

**Expected duration:** 2-3 minutes

---

### Step 4: Test Single User

```bash
# Still on bastion
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Test user1's Module 01 (validates pre-configured content)
./quick_test.sh 1 01
```

**Expected result:**
```
=========================================
✅ Grading Complete - PASSED
=========================================
Duration: 15 seconds

PASS: Demo user 'clouduser1' exists in AAP
PASS: Demo user 'networkuser1' exists in AAP
PASS: Demo user 'rheluser1' exists in AAP
...
SUCCESS 0 Errors
```

---

### Step 5: Load Test All Users

```bash
# Test all 3 users in parallel
./load_test_all_users.sh
```

**Expected result:**
```
=========================================
Load Test Complete
=========================================
Total Duration: 45 seconds

Results Summary:
  Total Users: 3
  Passed: 3
  Failed: 0
```

---

## 📝 Alternative: Manual Deployment

If you prefer manual steps:

### On Bastion:

```bash
# Connect
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net

# Create directory
mkdir -p ~/ftl-test
cd ~/ftl-test

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install ansible>=2.14 awxkit

# Install collections
ansible-galaxy collection install ansible.controller

# Set environment for user1
export AAP_CONTROLLER_URL='https://user1-aap-user1-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io'
export AAP_ADMIN_USERNAME='admin'
export AAP_ADMIN_PASSWORD='MjUxMzcw'
export SELF_SERVICE_PORTAL_URL='https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster-j7kml.dynamic.redhatworkshops.io'

# Test awx CLI
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username ${AAP_ADMIN_USERNAME} \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    users list

# Expected: List of users including clouduser1, networkuser1, rheluser1
```

---

## 🔍 Quick Verification Commands

Once on bastion, verify deployment:

```bash
# Set environment
source /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/set_user_env.sh 1

# Activate FTL venv
source /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/activate_ftl

# Check AAP users
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username ${AAP_ADMIN_USERNAME} \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    users list | grep -E "clouduser1|networkuser1|rheluser1"

# Check inventories
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username ${AAP_ADMIN_USERNAME} \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    inventories list

# Check job templates
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username ${AAP_ADMIN_USERNAME} \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    job_templates list | grep -E "Cloud/|Network/|Linux/"

# Check Portal access
curl -sk ${SELF_SERVICE_PORTAL_URL} | grep -c "Self-Service"
# Expected: 1
```

---

## 📦 Files to Copy to Bastion

**Essential files:**
```
aap-selfserv-intro-showroom/
├── setup_ftl_environment.sh      # Setup script
├── quick_test.sh                 # Quick test
├── load_test_all_users.sh        # Load test
├── set_user_env.sh               # Set environment
├── grade_lab.sh                  # Grade all modules
├── solve_lab.sh                  # Solve all modules
├── grade_module.sh               # Grade single module
├── solve_module.sh               # Solve single module
├── grade_lab.yml                 # Grading playbook
├── solve_lab.yml                 # Solving playbook
├── grade_module_01.yml           # Module graders
├── grade_module_02.yml
├── grade_module_03.yml
├── solve_module_01.yml           # Module solvers
├── solve_module_02.yml
├── solve_module_03.yml
├── lab.yml                       # Lab metadata
├── BASTION_USAGE.md              # Usage guide
└── TESTING_WITH_REAL_DEPLOYMENT.md
```

**Optional documentation:**
```
├── README.md
├── FTL_LAB_UPDATE_SUMMARY.md
├── WRAPPER_SCRIPTS_SUMMARY.md
├── FTL_AGNOSTICV_INTEGRATION_PLAN.md
├── REAL_LAB_ANALYSIS.md
├── SHOWROOM_VS_AGNOSTICV.md
└── AGNOSTICV_INTEGRATION.md
```

---

## 🎯 Expected Results

### Module 01: Pre-Configured Content
**Should PASS for all users**

Validates:
- ✅ clouduser1, networkuser1, rheluser1 exist
- ✅ AWS, Azure, GCP, RHEL, Network inventories exist
- ✅ Project "SelfService Demo playbooks" is synced
- ✅ 15+ job templates exist (Cloud/AWS, Network, Linux/RHEL)
- ✅ Self-Service Portal is accessible
- ✅ OAuth configuration complete

### Module 02: Job Execution
**Will FAIL initially** (student hasn't executed jobs)
**Will PASS after running solver**

### Module 03: Surveys/Templates
**Will FAIL initially** (student hasn't modified surveys)
**Will PASS after running solver**

---

## ⚠️ Troubleshooting

### Issue: Cannot connect to bastion

```bash
# Verify SSH access
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net echo "Connected!"
```

### Issue: Cannot reach AAP Controller

```bash
# Test from bastion
curl -sk https://user1-aap-user1-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io
```

If this fails, AAP may still be deploying. Wait 10-15 minutes.

### Issue: awx command not found

```bash
# Activate venv first
source /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/activate_ftl

# Verify awx installed
which awx
awx --version
```

### Issue: Python venv creation fails

```bash
# Check Python version
python3 --version
# Expected: Python 3.9 or higher

# Install venv if needed
sudo dnf install python3-pip
```

---

## 📊 Performance Benchmarks

**Expected timings on bastion:**

| Operation | Expected Duration |
|-----------|------------------|
| Copy files to bastion (scp) | 30-60 seconds |
| Setup FTL environment | 2-3 minutes |
| Grade single user (module 01) | 15-20 seconds |
| Grade all users (module 01) | 40-60 seconds |
| Solve module 02 (execute jobs) | 2-5 minutes |

---

## 🎯 Quick Commands Reference

```bash
# Connect to bastion
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net

# Navigate to FTL
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Quick test user1
./quick_test.sh 1 01

# Load test all users
./load_test_all_users.sh

# View results
cat /tmp/ftl_load_test/results.csv
less /tmp/ftl_load_test/grade_user1.log

# Set env manually
source set_user_env.sh 1

# Run grader manually
source activate_ftl
ansible-playbook grade_module_01.yml \
    -e "aap_controller_url=${AAP_CONTROLLER_URL}" \
    -e "aap_admin_password=${AAP_ADMIN_PASSWORD}" \
    -e "self_service_portal_url=${SELF_SERVICE_PORTAL_URL}"
```

---

## ✅ Success Criteria

- ✅ FTL scripts deployed to `/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/`
- ✅ Virtual environment created at `.venv/`
- ✅ `./quick_test.sh 1 01` passes (Module 01)
- ✅ `./load_test_all_users.sh` passes (all 3 users)
- ✅ Results saved to `/tmp/ftl_load_test/`
- ✅ No errors or timeouts

---

**Ready to deploy!** Start with Step 1: Connect to bastion 🚀
