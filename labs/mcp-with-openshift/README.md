# MCP with OpenShift Lab - FTL Grader and Solver

Automated grading and solving for the Model Context Protocol (MCP) with OpenShift lab.

## Prerequisites

- OpenShift cluster with MCP lab environment deployed
- `oc` CLI logged in as system:admin (for multi-user grading)
- FTL installed: `~/ftl/` with dependencies

## Environment Variables

The grader and solver require these environment variables to be set:

### Required Variables

```bash
# OpenShift cluster ingress domain
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-kg5jj.dynamic.redhatworkshops.io"

# User password (from AgnosticV user data)
export PASSWORD="NTEzMjI5OD"
```

**Note:** `LAB_USER` is automatically set from the username argument (e.g., `grade_lab mcp-with-openshift user1`). No need to export it manually.

### Optional Variables

```bash
# GUID (auto-detected from hostname if not set)
export GUID="kg5jj"
```

### Where to Find Values

These values are provided in the AgnosticV user data when the lab is deployed:

- **OPENSHIFT_CLUSTER_INGRESS_DOMAIN**: From `openshift_cluster_ingress_domain` in user data
- **PASSWORD**: From `password` or `gitea_password` in user data
- **GUID**: Extracted from cluster domain or hostname (optional)

### Setting Up for Multi-User Grading

When grading as system:admin for multiple users:

```bash
# Set cluster-wide settings once
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-kg5jj.dynamic.redhatworkshops.io"

# Grade user2 (LAB_USER is set automatically from the user2 argument)
export PASSWORD="NTEzMjI5OD"  # Get from user2's AgnosticV user data
grade_lab mcp-with-openshift user2

# Grade user3 (update PASSWORD for each user)
export PASSWORD="<user3_password>"  # Get from user3's AgnosticV user data
grade_lab mcp-with-openshift user3
```

**IMPORTANT**: Each user has a unique password in their AgnosticV user data. Make sure PASSWORD matches the user you're grading.

## Usage

### Grade Entire Lab

```bash
# Set environment variables first (see above)
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-kg5jj.dynamic.redhatworkshops.io"
export LAB_USER="user1"
export PASSWORD="NTEzMjI5OD"

# Grade all modules
grade_lab mcp-with-openshift

# Or specify user
grade_lab mcp-with-openshift user1
```

### Grade Individual Module

```bash
# Grade module 1 for current LAB_USER
grade_lab mcp-with-openshift 1

# Grade module 2 for user3
grade_lab mcp-with-openshift user3 2
```

### Solve Lab (Auto-Complete)

```bash
# Solve entire lab
solve_lab mcp-with-openshift

# Solve specific module
solve_lab mcp-with-openshift 2

# Solve for specific user
solve_lab mcp-with-openshift user2 3
```

## Lab Modules

### Module 1: Lab Setup
- OpenShift access validation
- MCP OpenShift Server pod running
- MCP Gitea Server pod running
- Gitea repository accessible
- LibreChat accessible

### Module 2: Sovereign SRE Agent Demo
- Agent pod deployed
- Agent connected to MCP servers (OpenShift & Gitea)
- Pipeline run triggered and failed
- Gitea issue created by agent

### Module 3: MCP Server Administration
- MCPToolConfig created for tool filtering
- Telemetry enabled on OpenShift MCP Server
- ServiceMonitor created for metrics
- Fetch MCP Server deployed
- Yardstick MCP Server deployed

### Module 4: MCP Registry
- PostgreSQL database deployed (CNPG)
- MCP Registry pod running
- MCP Registry service accessible
- MCP servers registered (at least 2)

## Report Files

### Per-Module Reports

When grading individual modules, reports are saved as:
```
/tmp/grading_dir/grading_report_user1_module_01.txt
/tmp/grading_dir/grading_report_user1_module_02.txt
/tmp/grading_dir/grading_report_user1_module_03.txt
/tmp/grading_dir/grading_report_user1_module_04.txt
```

### Full Lab Report

When grading the entire lab, a consolidated report is created:
```
/tmp/grading_dir/grading_report_user1.txt
```

This report combines results from all modules.

## Troubleshooting

### "PASSWORD environment variable not set"

The grader needs the Gitea password to validate repository access. Set it from AgnosticV user data:

```bash
export PASSWORD="NTEzMjI5OD"  # Get from user data
```

### "OPENSHIFT_CLUSTER_INGRESS_DOMAIN not set"

Set the cluster ingress domain:

```bash
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-kg5jj.dynamic.redhatworkshops.io"
```

### "Report file not found"

Make sure you're running the grader with the correct user:

```bash
export LAB_USER="user1"
grade_lab mcp-with-openshift user1
ls /tmp/grading_dir/grading_report_user1.txt
```

### Permission Issues

If running as system:admin, ensure you have cluster-admin privileges:

```bash
oc auth can-i '*' '*' --all-namespaces
```

## Development

### Testing Changes

```bash
# Pull latest FTL changes
cd ~/ftl
git pull

# Test grader
grade_lab mcp-with-openshift user1 1

# Test solver
solve_lab mcp-with-openshift user1 2
```

### Adding New Checkpoints

1. Edit the appropriate `grade_module_XX.yml` file
2. Add new grader role include with checkpoint details
3. Update `solve_module_XX.yml` with corresponding solution steps
4. Test both grader and solver

## Support

For issues or questions:
- Check FTL documentation: `~/ftl/README.adoc`
- Review grading reports in `/tmp/grading_dir/`
- Check pod logs: `oc logs -n <namespace> <pod-name>`
