# FTL Wrapper Scripts Summary

**Created:** 2026-02-04
**Purpose:** Simplify FTL usage on bastion by handling virtual environment setup and activation

---

## 📦 What Was Created

### 1. **setup_ftl_environment.sh** (155 lines)
One-time setup script that creates a Python virtual environment and installs all dependencies.

**Features:**
- ✅ Installs system dependencies (jq, curl, python3)
- ✅ Creates Python virtual environment at `.venv/`
- ✅ Installs Ansible (>=2.14) and awxkit
- ✅ Installs ansible.controller collection
- ✅ Installs rhdp.ftl collection (if available)
- ✅ Creates `activate_ftl` helper script for manual activation
- ✅ Displays setup summary with installed packages

**Usage:**
```bash
./setup_ftl_environment.sh
```

**Output:**
- Virtual environment at `.venv/`
- Activation helper at `activate_ftl`
- Clear instructions for next steps

---

### 2. **grade_lab.sh** (88 lines)
Wrapper script for grading all modules.

**Features:**
- ✅ Checks virtual environment exists
- ✅ Validates required environment variables (AAP_CONTROLLER_URL, AAP_ADMIN_PASSWORD, SELF_SERVICE_PORTAL_URL)
- ✅ Activates virtual environment automatically
- ✅ Runs `ansible-playbook grade_lab.yml`
- ✅ Displays grading report from `/tmp/grading_dir/grading_report.txt`
- ✅ Shows pass/fail status with colored output
- ✅ Tracks execution duration
- ✅ Deactivates virtual environment on exit

**Usage:**
```bash
export AAP_CONTROLLER_URL='https://...'
export AAP_ADMIN_PASSWORD='...'
export SELF_SERVICE_PORTAL_URL='https://...'
./grade_lab.sh
```

---

### 3. **solve_lab.sh** (81 lines)
Wrapper script for solving all modules.

**Features:**
- ✅ Same validation and environment handling as grade_lab.sh
- ✅ Runs `ansible-playbook solve_lab.yml`
- ✅ Shows solve status with colored output
- ✅ Tracks execution duration

**Usage:**
```bash
export AAP_CONTROLLER_URL='https://...'
export AAP_ADMIN_PASSWORD='...'
export SELF_SERVICE_PORTAL_URL='https://...'
./solve_lab.sh
```

---

### 4. **grade_module.sh** (113 lines)
Wrapper script for grading individual modules.

**Features:**
- ✅ Accepts module number as parameter (01, 02, 03)
- ✅ Validates module exists before running
- ✅ Same environment validation as grade_lab.sh
- ✅ Supports passing extra arguments to ansible-playbook
- ✅ Shows available modules if run without arguments

**Usage:**
```bash
./grade_module.sh 01        # Grade Module 1
./grade_module.sh 02 -v     # Grade Module 2 with verbose output
./grade_module.sh 03 -e "debug_mode=true"  # Grade Module 3 with extra vars
```

---

### 5. **solve_module.sh** (113 lines)
Wrapper script for solving individual modules.

**Features:**
- ✅ Same as grade_module.sh but for solving
- ✅ Accepts module number as parameter
- ✅ Validates module solver exists
- ✅ Supports extra arguments

**Usage:**
```bash
./solve_module.sh 01        # Solve Module 1 (validate environment)
./solve_module.sh 02        # Solve Module 2 (execute jobs)
./solve_module.sh 03        # Solve Module 3 (modify surveys)
```

---

### 6. **BASTION_USAGE.md** (500+ lines)
Comprehensive usage guide for the wrapper scripts.

**Sections:**
- 🚀 Quick Start
- 📁 Wrapper Scripts Overview
- 🔧 Manual Virtual Environment Activation
- 🧪 Testing FTL Before Event
- 🚀 Load Testing Multiple Users
- 📊 Grading Report Format
- ⚠️ Troubleshooting
- 📂 File Structure
- 🎯 Summary

---

## 🎯 Why These Scripts Were Created

### Problem Before
Using FTL required manual steps:
```bash
# Student had to remember:
1. Create virtual environment
2. Install dependencies
3. Activate venv every time
4. Remember ansible-playbook syntax
5. Pass all required variables
6. Remember to deactivate venv
```

### Solution After
Simple wrapper scripts:
```bash
# One-time setup
./setup_ftl_environment.sh

# Set environment variables (once per session)
export AAP_CONTROLLER_URL='...'
export AAP_ADMIN_PASSWORD='...'
export SELF_SERVICE_PORTAL_URL='...'

# Grade or solve
./grade_lab.sh
./solve_lab.sh
./grade_module.sh 01
```

---

## 🔑 Key Benefits

1. **No manual venv management**
   - Scripts activate/deactivate automatically
   - No need to remember to source activate

2. **Environment validation**
   - Checks required variables before running
   - Clear error messages if something is missing

3. **Consistent interface**
   - All scripts follow same pattern
   - Same environment variable names
   - Same error handling

4. **Load testing ready**
   - Can be called from parent scripts
   - Exit codes indicate success/failure
   - Duration tracking for performance analysis

5. **User-friendly output**
   - Colored output (green for success, red for errors)
   - Clear section headers
   - Progress indicators

6. **Idempotent setup**
   - `setup_ftl_environment.sh` can be run multiple times
   - Removes old venv if exists
   - Always starts fresh

---

## 📊 Script Comparison

| Script | Lines | Purpose | Output |
|--------|-------|---------|--------|
| setup_ftl_environment.sh | 155 | One-time setup | Creates venv, installs deps |
| grade_lab.sh | 88 | Grade all modules | Grading report |
| solve_lab.sh | 81 | Solve all modules | Solve status |
| grade_module.sh | 113 | Grade single module | Module grading result |
| solve_module.sh | 113 | Solve single module | Module solve result |
| **Total** | **550** | **Complete FTL workflow** | **Ready for deployment** |

---

## 🚀 Deployment to Bastion

These scripts will be deployed to bastion via AgnosticV `post_software` phase:

```yaml
# In AgnosticV catalog common.yaml
post_software:
  - name: Deploy FTL wrapper scripts
    ansible.builtin.copy:
      src: "{{ playbook_dir }}/ftl-labs/aap-selfserv-intro-showroom/"
      dest: "/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/"
      mode: preserve
    delegate_to: bastion

  - name: Ensure scripts are executable
    ansible.builtin.file:
      path: "/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/{{ item }}"
      mode: '0755'
    loop:
      - setup_ftl_environment.sh
      - grade_lab.sh
      - solve_lab.sh
      - grade_module.sh
      - solve_module.sh
    delegate_to: bastion
```

---

## 🧪 Testing Workflow

### For RHDP Team (Before Event)

1. **Deploy lab via AgnosticV:**
   ```bash
   agnosticv deploy aap-multiinstance-workshop --num-users 3
   ```

2. **SSH to bastion:**
   ```bash
   ssh lab-user@bastion.abc123.example.com
   ```

3. **Setup FTL:**
   ```bash
   cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
   ./setup_ftl_environment.sh
   ```

4. **Set environment for user1:**
   ```bash
   export AAP_CONTROLLER_URL='https://user1-aap-user1-aap.apps...'
   export AAP_ADMIN_PASSWORD='...'
   export SELF_SERVICE_PORTAL_URL='https://...'
   ```

5. **Test grading:**
   ```bash
   ./grade_module.sh 01  # Should pass (pre-configured content exists)
   ```

6. **Test solving:**
   ```bash
   ./solve_module.sh 02  # Execute jobs as personas
   ./grade_module.sh 02  # Verify jobs executed
   ```

7. **Load test all users:**
   ```bash
   # Create load test script (see BASTION_USAGE.md)
   ./load_test.sh
   ```

---

## 📝 Documentation Files

| File | Purpose |
|------|---------|
| BASTION_USAGE.md | Complete usage guide for wrapper scripts |
| WRAPPER_SCRIPTS_SUMMARY.md | This file - summary of what was created |
| FTL_LAB_UPDATE_SUMMARY.md | Summary of Module 1 updates |
| SHOWROOM_VS_AGNOSTICV.md | Analysis of Showroom vs deployment mismatch |
| REAL_LAB_ANALYSIS.md | What students actually do in the lab |
| AGNOSTICV_INTEGRATION.md | Integration with AgnosticV userdata |

---

## ✅ Completion Status

- [x] `setup_ftl_environment.sh` - One-time setup
- [x] `grade_lab.sh` - Grade all modules
- [x] `solve_lab.sh` - Solve all modules
- [x] `grade_module.sh` - Grade single module
- [x] `solve_module.sh` - Solve single module
- [x] `activate_ftl` - Manual activation helper (created by setup script)
- [x] `BASTION_USAGE.md` - Complete usage documentation
- [x] All scripts made executable
- [x] Ready for deployment to bastion via AgnosticV

---

## 🎯 Next Steps

1. **Test scripts locally** (if possible with test AAP instance)
2. **Update AgnosticV catalog** to deploy these scripts during `post_software`
3. **Test with real deployment** before RH1 2026 event
4. **Document in collection README** for other lab authors

---

**Impact:** FTL is now extremely easy to use on bastion - just 3 steps:
1. Run setup script (once)
2. Set environment variables
3. Run grade/solve scripts

Perfect for load testing, CI/CD, and lab validation! 🚀
