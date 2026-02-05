# AAP Self-Service Portal Introduction Lab

FTL (Finish The Labs) graders and solvers for the **Introduction to Ansible Automation Platform Self-Service Automation Portal** workshop.

## Lab Overview

This lab teaches students how to configure and use AAP Self-Service Portal with role-based access control (RBAC), user personas, and custom templates.

**Source:** https://github.com/rhpds/aap-selfserv-intro-showroom.git

## Modules

### Module 1: Configure AAP for Self-Service Portal
- Create teams in AAP (cloud-team, network-team, rhel-team)
- Assign users to teams
- Configure RBAC roles (job templates, inventories, credentials)
- Create Portal RBAC policies

**Checkpoints:**
- 3 teams created in AAP
- Users assigned to correct teams
- Role assignments for each team (execute, use permissions)
- Portal RBAC policies created (ssa-portal-users, saa-portal-rhel-team)

### Module 2: User Persona Testing
- Test Portal as clouduser1, networkuser1, rheluser1
- Execute job templates as different personas
- Validate RBAC correctly limits access

**Checkpoints:**
- Each user successfully executed their domain-specific job templates
- Jobs completed with status "successful"
- RBAC prevents unauthorized access

### Module 3: Surveys and Custom Templates
- Modify survey on "Linux/RHEL START Service" job template
- Synchronize changes to Portal
- Import custom dynamic template from Git
- Execute custom template

**Checkpoints:**
- Survey question "enable_service" added to job template
- Custom template "Manage RHEL Time Servers" imported
- Custom template executed successfully

## Environment Variables

Set these environment variables before running graders/solvers:

```bash
export AAP_CONTROLLER_URL="https://controller.example.com"
export AAP_ADMIN_PASSWORD="your-admin-password"
export SELF_SERVICE_PORTAL_URL="https://portal.example.com"
export GUID="your-guid"
```

## Usage

### Grade the Entire Lab

From bastion:
```bash
grade_lab aap-selfserv-intro-showroom
```

Or with ansible-playbook:
```bash
cd /opt/rhdp/ftl
ansible-playbook main.yml \
  -e purpose=grade_lab \
  -e lab_id=aap-selfserv-intro-showroom
```

### Grade Individual Modules

```bash
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Module 1 only
ansible-playbook grade_module_01.yml

# Module 2 only
ansible-playbook grade_module_02.yml

# Module 3 only
ansible-playbook grade_module_03.yml
```

### Solve the Entire Lab

From bastion:
```bash
solve_lab aap-selfserv-intro-showroom
```

Or with ansible-playbook:
```bash
cd /opt/rhdp/ftl
ansible-playbook main.yml \
  -e purpose=solve_lab \
  -e lab_id=aap-selfserv-intro-showroom
```

### Solve Individual Modules

```bash
cd /opt/rhdp/ftl/labs/aap-selfserv-intro-showroom

# Module 1 only (UI-based)
ansible-playbook solve_module_01_ui.yml

# Module 2 only
ansible-playbook solve_module_02.yml

# Module 3 only
ansible-playbook solve_module_03.yml
```

## Browser Automation

This lab uses **Playwright** for UI-based automation via the `solver_browser_action` role.

### Prerequisites

Install Playwright on bastion:
```bash
pip install playwright
playwright install chromium
```

### Headless Mode

By default, solvers run in headless mode (no GUI). To debug with visible browser:

```bash
# Edit solve_module_01_ui.yml and set:
headless: false
```

### Screenshots

To capture screenshots for debugging:
```bash
# Add to any browser action:
screenshot_path: "/tmp/debug_screenshot.png"
```

## File Structure

```
aap-selfserv-intro-showroom/
├── lab.yml                     # Lab metadata
├── README.md                   # This file
│
├── grade_lab.yml               # Main grading orchestrator
├── solve_lab.yml               # Main solving orchestrator
│
├── grade_module_01.yml         # Module 1 grader (CLI validation)
├── solve_module_01_ui.yml      # Module 1 solver (UI automation)
├── create_team_ui.yml          # Helper tasks for team creation
│
├── grade_module_02.yml         # Module 2 grader
├── solve_module_02.yml         # Module 2 solver
│
├── grade_module_03.yml         # Module 3 grader
└── solve_module_03.yml         # Module 3 solver
```

## Validation Strategy

### CLI Validation (Graders)
Graders use `awx` CLI and `curl` to validate outcomes:
- `awx teams list` - Verify teams exist
- `awx role_assignments list` - Verify RBAC roles
- `awx jobs list` - Verify job execution
- `curl` to Portal API - Verify Portal RBAC policies

### UI Automation (Solvers)
Solvers use Playwright browser automation to:
- Login to AAP Controller and Portal
- Click buttons, fill forms, navigate pages
- Create teams, assign roles, import templates
- Execute job templates as different users

## Testing

### Test Module 1 (RBAC Configuration)

```bash
# Solve Module 1
ansible-playbook solve_module_01_ui.yml

# Verify with grader
ansible-playbook grade_module_01.yml

# Expected: All 18 checks pass
```

### Test Module 2 (User Personas)

```bash
# Prerequisite: Module 1 must be complete

# Solve Module 2
ansible-playbook solve_module_02.yml

# Verify with grader
ansible-playbook grade_module_02.yml

# Expected: All 7 checks pass
```

### Test Module 3 (Surveys and Templates)

```bash
# Solve Module 3
ansible-playbook solve_module_03.yml

# Verify with grader
ansible-playbook grade_module_03.yml

# Expected: All 9 checks pass
```

## Integration with AgnosticV

This lab can be deployed via AgnosticV catalogs:

```yaml
# catalog/dev.yaml
post_software:
  - name: Deploy FTL to bastion
    ansible.builtin.copy:
      src: "{{ playbook_dir }}/ftl-labs/aap-selfserv-intro-showroom/"
      dest: "/opt/rhdp/ftl/labs/aap-selfserv-intro-showroom/"
    delegate_to: bastion

  - name: Set environment variables on bastion
    ansible.builtin.lineinfile:
      path: "/home/{{ ansible_user }}/.bashrc"
      line: "{{ item }}"
    loop:
      - "export AAP_CONTROLLER_URL={{ aap_controller_url }}"
      - "export AAP_ADMIN_PASSWORD={{ aap_admin_password }}"
      - "export SELF_SERVICE_PORTAL_URL={{ self_service_portal_url }}"
      - "export GUID={{ guid }}"
    delegate_to: bastion
```

## Troubleshooting

### Issue: Browser automation times out

**Solution:** Increase timeout in solver playbooks:
```yaml
timeout: 60000  # 60 seconds
```

### Issue: awx CLI commands fail with "unauthorized"

**Solution:** Verify environment variables are set correctly:
```bash
echo $AAP_CONTROLLER_URL
echo $AAP_ADMIN_PASSWORD
```

### Issue: Portal API validation fails

**Solution:** Portal API may require different authentication. Check Portal documentation for API access.

### Issue: Survey validation fails after adding question

**Solution:** Ensure survey is saved and job template is re-saved. Portal sync may take a few minutes.

## License

Apache-2.0

## Author

Red Hat Demo Platform
