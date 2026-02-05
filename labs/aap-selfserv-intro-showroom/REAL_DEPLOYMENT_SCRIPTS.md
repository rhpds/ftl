# FTL Scripts for Real Deployment Testing

**Created:** 2026-02-04
**Deployment:** j7kml (3 users)
**Status:** ✅ Ready for testing

---

## 📦 New Scripts Created (3)

### 1. **set_user_env.sh** - Set Environment for Specific User

**Purpose:** Quickly set environment variables for any user

**Usage:**
```bash
source set_user_env.sh 1  # Set env for user1
source set_user_env.sh 2  # Set env for user2
source set_user_env.sh 3  # Set env for user3
```

**What it does:**
- Sets `AAP_CONTROLLER_URL` for selected user
- Sets `AAP_ADMIN_USERNAME` and `AAP_ADMIN_PASSWORD`
- Sets `SELF_SERVICE_PORTAL_URL`
- Sets OpenShift variables (bonus)
- Displays all values

**Example:**
```bash
$ source set_user_env.sh 1
=========================================
FTL Environment Set for User 1
=========================================

AAP Controller: https://user1-aap-user1-aap.apps.cluster-j7kml.dynamic.redhatworkshops.io
AAP Admin: admin / MjUxMzcw
Portal: https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster-j7kml.dynamic.redhatworkshops.io
OpenShift User: user1
Showroom: https://showroom-showroom-j7kml-1-user1.apps.cluster-j7kml.dynamic.redhatworkshops.io/

Ready to run FTL graders/solvers!
```

---

### 2. **quick_test.sh** - Test Single User's Lab

**Purpose:** Quick validation of a single user's lab

**Usage:**
```bash
./quick_test.sh 1       # Grade all modules for user1
./quick_test.sh 2 01    # Grade module 01 for user2
./quick_test.sh 3 02    # Grade module 02 for user3
```

**What it does:**
- Sets environment for specified user
- Activates virtual environment
- Runs grading playbook
- Displays grading report
- Shows timing

**Example:**
```bash
$ ./quick_test.sh 1 01
=========================================
FTL Quick Test
=========================================
User: user1
Module: 01

Environment:
  AAP Controller: https://user1-aap-user1-aap.apps...
  Admin: admin
  Portal: https://self-service-rhaap-portal...

Activating FTL environment...

=========================================
Running FTL Grader
=========================================

[Ansible playbook output...]

=========================================
✅ Grading Complete - PASSED
=========================================
Duration: 15 seconds

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

### 3. **load_test_all_users.sh** - Parallel Load Test

**Purpose:** Test all 3 users simultaneously (load testing)

**Usage:**
```bash
./load_test_all_users.sh
```

**What it does:**
- Grades user1, user2, user3 in parallel
- Records timing for each user
- Generates results CSV
- Saves logs and reports
- Shows summary table

**Example output:**
```bash
$ ./load_test_all_users.sh
=========================================
FTL Load Test - All Users
=========================================
GUID: j7kml
Users: 3
Results: /tmp/ftl_load_test

=========================================
Running Graders in Parallel
=========================================

Starting user1...
Starting user2...
Starting user3...
✅ user1 - PASSED (42s)
✅ user2 - PASSED (43s)
✅ user3 - PASSED (41s)

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
  User logs: /tmp/ftl_load_test/grade_user*.log
  Reports: /tmp/ftl_load_test/report_user*.txt

✅ Load test PASSED - All users passed!
```

---

## 🎯 Quick Start Guide

### Step 1: Setup (Once)
```bash
cd /path/to/ftl/labs/aap-selfserv-intro-showroom
./setup_ftl_environment.sh
```

### Step 2: Test Single User
```bash
# Test user1's Module 01 (should pass - pre-configured content)
./quick_test.sh 1 01
```

### Step 3: Load Test All Users
```bash
# Test all 3 users in parallel
./load_test_all_users.sh
```

---

## 📊 Deployment Configuration

**Hard-coded in scripts** (from real deployment data):

```bash
GUID="j7kml"
CLUSTER_DOMAIN="apps.cluster-j7kml.dynamic.redhatworkshops.io"
COMMON_PASSWORD="MjUxMzcw"
NUM_USERS=3
```

**Per-user URLs (auto-constructed):**
- AAP: `https://user{N}-aap-user{N}-aap.${CLUSTER_DOMAIN}`
- Portal: `https://self-service-rhaap-portal-user{N}-aap-ssap.${CLUSTER_DOMAIN}`
- Showroom: `https://showroom-showroom-${GUID}-1-user{N}.${CLUSTER_DOMAIN}/`

---

## 🔧 Customization

### For Different Deployment

If you have a different GUID or cluster, edit the scripts:

**Files to update:**
- `set_user_env.sh` - lines 8-9
- `load_test_all_users.sh` - lines 17-19
- `quick_test.sh` - lines 23-25

**Change:**
```bash
GUID="j7kml"  # ← Change to your GUID
CLUSTER_DOMAIN="apps.cluster-${GUID}.dynamic.redhatworkshops.io"
COMMON_PASSWORD="MjUxMzcw"  # ← Change to your password
```

### For Different Number of Users

**Edit:** `load_test_all_users.sh` line 20
```bash
NUM_USERS=3  # ← Change to your user count
```

---

## 📁 Script Locations

All scripts are in:
```
/Users/psrivast/work/code/experiment/ftl/labs/aap-selfserv-intro-showroom/
```

**Full list:**
```
├── setup_ftl_environment.sh      # Setup venv (run once)
├── grade_lab.sh                  # Grade all modules (single user)
├── solve_lab.sh                  # Solve all modules (single user)
├── grade_module.sh               # Grade specific module (single user)
├── solve_module.sh               # Solve specific module (single user)
├── set_user_env.sh               # Set env for user (NEW)
├── quick_test.sh                 # Quick test single user (NEW)
├── load_test_all_users.sh        # Load test all users (NEW)
└── activate_ftl                  # Manual venv activation
```

---

## 🧪 Testing Scenarios

### Scenario 1: Validate Pre-Configured Content (Module 01)
```bash
# Should PASS for all users
./quick_test.sh 1 01
./quick_test.sh 2 01
./quick_test.sh 3 01
```

**Expected:** All 13 checkpoints pass (users, inventories, job templates exist)

---

### Scenario 2: Test Job Execution (Module 02)
```bash
# Solve for user1 (execute jobs)
source set_user_env.sh 1
./solve_module.sh 02

# Grade user1 (verify jobs executed)
./quick_test.sh 1 02
```

**Expected:** FAIL before solve, PASS after solve

---

### Scenario 3: Load Test Before Event
```bash
# Test all 3 users in parallel
./load_test_all_users.sh

# Check results
cat /tmp/ftl_load_test/results.csv
ls -lh /tmp/ftl_load_test/
```

**Expected:**
- All users pass Module 01 (pre-configured content)
- Total duration: 40-60 seconds
- Results CSV generated

---

## 📊 Results Files

After load test:
```
/tmp/ftl_load_test/
├── results.csv              # user,exit_code,duration
├── grade_user1.log          # Full Ansible output
├── grade_user2.log
├── grade_user3.log
├── report_user1.txt         # Grading report
├── report_user2.txt
└── report_user3.txt
```

**View results:**
```bash
# Summary
cat /tmp/ftl_load_test/results.csv

# User1's full log
less /tmp/ftl_load_test/grade_user1.log

# User1's report
cat /tmp/ftl_load_test/report_user1.txt
```

---

## ✅ Success Criteria

### Single User Test
- ✅ Module 01 passes (13 checkpoints)
- ✅ Completes in <20 seconds
- ✅ Grading report generated

### Load Test
- ✅ All 3 users graded in parallel
- ✅ All users pass Module 01
- ✅ Total duration <60 seconds
- ✅ No errors or timeouts
- ✅ Results CSV generated

---

## 🚀 Next Steps

1. **Run setup:**
   ```bash
   ./setup_ftl_environment.sh
   ```

2. **Quick test:**
   ```bash
   ./quick_test.sh 1 01
   ```

3. **If passes, run load test:**
   ```bash
   ./load_test_all_users.sh
   ```

4. **Document results** and prepare for RH1 2026 event!

---

**Status:** ✅ Ready for testing with real deployment!
