# Showroom Instructions vs AgnosticV Reality

## Critical Mismatch: Showroom Says CREATE, AgnosticV PRE-CONFIGURES

### Module 1: Configure AAP for Self-Service Portal

#### What Showroom Instructs Students to DO

**From `module-01.adoc` lines 44-132:**

```
=== Create 3 teams in AAP:

Log in to Ansible Automation Platform

`Access Management` -> `Teams` -> `+Create Team`.

* `cloud-team`
* `network-team`
* `rhel-team`

Create each team as follows and click `Create team` to save the team(s).

[image showing Create Team dialog]

Now that you have created the teams, you will assign roles and users to the teams.

Starting with the `cloud-team`:
`Access Management` -> `Teams` -> `cloud-team` -> `Roles` -> `+Assign roles`

1. In the `Assign roles` step one, select `Job Template` as the resource type, and click `Next`.
2. In step 2, select all the job templates that begin with `Cloud/AWS`, and click `Next`.
3. In step 3, select the role to apply, please select `Job Template Execute`, and click `Next`.
4. In step 4, review your work, and click `Finish`.

Repeat the same process for assigning roles by adding the following roles:
- Inventory use roles (AWS Inventory, Azure Inventory, GCP Inventory)
- Credential use roles (AWS Credential, Azure Credential, RHEL - SSH Credentials)

Assign users to cloud-team:
- Click on the `Users` tab, and select `+Assign users` -> select `clouduser1`, and click `Assign users`.

**Repeat the same process for role and user assignments to the `network-team` and `rhel-team` teams.**
```

**Students are explicitly instructed to:**
1. ✅ Click "Create Team" button in AAP UI
2. ✅ Enter team names manually (cloud-team, network-team, rhel-team)
3. ✅ Navigate through multi-step role assignment wizard
4. ✅ Select job templates starting with "Cloud/AWS"
5. ✅ Select "Job Template Execute" role
6. ✅ Repeat for inventories (select "Inventory Use" role)
7. ✅ Repeat for credentials (select "Credential Use" role)
8. ✅ Assign clouduser1 to cloud-team
9. ✅ Repeat entire process for network-team and rhel-team

**Showroom even has verification checkpoints:**

```
== Verify your RBAC configuration

Before proceeding to the Portal configuration, confirm your AAP RBAC is correctly set up:

**Verification 1: Check team creation**

Navigate to: `Access Management` → `Teams`

✅ **Expected result**: You should see 3 teams:
- `cloud-team`
- `network-team`
- `rhel-team`

**Verification 2: Confirm cloud-team roles**

Click on `cloud-team` → `Roles` tab

✅ **Expected result**: You should see roles assigned for:
- **Job Templates**: All `Cloud/AWS*` templates with "Execute" permission
- **Inventories**: AWS, Azure, GCP with "Use" permission
- **Credentials**: AWS, Azure, RHEL SSH with "Use" permission
```

#### What AgnosticV GIVES Them (Pre-Configured)

**From `aap_selfservice_custom/defaults/main.yml`:**

```yaml
aap_selfservice_custom_users:
  - username: clouduser1
    password: "{{ common_password }}"
    email: clouduser1@example.org
    first_name: Cloud
    last_name: CloudUser1

  - username: networkuser1
    ...

  - username: rheluser1
    ...

aap_selfservice_custom_inventories:
  - name: AWS Inventory
  - name: Azure Inventory
  - name: GCP Inventory
  - name: RHEL Inventory
  - name: Network Inventory

aap_selfservice_custom_credentials:
  - name: AWS Credentials
    credential_type: Amazon Web Services
    inputs:
      username: "blahblahblahAWSACCESSKEYID"
      password: "blahblahlahAWSSECRETACCESSKEY"
  ...

aap_selfservice_custom_job_templates:
  - name: Cloud/AWS AWS Provisioning Workflow
  - name: Cloud/AWS Create RHEL10 instance
  - name: Cloud/AWS Create RHEL9 instance
  ...
  - name: Network/Configure Switch
  - name: Network/Update Firewall Rules
  ...
  - name: Linux/RHEL START Service on RHEL
  - name: Linux/RHEL Package Management
  ...
```

**Students receive:**
- ✅ Users: clouduser1, networkuser1, rheluser1 (already created)
- ✅ Inventories: 5 inventories (already created)
- ✅ Credentials: 4 credentials (already created with placeholder values)
- ✅ Project: "SelfService Demo playbooks" (already synced)
- ✅ Job Templates: 15 templates (already configured)
- ✅ Self-Service Portal: Already deployed and connected

**Students do NOT receive:**
- ❌ Teams (cloud-team, network-team, rhel-team) - **NOT CREATED**
- ❌ Team-based RBAC assignments - **NOT CONFIGURED**

## The Mismatch

### Showroom Says Students Create:
- 3 teams
- Role assignments (job template execute, inventory use, credential use)
- User assignments to teams
- Portal RBAC policies

### AgnosticV Actually Gives Them:
- Users (clouduser1, networkuser1, rheluser1)
- Inventories
- Credentials
- Job templates
- Self-Service Portal deployment

### AgnosticV Does NOT Give Them:
- Teams (cloud-team, network-team, rhel-team)
- Team-based RBAC

## Analysis: Two Possible Scenarios

### Scenario A: Showroom Content is CORRECT, AgnosticV is INCOMPLETE

**If this is true:**
- AgnosticV deployment is missing the `aap_selfservice_custom` team creation
- Students SHOULD create teams manually per Showroom instructions
- FTL graders we built are CORRECT (check for teams created by students)
- AgnosticV needs to be updated to match Showroom

**Evidence for this:**
- Showroom has detailed step-by-step instructions for team creation
- Showroom has verification checkpoints for teams
- Showroom instructions are very specific (screenshots, field names, etc.)

### Scenario B: Showroom Content is ASPIRATIONAL, AgnosticV is CORRECT

**If this is true:**
- Showroom content describes "ideal" lab but deployment differs
- Students actually just use pre-configured content
- Module 1 is instructor-led demo or conceptual learning
- Students jump to Module 2 (using Portal)
- FTL graders need major rewrite

**Evidence for this:**
- AgnosticV `aap_selfservice_custom` doesn't create teams
- Creating teams/RBAC is complex for beginners
- Time-consuming to do manually (30+ minutes)
- Portal is already deployed and working without teams

### Scenario C: HYBRID - Students Create Teams, Content Already Exists

**If this is true:**
- Users/inventories/credentials/job templates are pre-configured
- Students create teams and assign RBAC as learning exercise
- Both resources exist (pre-configured content + student-created teams)
- FTL should check BOTH pre-configured content AND student actions

**Evidence for this:**
- Makes pedagogical sense (students learn RBAC)
- Pre-configured content saves time on tedious parts
- Students focus on learning RBAC concepts

## What We Need to Verify

### Questions for Hicham/Lab Authors:

1. **Do students actually create teams in the lab?**
   - If YES → Our FTL graders are correct
   - If NO → Showroom content needs update OR is instructor demo only

2. **Is Module 1 instructor-led demonstration?**
   - Instructor shows RBAC concepts
   - Students observe, don't create
   - Students start at Module 2 (using Portal)

3. **Is there a timing issue?**
   - Lab provisioned before event
   - Instructor creates teams during setup
   - Students see teams but don't create them

4. **Is Showroom content future state?**
   - Content describes what lab WILL BE
   - Current deployment doesn't match yet
   - AgnosticV being updated to match

### How to Verify:

**Option 1: Deploy the lab and test**
```bash
# Deploy via AgnosticV
agnosticv deploy aap-multiinstance-workshop --num-users 1

# Check what exists:
# - Login to AAP as admin
# - Check if teams exist
# - Check if users exist
# - Check if job templates exist

# Follow Showroom Module 1 instructions as student
# - Try to create cloud-team
# - Does it already exist or not?
```

**Option 2: Ask the lab maintainers**
- Email Hicham Mourad (hmourad@redhat.com)
- Email Ritesh Shah (rshah@redhat.com)
- Ask: "Do students create teams or are they pre-configured?"

**Option 3: Check lab delivery history**
- Find someone who delivered this lab
- Ask what students actually did
- Compare with Showroom instructions

## Implications for FTL

### If Showroom is Correct (Students Create Teams):

**FTL graders are mostly correct:**
```yaml
✅ Check teams created (cloud-team, network-team, rhel-team)
✅ Check role assignments
✅ Check user assignments
❌ Don't check pre-configured content (assumes doesn't exist)
```

**FTL solvers need update:**
```yaml
✅ Browser automation to create teams (already built)
❌ Skip creating users/inventories/job templates (already exist)
✅ Create Portal RBAC policies
```

### If AgnosticV is Correct (Content Pre-Configured):

**FTL graders need major rewrite:**
```yaml
✅ Check users exist (clouduser1, networkuser1, rheluser1)
✅ Check inventories exist
✅ Check job templates exist
✅ Check jobs were executed
❌ Don't check teams (don't exist)
❌ Don't check team-based RBAC (doesn't exist)
```

**FTL solvers much simpler:**
```yaml
❌ No team creation
❌ No browser automation
✅ Just execute jobs via AAP API
```

### If Hybrid (Both):

**FTL graders check everything:**
```yaml
✅ Check pre-configured content exists
✅ Check teams created by students
✅ Check RBAC assignments
✅ Check job execution
```

**FTL solvers do both:**
```yaml
⚠️ Skip pre-configured content creation
✅ Create teams via browser/API
✅ Execute jobs
```

## Recommended Next Steps

1. **URGENT: Verify actual lab behavior**
   - Deploy lab via AgnosticV
   - Check what exists before students start
   - Follow Module 1 instructions
   - Document reality

2. **Align Showroom with AgnosticV**
   - If mismatch, update one to match other
   - Ensure consistency

3. **Update FTL accordingly**
   - Based on verified behavior
   - Match what students actually do

4. **Document for future labs**
   - Clear pre-configured vs student-created
   - FTL design patterns for each scenario

## Current Status

**FTL Lab Status:** ⚠️ **UNCERTAIN**
- Built based on Showroom instructions
- May not match AgnosticV deployment
- Needs verification before use

**Risk:**
- FTL grader checks for teams that don't exist → All FAIL
- FTL solver creates teams that already exist → Errors
- Load testing gives false results

**Mitigation:**
- Mark FTL lab as "DRAFT - VERIFICATION NEEDED"
- Test with real deployment before RH1 2026 event
- Have backup plan (manual verification)

---

**Created:** 2026-02-04
**Status:** Analysis complete, awaiting verification
**Owner:** Prakhar Srivastava, RHDP Team
