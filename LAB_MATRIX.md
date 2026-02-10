# FTL Lab Matrix - At-a-Glance View

**Framework:** FTL (Finish The Labs)
**Date:** 2026-02-10

---

## Lab Overview Matrix

| Lab Name | ID | Modules | Checkpoints | Status | Multi-User | README Grade |
|----------|----|---------:|------------:|--------|------------|--------------|
| Automating RIPU with Ansible | `automating-ripu-with-ansible` | 3 | 57 | ✓ Production | No | A+ (492L) |
| MCP with OpenShift | `mcp-with-openshift` | 4 | 35 | ✓ Production | Yes | A (465L) |
| OpenShift 4 Getting Started | `ocp4-getting-started` | 3 | ~32 | ✓ Production | Yes | A+ (507L) |
| AAP Self-Service Intro | `aap-selfserv-intro-showroom` | 3 | ~23 | WIP | TBD | B+ (282L) |

---

## Module Breakdown by Lab

### Lab 1: Automating RIPU with Ansible (57 checkpoints)

| Module | Exercise Count | Checkpoints | Key Technologies |
|--------|---------------:|------------:|------------------|
| Module 1: Pre-upgrade Analysis | 6 | 26 | AAP, Leapp, MariaDB, Pet App |
| Module 2: Upgrade Execution | 4 | 26 | RHEL 7→8→9→10, Leapp, AAP Workflows |
| Module 3: Rollback (disabled) | 2 | 5 | Snapshots, Rollback Jobs |

### Lab 2: MCP with OpenShift (35 checkpoints)

| Module | Exercise Count | Checkpoints | Key Technologies |
|--------|---------------:|------------:|------------------|
| Module 1: Lab Setup | 5 | 6 | LibreChat, MCP Servers, Gitea |
| Module 2: SRE Agent Demo | 9 | 9 | Tekton, MCP Protocol, Issue Tracking |
| Module 3: MCP Administration | 11 | 11 | Tool Filtering, Prometheus, Metrics |
| Module 4: MCP Registry | 9 | 9 | PostgreSQL, CNPG, Registry API |

### Lab 3: OpenShift 4 Getting Started (~32 checkpoints)

| Module | Exercise Count | Checkpoints | Key Technologies |
|--------|---------------:|------------:|------------------|
| Module 1: Deploy and Manage Apps | 5 | ~11 | Container Images, Scaling, Routes |
| Module 2: Build from Source | 5 | ~16 | S2I, MongoDB, Health Probes |
| Module 3: CI/CD Pipelines | 4 | ~5 | Tekton, Webhooks, PVC |

### Lab 4: AAP Self-Service (WIP) (~23 checkpoints)

| Module | Exercise Count | Checkpoints | Key Technologies |
|--------|---------------:|------------:|------------------|
| Module 1: Configure AAP | Multiple | ~11 | AAP Teams, RBAC, Portal Policies |
| Module 2: User Personas | Multiple | ~7 | Job Templates, RBAC Testing |
| Module 3: Surveys & Templates | Multiple | ~5 | Surveys, Dynamic Templates |

---

## Technology Coverage Matrix

| Technology | RIPU | MCP | OCP4 | AAP (WIP) |
|------------|:----:|:---:|:----:|:---------:|
| **Platforms** |
| OpenShift 4.x | - | ✓ | ✓ | - |
| AAP 2.6 | ✓ | - | - | ✓ |
| RHEL 7-10 | ✓ | - | - | - |
| **Databases** |
| MariaDB | ✓ | - | - | - |
| PostgreSQL | - | ✓ | - | - |
| MongoDB | - | - | ✓ | - |
| **CI/CD** |
| Tekton Pipelines | - | ✓ | ✓ | - |
| AAP Workflows | ✓ | - | - | - |
| **Build Strategies** |
| S2I Builds | - | - | ✓ | - |
| Container Images | - | - | ✓ | - |
| Leapp Upgrades | ✓ | - | - | - |
| **Operators** |
| ToolHive | - | ✓ | - | - |
| CloudNativePG | - | ✓ | - | - |
| **Monitoring** |
| Prometheus | - | ✓ | - | - |
| ServiceMonitor | - | ✓ | - | - |
| **Special Features** |
| MCP Protocol | - | ✓ | - | - |
| Browser Automation | - | - | - | ✓ |

---

## Playbook Inventory

| Lab | grade_lab.yml | grade_module_*.yml | solve_module_*.yml | Other | Total |
|-----|:-------------:|:------------------:|:------------------:|:-----:|:-----:|
| RIPU | ✓ | 3 | 3 | inventory, ansible.cfg | 7 |
| MCP | ✓ | 4 | 4 | solve_lab.yml, lab.yml | 11 |
| OCP4 | ✓ | 3 | 3 | CHECKPOINT_MAPPING.md | 8 |
| AAP (WIP) | ✓ | 4 | 5 | test_*.yml (many) | 58 |

---

## Grader Role Usage Matrix

### AAP-Specific Roles

| Role | RIPU | MCP | OCP4 | AAP |
|------|:----:|:---:|:----:|:---:|
| `grader_check_aap_licensed` | ✓ | - | - | ✓ |
| `grader_check_aap_job_completed` | ✓ | - | - | ✓ |

### OpenShift-Specific Roles

| Role | RIPU | MCP | OCP4 | AAP |
|------|:----:|:---:|:----:|:---:|
| `grader_check_ocp_resource` | - | ✓ | ✓ | - |
| `grader_check_ocp_pod_running` | - | ✓ | ✓ | - |
| `grader_check_ocp_route_exists` | - | ✓ | ✓ | - |
| `grader_check_ocp_build_completed` | - | - | ✓ | - |
| `grader_check_ocp_secret_exists` | - | - | ✓ | - |
| `grader_check_ocp_configmap_exists` | - | - | ✓ | - |
| `grader_check_ocp_pvc_exists` | - | - | ✓ | - |
| `grader_check_ocp_pipeline_run` | - | ✓ | ✓ | - |

### Generic Roles

| Role | RIPU | MCP | OCP4 | AAP |
|------|:----:|:---:|:----:|:---:|
| `grader_check_command_output` | ✓ | ✓ | ✓ | ✓ |
| `grader_check_service_running` | ✓ | - | - | - |
| `grader_check_file_exists` | ✓ | - | - | - |
| `grader_check_file_contains` | ✓ | - | - | - |
| `grader_check_http_endpoint` | ✓ | - | - | - |
| `grader_check_http_json_response` | - | - | ✓ | - |

---

## Environment Variables Comparison

| Variable | RIPU | MCP | OCP4 | AAP (WIP) |
|----------|------|-----|------|-----------|
| **AAP/Controller** |
| AAP_HOSTNAME | ✓ Required | - | - | - |
| AAP_PASSWORD | ✓ Required | - | - | - |
| AAP_USERNAME | Optional (lab-user) | - | - | - |
| AAP_CONTROLLER_URL | - | - | - | ✓ Required |
| AAP_ADMIN_PASSWORD | - | - | - | ✓ Required |
| **OpenShift** |
| OPENSHIFT_CLUSTER_INGRESS_DOMAIN | - | ✓ Required | ✓ Required | - |
| PROJECT_NAME | - | - | ✓ Required | - |
| **User Identification** |
| LAB_USER | Auto-set | Auto-set | Auto-set | - |
| GUID | - | Auto-detect | Auto-detect | ✓ Required |
| **Passwords** |
| PASSWORD | - | ✓ Required | - | - |
| **Optional/Advanced** |
| MCP_OPENSHIFT_NAMESPACE | - | Optional | - | - |
| MCP_GITEA_NAMESPACE | - | Optional | - | - |
| LIBRECHAT_NAMESPACE | - | Optional | - | - |
| GITEA_URL | - | Optional | - | - |
| SELF_SERVICE_PORTAL_URL | - | - | - | ✓ Required |

---

## Pattern Compliance Checklist

| Pattern | RIPU | MCP | OCP4 | AAP | Overall |
|---------|:----:|:---:|:----:|:---:|:-------:|
| **Playbook Structure** |
| 3-play pattern (init/grade/finalize) | ✓ (4-play) | ✓ | ✓ | TBD | 100% |
| grader_student_report_file in ALL plays | ✓ | ✓ | ✓ | TBD | 100% |
| **Validation** |
| Environment variable validation | ✓ | ✓ | ✓ | TBD | 100% |
| Clear error messages | ✓ | ✓ | ✓ | TBD | 100% |
| Actionable hints | ✓ | ✓ | ✓ | TBD | 100% |
| **Labeling** |
| Exercise X.X checkpoint format | ✓ | ✓ | ✓ | TBD | 100% |
| task_description_message | ✓ | ✓ | ✓ | TBD | 100% |
| student_error_message | ✓ | ✓ | ✓ | TBD | 100% |
| **Documentation** |
| README.md present | ✓ | ✓ | ✓ | ✓ | 100% |
| Checkpoint tables | ✓ | ✓ | Partial | - | 67% |
| Environment setup guide | ✓ | ✓ | ✓ | ✓ | 100% |
| Troubleshooting section | ✓ | ✓ | ✓ | ✓ | 100% |
| **Multi-User** |
| Multi-user architecture | N/A | ✓ | ✓ | TBD | 100% (where applicable) |
| Per-user reports | ✓ | ✓ | ✓ | TBD | 100% |
| Namespace/project isolation | N/A | ✓ | ✓ | TBD | 100% (where applicable) |

---

## Quality Score Card

| Metric | RIPU | MCP | OCP4 | AAP (WIP) | Framework Avg |
|--------|:----:|:---:|:----:|:---------:|:-------------:|
| **Documentation** | A+ | A | A+ | B+ | A |
| **Pattern Compliance** | A+ | A+ | A+ | TBD | A+ |
| **Multi-User Support** | N/A | A+ | A+ | TBD | A+ |
| **Error Handling** | A+ | A | A | TBD | A |
| **Checkpoint Coverage** | A+ | A+ | A | TBD | A+ |
| **Code Quality** | A | A | A | B | A |
| **Testing** | Manual | Manual | Manual | Manual | Manual |
| **Overall Grade** | **A+** | **A** | **A+** | **B+** | **A** |

---

## Production Readiness Status

| Lab | Feature Complete | Documented | Tested | Multi-User Ready | Production Status |
|-----|:----------------:|:----------:|:------:|:----------------:|:-----------------:|
| RIPU | ✓ | ✓ | Manual | N/A | ✓ READY |
| MCP | ✓ | ✓ | Manual | ✓ | ✓ READY |
| OCP4 | ✓ | ✓ | Manual | ✓ | ✓ READY |
| AAP (WIP) | ✓ | Partial | Manual | TBD | ⚠ NOT READY |

---

## Framework Health Indicators

| Indicator | Value | Status | Target |
|-----------|-------|--------|--------|
| Production Labs | 3 | ✓ Good | 3+ |
| Total Checkpoints | 124 | ✓ Excellent | 100+ |
| Pattern Compliance | 100% | ✓ Excellent | 95%+ |
| Documentation Quality | A | ✓ Excellent | B+ or higher |
| Reusable Roles | 10+ | ✓ Excellent | 10+ |
| Multi-User Labs | 2/3 | ✓ Good | 50%+ |
| README Lines (avg) | 488 | ✓ Excellent | 300+ |

**Overall Framework Health: EXCELLENT** ✓

---

## Next Lab Candidates

Based on framework maturity and reusable components, these labs would be good additions:

### High Priority (Components Available)
1. **AAP Self-Service Portal** (WIP → Production)
   - Existing: 3 modules, ~23 checkpoints, browser automation
   - Needs: Cleanup, finalize documentation
   - Reusable roles: AAP roles already exist

2. **OpenShift Service Mesh** (New)
   - Existing components: OCP grader roles
   - Technology fit: Istio, Kiali, Jaeger
   - Multi-user: Yes (namespace isolation)

3. **RHEL System Administration** (New)
   - Existing components: Service, file, command grader roles
   - Technology fit: systemd, firewalld, SELinux
   - Multi-user: No (single system)

### Medium Priority (Partial Components)
4. **Ansible Automation Platform Advanced** (New)
   - Existing components: AAP grader roles
   - Technology fit: Workflows, inventories, surveys
   - Multi-user: No (AAP instance)

5. **OpenShift GitOps** (New)
   - Existing components: OCP grader roles
   - Technology fit: ArgoCD, GitOps patterns
   - Multi-user: Yes (namespace isolation)

### Long-Term (New Components Needed)
6. **Red Hat Build of Quarkus** (New)
   - New components: Quarkus-specific roles
   - Technology fit: Native builds, dev mode
   - Multi-user: Yes (project isolation)

7. **OpenShift Virtualization** (New)
   - New components: VM-specific grader roles
   - Technology fit: KubeVirt, VMs, migrations
   - Multi-user: Yes (namespace isolation)

---

## Legend

**Status Indicators:**
- ✓ = Complete/Present/Passing
- ⚠ = In Progress/Warning
- - = Not Applicable
- TBD = To Be Determined

**Grades:**
- A+ = Excellent (95-100%)
- A = Very Good (90-94%)
- B+ = Good (85-89%)
- B = Satisfactory (80-84%)

---

**Document Version:** 1.0
**Created:** 2026-02-10
**Last Updated:** 2026-02-10
