# Real Lab Analysis: AAP Self-Service Portal Workshop

## Critical Discovery: Lab Content is Pre-Configured

### What We Built (INCORRECT Assumptions)

**Original FTL lab assumed:**
- Students manually create teams (cloud-team, network-team, rhel-team)
- Students manually assign users to teams
- Students manually configure RBAC (job template execute, inventory use, credential use permissions)
- Students manually create Portal RBAC policies
- Lab is about **configuring** AAP and Portal

**Our graders checked:**
- Teams exist
- Users assigned to teams
- Role assignments configured
- Portal policies created

### What the REAL Lab Is (From AgnosticV Code)

**Reality:**
- `aap_selfservice_custom` role **PRE-CONFIGURES** all AAP content during deployment
- Students receive **fully configured** AAP instances with:
  - ✅ 3 demo users already created (clouduser1, networkuser1, rheluser1)
  - ✅ 5 inventories already created (AWS, Azure, GCP, RHEL, Network)
  - ✅ 4 credentials already configured (placeholder values for demo)
  - ✅ 1 SCM project already synced (github.com/ansible-tmm/ssap-lab)
  - ✅ 15 job templates already configured with surveys
  - ✅ Self-Service Portal already deployed and connected to AAP
  - ✅ Showroom instructions already available

**Students do:**
- ❌ NOT create teams or configure RBAC
- ❌ NOT create Portal policies
- ✅ ONLY **use** the pre-configured Portal
- ✅ Login as different personas (clouduser1, networkuser1, rheluser1)
- ✅ Execute job templates via Portal UI
- ✅ See RBAC in action (different users see different templates)
- ✅ Explore Portal features (surveys, custom templates)

## Real Lab Flow (From Showroom Content)

Based on `~/work/showroom-content/aap-selfserv-intro-showroom/content/modules/ROOT/pages/`:

### Module 1: Configure AAP for Self-Service Portal

**What Showroom says students do:**
1. Create 3 teams in AAP
2. Assign roles to teams
3. Assign users to teams
4. Create Portal RBAC policies

**REALITY:**
- This is **instructor demo** content or **conceptual** learning
- AgnosticV pre-configures this automatically via `aap_selfservice_custom`
- Students **observe** the configuration, they don't create it
- OR this is aspirational content not yet aligned with actual deployment

### Module 2: User Persona Testing

**What students actually do:**
1. Login to Portal as clouduser1
2. See only Cloud/AWS job templates (RBAC working)
3. Execute a cloud job template
4. Repeat for networkuser1 (sees only Network templates)
5. Repeat for rheluser1 (sees only RHEL templates)

**This matches reality!** Students execute jobs, validate RBAC works.

### Module 3: Surveys and Custom Templates

**What students do:**
1. View job template surveys (already configured)
2. Execute job with survey inputs
3. View custom template in Portal
4. Execute custom template

**This matches reality!** Content exploration and execution.

## Pre-Configured Content (from aap_selfservice_custom role)

### Users Created

```yaml
- clouduser1 / {{ common_password }}
- networkuser1 / {{ common_password }}
- rheluser1 / {{ common_password }}
```

All users have same password as OpenShift users and AAP admin (based on GUID hash).

### Inventories Created

```yaml
- AWS Inventory
- Azure Inventory
- GCP Inventory
- RHEL Inventory
- Network Inventory
```

### Credentials Created (Placeholder)

```yaml
- AWS Credentials (fake AWS keys)
- Azure Credentials (fake subscription ID)
- RHEL - SSH Credentials (empty)
- Network Credentials (empty)
```

**Note:** These are demo credentials, job templates won't actually execute against real cloud infrastructure.

### Project

```yaml
Name: SelfService Demo playbooks
SCM URL: https://github.com/ansible-tmm/ssap-lab
Branch: main
```

### Job Templates (15 total)

**Cloud/AWS Templates (5):**
1. Cloud/AWS AWS Provisioning Workflow
2. Cloud/AWS Create RHEL10 instance (has survey)
3. Cloud/AWS Create RHEL9 instance (has survey)
4. Cloud/AWS Check Region Connectivity
5. Cloud/AWS Terminate Instance

**Network Templates (4):**
1. Network/Configure Switch
2. Network/Update Firewall Rules
3. Network/Backup Configuration
4. Network/Check Device Status

**Linux/RHEL Templates (6):**
1. Linux/RHEL START Service on RHEL (has survey)
2. Linux/RHEL Package Management
3. Linux/RHEL User Management
4. Linux/RHEL File Operations
5. RHEL / Update RHEL Time Servers (custom template)
6. Linux/RHEL System Info

### Labels

```yaml
- aws
- rhel
- network
- custom
```

## What FTL Should Actually Grade

### Module 1: RBAC Configuration (OBSERVATION)

**Since content is pre-configured, grader should:**

1. ✅ **Verify pre-configured content exists**
   - Users clouduser1, networkuser1, rheluser1 exist
   - Inventories exist
   - Credentials exist
   - Job templates exist

2. ❌ **NOT check for teams created by student**
   - No teams are created (this was our incorrect assumption)
   - RBAC is configured differently (user permissions, not team-based)

3. ✅ **Verify students can login**
   - clouduser1 can login to Portal
   - networkuser1 can login to Portal
   - rheluser1 can login to Portal

**Updated Module 1 Grading:**
```yaml
- Verify clouduser1 account exists in AAP
- Verify networkuser1 account exists in AAP
- Verify rheluser1 account exists in AAP
- Verify AWS Inventory exists
- Verify Network Inventory exists
- Verify RHEL Inventory exists
- Verify project "SelfService Demo playbooks" exists and synced
- Verify Cloud/AWS job templates exist
- Verify Network job templates exist
- Verify Linux/RHEL job templates exist
- Verify Self-Service Portal is accessible
```

### Module 2: User Persona Testing (JOB EXECUTION)

**Grader should:**

1. ✅ **Verify job execution as different users**
   - clouduser1 executed at least 1 Cloud/AWS job
   - networkuser1 executed at least 1 Network job
   - rheluser1 executed at least 1 Linux/RHEL job

2. ✅ **Verify jobs completed successfully**
   - Jobs have status "successful"
   - Job output shows no errors

**Updated Module 2 Grading:**
```yaml
- Verify clouduser1 executed a Cloud/AWS job template
- Verify clouduser1's job completed successfully
- Verify networkuser1 executed a Network job template
- Verify networkuser1's job completed successfully
- Verify rheluser1 executed a Linux/RHEL job template
- Verify rheluser1's job completed successfully
```

### Module 3: Surveys and Custom Templates (FEATURE EXPLORATION)

**Grader should:**

1. ✅ **Verify students used surveys**
   - Job executed with survey enabled template
   - Survey inputs were provided

2. ✅ **Verify custom template execution**
   - "RHEL / Update RHEL Time Servers" job executed
   - Custom template job completed

**Updated Module 3 Grading:**
```yaml
- Verify "Linux/RHEL START Service on RHEL" executed (has survey)
- Verify survey inputs were provided in job
- Verify "RHEL / Update RHEL Time Servers" executed (custom template)
- Verify custom template job completed successfully
```

## Updated FTL Grader Structure

### grade_module_01.yml (Pre-Configuration Validation)

```yaml
---
- name: Grade Module 1 - Verify Pre-Configured AAP Content
  hosts: localhost
  tasks:
    # Verify users exist
    - name: Verify clouduser1 exists
      include_role:
        name: rhdp.ftl.grader_check_command_output
      vars:
        command: "awx users get clouduser1 --conf.host {{ aap_controller_url }} ..."
        expected_output: "clouduser1"

    # Verify inventories exist
    - name: Verify AWS Inventory exists
      include_role:
        name: rhdp.ftl.grader_check_command_output
      vars:
        command: "awx inventories get 'AWS Inventory' ..."

    # Verify job templates exist
    - name: Verify Cloud/AWS job templates exist
      include_role:
        name: rhdp.ftl.grader_check_command_output
      vars:
        command: "awx job_templates list --name__startswith 'Cloud/AWS' | wc -l"
        expected_output_regex: "^[5-9]|[1-9][0-9]+$"  # At least 5

    # Verify portal is accessible
    - name: Verify Self-Service Portal responds
      include_role:
        name: rhdp.ftl.grader_check_command_output
      vars:
        command: "curl -sk {{ self_service_portal_url }} | grep -c 'Self-Service'"
        expected_output: "1"
```

### grade_module_02.yml (Job Execution Validation)

```yaml
---
- name: Grade Module 2 - Verify Job Execution by User Personas
  hosts: localhost
  tasks:
    # Check clouduser1 job execution
    - name: Verify clouduser1 executed Cloud/AWS job
      include_role:
        name: rhdp.ftl.grader_check_command_output
      vars:
        command: >-
          awx jobs list
          --created_by__username clouduser1
          --job_template__name__startswith 'Cloud/AWS'
          --status successful
          | wc -l
        expected_output_regex: "^[1-9][0-9]*$"  # At least 1

    # Similar checks for networkuser1 and rheluser1
```

### grade_module_03.yml (Survey and Custom Template Validation)

```yaml
---
- name: Grade Module 3 - Verify Survey and Custom Template Usage
  hosts: localhost
  tasks:
    - name: Verify survey-enabled job executed
      include_role:
        name: rhdp.ftl.grader_check_command_output
      vars:
        command: >-
          awx jobs list
          --job_template__name 'Linux/RHEL START Service on RHEL'
          --status successful
          | wc -l
        expected_output_regex: "^[1-9][0-9]*$"

    - name: Verify custom template job executed
      include_role:
        name: rhdp.ftl.grader_check_command_output
      vars:
        command: >-
          awx jobs list
          --job_template__name 'RHEL / Update RHEL Time Servers'
          --status successful
          | wc -l
        expected_output_regex: "^[1-9][0-9]*$"
```

## FTL Solver: Auto-Execute Jobs

### solve_module_01.yml (No-Op or Validation)

```yaml
---
- name: Solve Module 1 - Verify Pre-Configuration
  hosts: localhost
  tasks:
    - name: Module 1 requires no solving
      ansible.builtin.debug:
        msg: |
          Module 1 content is pre-configured by AgnosticV.
          This solver validates the configuration exists.

    # Could add validation checks here if needed
```

### solve_module_02.yml (Execute Jobs as Personas)

```yaml
---
- name: Solve Module 2 - Execute Jobs as User Personas
  hosts: localhost
  tasks:
    # Execute job as clouduser1 via AAP API
    - name: Execute Cloud/AWS job as clouduser1
      ansible.controller.job_launch:
        controller_host: "{{ aap_controller_url }}"
        controller_username: "clouduser1"
        controller_password: "{{ common_password }}"
        validate_certs: false
        job_template: "Cloud/AWS Check Region Connectivity"
        inventory: "AWS Inventory"
      register: r_cloud_job

    # Wait for job completion
    - name: Wait for clouduser1 job completion
      ansible.controller.job_wait:
        controller_host: "{{ aap_controller_url }}"
        controller_username: "clouduser1"
        controller_password: "{{ common_password }}"
        validate_certs: false
        job_id: "{{ r_cloud_job.id }}"

    # Similar for networkuser1 and rheluser1
```

### solve_module_03.yml (Execute Survey and Custom Template Jobs)

```yaml
---
- name: Solve Module 3 - Execute Survey and Custom Template Jobs
  hosts: localhost
  tasks:
    # Execute survey-enabled job
    - name: Execute job with survey
      ansible.controller.job_launch:
        controller_host: "{{ aap_controller_url }}"
        controller_username: "rheluser1"
        controller_password: "{{ common_password }}"
        validate_certs: false
        job_template: "Linux/RHEL START Service on RHEL"
        inventory: "RHEL Inventory"
        extra_vars:
          enable_service: "yes"  # Survey input
      register: r_survey_job

    # Execute custom template job
    - name: Execute custom template job
      ansible.controller.job_launch:
        controller_host: "{{ aap_controller_url }}"
        controller_username: "rheluser1"
        controller_password: "{{ common_password }}"
        validate_certs: false
        job_template: "RHEL / Update RHEL Time Servers"
        inventory: "RHEL Inventory"
      register: r_custom_job
```

## Action Items

1. ✅ **Document real lab behavior** (this file)

2. ⚠️ **Update FTL lab to match reality:**
   - [ ] Rewrite grade_module_01.yml to check pre-configured content
   - [ ] Update grade_module_02.yml to check job execution only
   - [ ] Update grade_module_03.yml for survey/custom template validation
   - [ ] Rewrite solve_module_01.yml (no-op or validation)
   - [ ] Rewrite solve_module_02.yml to use ansible.controller collection
   - [ ] Rewrite solve_module_03.yml to execute jobs via API
   - [ ] Remove all browser automation (not needed for job execution)
   - [ ] Update lab.yml metadata

3. ⚠️ **Align with Showroom content:**
   - Check if Showroom instructions match AgnosticV reality
   - If mismatch, either update Showroom OR keep FTL as-is for "aspirational" lab

4. ⚠️ **Test with real deployment:**
   - Deploy via AgnosticV
   - Verify pre-configured content
   - Run FTL grader
   - Run FTL solver
   - Validate all checks pass

## Key Insights

1. **Lab is demonstration, not configuration**
   - Students see RBAC working, don't create it
   - Content is pre-built for exploration

2. **FTL should grade outcomes, not actions**
   - Check jobs were executed
   - Don't check if students created resources

3. **Solvers use AAP API, not browser**
   - No need for Playwright
   - Use `ansible.controller` collection
   - Direct API calls for job execution

4. **Multi-user mode implications**
   - Each user has separate AAP instance
   - Same demo content in each instance
   - Load testing = execute jobs across all instances

This is a fundamentally different lab than we initially understood! 🎯
