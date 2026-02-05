# FTL Quick Start - Deploy and Test

**Bastion:** ssh.ocpv08.rhdp.net (port 31422)
**User:** lab-user
**Password:** FZRNyvUPbkCZ

---

## 🚀 Option 1: Automated Deployment (Recommended)

**One command to deploy everything:**

```bash
cd /Users/psrivast/work/code/experiment/ftl/labs/aap-selfserv-intro-showroom
./deploy_to_bastion.sh
```

**What it does:**
1. ✅ Tests bastion connection
2. ✅ Copies all FTL files to bastion
3. ✅ Installs to `/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/`
4. ✅ Creates virtual environment
5. ✅ Installs all dependencies (Ansible, awxkit, collections)
6. ✅ Runs test (user1, module 01)

**Duration:** ~3-5 minutes

**Expected output:**
```
=========================================
✅ Deployment and Test SUCCESSFUL
=========================================

🎉 FTL is deployed and working!

Next steps:
  1. SSH to bastion:
     ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net

  2. Run load test:
     cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
     ./load_test_all_users.sh

  3. View results:
     cat /tmp/ftl_load_test/results.csv
```

---

## 🔧 Option 2: Manual Deployment

### Step 1: Copy Files to Bastion

```bash
cd /Users/psrivast/work/code/experiment/ftl/labs/aap-selfserv-intro-showroom

# Use rsync (faster)
rsync -avz -e "ssh -p 31422" \
    --exclude='.venv' \
    . lab-user@ssh.ocpv08.rhdp.net:/tmp/ftl-aap-selfserv/

# Or use scp
scp -P 31422 -r . lab-user@ssh.ocpv08.rhdp.net:/tmp/ftl-aap-selfserv/
```

Password: `FZRNyvUPbkCZ`

---

### Step 2: SSH to Bastion

```bash
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net
# Password: FZRNyvUPbkCZ
```

---

### Step 3: Install FTL on Bastion

```bash
# Create directory
sudo mkdir -p /opt/rhdp/ftl/labs/

# Move files
sudo mv /tmp/ftl-aap-selfserv /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Make executable
sudo chmod +x /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/*.sh

# Set ownership
sudo chown -R lab-user:users /opt/rhdp/ftl/

# Navigate to lab
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Run setup
./setup_ftl_environment.sh
```

**Duration:** 2-3 minutes

---

### Step 4: Test

```bash
# Quick test user1
./quick_test.sh 1 01
```

**Expected:** ✅ PASSED (13 checkpoints)

---

## 🧪 Run Tests

### Test Single User

```bash
# On bastion
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Test user1 - all modules
./quick_test.sh 1

# Test user1 - module 01 only
./quick_test.sh 1 01

# Test user2 - module 01
./quick_test.sh 2 01

# Test user3 - module 01
./quick_test.sh 3 01
```

---

### Load Test All Users

```bash
# Test all 3 users in parallel
./load_test_all_users.sh
```

**Expected output:**
```
=========================================
Load Test Complete
=========================================
Total Duration: 45 seconds

Results Summary:
  Total Users: 3
  Passed: 3
  Failed: 0

Detailed Results:
----------------------------------------
User       Status       Duration
----------------------------------------
user1      PASSED       42s
user2      PASSED       43s
user3      PASSED       41s
----------------------------------------

Files Generated:
  Results CSV: /tmp/ftl_load_test/results.csv
```

---

## 📊 View Results

```bash
# View summary
cat /tmp/ftl_load_test/results.csv

# View user1's full log
less /tmp/ftl_load_test/grade_user1.log

# View user1's report
cat /tmp/ftl_load_test/report_user1.txt

# View all files
ls -lh /tmp/ftl_load_test/
```

---

## 🔍 Manual Verification

### Check AAP Content

```bash
# On bastion
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Set environment for user1
source set_user_env.sh 1

# Activate venv
source activate_ftl

# List users (should include clouduser1, networkuser1, rheluser1)
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username ${AAP_ADMIN_USERNAME} \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    users list

# List inventories
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username ${AAP_ADMIN_USERNAME} \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    inventories list

# List job templates
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username ${AAP_ADMIN_USERNAME} \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    job_templates list | grep -E "Cloud/|Network/|Linux/"

# Test Portal access
curl -sk ${SELF_SERVICE_PORTAL_URL} | grep -c "Self-Service"
```

---

## ⚡ Quick Reference

### Deployment Info
```
Bastion:  ssh.ocpv08.rhdp.net:31422
User:     lab-user
Password: FZRNyvUPbkCZ
FTL Path: /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/
```

### User URLs
```
User1 AAP:    https://user1-aap-user1-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io
User1 Portal: https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster-j7kml.dynamic.redhatworkshops.io
Password:     MjUxMzcw
```

### Quick Commands
```bash
# Connect to bastion
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net

# Navigate to FTL
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Quick test
./quick_test.sh 1 01

# Load test
./load_test_all_users.sh

# View results
cat /tmp/ftl_load_test/results.csv
```

---

## ⚠️ Troubleshooting

### Can't connect to bastion
```bash
# Test connection
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net echo "Connected"
```

### Password not working
```
Password: FZRNyvUPbkCZ
(Copy-paste exactly as shown)
```

### Setup script fails
```bash
# Check Python version
python3 --version
# Should be 3.9+

# Install manually if needed
python3 -m venv .venv
source .venv/bin/activate
pip install ansible>=2.14 awxkit
ansible-galaxy collection install ansible.controller
```

### Tests fail
```bash
# Check AAP is accessible
curl -sk https://user1-aap-user1-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io

# If 404/timeout, AAP may still be deploying (wait 10-15 min)
```

---

## ✅ Success Checklist

- [ ] Connected to bastion successfully
- [ ] FTL files copied to `/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/`
- [ ] Virtual environment created (`.venv/` directory exists)
- [ ] Dependencies installed (awx command works)
- [ ] `./quick_test.sh 1 01` passes
- [ ] `./load_test_all_users.sh` passes (all 3 users)
- [ ] Results saved to `/tmp/ftl_load_test/results.csv`

---

**Ready to deploy!** 🚀

Choose Option 1 (automated) or Option 2 (manual) and get started!
