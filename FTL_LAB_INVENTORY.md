# FTL Framework - Comprehensive Lab Inventory

**Date:** 2026-02-10
**Framework Version:** FTL (Finish The Labs) - Red Hat Demo Platform
**Total Production Labs:** 3 active + 1 WIP

---

## Executive Summary

The FTL framework currently contains **3 production-ready labs** covering RHEL upgrades, Model Context Protocol (MCP), and OpenShift fundamentals. All labs follow consistent patterns with automated grading and solving capabilities.

**Total Framework Statistics:**
- **Total Production Labs:** 3
- **Total Modules:** 10 (3 + 4 + 3)
- **Total Checkpoints:** ~122 (57 + 35 + ~30)
- **Total Grader Playbooks:** 13 (4 + 5 + 4)
- **Total Solver Playbooks:** 10 (3 + 5 + 3, excluding WIP)

---

## Lab-by-Lab Breakdown

### 1. Automating RIPU with Ansible

**Lab ID:** `automating-ripu-with-ansible`
**Workshop Repository:** https://github.com/rhpds/automating-ripu-with-ansible-showroom
**AgnosticV Catalog:** `openshift_cnv/automating-ripu-with-ansible`
**Status:** Production Ready

#### Module Structure

| Module | Description | Checkpoints | Grader | Solver |
|--------|-------------|-------------|--------|--------|
| Module 1 | Pre-upgrade Analysis | 26 | ✓ | ✓ |
| Module 2 | Upgrade Execution | 26 | ✓ | ✓ |
| Module 3 | Rollback (disabled) | 5 | ✓ | ✓ |
| **Total** | | **57** | **4** | **3** |

#### Checkpoint Distribution

**Module 1: Pre-upgrade Analysis (26 checkpoints)**
- Exercise 1.1: Workshop Lab Environment (3 checkpoints)
  - AAP controller accessible and licensed
  - CaC job completed
  - Lab initialization job completed
- Exercise 1.2: Run Pre-upgrade Jobs (2 checkpoints)
  - Analysis job template configured
  - Pre-upgrade analysis executed
- Exercise 1.3: Review Pre-upgrade Reports (6 checkpoints - 2 per node × 3 nodes)
  - Leapp report generated (node1, node2, node3)
  - Leapp report contains risk analysis (node1, node2, node3)
- Exercise 1.4: Remediation (3 checkpoints - 1 per node × 3 nodes)
  - Leapp analysis re-run after remediation
- Exercise 1.5: Custom Pre-upgrade Checks (3 checkpoints - 1 per node × 3 nodes)
  - Custom Leapp repositories directory exists
- Exercise 1.6: Deploy Pet App (9 checkpoints - 3 per node × 3 nodes)
  - Pet app database (MariaDB) running
  - Pet application process running
  - Pet app reboot cron configured

**Module 2: Upgrade Execution (26 checkpoints)**
- Exercise 2.1: Run OS Upgrade Jobs (2 checkpoints)
  - Upgrade workflow template configured
  - Upgrade workflow executed
- Exercise 2.2: Snapshots (3 checkpoints - 1 per node × 3 nodes)
  - Leapp log directory exists (evidence of upgrade)
- Exercise 2.3: Check Upgrade Success (12 checkpoints - 4 per node × 3 nodes)
  - node1 upgraded from RHEL 7 to RHEL 8
  - node2 upgraded from RHEL 8 to RHEL 9
  - node3 upgraded from RHEL 9 to RHEL 10
  - System booted successfully post-upgrade (all nodes)
- Exercise 2.4: Pet App Post-Upgrade (9 checkpoints - 3 per node × 3 nodes)
  - Pet app database running post-upgrade
  - Pet application running post-upgrade
  - Pet app database accessible post-upgrade

**Module 3: Rollback (5 checkpoints - currently disabled)**
- Exercise 3.2: Run Rollback Job (2 checkpoints)
  - Rollback job template configured
  - Rollback job executed
- Exercise 3.3: Check Rollback Success (3 checkpoints - 1 per node × 3 nodes)
  - RHEL versions reverted back

#### Technology Stack

- **Automation Platform:** Ansible Automation Platform 2.6
- **Operating Systems:** RHEL 7, 8, 9, 10
- **Upgrade Framework:** Leapp
- **Infrastructure:** OpenShift Virtualization (CNV)
- **Database:** MariaDB
- **Application:** Spring PetClinic
- **API:** AAP Controller REST API (`/api/controller/v2/`, `/api/gateway/v1/`)

#### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| AAP_HOSTNAME | Yes | - | AAP controller URL |
| AAP_PASSWORD | Yes | - | AAP admin/lab-user password |
| AAP_USERNAME | No | lab-user | AAP username |

#### Playbook Files

```
labs/automating-ripu-with-ansible/
├── grade_lab.yml               # Full lab orchestrator (57 checkpoints)
├── grade_module_01.yml         # Module 1 grader (26 checkpoints)
├── grade_module_02.yml         # Module 2 grader (26 checkpoints)
├── grade_module_03.yml         # Module 3 grader (5 checkpoints)
├── solve_module_01.yml         # Module 1 solver
├── solve_module_02.yml         # Module 2 solver
├── solve_module_03.yml         # Module 3 solver
├── inventory                   # Node inventory (node1, node2, node3)
├── ansible.cfg                 # Ansible configuration
└── README.md                   # Lab documentation (492 lines)
```

#### Play Structure Validation

**Module 1 (4 plays):**
1. Initialize FTL Grading Session
2. Grade Module 1 - AAP Configuration (localhost tasks)
3. Grade Module 1 - Node Validation (remote node tasks)
4. Finalize FTL Grading Session

**grader_student_report_file:** Present in ALL 4 plays ✓

#### README Quality Assessment

**Grade: A+ (Excellent)**
- 492 lines of comprehensive documentation
- Detailed checkpoint mapping with tables
- Environment setup instructions with examples
- Troubleshooting section for AAP 2.6 API changes
- Testing instructions for fresh environments
- Manual verification commands
- AgnosticV integration notes
- Known limitations documented
- Development notes and design decisions

#### New Grader Roles Created

This lab introduced 4 reusable grader roles:
1. `grader_check_http_endpoint` - HTTP/HTTPS endpoint validation
2. `grader_check_aap_job_completed` - AAP job template execution
3. `grader_check_aap_licensed` - AAP license validation
4. `grader_check_file_contains` - File existence and content validation

---

### 2. Model Context Protocol (MCP) with OpenShift

**Lab ID:** `mcp-with-openshift`
**Workshop Repository:** https://github.com/rhpds/lb1726-mcp-showroom
**AgnosticV Catalog:** TBD
**Status:** Production Ready

#### Module Structure

| Module | Description | Checkpoints | Grader | Solver |
|--------|-------------|-------------|--------|--------|
| Module 1 | Lab Setup | 6 | ✓ | ✓ |
| Module 2 | Sovereign SRE Agent Demo | 9 | ✓ | ✓ |
| Module 3 | MCP Server Administration | 11 | ✓ | ✓ |
| Module 4 | MCP Registry | 9 | ✓ | ✓ |
| **Total** | | **35** | **5** | **5** |

#### Checkpoint Distribution

**Module 1: Lab Setup (6 checkpoints)**
- Exercise 1.1: OpenShift Console Login (1 checkpoint)
  - OpenShift Console accessible
- Exercise 1.2: LibreChat (3 checkpoints)
  - LibreChat pod running
  - LibreChat route exists
  - LibreChat UI accessible
- Exercise 1.3: MCP OpenShift Server (1 checkpoint)
  - MCP OpenShift Server pod running
- Exercise 1.4: MCP Gitea Server (1 checkpoint)
  - MCP Gitea Server pod running

**Module 2: Sovereign SRE Agent Demo (9 checkpoints)**
- Exercise 2.1: Agent Infrastructure (1 checkpoint)
  - Agent pod running
- Exercise 2.2: Agent MCP Connectivity (1 checkpoint)
  - Agent connected to both MCP servers
- Exercise 2.3: Pipeline Infrastructure (1 checkpoint)
  - build-agent pipeline exists
- Exercise 2.4: Pipeline Run Triggered (1 checkpoint)
  - Pipeline run with GIT_REVISION=broken parameter
- Exercise 2.5: Pipeline Failure (1 checkpoint)
  - Pipeline run failed as expected
- Exercise 2.6: Trigger-Agent Finally Task (1 checkpoint)
  - trigger-agent finally task executed
- Exercise 2.7: Agent Investigation (1 checkpoint)
  - Agent investigated failure (logs show analysis)
- Exercise 2.8: Gitea Issue Creation (1 checkpoint)
  - Gitea issue created by agent
- Exercise 2.9: LibreChat Queries (1 checkpoint)
  - LibreChat accessible for infrastructure queries

**Module 3: MCP Server Administration (11 checkpoints)**
- Tool Filtering (2 checkpoints)
  - Exercise 3.1: MCPToolConfig resource created
  - Exercise 3.2: Tool filter allowlist configured
- Telemetry and Observability (3 checkpoints)
  - Exercise 3.3: Prometheus telemetry enabled
  - Exercise 3.4: ServiceMonitor resource created
  - Exercise 3.5: Metrics endpoint accessible
- Fetch MCP Server (3 checkpoints)
  - Exercise 3.6: Fetch MCPServer resource created
  - Exercise 3.7: Fetch server pod running
  - Exercise 3.8: Fetch server route exists
- Yardstick MCP Server (3 checkpoints)
  - Exercise 3.9: Yardstick MCPServer resource created
  - Exercise 3.10: Yardstick server pod running
  - Exercise 3.11: Yardstick server route exists

**Module 4: MCP Registry (9 checkpoints)**
- PostgreSQL Backend (2 checkpoints)
  - Exercise 4.1: PostgreSQL Cluster CR created (CNPG)
  - Exercise 4.2: PostgreSQL pod running
- Server Catalog and Secrets (2 checkpoints)
  - Exercise 4.3: Server catalog ConfigMap created
  - Exercise 4.4: Registry database secret exists
- Registry Deployment (5 checkpoints)
  - Exercise 4.5: MCPRegistry CR created
  - Exercise 4.6: Registry pod running
  - Exercise 4.7: Registry route exists
  - Exercise 4.8: Registry API accessible
  - Exercise 4.9: MCP servers registered (at least 2)

#### Technology Stack

- **Platform:** OpenShift 4.x
- **MCP Infrastructure:** ToolHive Operator
- **Database:** PostgreSQL (CloudNativePG)
- **CI/CD:** Tekton Pipelines
- **Monitoring:** Prometheus, ServiceMonitor
- **AI Interface:** LibreChat
- **Version Control:** Gitea
- **Protocols:** MCP (SSE, streamable HTTP, stdio transports)

#### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| OPENSHIFT_CLUSTER_INGRESS_DOMAIN | Yes | - | Cluster ingress domain |
| PASSWORD | Yes | - | User password from AgV user data |
| LAB_USER | Auto-set | user1 | Username (for multi-user grading) |
| MCP_OPENSHIFT_NAMESPACE | No | mcp-openshift-{user} | MCP OpenShift namespace |
| MCP_GITEA_NAMESPACE | No | mcp-gitea-{user} | MCP Gitea namespace |
| LIBRECHAT_NAMESPACE | No | librechat-{user} | LibreChat namespace |
| GITEA_URL | No | https://gitea.{domain} | Gitea URL |

#### Playbook Files

```
labs/mcp-with-openshift/
├── grade_lab.yml               # Full lab orchestrator (35 checkpoints)
├── grade_module_01.yml         # Module 1 grader (6 checkpoints)
├── grade_module_02.yml         # Module 2 grader (9 checkpoints)
├── grade_module_03.yml         # Module 3 grader (11 checkpoints)
├── grade_module_04.yml         # Module 4 grader (9 checkpoints)
├── solve_lab.yml               # Full lab solver
├── solve_module_01.yml         # Module 1 solver
├── solve_module_02.yml         # Module 2 solver
├── solve_module_03.yml         # Module 3 solver
├── solve_module_04.yml         # Module 4 solver
├── lab.yml                     # Lab configuration
└── README.md                   # Lab documentation (465 lines)
```

#### Play Structure Validation

**Module 1 (3 plays):**
1. Initialize FTL Grading Session
2. Grade Module 1 - Lab Setup
3. Finalize FTL Grading Session

**grader_student_report_file:** Present in ALL 3 plays ✓

#### Multi-User Support

This lab has excellent multi-user support:
- Namespace isolation per user: `mcp-openshift-user1`, `mcp-gitea-user2`, etc.
- Per-user grading reports: `grading_report_user1.txt`
- Environment variables allow grading as system:admin for all users
- Documented multi-user grading patterns in README

#### README Quality Assessment

**Grade: A (Excellent)**
- 465 lines of comprehensive documentation
- Detailed checkpoint tables for all 4 modules
- Clear environment variable documentation with overrides
- Multi-user grading patterns documented
- Testing instructions for each module
- Troubleshooting section for common issues
- Technology stack and design decisions documented

---

### 3. OpenShift 4 Getting Started Workshop

**Lab ID:** `ocp4-getting-started`
**Workshop Repository:** https://github.com/rhpds/ocp4-getting-started-showroom
**AgnosticV Catalog:** TBD
**Status:** Production Ready

#### Module Structure

| Module | Description | Checkpoints | Grader | Solver |
|--------|-------------|-------------|--------|--------|
| Module 1 | Deploying and Managing Applications | ~11 | ✓ | ✓ |
| Module 2 | Building from Source and Data | ~16 | ✓ | ✓ |
| Module 3 | CI/CD with Tekton Pipelines | ~5 | ✓ | ✓ |
| **Total** | | **~32** | **4** | **3** |

#### Checkpoint Distribution

**Module 1: Deploying and Managing Applications (~11 checkpoints)**
- Exercise 1.1: Project Exists (1 checkpoint)
  - OpenShift project created
- Exercise 1.2: Parksmap Deployment (multiple checkpoints)
  - Parksmap deployment exists
  - Deployment has correct labels
  - Service exists
  - Pod is running
- Exercise 1.3: Application Scaling (checkpoints)
  - Application scaled to 2 replicas
  - Application scaled back to 1 replica
  - Self-healing validated
- Exercise 1.4: Route Creation (checkpoints)
  - HTTPS route created
  - Route accessible
- Exercise 1.5: Service Account Permissions (checkpoints)
  - Service account permissions granted

**Module 2: Building from Source and Data (~16 checkpoints)**
- Exercise 2.1: Nationalparks S2I Build (checkpoints)
  - BuildConfig created
  - Build completed successfully
  - Deployment created from S2I
- Exercise 2.2: MongoDB Deployment (checkpoints)
  - MongoDB deployment exists
  - MongoDB pod running
  - Secret with database credentials created
- Exercise 2.3: Database Connection (checkpoints)
  - Environment variables configured
  - Application connected to database
- Exercise 2.4: Data Loading (checkpoints)
  - Route labeled with `type=parksmap-backend`
  - Data loaded via REST API (2893 parks)
- Exercise 2.5: Health Probes (checkpoints)
  - Readiness probe configured
  - Liveness probe configured

**Module 3: CI/CD with Tekton Pipelines (~5 checkpoints)**
- Exercise 3.1: Pipeline Definition (checkpoints)
  - Pipeline `nationalparks-pipeline` created
  - Pipeline has 4 tasks (git-clone, build-test, build-image, redeploy)
- Exercise 3.2: Pipeline Workspace (checkpoints)
  - PVC `app-source-pvc` created
  - PVC bound
- Exercise 3.3: Pipeline Execution (checkpoints)
  - PipelineRun succeeded
  - All 4 tasks completed
  - Application redeployed with new image
- Exercise 3.4: Webhook Configuration (checkpoints)
  - Webhook configured on BuildConfig

#### Technology Stack

- **Platform:** OpenShift 4.x
- **Build Strategy:** Source-to-Image (S2I)
- **Database:** MongoDB (ephemeral)
- **CI/CD:** Tekton Pipelines
- **Applications:** Parksmap (frontend), Nationalparks (backend)
- **Storage:** PVC for Tekton workspace
- **Health Checks:** Readiness and Liveness probes

#### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| PROJECT_NAME | Yes | workshop-user1 | OpenShift project/namespace |
| OPENSHIFT_CLUSTER_INGRESS_DOMAIN | Yes | - | Cluster ingress domain |
| LAB_USER | No | student | Username (for multi-user) |
| GUID | No | Auto-detected | Cluster GUID |

#### Playbook Files

```
labs/ocp4-getting-started/
├── grade_lab.yml               # Full lab orchestrator (~32 checkpoints)
├── grade_module_01.yml         # Module 1 grader (~11 checkpoints)
├── grade_module_02.yml         # Module 2 grader (~16 checkpoints)
├── grade_module_03.yml         # Module 3 grader (~5 checkpoints)
├── solve_module_01.yml         # Module 1 solver
├── solve_module_02.yml         # Module 2 solver
├── solve_module_03.yml         # Module 3 solver
├── CHECKPOINT_MAPPING.md       # Detailed checkpoint-to-task mapping
└── README.md                   # Lab documentation (507 lines)
```

#### Play Structure Validation

**Module 1 (3 plays):**
1. Initialize FTL Grading Session
2. Grade Module 1 - Deploying and Managing Applications
3. Finalize FTL Grading Session

**grader_student_report_file:** Present in ALL 3 plays ✓

#### Multi-User Architecture

Excellent multi-user support:
- **Project-based isolation:** Each student has their own namespace (`workshop-user1`, `workshop-user2`)
- **No shared resources:** All resources isolated within student's project
- **Unique routes:** Routes get unique hostnames based on project
- **Report isolation:** Per-user grading reports
- **Batch grading support:** Documented for system admins to grade all students

#### README Quality Assessment

**Grade: A+ (Excellent)**
- 507 lines of comprehensive documentation
- Multi-user architecture section with patterns
- Detailed file inventory
- Application architecture diagram
- Testing approach with expected results at each stage
- Troubleshooting section for common issues
- AgnosticV integration examples
- New grader roles documented
- Statistics section

#### New Grader Roles Used

This lab exercises 6 new grader roles:
1. `grader_check_ocp_build_completed` - S2I build validation
2. `grader_check_ocp_secret_exists` - Secret verification with key checks
3. `grader_check_ocp_configmap_exists` - ConfigMap validation
4. `grader_check_ocp_pvc_exists` - PVC and bound status checks
5. `grader_check_ocp_pipeline_run` - Tekton pipeline validation
6. `grader_check_http_json_response` - HTTP endpoint with JSON validation

---

### 4. AAP Self-Service Portal Introduction (WIP)

**Lab ID:** `aap-selfserv-intro-showroom`
**Workshop Repository:** https://github.com/rhpds/aap-selfserv-intro-showroom
**AgnosticV Catalog:** TBD
**Status:** Work In Progress (WIP)

#### Module Structure

| Module | Description | Checkpoints | Grader | Solver |
|--------|-------------|-------------|--------|--------|
| Module 1 | Configure AAP for Self-Service | ~11 | ✓ | ✓ (UI + CLI) |
| Module 2 | User Persona Testing | ~7 | ✓ | ✓ |
| Module 3 | Surveys and Custom Templates | ~5 | ✓ | ✓ |
| **Total** | | **~23** | **4** | **5** |

#### Checkpoint Distribution

**Module 1: Configure AAP for Self-Service (~11 checkpoints)**
- Create teams in AAP (cloud-team, network-team, rhel-team)
- Assign users to teams
- Configure RBAC roles (job templates, inventories, credentials)
- Create Portal RBAC policies (ssa-portal-users, saa-portal-rhel-team)

**Module 2: User Persona Testing (~7 checkpoints)**
- Test Portal as clouduser1, networkuser1, rheluser1
- Execute job templates as different personas
- Validate RBAC correctly limits access

**Module 3: Surveys and Custom Templates (~5 checkpoints)**
- Modify survey on "Linux/RHEL START Service" job template
- Synchronize changes to Portal
- Import custom dynamic template from Git
- Execute custom template

#### Technology Stack

- **Platform:** Ansible Automation Platform Self-Service Portal
- **Automation:** AAP Controller, awx CLI
- **Browser Automation:** Playwright (for UI-based solvers)
- **RBAC:** AAP teams, roles, Portal RBAC policies

#### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| AAP_CONTROLLER_URL | Yes | - | AAP controller URL |
| AAP_ADMIN_PASSWORD | Yes | - | AAP admin password |
| SELF_SERVICE_PORTAL_URL | Yes | - | Self-Service Portal URL |
| GUID | Yes | - | Lab GUID |

#### Playbook Files

```
labs/WIP/aap-selfserv-intro-showroom/
├── grade_lab.yml                      # Full lab orchestrator
├── grade_module_01.yml                # Module 1 grader (11 checkpoints)
├── grade_module_01_portal_rbac.yml    # Portal RBAC validation (4 checkpoints)
├── grade_module_02.yml                # Module 2 grader (7 checkpoints)
├── grade_module_03.yml                # Module 3 grader (5 checkpoints)
├── solve_lab.yml                      # Full lab solver
├── solve_module_01.yml                # Module 1 solver (CLI-based)
├── solve_module_01_ui.yml             # Module 1 solver (UI-based)
├── solve_module_02.yml                # Module 2 solver
├── solve_module_03.yml                # Module 3 solver
├── create_team_ui.yml                 # Helper for team creation
├── test_*.yml                         # Multiple testing playbooks
└── README.md                          # Lab documentation (282 lines)
```

#### Special Features

**Browser Automation:**
- Uses Playwright for UI-based automation via `solver_browser_action` role
- Headless mode by default
- Screenshot capture for debugging
- Documented installation: `pip install playwright && playwright install chromium`

**Validation Strategy:**
- **Graders:** Use `awx` CLI and `curl` to validate outcomes
- **Solvers:** Use Playwright browser automation for UI tasks

#### README Quality Assessment

**Grade: B+ (Good)**
- 282 lines of documentation
- Clear module structure
- Browser automation prerequisites documented
- File structure explained
- Integration with AgnosticV outlined
- Troubleshooting section
- Missing: Detailed checkpoint tables, testing examples

#### WIP Status Notes

- Located in `/labs/WIP/` directory
- Has 58 files total (many test/debug playbooks)
- Multiple experimental approaches (UI vs CLI solving)
- Extensive testing infrastructure
- More polish needed before production

---

## Consistency Analysis

### 3-Play Pattern Compliance

All production labs follow the standard 3-play pattern (or 4-play for remote hosts):

**Standard Pattern (3 plays):**
1. **Initialize:** `ftl_run_init` role
2. **Grade:** Validation tasks with grader roles
3. **Finalize:** `ftl_run_grade_report_generation` and `ftl_run_finish` roles

**Extended Pattern (4 plays - RIPU only):**
1. **Initialize:** `ftl_run_init` role
2. **Grade (localhost):** AAP API validation tasks
3. **Grade (remote nodes):** Node-based validation tasks
4. **Finalize:** Report generation and finish

**Compliance:** ✓ All labs follow pattern correctly

### grader_student_report_file Consistency

| Lab | Init Play | Grade Play(s) | Finalize Play | Status |
|-----|-----------|---------------|---------------|--------|
| RIPU | ✓ | ✓ (both plays) | ✓ | Perfect ✓ |
| MCP | ✓ | ✓ | ✓ | Perfect ✓ |
| OCP4 | ✓ | ✓ | ✓ | Perfect ✓ |
| AAP (WIP) | - | - | - | Not verified |

**Compliance:** ✓ All production labs include `grader_student_report_file` in ALL plays

### Environment Variable Validation

All production labs validate required environment variables at the start of grading playbooks:

| Lab | Validation Method | Variables Checked |
|-----|-------------------|-------------------|
| RIPU | `ansible.builtin.assert` | AAP_HOSTNAME, AAP_PASSWORD |
| MCP | `ansible.builtin.fail` with loop | OPENSHIFT_CLUSTER_INGRESS_DOMAIN, PASSWORD |
| OCP4 | `ansible.builtin.assert` | PROJECT_NAME, OPENSHIFT_CLUSTER_INGRESS_DOMAIN |

**Compliance:** ✓ All labs validate environment variables

### Error Message Quality

All production labs provide:
- ✓ Clear error messages with variable names
- ✓ Example export commands
- ✓ Context-specific hints
- ✓ Actionable next steps

**Compliance:** ✓ Excellent error message quality across all labs

### README Documentation Quality

| Lab | Lines | Grade | Highlights |
|-----|-------|-------|------------|
| RIPU | 492 | A+ | Checkpoint tables, troubleshooting, AAP 2.6 API notes |
| MCP | 465 | A | Multi-user patterns, checkpoint tables, design decisions |
| OCP4 | 507 | A+ | Architecture diagrams, multi-user patterns, testing approach |
| AAP (WIP) | 282 | B+ | Browser automation docs, file structure |

**Overall:** All labs have high-quality documentation with detailed checkpoint mappings and usage examples.

---

## Framework-Wide Findings

### Strengths

1. **Consistent Patterns:**
   - All labs follow 3-play pattern (init, grade, finalize)
   - grader_student_report_file present in all plays
   - Environment variable validation at start
   - Clear error messages with actionable hints

2. **Comprehensive Coverage:**
   - 122+ total checkpoints across 3 production labs
   - Per-exercise validation matching workshop structure
   - Both grading and solving capabilities

3. **Multi-User Support:**
   - MCP and OCP4 labs have excellent multi-user architecture
   - Namespace/project isolation
   - Per-user grading reports
   - Documented batch grading patterns

4. **Technology Diversity:**
   - AAP/AWX automation (RIPU, AAP labs)
   - OpenShift/Kubernetes (MCP, OCP4)
   - CI/CD pipelines (MCP Tekton, OCP4 Tekton)
   - Database integration (RIPU MariaDB, MCP PostgreSQL, OCP4 MongoDB)

5. **Documentation Excellence:**
   - All READMEs 282-507 lines
   - Checkpoint mapping tables
   - Environment setup guides
   - Troubleshooting sections
   - Testing instructions

6. **Reusable Components:**
   - 10+ new grader roles created
   - AAP roles (aap_licensed, aap_job_completed)
   - OCP roles (ocp_build_completed, ocp_pipeline_run, etc.)
   - Generic roles (http_endpoint, file_contains, command_output)

### Gaps and Inconsistencies

1. **Play Pattern Variation:**
   - RIPU uses 4 plays (init + 2 grade + finalize) due to remote host validation
   - MCP and OCP4 use standard 3 plays
   - **Impact:** Minor - both patterns are valid for their use cases

2. **Checkpoint Counting Inconsistency:**
   - RIPU has exact counts in README (26, 26, 5 = 57 total)
   - MCP has exact counts in README (6, 9, 11, 9 = 35 total)
   - OCP4 has estimated counts (~50 total, ~11, ~16, ~5)
   - **Recommendation:** OCP4 should have exact checkpoint counts in README

3. **Lab Template Empty:**
   - `/labs/lab-template/` directory exists but is empty
   - **Recommendation:** Create template with standard structure, skeleton playbooks, README template

4. **Environment Variable Inconsistency:**
   - RIPU uses `AAP_USERNAME` (optional, defaults to lab-user)
   - MCP uses `LAB_USER` (auto-set from wrapper)
   - OCP4 uses `LAB_USER` (optional, defaults to student)
   - **Impact:** Minor - each lab has different user models
   - **Recommendation:** Document standard approach in lab template

5. **Orchestrator Pattern Variation:**
   - RIPU `grade_lab.yml` uses `ansible.builtin.command` to call module playbooks
   - MCP `grade_lab.yml` uses `import_playbook`
   - OCP4 `grade_lab.yml` uses `ansible.builtin.command`
   - **Recommendation:** Standardize on `import_playbook` (cleaner, better error handling)

6. **Inventory Files:**
   - RIPU has inventory file (node1, node2, node3)
   - MCP has no inventory file (uses localhost + oc commands)
   - OCP4 has no inventory file (uses localhost + oc commands)
   - **Impact:** None - each lab's needs are different

7. **WIP Lab Status:**
   - AAP Self-Service lab is in WIP directory
   - Has 58 files including many test/debug playbooks
   - Needs cleanup before promotion to production
   - **Recommendation:** Create production-ready branch, remove test files

---

## Completeness Assessment

### Production Labs: Grade A

All 3 production labs are **feature-complete** and **production-ready**:

| Lab | Modules | Graders | Solvers | README | Tests | Overall |
|-----|---------|---------|---------|--------|-------|---------|
| RIPU | ✓ 3/3 | ✓ 4/4 | ✓ 3/3 | A+ | Manual | A+ |
| MCP | ✓ 4/4 | ✓ 5/5 | ✓ 5/5 | A | Manual | A |
| OCP4 | ✓ 3/3 | ✓ 4/4 | ✓ 3/3 | A+ | Manual | A+ |

**Missing Items (All Labs):**
- Automated testing (no CI/CD pipeline for FTL framework itself)
- HTML report generation (text reports only)
- Video/screenshot documentation

### Framework Maturity: Grade A-

**Strengths:**
- Consistent patterns across labs
- Comprehensive documentation
- Reusable grader roles
- Multi-user support
- Environment variable validation

**Areas for Improvement:**
- Lab template creation
- Standardize orchestrator pattern (import_playbook vs command)
- Add exact checkpoint counts to all READMEs
- Automated testing for FTL framework
- HTML report generation
- Promote AAP Self-Service lab from WIP to production

---

## Technology Stack Summary

### Platforms Covered

| Platform | Labs | Coverage |
|----------|------|----------|
| OpenShift 4.x | MCP, OCP4 | Excellent |
| Ansible Automation Platform 2.6 | RIPU, AAP (WIP) | Excellent |
| RHEL (7, 8, 9, 10) | RIPU | Excellent |
| Tekton Pipelines | MCP, OCP4 | Good |
| Kubernetes Operators | MCP (ToolHive, CNPG) | Good |

### Databases

| Database | Lab | Use Case |
|----------|-----|----------|
| MariaDB | RIPU | Pet app persistence |
| PostgreSQL | MCP | MCP Registry backend |
| MongoDB | OCP4 | Nationalparks data |

### Build Strategies

| Strategy | Lab | Use Case |
|----------|-----|----------|
| Source-to-Image (S2I) | OCP4 | Nationalparks backend build |
| Container Image | OCP4 | Parksmap frontend deployment |
| Leapp Upgrades | RIPU | RHEL in-place upgrades |

### Observability

| Technology | Lab | Use Case |
|------------|-----|----------|
| Prometheus | MCP | MCP server telemetry |
| ServiceMonitor | MCP | Metrics scraping |
| AAP Job Logs | RIPU | Automation execution tracking |

---

## File Statistics

### Total Files by Lab

| Lab | YAML Files | Total Files | README Lines |
|-----|------------|-------------|--------------|
| RIPU | 7 | 7 | 492 |
| MCP | 11 | 12 | 465 |
| OCP4 | 7 | 8 | 507 |
| AAP (WIP) | 23+ | 58 | 282 |

### Playbook Distribution

**Total Playbooks:** 30+ (production only)
- **Grader Playbooks:** 13 (4 + 5 + 4)
- **Solver Playbooks:** 10 (3 + 5 + 3, excluding WIP)
- **Orchestrator Playbooks:** 6 (grade_lab.yml × 3, solve_lab.yml × 3)
- **Helper Playbooks:** 1+ (MCP lab.yml, etc.)

---

## Recommendations

### High Priority

1. **Create Lab Template:**
   - Populate `/labs/lab-template/` with skeleton structure
   - Include: grade_module_01.yml, solve_module_01.yml, grade_lab.yml, README.md
   - Add comments explaining 3-play pattern
   - Document environment variable conventions

2. **Standardize Orchestrator Pattern:**
   - Use `import_playbook` instead of `ansible.builtin.command`
   - Better error handling and output formatting
   - Update RIPU and OCP4 labs

3. **Add Exact Checkpoint Counts to OCP4 README:**
   - Count actual grader role invocations
   - Update checkpoint tables with exact numbers
   - Verify total matches actual implementation

4. **Promote AAP Self-Service Lab:**
   - Remove test/debug playbooks
   - Finalize documentation
   - Move from WIP to production labs directory

### Medium Priority

5. **Add Automated Testing:**
   - Create test suite for FTL framework itself
   - Test grader roles in isolation
   - Test playbook syntax and structure
   - CI/CD pipeline for FTL repository

6. **HTML Report Generation:**
   - Add optional HTML report format
   - Include graphs/charts for checkpoint progress
   - Color-coded pass/fail indicators
   - Export to PDF option

7. **Standardize Environment Variables:**
   - Document standard variable names in lab template
   - LAB_USER vs USER consistency
   - Common password variable names

### Low Priority

8. **Add Video/Screenshot Documentation:**
   - Record demos of each lab
   - Screenshot key validation checkpoints
   - Embed in README or separate docs

9. **Create Grader Role Reference:**
   - Central documentation for all reusable grader roles
   - Examples for each role
   - Parameter reference

10. **Add Negative Test Cases:**
    - Test graders with incomplete lab state
    - Verify error messages are helpful
    - Document expected failures

---

## Conclusion

The FTL framework demonstrates **excellent maturity** with 3 production-ready labs covering diverse Red Hat technologies. All labs follow consistent patterns, have comprehensive documentation, and provide both grading and solving capabilities.

**Key Achievements:**
- 122+ checkpoints across 10 modules
- Multi-user support in OpenShift labs
- Reusable grader roles for AAP and OCP validation
- High-quality documentation (A/A+ grades)
- Clear error messages with actionable hints

**Next Steps:**
- Create lab template for future labs
- Promote AAP Self-Service lab to production
- Add automated testing for FTL framework
- Standardize orchestrator pattern across all labs

The framework is **ready for production use** and **suitable for expansion** to additional workshops and technologies.

---

**Document Version:** 1.0
**Created:** 2026-02-10
**Author:** FTL Lab Documentation Specialist
**Last Updated:** 2026-02-10
