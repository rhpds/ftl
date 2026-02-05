# Testing FTL with Real Deployment

**Deployment:** AAP Self-Service Portal Lab (3 users)
**GUID:** j7kml
**Cluster:** cluster-j7kml.dynamic.redhatworkshops.io
**Status:** ✅ Active deployment ready for FTL testing

---

## 📊 Deployment Details

### Users Deployed
- **user1** - Full AAP + Portal + Showroom
- **user2** - Full AAP + Portal + Showroom
- **user3** - Full AAP + Portal + Showroom

### Common Configuration
- **Password:** MjUxMzcw (shared by all users)
- **AAP Admin:** admin / MjUxMzcw
- **Cluster Domain:** apps.cluster-j7kml.dynamic.redhatworkshops.io

### Per-User URLs

#### User 1
- **AAP Controller:** https://user1-aap-user1-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io
- **Self-Service Portal:** https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster-j7kml.dynamic.redhatworkshops.io
- **Showroom:** https://showroom-showroom-j7kml-1-user1.apps.cluster-j7kml.dynamic.redhatworkshops.io/
- **AAP Namespace:** user1-aap

#### User 2
- **AAP Controller:** https://user2-aap-user2-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io
- **Self-Service Portal:** https://self-service-rhaap-portal-user2-aap-ssap.apps.cluster-j7kml.dynamic.redhatworkshops.io
- **Showroom:** https://showroom-showroom-j7kml-1-user2.apps.cluster-j7kml.dynamic.redhatworkshops.io/
- **AAP Namespace:** user2-aap

#### User 3
- **AAP Controller:** https://user3-aap-user3-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io
- **Self-Service Portal:** https://self-service-rhaap-portal-user3-aap-ssap.apps.cluster-j7kml.dynamic.redhatworkshops.io
- **Showroom:** https://showroom-showroom-j7kml-1-user3.apps.cluster-j7kml.dynamic.redhatworkshops.io/
- **AAP Namespace:** user3-aap

---

## 🚀 Quick Start Testing

### 1. Setup FTL Environment (Once)

```bash
cd /path/to/ftl/labs/aap-selfserv-intro-showroom
./setup_ftl_environment.sh
```

**What this does:**
- Creates Python virtual environment
- Installs Ansible, awxkit, collections
- Takes ~2-3 minutes

---

### 2. Test Single User (Quick Validation)

```bash
# Test user1 - all modules
./quick_test.sh 1

# Test user2 - module 01 only
./quick_test.sh 2 01

# Test user3 - module 02 only
./quick_test.sh 3 02
```

**Expected behavior:**
- Module 01 should PASS (pre-configured content exists)
- Module 02/03 depend on student actions (may fail if not completed)

---

### 3. Load Test All Users (Parallel)

```bash
# Test all 3 users simultaneously
./load_test_all_users.sh
```

**What this does:**
- Grades user1, user2, user3 in parallel
- Records results to `/tmp/ftl_load_test/`
- Shows summary table with pass/fail status
- Generates CSV with timing data

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

✅ Load test PASSED - All users passed!
```

---

## 🔧 Manual Testing (Advanced)

### Set Environment for Specific User

```bash
# Set environment for user1
source set_user_env.sh 1

# Now you can run any FTL script
./grade_lab.sh
./grade_module.sh 01
./solve_module.sh 02
```

### Run Ansible Playbooks Directly

```bash
# Activate venv
source activate_ftl

# Grade specific module for user1
export AAP_CONTROLLER_URL='https://user1-aap-user1-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io'
export AAP_ADMIN_PASSWORD='MjUxMzcw'
export SELF_SERVICE_PORTAL_URL='https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster-j7kml.dynamic.redhatworkshops.io'

ansible-playbook grade_module_01.yml \
    -e "aap_controller_url=${AAP_CONTROLLER_URL}" \
    -e "aap_admin_password=${AAP_ADMIN_PASSWORD}" \
    -e "self_service_portal_url=${SELF_SERVICE_PORTAL_URL}"

# Deactivate when done
deactivate
```

---

## 📋 Testing Checklist

### Module 1: Verify Pre-Configured Content
Expected to **PASS** for all users (content is pre-configured by AgnosticV).

**What it validates:**
- ✅ Demo users exist (clouduser1, networkuser1, rheluser1)
- ✅ Inventories exist (AWS, Azure, GCP, RHEL, Network)
- ✅ Project "SelfService Demo playbooks" is synced
- ✅ 15+ job templates exist
- ✅ Self-Service Portal is accessible
- ✅ OAuth configuration complete

**Test:**
```bash
./quick_test.sh 1 01  # Test user1 module 1
```

**Expected result:**
```
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
PASS: clouduser1 can login to Portal

SUCCESS 0 Errors
```

---

### Module 2: User Persona Testing
Expected to **FAIL** initially (student hasn't executed jobs yet).
Expected to **PASS** after running solver.

**What it validates:**
- Job executed as clouduser1
- Job executed as networkuser1
- Job executed as rheluser1

**Test solver then grader:**
```bash
# Solve module 2 (execute jobs as personas)
./solve_module.sh 2

# Grade module 2 (verify jobs executed)
./quick_test.sh 1 02
```

---

### Module 3: Surveys and Custom Templates
Expected to **FAIL** initially (student hasn't modified surveys).
Expected to **PASS** after running solver.

**What it validates:**
- Survey modifications in job templates
- Custom template import
- Custom template execution

**Test:**
```bash
# Solve module 3
./solve_module.sh 3

# Grade module 3
./quick_test.sh 1 03
```

---

## 📊 Load Test Results Analysis

After running `./load_test_all_users.sh`, check results:

```bash
# View results CSV
cat /tmp/ftl_load_test/results.csv

# View user1's full log
less /tmp/ftl_load_test/grade_user1.log

# View user1's grading report
cat /tmp/ftl_load_test/report_user1.txt

# Check all reports
ls -lh /tmp/ftl_load_test/
```

**Files generated:**
```
/tmp/ftl_load_test/
├── results.csv              # Summary: user,exit_code,duration
├── grade_user1.log          # Full Ansible output for user1
├── grade_user2.log          # Full Ansible output for user2
├── grade_user3.log          # Full Ansible output for user3
├── report_user1.txt         # Grading report for user1
├── report_user2.txt         # Grading report for user2
└── report_user3.txt         # Grading report for user3
```

---

## 🔍 Verifying Pre-Configured Content

### Check AAP Content via awx CLI

```bash
# Activate venv
source activate_ftl

# Set environment for user1
source set_user_env.sh 1

# List users (should include clouduser1, networkuser1, rheluser1)
awx --conf.host ${AAP_CONTROLLER_URL} \
    --conf.username ${AAP_ADMIN_USERNAME} \
    --conf.password ${AAP_ADMIN_PASSWORD} \
    --conf.insecure \
    users list

# List inventories (should include AWS, Azure, GCP, RHEL, Network)
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

# Check Portal access
curl -sk ${SELF_SERVICE_PORTAL_URL} | grep -c "Self-Service"
```

---

## ⚠️ Troubleshooting

### Issue: Module 01 fails with "User clouduser1 not found"

**Cause:** `aap_selfservice_custom` workload may not have run or failed.

**Check:**
```bash
# Login to AAP UI
open https://user1-aap-user1-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io

# Navigate to: Access Management → Users
# Verify: clouduser1, networkuser1, rheluser1 exist
```

**Fix:** Re-run `aap_selfservice_custom` workload if needed.

---

### Issue: Connection timeout to AAP Controller

**Cause:** AAP deployment may still be in progress.

**Check AAP status:**
```bash
# Check AAP pods
oc get pods -n user1-aap

# Expected: controller-web, controller-task, eda, postgres, redis all Running
```

**Wait:** AAP deployment can take 10-15 minutes per user.

---

### Issue: awx command not found

**Cause:** Virtual environment not activated.

**Fix:**
```bash
source activate_ftl
```

---

## 📈 Performance Benchmarks

Expected timing for this 3-user deployment:

| Operation | Expected Duration |
|-----------|------------------|
| Setup FTL environment | 2-3 minutes |
| Grade single user (all modules) | 30-60 seconds |
| Grade single user (module 01 only) | 10-20 seconds |
| Load test 3 users in parallel | 40-60 seconds |
| Solve module 02 (execute jobs) | 2-5 minutes |

**Factors affecting timing:**
- Network latency to cluster
- AAP job execution time
- Number of simultaneous operations
- Bastion resources

---

## ✅ Success Criteria

### Module 1 (Pre-Configured Content)
- ✅ All 13 checkpoints PASS
- ✅ All 3 users have identical results
- ✅ Grading completes in <20 seconds per user

### Module 2 (Job Execution)
- ✅ FAIL before solving (no jobs executed)
- ✅ PASS after solving (jobs executed successfully)
- ✅ Jobs visible in AAP UI under Jobs

### Module 3 (Surveys/Templates)
- ✅ FAIL before solving (no modifications)
- ✅ PASS after solving (surveys modified, templates imported)

### Load Test
- ✅ All 3 users graded in parallel
- ✅ Results consistent across all users
- ✅ Total time < 60 seconds
- ✅ No errors or timeouts

---

## 🎯 Next Steps

1. **Run initial test:**
   ```bash
   ./quick_test.sh 1 01
   ```

2. **If Module 01 passes:**
   - ✅ FTL is working correctly
   - ✅ Pre-configured content matches expectations
   - ✅ Ready for full load test

3. **Run load test:**
   ```bash
   ./load_test_all_users.sh
   ```

4. **If load test passes:**
   - ✅ FTL scales to multiple users
   - ✅ Ready for RH1 2026 event
   - ✅ Can be integrated into AgnosticV catalog

5. **Document findings:**
   - Record timing data
   - Note any failures
   - Update FTL documentation

---

**Ready to test!** 🚀

Start with: `./quick_test.sh 1 01`
