# FTL Lab: Model Context Protocol (MCP) with OpenShift

Automated grading and solving for the MCP with OpenShift workshop on Red Hat Demo Platform.

## Lab Overview

This lab provides automated grading for the [MCP with OpenShift workshop](https://github.com/rhpds/lb1726-mcp-showroom). Students learn to deploy and manage MCP servers, implement security controls, enable observability, and deploy an MCP Registry for enterprise governance.

**Workshop Repository:** https://github.com/rhpds/lb1726-mcp-showroom
**AgnosticV Catalog:** TBD
**Total Checkpoints:** 35 (6 Module 1 + 9 Module 2 + 11 Module 3 + 9 Module 4)

## Lab Structure

### Module 1: Lab Setup (6 checkpoints)

**Exercise 1.1: OpenShift Console Login (1 checkpoint)**
- OpenShift Console accessible

**Exercise 1.2: LibreChat Login and Configuration (3 checkpoints)**
- LibreChat pod running
- LibreChat route exists
- LibreChat UI accessible

**Exercise 1.3: MCP OpenShift Server Available (1 checkpoint)**
- MCP OpenShift Server pod running

**Exercise 1.4: MCP Gitea Server Available (1 checkpoint)**
- MCP Gitea Server pod running

**Exercise 1.5: Gitea Login (1 checkpoint)**
- Gitea repository accessible

### Module 2: Sovereign SRE Agent Demo (9 checkpoints)

**Exercise 2.1: Agent Infrastructure (1 checkpoint)**
- Agent pod running

**Exercise 2.2: Agent MCP Connectivity (1 checkpoint)**
- Agent connected to both MCP servers (OpenShift + Gitea)

**Exercise 2.3: Pipeline Infrastructure (1 checkpoint)**
- build-agent pipeline exists

**Exercise 2.4: Pipeline Run Triggered (1 checkpoint)**
- Pipeline run with GIT_REVISION=broken parameter

**Exercise 2.5: Pipeline Failure (1 checkpoint)**
- Pipeline run failed as expected (requirements.txt missing)

**Exercise 2.6: Trigger-Agent Finally Task (1 checkpoint)**
- trigger-agent finally task executed

**Exercise 2.7: Agent Investigation (1 checkpoint)**
- Agent investigated failure (logs show analysis)

**Exercise 2.8: Gitea Issue Creation (1 checkpoint)**
- Gitea issue created by agent

**Exercise 2.9: LibreChat Infrastructure Queries (1 checkpoint)**
- LibreChat accessible for querying infrastructure

### Module 3: MCP Server Administration (11 checkpoints)

**Tool Filtering (2 checkpoints)**
- Exercise 3.1: MCPToolConfig resource created
- Exercise 3.2: Tool filter allowlist configured (least-privilege)

**Telemetry and Observability (3 checkpoints)**
- Exercise 3.3: Prometheus telemetry enabled on MCPServer
- Exercise 3.4: ServiceMonitor resource created
- Exercise 3.5: Metrics endpoint accessible and exposing data

**Fetch MCP Server Deployment (3 checkpoints)**
- Exercise 3.6: Fetch MCPServer resource created
- Exercise 3.7: Fetch server pod running
- Exercise 3.8: Fetch server route exists (accessible to LibreChat)

**Yardstick MCP Server Deployment (3 checkpoints)**
- Exercise 3.9: Yardstick MCPServer resource created
- Exercise 3.10: Yardstick server pod running
- Exercise 3.11: Yardstick server route exists (accessible to LibreChat)

### Module 4: MCP Registry (9 checkpoints)

**PostgreSQL Backend (2 checkpoints)**
- Exercise 4.1: PostgreSQL Cluster CR created (CNPG)
- Exercise 4.2: PostgreSQL pod running

**Server Catalog and Secrets (2 checkpoints)**
- Exercise 4.3: Server catalog ConfigMap created
- Exercise 4.4: Registry database secret exists

**Registry Deployment (5 checkpoints)**
- Exercise 4.5: MCPRegistry CR created
- Exercise 4.6: Registry pod running
- Exercise 4.7: Registry route exists
- Exercise 4.8: Registry API accessible
- Exercise 4.9: MCP servers registered (at least 2)

## Environment Setup

### Required Environment Variables

```bash
# OpenShift cluster ingress domain
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-<guid>.<domain>"

# User password (from AgnosticV user data)
export PASSWORD="<password_from_user_data>"
```

**Note:** `LAB_USER` is automatically set from the username argument when using grade_lab/solve_lab commands.

### Optional Environment Variables

If your lab environment uses different namespace or URL conventions, you can override the defaults:

```bash
# Namespace overrides (defaults shown)
export MCP_OPENSHIFT_NAMESPACE="mcp-openshift"
export MCP_GITEA_NAMESPACE="mcp-gitea"
export LIBRECHAT_NAMESPACE="librechat"

# URL override (defaults to https://gitea.$OPENSHIFT_CLUSTER_INGRESS_DOMAIN)
export GITEA_URL="https://gitea.apps.cluster-<guid>.<domain>"
```

These are typically not needed unless your lab deployment uses custom namespace names.

### Setting Up Environment

1. **Get ingress domain from user data:**
   ```bash
   cat ~/user_data.yaml | grep openshift_cluster_ingress_domain
   ```

2. **Get password from user data:**
   ```bash
   cat ~/user_data.yaml | grep password
   ```

3. **Set environment variables:**
   ```bash
   export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-abc123.example.com"
   export PASSWORD="Xy9aB_1"
   ```

### Multi-User Grading

When grading as system:admin for multiple users:

```bash
# Set cluster-wide settings once
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-kg5jj.example.com"

# Grade user2 (LAB_USER set automatically)
export PASSWORD="<user2_password>"
grade_lab mcp-with-openshift user2

# Grade user3 (update PASSWORD for each user)
export PASSWORD="<user3_password>"
grade_lab mcp-with-openshift user3
```

**IMPORTANT:** Each user has a unique password in their AgnosticV user data.

## Grading

### Grade Individual Modules

```bash
# Module 1: Lab Setup (6 checkpoints)
grade_lab mcp-with-openshift 1

# Module 2: SRE Agent Demo (9 checkpoints)
grade_lab mcp-with-openshift 2

# Module 3: MCP Administration (11 checkpoints)
grade_lab mcp-with-openshift 3

# Module 4: MCP Registry (9 checkpoints)
grade_lab mcp-with-openshift 4
```

### Grade Full Lab

```bash
# All modules (35 checkpoints total)
grade_lab mcp-with-openshift

# Or specify user
grade_lab mcp-with-openshift user1
```

### Direct Playbook Execution

```bash
cd ~/ftl/labs/mcp-with-openshift

# Grade specific module
ansible-playbook grade_module_01.yml
ansible-playbook grade_module_02.yml
ansible-playbook grade_module_03.yml
ansible-playbook grade_module_04.yml

# Grade full lab
ansible-playbook grade_lab.yml
```

## Solving

Solvers are available for automated completion of workshop exercises.

```bash
# Solve Module 1
solve_lab mcp-with-openshift 1

# Solve Module 2
solve_lab mcp-with-openshift 2

# Solve Module 3
solve_lab mcp-with-openshift 3

# Solve Module 4
solve_lab mcp-with-openshift 4

# Solve full lab
solve_lab mcp-with-openshift
```

## Report Files

Per-module reports:
- `/tmp/grading_dir/grading_report_<user>_module_01.txt`
- `/tmp/grading_dir/grading_report_<user>_module_02.txt`
- `/tmp/grading_dir/grading_report_<user>_module_03.txt`
- `/tmp/grading_dir/grading_report_<user>_module_04.txt`

Full lab report:
- `/tmp/grading_dir/grading_report_<user>.txt`

View reports:
```bash
cat /tmp/grading_dir/grading_report_${LAB_USER}_module_01.txt
cat /tmp/grading_dir/grading_report_${LAB_USER}.txt
```

## Checkpoint Details

### Module 1 Checkpoints (6 total)

| Exercise | Checkpoint | Total | Description |
|----------|------------|-------|-------------|
| 1.1 | OpenShift Access | 1 | Console accessible |
| 1.2 | LibreChat Pod | 1 | LibreChat pod running |
| 1.2 | LibreChat Route | 1 | LibreChat route exists |
| 1.2 | LibreChat UI | 1 | LibreChat UI responding |
| 1.3 | OpenShift MCP Server | 1 | OpenShift MCP Server pod running |
| 1.4 | Gitea MCP Server | 1 | Gitea MCP Server pod running |
| 1.5 | Gitea Repository | 1 | Gitea repository accessible |

**Module 1 Total:** 6 checkpoints

### Module 2 Checkpoints (9 total)

| Exercise | Checkpoint | Total | Description |
|----------|------------|-------|-------------|
| 2.1 | Agent Pod | 1 | Agent pod running |
| 2.2 | MCP Connections | 1 | Agent connected to MCP servers |
| 2.3 | Pipeline Exists | 1 | build-agent pipeline exists |
| 2.4 | Pipeline Triggered | 1 | Pipeline run with broken branch |
| 2.5 | Pipeline Failed | 1 | Pipeline run failed as expected |
| 2.6 | trigger-agent Task | 1 | Finally task executed |
| 2.7 | Agent Investigation | 1 | Agent investigated failure |
| 2.8 | Issue Created | 1 | Gitea issue created |
| 2.9 | LibreChat Queries | 1 | LibreChat accessible for queries |

**Module 2 Total:** 9 checkpoints

### Module 3 Checkpoints (11 total)

| Exercise | Checkpoint | Total | Description |
|----------|------------|-------|-------------|
| 3.1 | MCPToolConfig Created | 1 | Tool filter CR created |
| 3.2 | Allowlist Configured | 1 | Tool filter allowlist defined |
| 3.3 | Telemetry Enabled | 1 | Prometheus telemetry on MCPServer |
| 3.4 | ServiceMonitor | 1 | ServiceMonitor resource created |
| 3.5 | Metrics Exposed | 1 | Metrics endpoint accessible |
| 3.6 | Fetch CR Created | 1 | Fetch MCPServer resource created |
| 3.7 | Fetch Pod Running | 1 | Fetch server pod running |
| 3.8 | Fetch Route | 1 | Fetch server route exists |
| 3.9 | Yardstick CR Created | 1 | Yardstick MCPServer resource created |
| 3.10 | Yardstick Pod Running | 1 | Yardstick server pod running |
| 3.11 | Yardstick Route | 1 | Yardstick server route exists |

**Module 3 Total:** 11 checkpoints

### Module 4 Checkpoints (9 total)

| Exercise | Checkpoint | Total | Description |
|----------|------------|-------|-------------|
| 4.1 | PostgreSQL Cluster | 1 | CNPG Cluster CR created |
| 4.2 | PostgreSQL Pod | 1 | Database pod running |
| 4.3 | Server Catalog | 1 | ConfigMap with servers created |
| 4.4 | Database Secret | 1 | CNPG secret exists |
| 4.5 | Registry CR Created | 1 | MCPRegistry resource created |
| 4.6 | Registry Pod | 1 | Registry pod running |
| 4.7 | Registry Route | 1 | Registry route exists |
| 4.8 | API Accessible | 1 | Registry API responding |
| 4.9 | Servers Registered | 1 | At least 2 servers in registry |

**Module 4 Total:** 9 checkpoints

## Testing Instructions

### Fresh Environment (Before Any Lab Work)

Expected: Module 1 checkpoints mostly PASS (pre-deployed)

```bash
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-abc123.example.com"
export PASSWORD="<password>"
grade_lab mcp-with-openshift 1
# Expected: SUCCESS (pre-deployed environment)
```

### After Module 2 Demo

Expected: Module 1 and 2 PASS

```bash
# Manually trigger pipeline with broken branch in OpenShift console
# Then grade
grade_lab mcp-with-openshift 2
# Expected: SUCCESS if pipeline failed and issue created
```

### After Module 3 Configuration

Expected: Module 3 PASS

```bash
# After creating MCPToolConfig, enabling telemetry, deploying fetch and yardstick
grade_lab mcp-with-openshift 3
# Expected: SUCCESS
```

### After Module 4 Registry Setup

Expected: All modules PASS

```bash
# After deploying PostgreSQL, creating catalog, deploying registry
grade_lab mcp-with-openshift
# Expected: SUCCESS across all 35 checkpoints
```

## Troubleshooting

### OpenShift Connection Issues

```bash
# Test OpenShift access
oc whoami
oc get pods -n mcp-openshift-user1

# Re-login if needed
oc login <cluster_url>
```

### MCP Server Not Running

```bash
# Check MCPServer resources
oc get mcpservers -n mcp-openshift-user1
oc get mcpservers -n mcp-gitea-user1

# Check pod status
oc get pods -n mcp-openshift-user1
oc logs -n mcp-openshift-user1 <mcp-server-pod>
```

### Pipeline Not Failing

```bash
# Check pipeline runs
oc get pipelineruns -n agent-user1

# Check for broken branch parameter
oc get pipelinerun <run-name> -n agent-user1 -o yaml | grep -A5 params
```

### Registry API Not Accessible

```bash
# Check registry pod
oc get pods -n mcp-gitea-user1 | grep mcp-registry
oc logs -n mcp-gitea-user1 <mcp-registry-pod>

# Check route
oc get route -n mcp-gitea-user1 mcp-registry

# Test API manually
curl -k https://mcp-registry-mcp-gitea-user1.<cluster_domain>/health
```

## Prerequisites

- OpenShift cluster with MCP lab environment deployed via AgnosticV
- `oc` CLI installed and logged in
- FTL installed: `~/ftl/` with dependencies
- Multi-user grading requires system:admin access

## Files

```
labs/mcp-with-openshift/
├── README.md                   # This file
├── grade_lab.yml               # Full lab grader (35 checkpoints)
├── grade_module_01.yml         # Module 1 grader (6 checkpoints)
├── grade_module_02.yml         # Module 2 grader (9 checkpoints)
├── grade_module_03.yml         # Module 3 grader (11 checkpoints)
├── grade_module_04.yml         # Module 4 grader (9 checkpoints)
├── solve_lab.yml               # Full lab solver
├── solve_module_01.yml         # Module 1 solver
├── solve_module_02.yml         # Module 2 solver
├── solve_module_03.yml         # Module 3 solver
├── solve_module_04.yml         # Module 4 solver
└── lab.yml                     # Lab configuration
```

## Development Notes

### Design Decisions

1. **Comprehensive Exercise Coverage** - All workshop exercises validated (35 checkpoints)
2. **Exercise Labeling** - Clear "Exercise X.X" format matching workshop structure
3. **OpenShift-Native** - Uses OCP custom resources (MCPServer, MCPToolConfig, MCPRegistry)
4. **Multi-User Support** - Namespace isolation per user
5. **Detailed Error Messages** - Actionable hints for students

### Key Technologies Validated

- **ToolHive Operator** - MCP server lifecycle management
- **CloudNativePG** - PostgreSQL cluster management
- **Tekton Pipelines** - CI/CD pipeline failure scenarios
- **Prometheus** - Metrics and observability
- **MCP Protocol** - SSE, streamable HTTP, stdio transports

### Workshop-Specific Features

- Pipeline failure detection and agent response
- Tool filtering for least-privilege access
- MCP server discovery via registry
- Gitea integration for issue creation
- LibreChat as AI interface

## References

- **Workshop Content:** https://github.com/rhpds/lb1726-mcp-showroom
- **MCP Specification:** https://modelcontextprotocol.io
- **ToolHive Operator:** https://github.com/stacklok/toolhive
- **FTL Documentation:** `~/work/code/experiment/ftl/README.adoc`
