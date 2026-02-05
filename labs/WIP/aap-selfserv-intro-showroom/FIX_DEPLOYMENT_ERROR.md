# FTL Deployment Error - FIXED

## ❌ Error You Encountered

```
[ERROR]: the role 'rhdp.ftl.grader_check_command_output' was not found
```

**Cause:** The FTL collection roles weren't on the bastion - only the lab files were copied.

---

## ✅ Fix Applied

**What was fixed:**

1. **Created new deployment script:** `deploy_ftl_collection.sh`
   - Copies **both** the FTL roles AND the lab files
   - Sets up proper directory structure on bastion

2. **Added ansible.cfg:** Tells Ansible where to find FTL roles
   - Roles path includes: `/opt/rhdp/ftl/roles`

3. **Updated all playbooks:** Removed `rhdp.ftl.` namespace prefix
   - Before: `rhdp.ftl.grader_check_command_output`
   - After: `grader_check_command_output`

**Files updated:**
- ✅ grade_module_01.yml
- ✅ grade_module_02.yml
- ✅ grade_module_03.yml
- ✅ solve_module_01_ui.yml
- ✅ solve_module_02.yml
- ✅ solve_module_03.yml
- ✅ create_team_ui.yml
- ✅ ansible.cfg (new)
- ✅ deploy_ftl_collection.sh (new)

---

## 🚀 Deploy Again (Fixed Version)

### Step 1: Navigate to Lab Directory

```bash
cd /Users/psrivast/work/code/experiment/ftl/labs/aap-selfserv-intro-showroom
```

---

### Step 2: Copy Files to Bastion

```bash
./copy_to_bastion.sh
```

**Password:** `FZRNyvUPbkCZ` (you'll enter this twice - once for roles, once for lab files)

**This script will:**
1. ✅ Copy FTL collection roles to bastion `/tmp/ftl-roles/`
2. ✅ Copy lab files to bastion `/tmp/ftl-lab/`

---

### Step 3: SSH to Bastion

```bash
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net
```

**Password:** `FZRNyvUPbkCZ`

---

### Step 4: Run Setup on Bastion

```bash
# Run as root to install to /opt/rhdp/ftl
sudo bash /tmp/ftl-lab/setup_on_bastion.sh
```

**This will:**
1. ✅ Move FTL roles to `/opt/rhdp/ftl/roles/`
2. ✅ Move lab files to `/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/`
3. ✅ Set permissions

---

### Step 5: Install Dependencies

```bash
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
./setup_ftl_environment.sh
```

**This will:**
1. ✅ Create Python virtual environment
2. ✅ Install Ansible and awxkit

---

### Step 6: Run Test

```bash
./quick_test.sh 1 01
```

**Expected duration:** 1-2 minutes

---

## 📊 Expected Result

After running `./deploy_ftl_collection.sh`:

```
=========================================
✅ Deployment and Test SUCCESSFUL
=========================================

🎉 FTL is fully deployed and working!

FTL Collection installed at:
  Roles: /opt/rhdp/ftl/roles/
  Lab:   /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/

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

## 📂 What Gets Deployed to Bastion

```
/opt/rhdp/ftl/
├── roles/                              ← FTL collection roles (NEW!)
│   ├── grader_check_command_output/
│   ├── grader_check_file_exists/
│   ├── grader_check_service_running/
│   ├── grader_check_package_installed/
│   ├── grader_check_user_exists/
│   ├── grader_check_container_running/
│   ├── solver_browser_action/
│   ├── ftl_run_init/
│   ├── ftl_run_log_grade_to_log/
│   ├── ftl_run_grade_report_generation/
│   └── ftl_run_finish/
│
└── labs/
    └── aap-selfserv-intro-showroom/    ← Lab files
        ├── ansible.cfg                 ← Tells Ansible where roles are
        ├── grade_module_01.yml
        ├── grade_module_02.yml
        ├── grade_module_03.yml
        ├── solve_module_01.yml
        ├── solve_module_02.yml
        ├── solve_module_03.yml
        ├── quick_test.sh
        ├── load_test_all_users.sh
        └── ... (all other files)
```

---

## 🔍 What Changed in Playbooks

**Before (BROKEN):**
```yaml
- name: Verify user exists
  include_role:
    name: rhdp.ftl.grader_check_command_output  # ❌ Collection namespace
```

**After (FIXED):**
```yaml
- name: Verify user exists
  include_role:
    name: grader_check_command_output           # ✅ Direct role name
```

**Why this works:**
- `ansible.cfg` sets `roles_path = /opt/rhdp/ftl/roles:...`
- Ansible can now find `grader_check_command_output` in `/opt/rhdp/ftl/roles/`

---

## ⚠️ If You Already Deployed (Clean Up First)

If you already ran the broken deployment, clean up first:

```bash
# SSH to bastion
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net

# Remove old installation
sudo rm -rf /opt/rhdp/ftl

# Logout
exit

# Now run the fixed deployment from your local machine
cd /Users/psrivast/work/code/experiment/ftl/labs/aap-selfserv-intro-showroom
./deploy_ftl_collection.sh
```

---

## ✅ Verification

After deployment succeeds, you can verify on bastion:

```bash
# SSH to bastion
ssh -p 31422 lab-user@ssh.ocpv08.rhdp.net

# Check FTL collection structure
ls -la /opt/rhdp/ftl/roles/
# Should show: grader_check_command_output, grader_check_file_exists, etc.

# Check lab
ls -la /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/
# Should show: ansible.cfg, grade_module_*.yml, etc.

# Run test
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
./quick_test.sh 1 01
# Should PASS with 13 checkpoints
```

---

## 🎯 Summary

**Problem:** Missing FTL collection roles on bastion

**Solution:**
1. ✅ New deployment script that copies roles + lab
2. ✅ ansible.cfg to find roles
3. ✅ Updated playbooks to use direct role names

**Action:** Run `./deploy_ftl_collection.sh` from the lab directory

---

**Ready to deploy!** 🚀

```bash
cd /Users/psrivast/work/code/experiment/ftl/labs/aap-selfserv-intro-showroom
./deploy_ftl_collection.sh
```
