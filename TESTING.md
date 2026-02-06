# FTL Testing Guide - MCP with OpenShift Lab

## Quick Start (for Team Review)

### From Bastion Host

```bash
# 1. Install FTL (first time only)
git clone https://github.com/rhpds/ftl.git ~/ftl
cd ~/ftl

# 2. Add to PATH (optional but recommended)
echo 'export PATH="$HOME/ftl/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 3. Set environment (system:admin on bastion)
export LAB_USER=user1  # Which student to grade

# 4. Grade the lab
grade_lab mcp-with-openshift

# 5. Solve the lab (auto-complete)
solve_lab mcp-with-openshift
```

### Test Individual Modules

```bash
# Grade specific modules
grade_lab mcp-with-openshift 1  # Module 1: Lab Setup
grade_lab mcp-with-openshift 2  # Module 2: SRE Agent Demo
grade_lab mcp-with-openshift 3  # Module 3: MCP Server Administration
grade_lab mcp-with-openshift 4  # Module 4: MCP Registry

# Solve specific modules
solve_lab mcp-with-openshift 1
solve_lab mcp-with-openshift 2
solve_lab mcp-with-openshift 3
solve_lab mcp-with-openshift 4
```

### Manual Testing (without wrappers)

```bash
cd ~/ftl

# Set environment
export LAB_USER=user1
export GUID=$(hostname | cut -d'-' -f2)
export OPENSHIFT_API_URL=https://api.cluster-kg5jj.dynamic.redhatworkshops.io:6443
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN=apps.cluster-kg5jj.dynamic.redhatworkshops.io

# Run grader directly
ansible-playbook labs/mcp-with-openshift/grade_lab.yml

# View report
cat /tmp/grading_dir/grading_report.txt
```

## Expected Results

### Module 1: Lab Setup (5 checkpoints)
✅ 1.1: OpenShift access validated
✅ 1.2: MCP OpenShift Server pod is running
✅ 1.3: MCP Gitea Server pod is running
✅ 1.4: Gitea repository 'mcp' accessible
✅ 1.5: LibreChat route is accessible

### Module 2: SRE Agent Demo (4 checkpoints)
✅ 2.1: Agent pod is running
✅ 2.2: Agent connected to MCP servers (129 tools)
✅ 2.3: Pipeline run with broken branch executed and failed
✅ 2.4: Gitea issue created by agent

### Module 3: MCP Server Administration (5 checkpoints)
✅ 3.1: MCPToolConfig 'openshift-tool-filter' created
✅ 3.2: Telemetry enabled - metrics endpoint accessible
✅ 3.3: ServiceMonitor 'mcp-openshift' created
✅ 3.4: Fetch MCP Server pod is running
✅ 3.5: Yardstick MCP Server pod is running

### Module 4: MCP Registry (4 checkpoints)
✅ 4.1: PostgreSQL database pod is running
✅ 4.2: MCP Registry pod is running
✅ 4.3: MCP Registry service 'mcp-registry-api' exists
✅ 4.4: MCP servers registered in registry (at least 2)

**Total: 18/18 checkpoints passing**

## Verification Commands

### Check Namespaces
```bash
oc get pods -n mcp-openshift-user1
oc get pods -n mcp-gitea-user1
oc get pods -n agent-user1
```

### Check Custom Resources
```bash
oc get mcpserver -n mcp-openshift-user1
oc get mcpserver -n mcp-gitea-user1
oc get mcptoolconfig -n mcp-openshift-user1
oc get mcpregistry -n mcp-gitea-user1
```

### Check Registry
```bash
# Get registry route
oc get route mcp-registry -n mcp-gitea-user1

# Query registry API
curl -s -k https://mcp-registry-mcp-gitea-user1.apps.cluster-kg5jj.dynamic.redhatworkshops.io/registry/rh-one-mcp/v0.1/servers | jq
```

## Troubleshooting

### Reset Module (for testing solver)

```bash
# Module 2: Delete pipeline run
oc delete pipelineruns --all -n agent-user1

# Module 3: Delete additional MCP servers
oc delete mcpserver fetch yardstick -n mcp-gitea-user1
oc delete mcptoolconfig openshift-tool-filter -n mcp-openshift-user1

# Module 4: Delete registry
oc delete mcpregistry mcp-registry -n mcp-gitea-user1
oc delete cluster mcp-registry-db -n mcp-gitea-user1
oc delete route mcp-registry -n mcp-gitea-user1
oc delete configmap rh-one-mcp -n mcp-gitea-user1
oc delete secret mcp-registry-db-password -n mcp-gitea-user1
```

### Common Issues

**Issue: LAB_USER not set**
```bash
export LAB_USER=user1
```

**Issue: grader_check_ocp_resource can't find custom resources**
- Ensure `resource_api_version` is specified for CRDs
- Example: `resource_api_version: "toolhive.stacklok.dev/v1alpha1"`

**Issue: Pod name patterns don't match**
- Check actual pod names: `oc get pods -n <namespace>`
- Update grader patterns to match (e.g., `openshift-.*` instead of `mcp-openshift-server-.*`)

## Architecture Notes

### Execution Model
- Graders run as **system:admin** from bastion
- LAB_USER environment variable specifies which student to grade
- Multi-user support: `mcp-openshift-user1`, `mcp-openshift-user2`, etc.

### Key Design Decisions
1. **100% API-based validation** - No browser automation (Playwright)
2. **Pre-rendered error messages** - Prevents Ansible template recursion loops
3. **API version support** - Custom resources require explicit API version
4. **jq over JSONPath** - More reliable for complex queries
5. **Namespace-scoped permissions** - Students don't need cluster-admin

## File Structure

```
ftl/
├── bin/
│   ├── grade_lab          # Student wrapper for grading
│   ├── solve_lab          # Student wrapper for solving
│   └── README.md          # Wrapper documentation
├── roles/
│   ├── ftl_run_init/      # Initialize grading session
│   ├── ftl_run_log_grade_to_log/  # Log results
│   ├── ftl_run_grade_report_generation/  # Generate report
│   ├── ftl_run_finish/    # Finalize session
│   ├── grader_check_ocp_resource/  # Generic OCP resource validator
│   ├── grader_check_ocp_pod_running/  # Pod state validator
│   ├── grader_check_command_output/   # Command output validator
│   └── ...
└── labs/
    └── mcp-with-openshift/
        ├── lab.yml           # Lab metadata
        ├── grade_lab.yml     # Main grader (all modules)
        ├── grade_module_01.yml
        ├── grade_module_02.yml
        ├── grade_module_03.yml
        ├── grade_module_04.yml
        ├── solve_lab.yml     # Main solver (all modules)
        ├── solve_module_01.yml
        ├── solve_module_02.yml
        ├── solve_module_03.yml
        └── solve_module_04.yml
```

## Next Steps

1. **Test on fresh cluster** - Validate graders on clean environment
2. **Add to AgnosticV catalog** - Include in `post_software` phase
3. **Create student documentation** - How to use grade_lab/solve_lab
4. **Add more labs** - Use MCP lab as template
5. **Consider LMS integration** - SCORMCLOUD API for grade reporting
