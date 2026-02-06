# FTL - Finish The Labs

Automated grading and solving framework for hands-on labs using Ansible.

## Overview

FTL (Finish The Labs) provides automated validation (grading) and completion (solving) for hands-on technical labs. It's designed to work with AgnosticV/AgnosticD catalogs and supports multiple lab types: OpenShift, Ansible, RHEL, AI, Virtualization, etc.

## Features

- ✅ **Automated Grading** - Validate lab completion with detailed checkpoints
- ✅ **Auto-Solving** - Complete labs automatically for testing or demos
- ✅ **Multi-User Support** - Grade individual students in shared environments
- ✅ **Reusable Roles** - Pre-built grader/solver roles for common checks
- ✅ **OpenShift Native** - Custom resource validation (MCPServer, MCPRegistry, etc.)
- ✅ **Signed Reports** - SHA256-signed grading reports for verification
- ✅ **Student-Friendly** - Simple wrapper scripts for easy usage

## Quick Start

### On Bastion (as system:admin)

```bash
# Clone FTL
git clone https://github.com/rhpds/ftl.git ~/ftl

# Add to PATH
echo 'export PATH="$HOME/ftl/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Set which student to grade
export LAB_USER=user1

# Grade the lab
grade_lab mcp-with-openshift

# Or solve (auto-complete) the lab
solve_lab mcp-with-openshift
```

## Current Labs

### MCP with OpenShift (`mcp-with-openshift`)
**Model Context Protocol Enterprise Integration Lab**

- **Modules**: 4 modules, 18 total checkpoints
- **Duration**: 60-90 minutes
- **Technology**: OpenShift, MCP, ToolHive, LibreChat, Gitea, PostgreSQL
- **Validation**: 100% API-based (no browser automation)

**Checkpoints:**
- Module 1: Lab Setup (5 checkpoints)
- Module 2: SRE Agent Demo (4 checkpoints)
- Module 3: MCP Server Administration (5 checkpoints)
- Module 4: MCP Registry (4 checkpoints)

**Test Status**: ✅ All 18/18 checkpoints passing

## Architecture

### Execution Model
- **Graders** run as `system:admin` on bastion
- **Multi-user** via `LAB_USER` environment variable
- **Check mode** - graders don't modify resources
- **Solvers** make actual changes to complete labs

### Directory Structure

```
ftl/
├── bin/                    # Student wrapper scripts
│   ├── grade_lab          # Grade lab wrapper
│   ├── solve_lab          # Solve lab wrapper
│   └── README.md
├── roles/                  # Reusable grader/solver roles
│   ├── ftl_run_init/
│   ├── ftl_run_log_grade_to_log/
│   ├── ftl_run_grade_report_generation/
│   ├── ftl_run_finish/
│   ├── grader_check_ocp_resource/
│   ├── grader_check_ocp_pod_running/
│   ├── grader_check_command_output/
│   └── ...
├── labs/                   # Lab-specific graders/solvers
│   └── mcp-with-openshift/
│       ├── lab.yml        # Lab metadata
│       ├── grade_lab.yml  # Main grader
│       ├── grade_module_*.yml
│       ├── solve_lab.yml  # Main solver
│       └── solve_module_*.yml
├── plugins/               # Custom Ansible modules
│   ├── modules/
│   │   └── agnosticd_user_info.py
│   └── action/
│       └── agnosticd_user_info.py
├── ansible.cfg            # Ansible configuration
├── TESTING.md             # Testing guide
└── README.md              # This file
```

### Key Grader Roles

**Lifecycle Roles:**
- `ftl_run_init` - Initialize grading session
- `ftl_run_log_grade_to_log` - Log PASS/FAIL results
- `ftl_run_grade_report_generation` - Generate signed report
- `ftl_run_finish` - Display final results

**OpenShift Graders:**
- `grader_check_ocp_resource` - Generic K8s/OCP resource validator
- `grader_check_ocp_pod_running` - Verify pod Running state
- `grader_check_ocp_route_exists` - Verify route exists
- `grader_check_ocp_deployment` - Verify deployment
- `grader_check_ocp_service_exists` - Verify service

**Generic Graders:**
- `grader_check_command_output` - Execute and validate command output
- `grader_check_file_exists` - Verify file/directory exists
- `grader_check_service_running` - Verify systemd service
- `grader_check_package_installed` - Verify RPM package
- `grader_check_user_exists` - Verify user account
- `grader_check_container_running` - Verify podman/docker container

## Usage Examples

### Grade Individual Modules

```bash
# Grade specific modules
grade_lab mcp-with-openshift 1  # Module 1 only
grade_lab mcp-with-openshift 2  # Module 2 only
grade_lab mcp-with-openshift 3  # Module 3 only
grade_lab mcp-with-openshift 4  # Module 4 only
```

### Solve Individual Modules

```bash
# Auto-complete specific modules
solve_lab mcp-with-openshift 1
solve_lab mcp-with-openshift 2
solve_lab mcp-with-openshift 3
solve_lab mcp-with-openshift 4
```

### Manual Execution

```bash
cd ~/ftl

# Set environment
export LAB_USER=user1
export GUID=abc123
export OPENSHIFT_API_URL=https://api.cluster.example.com:6443

# Run grader directly
ansible-playbook labs/mcp-with-openshift/grade_lab.yml

# View report
cat /tmp/grading_dir/grading_report.txt
```

## Grading Report Format

```
================================================================================
FTL Grading Report
================================================================================

Lab:      Model Context Protocol (MCP) Enterprise Integration
Date:     2026-02-06 07:45:02 UTC
Student:  user1
GUID:     kg5jj

================================================================================
Results
================================================================================

PASS: OpenShift access validated
PASS: MCP OpenShift Server pod is running
PASS: MCP Gitea Server pod is running
PASS: Gitea repository 'mcp' accessible
PASS: LibreChat route is accessible
...

================================================================================
Summary
================================================================================

SUCCESS 0 Errors

SHA256: a2227ed2a65e0cc823cbfdb13e856742741835ae4b5344f6ee9e449ee997aef7
================================================================================
```

## AgnosticV Integration

FTL is designed to integrate with AgnosticV catalogs in the `post_software` phase:

```yaml
# catalog/dev.yaml
post_software:
  - name: Install FTL
    ansible.builtin.git:
      repo: https://github.com/rhpds/ftl.git
      dest: /home/{{ ansible_user }}/ftl
    delegate_to: bastion

  - name: Deploy grade_lab wrapper
    ansible.builtin.copy:
      src: /home/{{ ansible_user }}/ftl/bin/grade_lab
      dest: /usr/local/bin/grade_lab
      mode: '0755'
    delegate_to: bastion

  - name: Set LAB_USER for grading
    ansible.builtin.lineinfile:
      path: /home/{{ ansible_user }}/.bashrc
      line: 'export LAB_USER={{ ansible_user }}'
    delegate_to: bastion
```

## Creating New Labs

1. **Create lab directory:**
   ```bash
   mkdir -p labs/my-lab
   ```

2. **Create lab metadata** (`labs/my-lab/lab.yml`)

3. **Create graders** (`grade_module_01.yml`, `grade_module_02.yml`, etc.)

4. **Create solvers** (`solve_module_01.yml`, `solve_module_02.yml`, etc.)

5. **Create orchestrators** (`grade_lab.yml`, `solve_lab.yml`)

See `labs/mcp-with-openshift/` for a complete example.

## Key Design Decisions

### 1. 100% API-Based Validation
No browser automation (Playwright) - all validation via Kubernetes API, CLI commands, and HTTP APIs.

### 2. Pre-Rendered Error Messages
Prevents Ansible template recursion loops by using `set_fact` before passing variables to roles.

### 3. API Version Support for CRDs
Custom resources require explicit `resource_api_version` parameter:
```yaml
resource_api_version: "toolhive.stacklok.dev/v1alpha1"
```

### 4. jq Over JSONPath
More reliable for complex queries and better error handling than Kubernetes JSONPath.

### 5. Namespace-Scoped Permissions
Students don't need cluster-admin - graders run as system:admin, validate student namespaces.

## Testing

See [TESTING.md](TESTING.md) for comprehensive testing guide.

## Contributing

1. Create feature branch
2. Add/modify grader roles in `roles/`
3. Test with real lab environment
4. Submit PR with test results

## Support

- **Issues**: https://github.com/rhpds/ftl/issues
- **Source**: https://github.com/rhpds/ftl
- **Docs**: See `docs/` directory (coming soon)

## License

Apache 2.0

## Authors

Red Hat Demo Platform (RHDP) Team
