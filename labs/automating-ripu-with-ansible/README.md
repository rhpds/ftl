# Automating RHEL In-Place Upgrades — FTL Lab

Graders and solvers for the [RIPU workshop](https://github.com/rhpds/automating-ripu-with-ansible-showroom).

**Modules:** 3 | **Checkpoints:** 57 | **Type:** AAP 2.6 + RHEL bastion (no OCP for student exercises)

## Run

```bash
# Credentials — from Showroom → User tab / demo.redhat.com
export AAP_HOSTNAME="https://controller-xxx.apps.example.com"
export AAP_PASSWORD="<password>"
export AAP_USERNAME="lab-user"

# No oc login needed — AAP lab, not OCP

# Grade module 1 (expect FAIL — CaC not run)
grade_lab automating-ripu-with-ansible 1

# Solve module 1 (runs CaC → Lab Init → Analysis — ~15 min)
solve_lab automating-ripu-with-ansible 1
grade_lab automating-ripu-with-ansible 1   # expect SUCCESS

# Module 2 performs real RHEL upgrades (30-60 min)
solve_lab automating-ripu-with-ansible 2
grade_lab automating-ripu-with-ansible 2
```

**Expected on fresh environment:** Module 1 FAIL (CaC not run, no templates exist yet).

**After solver:** SUCCESS 0 Errors per module (57/57 total checkpoints)

> ⚠️  Module 2 performs actual RHEL upgrades on RHEL 7/8/9/10 nodes. Non-reversible without rollback.

## Showroom → Env Var Mapping

| Showroom attribute | Set this env var |
|---|---|
| `{controller_url}` | `AAP_HOSTNAME` |
| `{controller_password}` | `AAP_PASSWORD` |

## Modules

| Module | Description | Checkpoints |
|---|---|---|
| 1 | Pre-upgrade analysis — CaC, Lab Init, Leapp reports, pet app deploy | 26 |
| 2 | Upgrade execution — RHEL 7→8, 8→9, 9→10 upgrades via AAP | 26 |
| 3 | Post-upgrade validation — pet app accessibility, OS versions | 5 |

## Notes

- **AAP version:** 2.6 with gateway architecture — uses `/api/controller/v2/` endpoints
- **Lab Init template name:** `Ansible Leapp Lab initailization` (typo is in the actual AAP template created by CaC — match exactly)
- **Showroom repo:** https://github.com/rhpds/automating-ripu-with-ansible-showroom
