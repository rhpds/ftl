# OpenShift 4 Getting Started Workshop - FTL Graders and Solvers

Automated grading and solving for the OpenShift 4 Getting Started workshop.

**Workshop Repository:** https://github.com/rhpds/ocp4-getting-started-showroom

---

## Overview

This lab teaches beginner developers core OpenShift concepts through hands-on exercises:

- Deploying applications from container images and source code
- Scaling, networking, and storage
- Application health checks and monitoring
- CI/CD with Tekton pipelines
- Webhooks for automated builds

**Duration:** 90 minutes
**Checkpoints:** ~50 validation points across 3 modules
**Technology:** OpenShift 4.x, S2I builds, MongoDB, Tekton

---

## Module Structure

### Module 1: Deploying and Managing Applications (20 checkpoints)

**Coverage:**
- Project creation and CLI access
- Parksmap frontend deployment from container image
- Application scaling (up/down, self-healing)
- Route creation for external access
- Log viewing and container access
- Permission management (service accounts)

**Key Validations:**
- Deployment, Service, and Pod created with correct labels
- Application scaled to 2 replicas, then back to 1
- HTTPS route configured
- Service account permissions granted

---

### Module 2: Building from Source and Data Integration (18 checkpoints)

**Coverage:**
- Nationalparks backend deployment via S2I from Git
- MongoDB database deployment and configuration
- Database user creation and connection setup
- Data loading via REST API
- Application health probes (readiness/liveness)

**Key Validations:**
- BuildConfig and successful Build completion
- Secret with database credentials
- Environment variables configured for DB connection
- Route label `type=parksmap-backend` for service discovery
- Data loaded successfully (2893 parks)
- Health probes configured in deployment

---

### Module 3: CI/CD with Tekton Pipelines (12 checkpoints)

**Coverage:**
- Tekton pipeline definition with 4 tasks
- PersistentVolumeClaim for pipeline workspace
- Pipeline execution and monitoring
- Webhook configuration for automated builds

**Key Validations:**
- Pipeline `nationalparks-pipeline` created
- PVC `app-source-pvc` exists and bound
- PipelineRun succeeded with all 4 tasks
- Application redeployed with new image
- Webhook configured on BuildConfig

---

## Environment Variables

**Required:**
```bash
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxxxx.dynamic.redhatworkshops.io"
export PROJECT_NAME="workshop-user1"  # Student's project/namespace
```

**Optional:**
```bash
export LAB_USER="user1"  # For multi-user environments
export GUID="xxxxx"      # Auto-detected from hostname if not set
```

**Variable Priority:**
1. Explicitly set environment variable
2. Auto-detection (for GUID)
3. Default values in playbooks

---

## Usage

### Grading

**Full lab (all modules):**
```bash
grade_lab ocp4-getting-started
```

**Specific module:**
```bash
grade_lab ocp4-getting-started 1  # Module 1 only
grade_lab ocp4-getting-started 2  # Module 2 only
grade_lab ocp4-getting-started 3  # Module 3 only
```

**Multi-user grading:**
```bash
# Each user grades their own project
export PROJECT_NAME="workshop-user1"
grade_lab ocp4-getting-started

export PROJECT_NAME="workshop-user2"
grade_lab ocp4-getting-started
```

---

### Solving

**Full lab automation:**
```bash
solve_lab ocp4-getting-started
```

**Specific module:**
```bash
solve_lab ocp4-getting-started 1  # Auto-complete Module 1
solve_lab ocp4-getting-started 2  # Auto-complete Module 2
solve_lab ocp4-getting-started 3  # Auto-complete Module 3
```

**What solvers do:**
- Module 1: Deploy parksmap, scale, create route, grant permissions
- Module 2: Deploy nationalparks with S2I, deploy MongoDB, configure DB connection, load data, add health probes
- Module 3: Create Tekton pipeline, create PVC, execute pipeline, configure webhook

---

## Reports

**Report File Naming:**
- Full lab: `/tmp/grading_dir/grading_report_{{ LAB_USER }}.txt`
- Per-module: `/tmp/grading_dir/grading_report_{{ LAB_USER }}_module_01.txt`

**Expected Results (Fresh Environment):**
- **Before solver:** Module 1 FAIL (no apps deployed)
- **After Module 1 solver:** Module 1 PASS
- **After Module 2 solver:** Modules 1-2 PASS
- **After Module 3 solver:** All modules PASS (SUCCESS 0 Errors)

---

## File Inventory

### Grading Playbooks
- `grade_module_01.yml` - Module 1: Parksmap deployment and management
- `grade_module_02.yml` - Module 2: Nationalparks S2I build and database
- `grade_module_03.yml` - Module 3: Tekton pipeline
- `grade_lab.yml` - Full lab orchestrator

### Solver Playbooks
- `solve_module_01.yml` - Auto-deploy parksmap application
- `solve_module_02.yml` - Auto-deploy nationalparks with database
- `solve_module_03.yml` - Auto-create and run pipeline

### Documentation
- `README.md` - This file
- `CHECKPOINT_MAPPING.md` - Detailed checkpoint-to-task mapping

---

## Workshop Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenShift Cluster                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Project: workshop-user1                            │  │
│  │                                                       │  │
│  │  ┌──────────────┐       ┌─────────────────────┐    │  │
│  │  │  Parksmap    │       │  Nationalparks      │    │  │
│  │  │  (Frontend)  │◄──────│  (Backend)          │    │  │
│  │  │              │       │                     │    │  │
│  │  │  Container   │       │  S2I Build from Git │    │  │
│  │  │  Image       │       │                     │    │  │
│  │  └──────────────┘       └─────────────────────┘    │  │
│  │         │                         │                 │  │
│  │         │                         │                 │  │
│  │         │                         ▼                 │  │
│  │         │                  ┌─────────────┐         │  │
│  │         │                  │  MongoDB    │         │  │
│  │         │                  │  (Database) │         │  │
│  │         │                  └─────────────┘         │  │
│  │         │                                           │  │
│  │         ▼                                           │  │
│  │  ┌──────────────┐                                  │  │
│  │  │  Route       │  (HTTPS)                         │  │
│  │  │  parksmap-*  │                                  │  │
│  │  └──────────────┘                                  │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Tekton Pipeline                                    │  │
│  │                                                       │  │
│  │  git-clone → build-test → build-image → redeploy    │  │
│  │                                                       │  │
│  │  Workspace: app-source-pvc (1Gi)                    │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Concepts Validated

### Labels and Selectors
All resources use consistent labels for grouping:
- `app=workshop` - Application group
- `component=parksmap` or `component=nationalparks` - Component name
- `role=frontend`, `role=backend`, `role=database` - Component role

### Service Discovery
Nationalparks route requires label `type=parksmap-backend` for the parksmap frontend to discover it automatically.

### Storage
MongoDB uses ephemeral storage (EmptyDir) for workshop simplicity. Tekton pipeline uses PVC for workspace persistence.

### Build Strategies
- **Container Image:** Parksmap (pre-built image)
- **Source-to-Image (S2I):** Nationalparks (built from Git)

### Health Checks
- **Readiness Probe:** `/ws/info/` endpoint - determines if pod receives traffic
- **Liveness Probe:** `/ws/info/` endpoint - determines if pod needs restart

---

## Troubleshooting

### Common Issues

**1. "Project not found"**
```bash
# Verify project exists
oc get project $PROJECT_NAME

# Create if missing
oc new-project $PROJECT_NAME
```

**2. "Build failed"**
```bash
# Check build logs
oc logs -f bc/nationalparks

# Common causes:
# - Git repository unreachable
# - Builder image pull failed
# - Maven dependency download issues
```

**3. "Pod not running"**
```bash
# Check pod status
oc get pods

# View pod events
oc describe pod <pod-name>

# Check logs
oc logs <pod-name>
```

**4. "Route not accessible"**
```bash
# Verify route exists
oc get route

# Test route
curl -k https://$(oc get route parksmap -o jsonpath='{.spec.host}')
```

**5. "Data not loading"**
```bash
# Check MongoDB pod running
oc get pods -l role=database

# Verify environment variables set
oc set env deployment/nationalparks --list

# Test database connection from nationalparks pod
oc rsh deployment/nationalparks
mongo $MONGODB_SERVER_HOST/$MONGODB_DATABASE -u $MONGODB_USER -p $MONGODB_PASSWORD
```

---

## Testing Approach

### Fresh Environment Test

**Expected Behavior (Before Solver):**
```
Module 1: FAILED (no resources deployed)
Module 2: FAILED (no apps deployed)
Module 3: FAILED (no pipeline)
Total: FAILED ~50 Errors
```

**After Module 1 Solver:**
```
Module 1: SUCCESS (parksmap deployed and scaled)
Module 2: FAILED (no backend deployed)
Module 3: FAILED (no pipeline)
Total: FAILED ~30 Errors
```

**After Module 2 Solver:**
```
Module 1: SUCCESS
Module 2: SUCCESS (nationalparks + mongodb deployed)
Module 3: FAILED (no pipeline)
Total: FAILED ~12 Errors
```

**After Module 3 Solver:**
```
Module 1: SUCCESS
Module 2: SUCCESS
Module 3: SUCCESS (pipeline created and executed)
Total: SUCCESS 0 Errors
```

### Manual Testing

Test individual components:

```bash
# Module 1 - Parksmap
oc get deployment parksmap
oc get route parksmap
curl -k https://$(oc get route parksmap -o jsonpath='{.spec.host}')

# Module 2 - Nationalparks
oc get bc nationalparks
oc get builds
oc get deployment nationalparks
curl -k https://$(oc get route nationalparks -o jsonpath='{.spec.host}')/ws/info/
curl -k https://$(oc get route nationalparks -o jsonpath='{.spec.host}')/ws/data/all | jq length

# Module 3 - Pipeline
oc get pipeline nationalparks-pipeline
oc get pipelineruns
oc logs -f pipelinerun/<pipelinerun-name>
```

---

## AgnosticV Integration

**Post-software installation:**
```yaml
# catalog/dev.yaml
post_software:
  - name: Install FTL
    command: git clone https://github.com/rhpds/ftl.git ~/ftl

  - name: Setup FTL
    command: bash ~/ftl/bin/setup_ftl

  - name: Add grade_lab to PATH
    lineinfile:
      path: ~/.bashrc
      line: 'export PATH="$HOME/ftl/bin:$PATH"'
```

**User info integration:**
```yaml
# Enable AgnosticD user info reporting
agnosticd_user_info_enabled: true
```

Students can then grade their work:
```bash
grade_lab ocp4-getting-started
```

---

## New Grader Roles Used

This lab exercises **6 new grader roles** created for OpenShift validation:

1. `grader_check_ocp_build_completed` - Validate S2I builds
2. `grader_check_ocp_secret_exists` - Check Secrets with key verification
3. `grader_check_ocp_configmap_exists` - Validate ConfigMaps
4. `grader_check_ocp_pvc_exists` - Check PVCs and bound status
5. `grader_check_ocp_pipeline_run` - Validate Tekton pipelines
6. `grader_check_http_json_response` - HTTP endpoint with JSON validation

See `docs/GRADER_ROLES_REFERENCE.md` for complete documentation.

---

## Statistics

**Checkpoints:** ~50 across 3 modules
**Grader Playbooks:** 4 (3 modules + 1 orchestrator)
**Solver Playbooks:** 3 (one per module)
**Lines of Code:** ~2,500 (estimate)
**Roles Used:** 12 grader roles (6 existing + 6 new)

---

## Contributing

When adding new checkpoints:

1. Add validation to appropriate module grader
2. Update solver if automatable
3. Update this README
4. Test on fresh environment
5. Verify error messages are helpful

---

## License

Part of the FTL (Finish The Labs) framework.
Repository: https://github.com/rhpds/ftl
