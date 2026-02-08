# FTL Lab: Automating RHEL In-Place Upgrades with Ansible

Automated grading and solving for the RIPU (RHEL In-Place Upgrade) workshop using Ansible Automation Platform.

## Lab Overview

This lab provides automated grading and solving for the [Automating RIPU with Ansible workshop](https://github.com/rhpds/automating-ripu-with-ansible-showroom). Students learn to automate RHEL in-place upgrades using Leapp and AAP across RHEL 7→8, 8→9, and 9→10.

**Workshop Repository:** https://github.com/rhpds/automating-ripu-with-ansible-showroom
**AgnosticV Catalog:** `openshift_cnv/automating-ripu-with-ansible`
**Total Checkpoints:** 57 (26 Module 1 + 26 Module 2 + 5 Module 3)

## Lab Structure

### Module 1: Pre-upgrade Analysis (26 checkpoints across 6 exercises)

**Exercise 1.1: Workshop Lab Environment (3 checkpoints)**
- AAP controller accessible and licensed
- CaC job completed (AAP configured)
- Lab initialization job completed

**Exercise 1.2: Run Pre-upgrade Jobs (2 checkpoints)**
- Analysis job template configured
- Pre-upgrade analysis executed successfully

**Exercise 1.3: Review Pre-upgrade Reports (6 checkpoints - 2 per node)**
- Leapp report generated (node1, node2, node3)
- Leapp report contains risk analysis (node1, node2, node3)

**Exercise 1.4: Perform Recommended Remediation (3 checkpoints - 1 per node)**
- Leapp analysis re-run after remediation (node1, node2, node3)

**Exercise 1.5: Custom Pre-upgrade Checks (3 checkpoints - 1 per node)**
- Custom Leapp repositories directory exists (node1, node2, node3)

**Exercise 1.6: Deploy a Pet App (9 checkpoints - 3 per node)**
- Pet app database (MariaDB) running (node1, node2, node3)
- Pet application process running (node1, node2, node3)
- Pet app reboot cron configured (node1, node2, node3)

### Module 2: Upgrade Execution (26 checkpoints across 4 exercises)

**Exercise 2.1: Run OS Upgrade Jobs (2 checkpoints)**
- Upgrade workflow template configured
- Upgrade workflow executed successfully

**Exercise 2.2: Let's Talk About Snapshots (3 checkpoints - 1 per node)**
- Leapp log directory exists (evidence of upgrade) (node1, node2, node3)

**Exercise 2.3: Check if the Upgrade Worked (12 checkpoints - 4 per node)**
- node1 upgraded from RHEL 7 to RHEL 8
- node2 upgraded from RHEL 8 to RHEL 9
- node3 upgraded from RHEL 9 to RHEL 10
- System booted successfully post-upgrade (node1, node2, node3)

**Exercise 2.4: How is the Pet App Doing (9 checkpoints - 3 per node)**
- Pet app database running post-upgrade (node1, node2, node3)
- Pet application running post-upgrade (node1, node2, node3)
- Pet app database accessible post-upgrade (node1, node2, node3)

### Module 3: Rollback (5 checkpoints - currently disabled)

**Exercise 3.2: Run Rollback Job (2 checkpoints)**
- Rollback job template configured
- Rollback job executed

**Exercise 3.3: Check if Upgrade Undone (3 checkpoints - 1 per node)**
- RHEL versions reverted back (node1, node2, node3)

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
# Module 1: Pre-upgrade Analysis (26 checkpoints)
grade_lab automating-ripu-with-ansible 1

# Module 2: Upgrade Execution (26 checkpoints)
grade_lab automating-ripu-with-ansible 2

# Module 3: Rollback (5 checkpoints - currently disabled)
grade_lab automating-ripu-with-ansible 3
```

### Grade Full Lab

```bash
# All modules (57 checkpoints total)
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
# Module 1: Run CaC, lab init, analysis, and pet app install
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

### Module 1 Checkpoints (26 total)

| Exercise | Checkpoint | Per Node | Total | Description |
|----------|------------|----------|-------|-------------|
| 1.1 | AAP Licensed | No | 1 | Controller accessible with valid license |
| 1.1 | CaC Completed | No | 1 | Configuration as Code job configured AAP |
| 1.1 | Lab Init | No | 1 | Lab initialization prepared nodes |
| 1.2 | Analysis Template | No | 1 | Pre-upgrade analysis job template exists |
| 1.2 | Analysis Executed | No | 1 | Leapp pre-upgrade reports generated |
| 1.3 | Report Exists | Yes × 3 | 3 | Leapp report file exists |
| 1.3 | Report Has Risks | Yes × 3 | 3 | Report contains risk analysis |
| 1.4 | Report Updated | Yes × 3 | 3 | Analysis re-run after remediation |
| 1.5 | Custom Repos | Yes × 3 | 3 | Custom Leapp repos directory exists |
| 1.6 | MariaDB Running | Yes × 3 | 3 | Pet app database running |
| 1.6 | App Running | Yes × 3 | 3 | Pet application process running |
| 1.6 | Cron Configured | Yes × 3 | 3 | Reboot cron entry configured |

**Module 1 Total:** 5 + 6 + 3 + 3 + 9 = **26 checkpoints**

### Module 2 Checkpoints (26 total)

| Exercise | Checkpoint | Per Node | Total | Description |
|----------|------------|----------|-------|-------------|
| 2.1 | Upgrade Template | No | 1 | Upgrade workflow template configured |
| 2.1 | Upgrade Executed | No | 1 | Upgrade workflow completed successfully |
| 2.2 | Leapp Logs | Yes × 3 | 3 | Leapp log directory exists |
| 2.3 | node1 → RHEL 8 | node1 | 1 | RHEL 7 → 8 upgrade successful |
| 2.3 | node2 → RHEL 9 | node2 | 1 | RHEL 8 → 9 upgrade successful |
| 2.3 | node3 → RHEL 10 | node3 | 1 | RHEL 9 → 10 upgrade successful |
| 2.3 | Booted Successfully | Yes × 3 | 3 | System booted post-upgrade |
| 2.4 | MariaDB Post-upgrade | Yes × 3 | 3 | Database running after upgrade |
| 2.4 | App Post-upgrade | Yes × 3 | 3 | Pet app running after upgrade |
| 2.4 | Database Accessible | Yes × 3 | 3 | Pet app database accessible |

**Module 2 Total:** 2 + 3 + 12 + 9 = **26 checkpoints**

### Module 3 Checkpoints (5 total - currently disabled)

| Exercise | Checkpoint | Per Node | Total | Description |
|----------|------------|----------|-------|-------------|
| 3.2 | Rollback Template | No | 1 | Rollback job template configured |
| 3.2 | Rollback Executed | No | 1 | Rollback job completed |
| 3.3 | node1 Reverted | node1 | 1 | RHEL 8 → 7 rollback successful |
| 3.3 | node2 Reverted | node2 | 1 | RHEL 9 → 8 rollback successful |
| 3.3 | node3 Reverted | node3 | 1 | RHEL 10 → 9 rollback successful |

**Module 3 Total:** 2 + 3 = **5 checkpoints**

## Testing Instructions

### Fresh Environment (Before Any Lab Work)

Expected: Module 1 checkpoints FAIL (AAP not configured yet)

```bash
export AAP_HOSTNAME="https://controller-abc123.example.com"
export AAP_PASSWORD="<password>"
grade_lab automating-ripu-with-ansible 1
# Expected: FAILED 26 Errors
```

### After Module 1 Solver

Expected: Module 1 PASS (except possibly some remediation/custom checks)

```bash
solve_lab automating-ripu-with-ansible 1
grade_lab automating-ripu-with-ansible 1
# Expected: SUCCESS or minimal failures
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
ssh node1
cat /etc/redhat-release  # Should show RHEL 8

ssh node2
cat /etc/redhat-release  # Should show RHEL 9

ssh node3
cat /etc/redhat-release  # Should show RHEL 10 (or 9 if not available)

# Check pet app
pgrep -f spring-petclinic  # Should show process ID
curl localhost:8080  # Should return HTML
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

### Pet App Not Running

```bash
# Check MariaDB
systemctl status mariadb

# Check pet app process
pgrep -f spring-petclinic

# Check cron entry
crontab -l | grep petclinic

# Check app logs
tail -f ~/app.log
```

## New Grader Roles Created

This lab introduced 4 new reusable grader roles:

1. **grader_check_http_endpoint** - Validates HTTP/HTTPS endpoints
   - Use case: Pet app accessibility, web services
   - Checks: HTTP status codes, SSL validation

2. **grader_check_aap_job_completed** - Validates AAP job template execution
   - Use case: Any AAP-based workshop
   - Checks: Template exists, job executed successfully

3. **grader_check_aap_licensed** - Validates AAP license
   - Use case: Any AAP-based workshop
   - Checks: Valid license or subscription installed

4. **grader_check_file_contains** - Validates file existence and content
   - Use case: Leapp reports, cron entries, configuration files
   - Checks: File exists, exact content match, regex pattern match

## Known Limitations

1. **Module 3 (Rollback):** Currently disabled because snapshots are not available in the lab environment. Will work when snapshots are re-enabled.

2. **RHEL 10:** Workshop mentions RHEL 9→10 upgrades, but verification depends on RHEL 10 availability and Leapp support. Grader accepts RHEL 9 or 10 for node3.

3. **Custom Remediation:** Exercise 1.4 validates that analysis was re-run, but specific remediation steps vary by environment.

4. **Pet App Optional:** Exercises 1.6 and 2.4 are technically optional, but recommended for full lab experience.

## Files

```
labs/automating-ripu-with-ansible/
├── README.md                   # This file
├── ansible.cfg                 # Ansible configuration
├── inventory                   # Node inventory file
├── grade_lab.yml               # Full lab grader (57 checkpoints)
├── grade_module_01.yml         # Module 1 grader (26 checkpoints)
├── grade_module_02.yml         # Module 2 grader (26 checkpoints)
├── grade_module_03.yml         # Module 3 grader (5 checkpoints)
├── solve_module_01.yml         # Module 1 solver
├── solve_module_02.yml         # Module 2 solver
└── solve_module_03.yml         # Module 3 solver
```

## Development Notes

### Design Decisions

1. **Comprehensive Coverage** - All 14 workshop exercises validated with 57 total checkpoints
2. **Per-Node Validation** - Most checks run on all 3 nodes for thorough coverage
3. **AAP API-based** - Uses AAP REST API instead of awx CLI for better portability
4. **Modular Design** - Each module has independent grader/solver
5. **Multi-Version Support** - Handles RHEL 7, 8, 9, and 10
6. **Generic Roles** - All AAP roles reusable across any AAP lab

### Future Enhancements

- [x] Add Leapp report validation (Exercise 1.3)
- [x] Add remediation validation (Exercise 1.4)
- [x] Add custom modules validation (Exercise 1.5)
- [x] Add pet app deployment/validation (Exercises 1.6, 2.4)
- [x] Add snapshot/upgrade evidence checks (Exercise 2.2)
- [ ] Parse Leapp reports for specific inhibitors resolved
- [ ] Enable Module 3 when snapshots available
- [ ] Add HTML report generation

## References

- **Workshop Content:** https://github.com/rhpds/automating-ripu-with-ansible-showroom
- **Leapp Project:** https://github.com/rhpds/leapp-project
- **AgnosticV Catalog:** `~/work/code/agnosticv/openshift_cnv/automating-ripu-with-ansible/`
- **FTL Documentation:** `~/work/code/experiment/ftl/README.adoc`
