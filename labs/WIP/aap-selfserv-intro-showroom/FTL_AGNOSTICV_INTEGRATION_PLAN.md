# FTL AgnosticV Integration Plan

**Lab:** AAP Self-Service Portal Introduction (LB1652)
**Catalog:** `agd_v2/aap-multiinstance-workshop/common.yaml`
**Current Status:** Analysis only - NOT implementing yet

---

## 📋 Current Catalog Structure Analysis

From `/Users/psrivast/work/code/agnosticv/agd_v2/aap-multiinstance-workshop/common.yaml`:

### Collections (Lines 90-117)
```yaml
requirements_content:
  collections:
    - name: kubernetes.core
      version: 2.3.1
    # ... other collections ...
    - name: ansible.controller
      version: 4.5.0
    - name: https://github.com/rhpds/rhpds.aap_self_service_portal.git
      type: git
      version: main
    - name: https://github.com/agnosticd/showroom.git
      type: git
      version: v1.3.9
```

### Workloads (Lines 122-129)
```yaml
workloads:
  - agnosticd.core_workloads.ocp4_workload_authentication_keycloak
  - rhpds.aap_self_service_portal.ocp4_workload_aap_multiinstance
  - rhpds.aap_self_service_portal.self_service
  - rhpds.aap_self_service_portal.aap_selfservice_custom  # ← Pre-configures demo content
  - agnosticd.showroom.ocp4_workload_showroom_ocp_integration
  - agnosticd.showroom.ocp4_workload_showroom
  - rhpds.aap_self_service_portal.ocp4_workload_aap_multiinstance_validation
```

### Bastion Configuration (Lines 76-79)
```yaml
install_student_user: true
student_name: lab-user
student_sudo: true
```

### Multi-User Support (Lines 56, 150, 294-303)
```yaml
# Worker nodes auto-scale based on num_users
worker_instance_count: "{{ [2, ((num_users | int / 7.0) | round(0, 'ceil') | int) + 1] | max }}"

# Keycloak creates user1, user2, ..., userN
ocp4_workload_authentication_keycloak_num_users: "{{ num_users }}"

# Catalog parameter
parameters:
  - name: num_users
    default: 3
    minimum: 3
    maximum: 30
```

---

## 🎯 FTL Integration Options

### Option 1: Add FTL Collection + New Workload (Recommended)

**Where it fits:**
- **Collections section** (after line 117): Add FTL collection
- **Workloads section** (after line 129): Add FTL workload

**Changes to make:**

```yaml
# Lines 90-117: Collections
requirements_content:
  collections:
    # ... existing collections ...
    - name: https://github.com/agnosticd/showroom.git
      type: git
      version: v1.3.9
    # ↓↓↓ ADD FTL COLLECTION HERE ↓↓↓
    - name: https://github.com/rhdp/rhdp.ftl.git
      type: git
      version: main
```

```yaml
# Lines 122-129: Workloads
workloads:
  # ... existing workloads ...
  - rhpds.aap_self_service_portal.ocp4_workload_aap_multiinstance_validation
  # ↓↓↓ ADD FTL WORKLOAD HERE ↓↓↓
  - rhdp.ftl.ocp4_workload_ftl_deployment
```

**New workload to create:**
`roles/ocp4_workload_ftl_deployment/tasks/main.yml`:
```yaml
---
# Deploy FTL to bastion for lab grading/solving

- name: Copy FTL labs to bastion
  ansible.builtin.copy:
    src: "{{ playbook_dir }}/ftl-labs/aap-selfserv-intro-showroom/"
    dest: "/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/"
    mode: preserve
  delegate_to: bastion

- name: Ensure FTL scripts are executable
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

# Optional: Run setup automatically
- name: Setup FTL environment on bastion
  ansible.builtin.shell: |
    cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
    ./setup_ftl_environment.sh
  delegate_to: bastion
  when: ftl_auto_setup | default(false)
```

**Pros:**
- ✅ Clean separation of concerns
- ✅ Reusable workload for other labs
- ✅ Follows AgnosticV patterns
- ✅ Easy to enable/disable

**Cons:**
- ❌ Requires creating new workload role
- ❌ More complex initial setup

---

### Option 2: Extend Existing Validation Workload (Simpler)

**Where it fits:**
Extend `rhpds.aap_self_service_portal.ocp4_workload_aap_multiinstance_validation`

**Changes to make:**

In `rhpds.aap_self_service_portal` collection, update the validation workload:

```yaml
# roles/ocp4_workload_aap_multiinstance_validation/tasks/main.yml

# ... existing validation tasks ...

# ↓↓↓ ADD FTL DEPLOYMENT AT END ↓↓↓
- name: Deploy FTL to bastion (if enabled)
  when: ftl_deploy_to_bastion | default(false)
  block:
    - name: Copy FTL labs to bastion
      ansible.builtin.copy:
        src: files/ftl-labs/aap-selfserv-intro-showroom/
        dest: /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/
        mode: preserve
      delegate_to: bastion

    - name: Make FTL scripts executable
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

**Pros:**
- ✅ Simpler - no new workload needed
- ✅ FTL bundled with validation
- ✅ Less changes to common.yaml

**Cons:**
- ❌ Couples FTL to validation workload
- ❌ Less reusable for other labs
- ❌ Validation workload becomes FTL-aware

---

### Option 3: Manual Deployment (Current Approach)

**No changes to common.yaml**

Students/instructors manually copy FTL to bastion:

```bash
# After lab deployment, on bastion:
scp -r ftl-labs/aap-selfserv-intro-showroom lab-user@bastion.abc123.example.com:/opt/rhdp/ftl/labs/

# Then SSH to bastion
ssh lab-user@bastion.abc123.example.com
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
./setup_ftl_environment.sh
```

**Pros:**
- ✅ No catalog changes needed
- ✅ Can test FTL independently
- ✅ Students control when to setup
- ✅ Good for initial testing

**Cons:**
- ❌ Manual steps required
- ❌ Not automated for load testing
- ❌ Harder to integrate with CI/CD

---

## 🔍 Detailed Integration Points

### 1. Where FTL Collection Would Go

**File:** `common.yaml`
**Lines:** 90-117 (requirements_content section)

```yaml
requirements_content:
  collections:
    # ... existing 16 collections ...
    - name: https://github.com/agnosticd/showroom.git
      type: git
      version: v1.3.9

    # ↓↓↓ ADD HERE ↓↓↓
    - name: https://github.com/rhdp/rhdp.ftl.git  # FTL collection repo
      type: git
      version: v1.0.0  # or 'main' for latest
```

**What this does:**
- Makes `rhdp.ftl` collection available to all playbooks
- Provides FTL roles: `grader_check_*`, `solver_*`, `ftl_run_*`
- Available in execution environment

---

### 2. Where FTL Workload Would Go

**File:** `common.yaml`
**Lines:** 122-129 (workloads section)

```yaml
workloads:
  - agnosticd.core_workloads.ocp4_workload_authentication_keycloak
  - rhpds.aap_self_service_portal.ocp4_workload_aap_multiinstance
  - rhpds.aap_self_service_portal.self_service
  - rhpds.aap_self_service_portal.aap_selfservice_custom
  - agnosticd.showroom.ocp4_workload_showroom_ocp_integration
  - agnosticd.showroom.ocp4_workload_showroom
  - rhpds.aap_self_service_portal.ocp4_workload_aap_multiinstance_validation

  # ↓↓↓ ADD HERE ↓↓↓
  - rhdp.ftl.ocp4_workload_ftl_deployment  # Deploy FTL to bastion
```

**Execution order:**
1. Keycloak (users)
2. AAP multiinstance (AAP per user)
3. Self-service portal
4. aap_selfservice_custom (demo content) ← Critical for our lab!
5. Showroom integration
6. Showroom deployment
7. AAP validation
8. **FTL deployment** ← Would go here

---

### 3. FTL Workload Configuration

**File:** `common.yaml`
**Lines:** After line 252 (new section)

```yaml
# -------------------------------------------------------------------
# Workload: rhdp.ftl.ocp4_workload_ftl_deployment
# -------------------------------------------------------------------
# FTL (Finish The Labs) - Automated grading and solving
# Deploys FTL scripts to bastion for lab validation and load testing

# Enable/disable FTL deployment
ftl_deploy_to_bastion: true

# Auto-setup virtual environment on bastion
ftl_auto_setup: false  # Set to true for automatic setup

# Which labs to deploy
ftl_labs_to_deploy:
  - aap-selfserv-intro-showroom

# FTL collection version
ftl_collection_version: v1.0.0
```

---

### 4. Bastion Userdata After FTL Deployment

**Current bastion access** (from catalog):
```
Bastion Host Access
Hostname: bastion.abc123.example.com
Username: lab-user
Password: Xy8aB2cD
```

**With FTL deployed:**
```
Bastion Host Access
Hostname: bastion.abc123.example.com
Username: lab-user
Password: Xy8aB2cD

FTL Lab Grading/Solving
Location: /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/
Setup: ./setup_ftl_environment.sh (run once)
Grade Lab: ./grade_lab.sh
Solve Lab: ./solve_lab.sh

Environment Variables Needed:
  export AAP_CONTROLLER_URL='https://user1-aap-user1-aap.apps...'
  export AAP_ADMIN_PASSWORD='Xy8aB2cD'
  export SELF_SERVICE_PORTAL_URL='https://self-service-...'
```

---

## 🚀 Multi-User Considerations

### How FTL Works with Multi-User Deployments

**Deployment creates (per user):**
- user1 → AAP instance → Self-Service Portal
- user2 → AAP instance → Self-Service Portal
- user3 → AAP instance → Self-Service Portal

**FTL on bastion can grade:**
1. **Single user** (manual testing):
   ```bash
   export AAP_CONTROLLER_URL='https://user1-aap-...'
   ./grade_lab.sh
   ```

2. **All users** (load testing):
   ```bash
   for user in user1 user2 user3; do
       export AAP_CONTROLLER_URL="https://${user}-aap-..."
       ./grade_lab.sh > /tmp/ftl_results/${user}.log 2>&1 &
   done
   wait
   ```

3. **From AgnosticD userdata**:
   ```bash
   # FTL can read aap_instances from agnosticd_user_data
   # See AGNOSTICV_INTEGRATION.md for details
   ```

---

## 📝 Files That Would Be Deployed to Bastion

```
/opt/rhdp/ftl/
└── labs/
    └── aap-selfserv-intro-showroom/
        ├── setup_ftl_environment.sh        # One-time setup
        ├── activate_ftl                    # Manual activation helper
        ├── grade_lab.sh                    # Grade all modules
        ├── solve_lab.sh                    # Solve all modules
        ├── grade_module.sh                 # Grade single module
        ├── solve_module.sh                 # Solve single module
        ├── grade_lab.yml                   # Main grading playbook
        ├── solve_lab.yml                   # Main solving playbook
        ├── grade_module_01.yml             # Module graders
        ├── grade_module_02.yml
        ├── grade_module_03.yml
        ├── solve_module_01.yml             # Module solvers
        ├── solve_module_02.yml
        ├── solve_module_03.yml
        ├── lab.yml                         # Lab metadata
        ├── README.md                       # Lab documentation
        ├── BASTION_USAGE.md                # Usage guide
        └── .venv/                          # Created by setup script
```

---

## ⚠️ Important Notes

### 1. FTL is INTERNAL TOOL ONLY
- **NOT for students** - only for RHDP team, instructors, load testing
- Bastion access is instructor/admin only for this lab
- Students interact with Portal UI, not FTL

### 2. Dependencies
FTL requires on bastion:
- Python 3 (already installed via bastion_instance_image: rhel-9.5)
- jq, curl (installed by setup script)
- ansible, awxkit (installed in venv by setup script)

### 3. Execution Environment
- FTL collection would be available in EE: `quay.io/agnosticd/ee-multicloud:chained-2025-10-09`
- But FTL scripts run on bastion (not in containers)
- Scripts create own venv with required packages

---

## 🎯 Recommendation for Initial Testing

**For now (manual approach):**
1. ✅ Deploy lab via AgnosticV as-is (no changes to catalog)
2. ✅ Manually copy FTL scripts to bastion
3. ✅ Test grading/solving
4. ✅ Validate with real AAP instances

**After successful testing:**
1. Create FTL collection repo at `https://github.com/rhdp/rhdp.ftl.git`
2. Decide on integration approach (Option 1 or 2)
3. Update common.yaml with chosen approach
4. Test automated deployment
5. Use for load testing before RH1 2026 event

---

## 📊 Summary

| Aspect | Current State | With FTL Integration |
|--------|---------------|---------------------|
| **Collections** | 17 collections | 18 (+ rhdp.ftl) |
| **Workloads** | 7 workloads | 8 (+ ftl_deployment) |
| **Bastion files** | Showroom content | + FTL scripts |
| **Student impact** | None | None (FTL is internal) |
| **Load testing** | Manual | Automated via FTL |
| **Lab validation** | Manual checks | Automated grading |

---

## 🚦 Next Steps (When Ready)

1. **Create FTL collection repo** on GitHub
2. **Choose integration approach** (Option 1 recommended)
3. **Create workload role** `ocp4_workload_ftl_deployment`
4. **Update common.yaml** with collection + workload
5. **Test deployment** with 1 user
6. **Scale test** with 30 users
7. **Document** for other lab authors

---

**Status:** Analysis complete - ready for manual testing
**Integration:** Deferred until after initial validation
**Location:** Scripts ready at `/Users/psrivast/work/code/experiment/ftl/labs/aap-selfserv-intro-showroom/`
