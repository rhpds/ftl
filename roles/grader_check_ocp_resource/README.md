# grader_check_ocp_resource

Generic OpenShift/Kubernetes resource validation grader role.

## Purpose

Validates that an OpenShift/Kubernetes resource exists and optionally checks its state.

## Requirements

- `kubernetes.core` collection
- Access to OpenShift/Kubernetes cluster (kubeconfig or in-cluster auth)

## Role Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `task_description_message` | Human-readable description for grading report | "MCP Server pod exists" |
| `resource_kind` | Kubernetes resource kind | "Pod", "Deployment", "Service", "Route" |
| `resource_name` | Name of the resource (supports regex) | "mcp-server" or "mcp-.*" |
| `resource_namespace` | Namespace where resource should exist | "mcp-demo" |

### Optional

| Variable | Description | Example |
|----------|-------------|---------|
| `resource_state` | Expected state value | "Running" |
| `resource_state_path` | JSONPath to state field | "status.phase" |
| `student_error_message` | Custom error message | "Pod not running" |

## Example Usage

### Check if Pod Exists

```yaml
- include_role:
    name: grader_check_ocp_resource
  vars:
    task_description_message: "MCP Server pod exists"
    resource_kind: "Pod"
    resource_name: "mcp-server"
    resource_namespace: "mcp-demo"
    student_error_message: "MCP Server pod not found"
```

### Check Pod with State Validation

```yaml
- include_role:
    name: grader_check_ocp_resource
  vars:
    task_description_message: "MCP Server pod is running"
    resource_kind: "Pod"
    resource_name: "mcp-server-.*"  # Regex pattern
    resource_namespace: "mcp-demo"
    resource_state: "Running"
    resource_state_path: "status.phase"
    student_error_message: "MCP Server pod not in Running state"
```

### Check Deployment with Replicas

```yaml
- include_role:
    name: grader_check_ocp_resource
  vars:
    task_description_message: "Registry has 1 ready replica"
    resource_kind: "Deployment"
    resource_name: "mcp-registry"
    resource_namespace: "mcp-registry"
    resource_state: 1
    resource_state_path: "status.readyReplicas"
    student_error_message: "Registry deployment not ready"
```

### Check Custom Resource

```yaml
- include_role:
    name: grader_check_ocp_resource
  vars:
    task_description_message: "MCPToolConfig exists"
    resource_kind: "MCPToolConfig"
    resource_name: "readonly-tools"
    resource_namespace: "mcp-demo"
    student_error_message: "Tool filtering configuration not found"
```

## Return Values

Sets the following facts:

- `success`: Boolean indicating if validation passed
- `grader_output_message`: Formatted PASS/FAIL message for the report

## Dependencies

- `ftl_run_log_grade_to_log` role (called automatically)

## Author

Red Hat Demo Platform - FTL Collection
