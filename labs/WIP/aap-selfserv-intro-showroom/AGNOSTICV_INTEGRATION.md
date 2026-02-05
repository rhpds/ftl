# AgnosticV Integration for AAP Self-Service Portal Lab

## Userdata Structure from AgnosticV

### Single-User Mode (num_users=1)

**User sees (from `agnosticd_user_info`):**

```asciidoc
OpenShift Console: https://console-openshift-console.apps.cluster-abc123.example.com
Username: user1
Password: Xy8aB2cD

Ansible Automation Platform
Controller URL: https://user1-aap-user1-aap.apps.cluster-abc123.example.com
Admin Username: admin
Admin Password: Xy8aB2cD

Self-Service Automation Portal
Portal URL: https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster-abc123.example.com
Login: Use AAP admin credentials above

Lab Instructions (Showroom)
Instructions URL: https://showroom-user1-showroom.apps.cluster-abc123.example.com
```

**Userdata variables available:**

```yaml
# Per-user data (accessed via agnosticd_user_data lookup)
openshift_username: "user1"
openshift_password: "Xy8aB2cD"  # common_password based on GUID
aap_controller_url: "https://user1-aap-user1-aap.apps.cluster-abc123.example.com"
aap_admin_username: "admin"
aap_admin_password: "Xy8aB2cD"  # same as openshift_password
aap_namespace: "user1-aap"
self_service_portal_url: "https://self-service-rhaap-portal-user1-aap-ssap.apps.cluster-abc123.example.com"
showroom_url: "https://showroom-user1-showroom.apps.cluster-abc123.example.com"

# Global data
aap_multi_user_mode: false
guid: "abc123"
```

### Multi-User Mode (num_users=3)

**Each user (user1, user2, user3) sees:**

```asciidoc
OpenShift Username: user2
OpenShift Password: Xy8aB2cD
AAP Controller: https://user2-aap-user2-aap.apps.cluster-abc123.example.com
AAP Admin Username: admin
AAP Admin Password: Xy8aB2cD
AAP Namespace: user2-aap
Self-Service Portal: https://self-service-rhaap-portal-user2-aap-ssap.apps.cluster-abc123.example.com
Showroom: https://showroom-user2-showroom.apps.cluster-abc123.example.com
```

**Global data saved for internal use:**

```yaml
aap_multi_user_mode: true
aap_admin_username: "admin"
aap_instances:
  - user: "user1"
    namespace: "user1-aap"
    route: "user1-aap-user1-aap.apps.cluster-abc123.example.com"  # Gateway route
    controller_route: "user1-aap-controller-user1-aap.apps.cluster-abc123.example.com"  # Controller route
    password: "Xy8aB2cD"
  - user: "user2"
    namespace: "user2-aap"
    route: "user2-aap-user2-aap.apps.cluster-abc123.example.com"
    controller_route: "user2-aap-controller-user2-aap.apps.cluster-abc123.example.com"
    password: "Xy8aB2cD"
  - user: "user3"
    namespace: "user3-aap"
    route: "user3-aap-user3-aap.apps.cluster-abc123.example.com"
    controller_route: "user3-aap-controller-user3-aap.apps.cluster-abc123.example.com"
    password: "Xy8aB2cD"
```

## Bastion Access

**Instructor/Admin only** (from `info-message-template.adoc`):

```asciidoc
Bastion Host Access

Hostname: bastion.abc123.example.com
Port: 22
Command: ssh lab-user@bastion.abc123.example.com
Username: lab-user
Password: Xy8aB2cD
```

**Students:** NO bastion access (only web UIs)

## FTL Deployment on Bastion

### Via AgnosticV post_software

```yaml
# In catalog common.yaml
post_software:
  - name: Install FTL collection on bastion
    ansible.builtin.shell: |
      ansible-galaxy collection install rhdp.ftl
    delegate_to: bastion

  - name: Copy FTL labs to bastion
    ansible.builtin.copy:
      src: "{{ playbook_dir }}/ftl-labs/aap-selfserv-intro-showroom/"
      dest: "/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/"
    delegate_to: bastion

  - name: Create environment file for FTL on bastion
    ansible.builtin.template:
      src: ftl_env.sh.j2
      dest: /etc/profile.d/ftl_env.sh
      mode: '0644'
    delegate_to: bastion
```

**Template: `ftl_env.sh.j2`**

```bash
#!/bin/bash
# FTL Environment Variables (for instructor/load testing only)
# Source: AgnosticV deployment userdata

# GUID
export GUID="{{ guid }}"

# Common password (used for all users in workshop)
export COMMON_PASSWORD="{{ common_password }}"

# For load testing: These are set per-user dynamically
# FTL scripts should fetch from agnosticd_user_data lookup
export AAP_CONTROLLER_URL="{{ aap_controller_url | default('') }}"
export AAP_ADMIN_USERNAME="{{ aap_admin_username | default('admin') }}"
export AAP_ADMIN_PASSWORD="{{ aap_admin_password | default(common_password) }}"
export SELF_SERVICE_PORTAL_URL="{{ self_service_portal_url | default('') }}"

# OpenShift access (for grading that needs OCP API)
export OPENSHIFT_API_URL="{{ openshift_api_url }}"
export OPENSHIFT_USERNAME="{{ openshift_username | default('') }}"
export OPENSHIFT_PASSWORD="{{ openshift_password | default(common_password) }}"

# Multi-user mode flag
export AAP_MULTI_USER_MODE="{{ aap_multi_user_mode | default('false') }}"
```

## Updated FTL Lab Variables

### Update `labs/aap-selfserv-intro-showroom/lab.yml`

```yaml
---
lab:
  id: aap-selfserv-intro-showroom
  name: "Introduction to Ansible Automation Platform Self-Service Automation Portal"
  version: "1.0"

# Multi-user support
multi_user_mode: "{{ lookup('env', 'AAP_MULTI_USER_MODE') | default('false') | bool }}"

# Environment detection: Pull from AgnosticD userdata or env vars
environment:
  # For single-user or when running as specific user
  aap_controller_url: "{{ lookup('env', 'AAP_CONTROLLER_URL') | default(lookup('agnosticd_user_data', 'aap_controller_url', default='')) }}"
  aap_admin_username: "{{ lookup('env', 'AAP_ADMIN_USERNAME') | default(lookup('agnosticd_user_data', 'aap_admin_username', default='admin')) }}"
  aap_admin_password: "{{ lookup('env', 'AAP_ADMIN_PASSWORD') | default(lookup('agnosticd_user_data', 'aap_admin_password', default='')) }}"
  self_service_portal_url: "{{ lookup('env', 'SELF_SERVICE_PORTAL_URL') | default(lookup('agnosticd_user_data', 'self_service_portal_url', default='')) }}"

  # For load testing with multiple users
  aap_instances: "{{ lookup('agnosticd_user_data', 'aap_instances', default=[]) }}"

  # OpenShift access
  openshift_api_url: "{{ lookup('env', 'OPENSHIFT_API_URL') | default('') }}"
  openshift_username: "{{ lookup('env', 'OPENSHIFT_USERNAME') | default(lookup('agnosticd_user_data', 'openshift_username', default='')) }}"
  openshift_password: "{{ lookup('env', 'OPENSHIFT_PASSWORD') | default(lookup('agnosticd_user_data', 'openshift_password', default='')) }}"

  # GUID
  guid: "{{ lookup('env', 'GUID') | default('test') }}"
```

### Update Grader/Solver Playbooks

**For single-user grading:**

```yaml
---
# grade_module_01.yml
- name: Grade Module 1 - AAP RBAC Configuration
  hosts: localhost
  gather_facts: false

  vars:
    # Pull from AgnosticD userdata (preferred) or environment vars (fallback)
    aap_controller_url: "{{ lookup('agnosticd_user_data', 'aap_controller_url', default=lookup('env', 'AAP_CONTROLLER_URL')) }}"
    aap_admin_username: "{{ lookup('agnosticd_user_data', 'aap_admin_username', default=lookup('env', 'AAP_ADMIN_USERNAME')) }}"
    aap_admin_password: "{{ lookup('agnosticd_user_data', 'aap_admin_password', default=lookup('env', 'AAP_ADMIN_PASSWORD')) }}"
    self_service_portal_url: "{{ lookup('agnosticd_user_data', 'self_service_portal_url', default=lookup('env', 'SELF_SERVICE_PORTAL_URL')) }}"

  tasks:
    - name: "Module 1.1: Verify cloud-team exists"
      include_role:
        name: rhdp.ftl.grader_check_command_output
      vars:
        task_description_message: "Team 'cloud-team' exists in AAP"
        command: >-
          awx --conf.host {{ aap_controller_url }}
          --conf.username {{ aap_admin_username }}
          --conf.password {{ aap_admin_password }}
          --conf.insecure
          teams list --name "^cloud-team$" -f json | jq -r '.[].name'
        expected_output: "cloud-team"
        student_error_message: "Team not found. Create via AAP UI: Access Management → Teams → Create Team"
```

**For multi-user load testing:**

```yaml
---
# load_test_all_users.yml
- name: Load Test - Grade All Users
  hosts: localhost
  gather_facts: false

  vars:
    # Pull all AAP instances from AgnosticD data
    aap_instances: "{{ lookup('agnosticd_user_data', 'aap_instances', default=[]) }}"

  tasks:
    - name: Verify we have AAP instances to test
      ansible.builtin.assert:
        that:
          - aap_instances | length > 0
        fail_msg: "No AAP instances found. Check agnosticd_user_data."

    - name: Grade each user's lab in parallel
      ansible.builtin.include_tasks: grade_single_user.yml
      loop: "{{ aap_instances }}"
      loop_control:
        loop_var: aap_instance
        label: "{{ aap_instance.user }}"
```

**Helper: `grade_single_user.yml`**

```yaml
---
# Grade a single user's lab
- name: Set user-specific variables
  ansible.builtin.set_fact:
    user_id: "{{ aap_instance.user }}"
    user_aap_url: "https://{{ aap_instance.route }}"
    user_aap_password: "{{ aap_instance.password }}"
    user_namespace: "{{ aap_instance.namespace }}"

- name: Grade user {{ user_id }}
  ansible.builtin.shell: |
    cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
    ansible-playbook grade_lab.yml \
      -e "aap_controller_url={{ user_aap_url }}" \
      -e "aap_admin_password={{ user_aap_password }}" \
      -e "aap_admin_username=admin" \
      -e "grader_working_dir=/tmp/grading_dir_{{ user_id }}/" \
      > /tmp/ftl_load_test/grade_{{ user_id }}.log 2>&1
  register: r_grade
  failed_when: false

- name: Record result for {{ user_id }}
  ansible.builtin.lineinfile:
    path: /tmp/ftl_load_test/results.csv
    line: "{{ user_id }},{{ r_grade.rc }},{{ ansible_date_time.epoch }}"
    create: yes
```

## Load Testing Pattern

**Script: `/opt/rhdp/ftl/utils/load_test_multiuser.sh`**

```bash
#!/bin/bash
# Load test all users in parallel using AgnosticD userdata

cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# This playbook reads aap_instances from agnosticd_user_data
# and runs grader for each user in parallel
ansible-playbook load_test_all_users.yml

# Results in /tmp/ftl_load_test/
echo "Results:"
cat /tmp/ftl_load_test/results.csv
```

## Key Differences from Original Design

| Aspect | Original FTL Design | AgnosticV Reality |
|--------|-------------------|-------------------|
| **User access** | Bastion with student SSH | Students have NO bastion access |
| **URLs** | Generic placeholders | Per-user namespaced routes |
| **Passwords** | Separate per service | Same `common_password` for all |
| **Multi-user** | User prefix on teams | Each user has separate AAP instance |
| **AAP Routes** | Single controller route | Gateway route + Controller route (AAP 2.6) |
| **Data source** | Environment variables | AgnosticD `agnosticd_user_data` lookup |
| **Deployment** | Manual copy | AgnosticV `post_software` phase |

## Implementation Checklist

- [ ] Update `lab.yml` to use `agnosticd_user_data` lookups
- [ ] Update grader playbooks to pull from userdata
- [ ] Update solver playbooks to pull from userdata
- [ ] Create `load_test_all_users.yml` for multi-user testing
- [ ] Create `ftl_env.sh.j2` template for bastion deployment
- [ ] Add `post_software` tasks to AgnosticV catalog
- [ ] Test single-user grading from bastion
- [ ] Test multi-user load testing from bastion
- [ ] Document for lab authors

## Usage Examples

**Single User Grading (as instructor on bastion):**

```bash
ssh lab-user@bastion.abc123.example.com

# Variables auto-set from /etc/profile.d/ftl_env.sh
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
ansible-playbook grade_lab.yml

# Output: /tmp/grading_dir/grading_report.txt
```

**Multi-User Load Test (before event with 30 students):**

```bash
ssh lab-user@bastion.abc123.example.com

cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom
ansible-playbook load_test_all_users.yml

# Runs 30 graders in parallel
# Results: /tmp/ftl_load_test/results.csv
#   user1,0,1738776543
#   user2,0,1738776545
#   user3,1,1738776550  # FAILED
#   ...
```

This integration aligns FTL with the actual AgnosticV deployment model!
