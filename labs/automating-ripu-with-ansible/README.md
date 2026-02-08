# FTL Lab: Automating RHEL In-Place Upgrades with Ansible

Automated grading and solving for the RIPU (RHEL In-Place Upgrade) workshop using Ansible Automation Platform.

## Lab Overview

This lab provides automated grading and solving for the [Automating RIPU with Ansible workshop](https://github.com/rhpds/automating-ripu-with-ansible-showroom). Students learn to automate RHEL in-place upgrades using Leapp and AAP across RHEL 7→8, 8→9, and 9→10.

**Workshop Repository:** https://github.com/rhpds/automating-ripu-with-ansible-showroom
**AgnosticV Catalog:** `openshift_cnv/automating-ripu-with-ansible`
**Total Checkpoints:** 13 (5 Module 1 + 5 Module 2 + 3 Module 3)

## Lab Structure

### Module 1: Pre-upgrade Analysis (5 checkpoints)
- AAP controller accessible and licensed
- CaC job completed (AAP configured)
- Lab initialization job completed
- Analysis job template configured
- Pre-upgrade analysis executed successfully

### Module 2: Upgrade Execution (5 checkpoints)
- Upgrade job template configured
- Upgrade workflow executed successfully
- node1 upgraded from RHEL 7 to RHEL 8
- node2 upgraded from RHEL 8 to RHEL 9
- node3 upgraded from RHEL 9 to RHEL 10

### Module 3: Rollback (3 checkpoints - currently disabled)
- Rollback job template configured
- Rollback job executed
- RHEL versions reverted back

**Note:** Module 3 rollback functionality is currently disabled because snapshots are not available in the lab environment. Graders/solvers are provided for completeness.

## Environment Setup

### Required Environment Variables

```bash
# AAP Controller connection
export AAP_HOSTNAME="https://controller-<guid>.<domain>"
export AAP_USERNAME="lab-user"  # Optional, defaults to lab-user
export AAP_PASSWORD="<password_from_user_data>"
```

### Setting Up Environment

1. **Get AAP hostname from user data:**
   ```bash
   cat ~/user_data.yaml | grep controller_url
   ```

2. **Get password from user data:**
   ```bash
   cat ~/user_data.yaml | grep password
   ```

3. **Set environment variables:**
   ```bash
   export AAP_HOSTNAME="https://controller-abc123.apps.example.com"
   export AAP_PASSWORD="Xy9aB_1"
   ```

## Grading

### Grade Individual Modules

```bash
# Module 1: Pre-upgrade Analysis
grade_lab automating-ripu-with-ansible 1

# Module 2: Upgrade Execution
grade_lab automating-ripu-with-ansible 2

# Module 3: Rollback (currently disabled)
grade_lab automating-ripu-with-ansible 3
```

### Grade Full Lab

```bash
grade_lab automating-ripu-with-ansible
```

### Direct Playbook Execution

```bash
cd ~/ftl/labs/automating-ripu-with-ansible

# Grade specific module
ansible-playbook grade_module_01.yml
ansible-playbook grade_module_02.yml
ansible-playbook grade_module_03.yml

# Grade full lab
ansible-playbook grade_lab.yml
```

## Solving

### Solve Individual Modules

```bash
# Module 1: Run CaC, lab init, and analysis jobs
solve_lab automating-ripu-with-ansible 1

# Module 2: Run upgrade workflow (WARNING: takes 30-60 minutes)
solve_lab automating-ripu-with-ansible 2

# Module 3: Run rollback job (currently disabled)
export ROLLBACK_NODE=node1
solve_lab automating-ripu-with-ansible 3
```

### Direct Playbook Execution

```bash
cd ~/ftl/labs/automating-ripu-with-ansible

# Solve Module 1
ansible-playbook solve_module_01.yml

# Solve Module 2 (with confirmation prompt)
ansible-playbook solve_module_02.yml

# Solve Module 3 (specify node to rollback)
export ROLLBACK_NODE=node1
ansible-playbook solve_module_03.yml
```

## Report Files

Per-module reports:
- `/tmp/grading_dir/grading_report_<user>_module_01.txt`
- `/tmp/grading_dir/grading_report_<user>_module_02.txt`
- `/tmp/grading_dir/grading_report_<user>_module_03.txt`

Full lab report:
- `/tmp/grading_dir/grading_report_<user>.txt`

View reports:
```bash
cat /tmp/grading_dir/grading_report_${USER}_module_01.txt
cat /tmp/grading_dir/grading_report_${USER}.txt
```

## Checkpoint Details

### Module 1 Checkpoints

| # | Checkpoint | Description |
|---|------------|-------------|
| 1.1 | AAP Licensed | Controller accessible with valid license |
| 1.2 | CaC Job Completed | Configuration as Code job configured AAP |
| 1.3 | Lab Init Completed | Lab initialization prepared nodes |
| 1.4 | Analysis Template | Pre-upgrade analysis job template exists |
| 1.5 | Analysis Executed | Leapp pre-upgrade reports generated |

### Module 2 Checkpoints

| # | Checkpoint | Description |
|---|------------|-------------|
| 2.1 | Upgrade Template | Upgrade workflow template configured |
| 2.2 | Upgrade Executed | Upgrade workflow completed successfully |
| 2.3 | Node1 Upgraded | RHEL 7 → 8 upgrade successful |
| 2.4 | Node2 Upgraded | RHEL 8 → 9 upgrade successful |
| 2.5 | Node3 Upgraded | RHEL 9 → 10 upgrade successful |

### Module 3 Checkpoints

| # | Checkpoint | Description |
|---|------------|-------------|
| 3.1 | Rollback Template | Rollback job template configured |
| 3.2 | Rollback Executed | Rollback job completed |
| 3.3 | Versions Reverted | RHEL versions rolled back |

## Testing Instructions

### Fresh Environment (Before Any Lab Work)

Expected: Module 1 checkpoints FAIL (AAP not configured yet)

```bash
export AAP_HOSTNAME="https://controller-abc123.example.com"
export AAP_PASSWORD="<password>"
grade_lab automating-ripu-with-ansible 1
# Expected: FAILED 5 Errors
```

### After Module 1 Solver

Expected: Module 1 PASS

```bash
solve_lab automating-ripu-with-ansible 1
grade_lab automating-ripu-with-ansible 1
# Expected: SUCCESS 0 Errors
```

### After Module 2 Solver

Expected: Module 1 and 2 PASS

```bash
solve_lab automating-ripu-with-ansible 2  # Takes 30-60 minutes
grade_lab automating-ripu-with-ansible
# Expected: Module 1 SUCCESS, Module 2 SUCCESS
```

### Manual Verification

```bash
# Check RHEL versions after upgrade
ssh node1  # Should show RHEL 8
cat /etc/redhat-release

ssh node2  # Should show RHEL 9
cat /etc/redhat-release

ssh node3  # Should show RHEL 10
cat /etc/redhat-release
```

## Troubleshooting

### AAP Connection Issues

```bash
# Test AAP API access
curl -k -u "${AAP_USERNAME}:${AAP_PASSWORD}" \
  "${AAP_HOSTNAME}/api/v2/ping/"

# Should return JSON with "instances" and "version"
```

### Job Template Not Found

```bash
# List all job templates
curl -k -u "${AAP_USERNAME}:${AAP_PASSWORD}" \
  "${AAP_HOSTNAME}/api/v2/job_templates/" | jq '.results[].name'

# Verify CaC job completed
curl -k -u "${AAP_USERNAME}:${AAP_PASSWORD}" \
  "${AAP_HOSTNAME}/api/v2/job_templates/?name=Z%20/%20CaC%20/%20Controller"
```

### Node SSH Access Issues

```bash
# Check inventory
ansible-inventory -i ~/ftl/labs/automating-ripu-with-ansible/inventory --list

# Test node connectivity
ansible nodes -i ~/ftl/labs/automating-ripu-with-ansible/inventory -m ping
```

## New Grader Roles Created

This lab introduced 3 new reusable grader roles:

1. **grader_check_http_endpoint** - Validates HTTP/HTTPS endpoints
   - Use case: Pet app accessibility, web services
   - Checks: HTTP status codes, SSL validation

2. **grader_check_aap_job_completed** - Validates AAP job template execution
   - Use case: Any AAP-based workshop
   - Checks: Template exists, job executed successfully

3. **grader_check_aap_licensed** - Validates AAP license
   - Use case: Any AAP-based workshop
   - Checks: Valid license or subscription installed

## Known Limitations

1. **Module 3 (Rollback):** Currently disabled because snapshots are not available in the lab environment. Will work when snapshots are re-enabled.

2. **Pet App Validation:** Optional exercise (1.6) not validated by graders. Can be added if needed.

3. **RHEL 10:** Workshop mentions RHEL 9→10 upgrades, but verification depends on RHEL 10 availability and Leapp support.

## Files

```
labs/automating-ripu-with-ansible/
├── README.md                   # This file
├── grade_lab.yml               # Full lab grader
├── grade_module_01.yml         # Module 1 grader
├── grade_module_02.yml         # Module 2 grader
├── grade_module_03.yml         # Module 3 grader
├── solve_module_01.yml         # Module 1 solver
├── solve_module_02.yml         # Module 2 solver
└── solve_module_03.yml         # Module 3 solver
```

## Development Notes

### Design Decisions

1. **AAP API-based validation** - Uses AAP REST API instead of awx CLI for better portability
2. **Modular design** - Each module has independent grader/solver
3. **Multi-version support** - Handles RHEL 7, 8, 9, and 10
4. **Generic roles** - AAP roles reusable across all AAP labs

### Future Enhancements

- [ ] Add Leapp report parsing to validate specific inhibitors resolved
- [ ] Add pet app deployment/validation checkpoints (optional exercise 1.6)
- [ ] Add custom pre-upgrade checks validation (exercise 1.5)
- [ ] Enable Module 3 when snapshots available
- [ ] Add HTML report generation

## References

- **Workshop Content:** https://github.com/rhpds/automating-ripu-with-ansible-showroom
- **Leapp Project:** https://github.com/rhpds/leapp-project
- **AgnosticV Catalog:** `~/work/code/agnosticv/openshift_cnv/automating-ripu-with-ansible/`
- **FTL Documentation:** `~/work/code/experiment/ftl/README.adoc`
