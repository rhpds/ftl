# FTL Grader Roles Reference

Complete reference guide for all FTL grader roles with examples and best practices.

---

## Table of Contents

- [Overview](#overview)
- [Generic System Graders](#generic-system-graders)
- [OpenShift/Kubernetes Graders](#openshiftkubernetes-graders)
- [AAP/Tower Graders](#aaptower-graders)
- [HTTP/Network Graders](#httpnetwork-graders)
- [Best Practices](#best-practices)

---

## Overview

Grader roles validate student work without modifying system state. All graders follow a consistent pattern:

1. Check resource/condition exists
2. Validate required attributes
3. Generate PASS/FAIL message
4. Log result to grading report

**Common Variables (All Graders):**
- `task_description_message` (required): Short description for report
- `student_error_message` (optional): Custom failure message
- `grader_student_report_file` (auto-included): Report file path

---

## Generic System Graders

### grader_check_command_output

Validates command output matches expected value (exact or regex).

**Required Variables:**
```yaml
task_description_message: "Description"
command: "cat /etc/hostname"
expected_output: "bastion.example.com"
```

**Optional Variables:**
```yaml
use_regex: false              # Use regex matching instead of exact
student_error_message: "..."  # Custom error message
```

**Example Usage:**
```yaml
- name: Check hostname configured
  ansible.builtin.include_role:
    name: grader_check_command_output
  vars:
    task_description_message: "Hostname set to bastion"
    command: "hostname"
    expected_output: "bastion"
```

---

### grader_check_file_exists

Verifies file or directory exists at specified path.

**Required Variables:**
```yaml
task_description_message: "Description"
file_path: "/etc/myapp/config.yml"
```

**Optional Variables:**
```yaml
check_file_type: "file"       # file, directory, or link
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check config file exists
  ansible.builtin.include_role:
    name: grader_check_file_exists
  vars:
    task_description_message: "Application config file created"
    file_path: "/opt/app/config.yml"
    check_file_type: "file"
```

---

### grader_check_file_contains

Validates file exists and contains expected content.

**Required Variables:**
```yaml
task_description_message: "Description"
file_path: "/etc/myapp/config.yml"
expected_content: "database: postgres"
```

**Optional Variables:**
```yaml
use_regex: false              # Use regex matching
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check database configured in config file
  ansible.builtin.include_role:
    name: grader_check_file_contains
  vars:
    task_description_message: "Database connection configured"
    file_path: "/opt/app/config.yml"
    expected_content: "db_host: postgresql.example.com"
```

---

### grader_check_service_running

Checks systemd service status.

**Required Variables:**
```yaml
task_description_message: "Description"
service_name: "httpd"
```

**Optional Variables:**
```yaml
check_enabled: true           # Also verify service enabled at boot
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check httpd service running
  ansible.builtin.include_role:
    name: grader_check_service_running
  vars:
    task_description_message: "Apache web server running and enabled"
    service_name: "httpd"
    check_enabled: true
```

---

### grader_check_package_installed

Validates package is installed via yum/dnf.

**Required Variables:**
```yaml
task_description_message: "Description"
package_name: "httpd"
```

**Optional Variables:**
```yaml
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check httpd package installed
  ansible.builtin.include_role:
    name: grader_check_package_installed
  vars:
    task_description_message: "Apache HTTP Server installed"
    package_name: "httpd"
```

---

### grader_check_user_exists

Checks if user account exists on the system.

**Required Variables:**
```yaml
task_description_message: "Description"
username: "appuser"
```

**Optional Variables:**
```yaml
check_uid: 1001               # Verify specific UID
check_groups: ["wheel"]       # Verify group membership
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check application user created
  ansible.builtin.include_role:
    name: grader_check_user_exists
  vars:
    task_description_message: "Application service account created"
    username: "appuser"
    check_groups: ["appgroup"]
```

---

### grader_check_container_running

Validates podman/docker container is running.

**Required Variables:**
```yaml
task_description_message: "Description"
container_name_pattern: "myapp-.*"
```

**Optional Variables:**
```yaml
container_runtime: "podman"   # podman or docker
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check database container running
  ansible.builtin.include_role:
    name: grader_check_container_running
  vars:
    task_description_message: "PostgreSQL container running"
    container_name_pattern: "postgres-.*"
    container_runtime: "podman"
```

---

## OpenShift/Kubernetes Graders

### grader_check_ocp_resource

Generic Kubernetes/OpenShift resource validation.

**Required Variables:**
```yaml
task_description_message: "Description"
resource_kind: "Deployment"
resource_name: "myapp"
resource_namespace: "myproject"
```

**Optional Variables:**
```yaml
resource_api_version: "v1"    # Default: v1
label_selectors: []           # Optional label filtering
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check deployment exists
  ansible.builtin.include_role:
    name: grader_check_ocp_resource
  vars:
    task_description_message: "Application deployment created"
    resource_kind: "Deployment"
    resource_name: "myapp"
    resource_namespace: "production"
```

---

### grader_check_ocp_pod_running

Validates pod(s) are in Running status.

**Required Variables:**
```yaml
task_description_message: "Description"
pod_name: "myapp-.*"          # Regex pattern
pod_namespace: "myproject"
```

**Optional Variables:**
```yaml
min_ready_pods: 1             # Minimum pods in Ready state
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check application pod running
  ansible.builtin.include_role:
    name: grader_check_ocp_pod_running
  vars:
    task_description_message: "Application pod running in production namespace"
    pod_name: "myapp-.*"
    pod_namespace: "production"
    min_ready_pods: 1
```

---

### grader_check_ocp_deployment

Validates Deployment exists and optionally checks ready replicas.

**Required Variables:**
```yaml
task_description_message: "Description"
deployment_name: "myapp"
deployment_namespace: "myproject"
```

**Optional Variables:**
```yaml
expected_replicas: 3          # Verify specific number of ready replicas
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check application deployment ready
  ansible.builtin.include_role:
    name: grader_check_ocp_deployment
  vars:
    task_description_message: "Application deployment ready with 3 replicas"
    deployment_name: "myapp"
    deployment_namespace: "production"
    expected_replicas: 3
```

**Note:** This role is a convenience wrapper around `grader_check_ocp_resource` specifically for Deployment validation with replica checking.

---

### grader_check_ocp_route_exists

Validates OpenShift route exists.

**Required Variables:**
```yaml
task_description_message: "Description"
route_name: "myapp"
route_namespace: "myproject"
```

**Optional Variables:**
```yaml
check_https: true             # Verify TLS termination configured
expected_hostname_pattern: "myapp-.*\\.apps\\..*"  # Regex for hostname
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check application route with HTTPS
  ansible.builtin.include_role:
    name: grader_check_ocp_route_exists
  vars:
    task_description_message: "Application route configured with HTTPS"
    route_name: "myapp"
    route_namespace: "production"
    check_https: true
```

---

### grader_check_ocp_service_exists

Validates Kubernetes service exists.

**Required Variables:**
```yaml
task_description_message: "Description"
service_name: "myapp"
service_namespace: "myproject"
```

**Optional Variables:**
```yaml
check_port: 8080              # Verify specific port exposed
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check application service
  ansible.builtin.include_role:
    name: grader_check_ocp_service_exists
  vars:
    task_description_message: "Application service exposing port 8080"
    service_name: "myapp"
    service_namespace: "production"
    check_port: 8080
```

---

### grader_check_ocp_build_completed

Validates BuildConfig exists and Build succeeded (new role).

**Required Variables:**
```yaml
task_description_message: "Description"
build_config_name: "myapp"
build_config_namespace: "myproject"
```

**Optional Variables:**
```yaml
require_build_execution: true # Verify at least one build succeeded
check_last_n_builds: 5        # Number of recent builds to check
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check S2I build completed
  ansible.builtin.include_role:
    name: grader_check_ocp_build_completed
  vars:
    task_description_message: "Nationalparks S2I build completed successfully"
    build_config_name: "nationalparks"
    build_config_namespace: "workshop"
    require_build_execution: true
```

---

### grader_check_ocp_secret_exists

Validates Secret exists with required keys (new role).

**Required Variables:**
```yaml
task_description_message: "Description"
secret_name: "db-credentials"
secret_namespace: "myproject"
```

**Optional Variables:**
```yaml
required_keys:                # List of keys to verify
  - username
  - password
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check database credentials secret
  ansible.builtin.include_role:
    name: grader_check_ocp_secret_exists
  vars:
    task_description_message: "MongoDB credentials secret created"
    secret_name: "mongodb-credentials"
    secret_namespace: "workshop"
    required_keys:
      - admin-usr
      - admin-pwd
      - app-usr
      - app-pwd
```

---

### grader_check_ocp_configmap_exists

Validates ConfigMap exists with required keys (new role).

**Required Variables:**
```yaml
task_description_message: "Description"
configmap_name: "app-config"
configmap_namespace: "myproject"
```

**Optional Variables:**
```yaml
required_keys:                # List of keys to verify
  - database.host
  - database.port
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check application config
  ansible.builtin.include_role:
    name: grader_check_ocp_configmap_exists
  vars:
    task_description_message: "Application configuration created"
    configmap_name: "app-config"
    configmap_namespace: "production"
    required_keys:
      - database.host
      - api.endpoint
```

---

### grader_check_ocp_pvc_exists

Validates PersistentVolumeClaim exists and optionally bound (new role).

**Required Variables:**
```yaml
task_description_message: "Description"
pvc_name: "app-data"
pvc_namespace: "myproject"
```

**Optional Variables:**
```yaml
check_pvc_bound: true         # Verify PVC is Bound to a PV
min_storage_size: "1Gi"       # Minimum storage capacity
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check pipeline workspace PVC
  ansible.builtin.include_role:
    name: grader_check_ocp_pvc_exists
  vars:
    task_description_message: "Pipeline workspace PVC created and bound"
    pvc_name: "app-source-pvc"
    pvc_namespace: "workshop"
    check_pvc_bound: true
    min_storage_size: "1Gi"
```

---

### grader_check_ocp_pipeline_run

Validates Tekton Pipeline and PipelineRun (new role).

**Required Variables:**
```yaml
task_description_message: "Description"
pipeline_name: "build-pipeline"
pipeline_namespace: "myproject"
```

**Optional Variables:**
```yaml
require_pipeline_run: true    # Verify at least one run succeeded
check_last_n_runs: 5          # Number of recent runs to check
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check pipeline executed successfully
  ansible.builtin.include_role:
    name: grader_check_ocp_pipeline_run
  vars:
    task_description_message: "Nationalparks pipeline executed successfully"
    pipeline_name: "nationalparks-pipeline"
    pipeline_namespace: "workshop"
    require_pipeline_run: true
    check_last_n_runs: 10
```

---

## AAP/Tower Graders

### grader_check_aap_licensed

Validates AAP controller is licensed.

**Required Variables:**
```yaml
task_description_message: "Description"
aap_hostname: "https://controller.example.com"
aap_username: "admin"
aap_password: "password"
```

**Optional Variables:**
```yaml
aap_validate_certs: false
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check AAP controller licensed
  ansible.builtin.include_role:
    name: grader_check_aap_licensed
  vars:
    task_description_message: "AAP controller licensed and operational"
    aap_hostname: "{{ lookup('env', 'AAP_HOSTNAME') }}"
    aap_username: "admin"
    aap_password: "{{ lookup('env', 'AAP_PASSWORD') }}"
```

---

### grader_check_aap_job_completed

Validates AAP job template exists and optionally executed successfully.

**Required Variables:**
```yaml
task_description_message: "Description"
job_template_name: "Deploy Application"
```

**Optional Variables:**
```yaml
require_job_execution: true   # Verify job ran successfully
check_last_n_jobs: 5          # Recent jobs to check
allow_failed_status: false    # Accept failed jobs as executed
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check upgrade job executed
  ansible.builtin.include_role:
    name: grader_check_aap_job_completed
  vars:
    task_description_message: "RHEL upgrade job completed successfully"
    job_template_name: "AUTO / 02 Upgrade"
    require_job_execution: true
    check_last_n_jobs: 10
```

---

### grader_check_aap_workflow_completed

Validates AAP workflow template exists and optionally executed successfully.

**Required Variables:**
```yaml
task_description_message: "Description"
workflow_template_name: "Workflow Name"
aap_hostname: "https://controller.example.com"
aap_username: "admin"
aap_password: "password"
```

**Optional Variables:**
```yaml
aap_validate_certs: false
require_job_execution: true   # Verify workflow ran successfully
check_last_n_jobs: 5          # Recent workflow jobs to check
allow_failed_status: false    # Accept failed jobs as executed
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check upgrade workflow executed
  ansible.builtin.include_role:
    name: grader_check_aap_workflow_completed
  vars:
    task_description_message: "RHEL upgrade workflow completed successfully"
    workflow_template_name: "AUTO / 02 Upgrade Workflow"
    aap_hostname: "{{ lookup('env', 'AAP_HOSTNAME') }}"
    aap_username: "admin"
    aap_password: "{{ lookup('env', 'AAP_PASSWORD') }}"
    require_job_execution: true
    check_last_n_jobs: 10
```

---

## HTTP/Network Graders

### grader_check_http_endpoint

Basic HTTP endpoint validation.

**Required Variables:**
```yaml
task_description_message: "Description"
endpoint_url: "https://myapp.example.com"
```

**Optional Variables:**
```yaml
expected_status_code: 200
validate_certs: false
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check application accessible
  ansible.builtin.include_role:
    name: grader_check_http_endpoint
  vars:
    task_description_message: "Application web UI accessible"
    endpoint_url: "https://myapp-production.apps.cluster.example.com"
    expected_status_code: 200
```

---

### grader_check_http_json_response

Advanced HTTP validation with JSON content checks (new role).

**Required Variables:**
```yaml
task_description_message: "Description"
endpoint_url: "https://api.example.com/info"
```

**Optional Variables:**
```yaml
expected_status_code: 200
validate_https: true          # Require HTTPS
validate_certs: false
json_field_checks:            # Fields that must exist
  - id
  - version
json_value_checks:            # Field values to validate
  id: "myapp"
  version: "1.0"
timeout: 10
student_error_message: "..."
```

**Example Usage:**
```yaml
- name: Check API returns correct metadata
  ansible.builtin.include_role:
    name: grader_check_http_json_response
  vars:
    task_description_message: "Nationalparks API returns correct metadata"
    endpoint_url: "https://nationalparks-workshop.apps.example.com/ws/info/"
    validate_https: true
    json_field_checks:
      - id
      - displayName
      - center
      - zoom
    json_value_checks:
      id: "nationalparks"
```

---

## Best Practices

### 1. Error Messages

Provide helpful error messages that tell students:
- **What failed**: Which resource/condition
- **Why it failed**: Current state vs expected state
- **How to fix**: Command to check status or corrective action

**Good Example:**
```yaml
student_error_message: |
  BuildConfig 'nationalparks' not found in namespace {{ project_name }}.

  Deploy the application from source:
    1. Open Developer Perspective
    2. Click +Add → Import from Git
    3. Enter repository URL
    4. Set name to 'nationalparks'

  Check builds: oc get builds -n {{ project_name }}
```

**Bad Example:**
```yaml
student_error_message: "Build not found"  # Too vague
```

---

### 2. Variable Scope

Remember: **Ansible plays have isolated variable scopes**

Always define `grader_student_report_file` in EVERY play:

```yaml
# Play 1: Initialize
- name: Initialize Grading
  vars:
    grader_student_report_file: "grading_report_{{ lookup('env', 'LAB_USER') }}_module_01.txt"
  roles:
    - ftl_run_init

# Play 2: Grade (MUST include the variable again!)
- name: Grade Module
  vars:
    grader_student_report_file: "grading_report_{{ lookup('env', 'LAB_USER') }}_module_01.txt"
  tasks:
    - include_role: grader_check_ocp_pod_running

# Play 3: Finalize
- name: Finalize Grading
  vars:
    grader_student_report_file: "grading_report_{{ lookup('env', 'LAB_USER') }}_module_01.txt"
  roles:
    - ftl_run_grade_report_generation
    - ftl_run_finish
```

---

### 3. Regex Patterns

Use regex patterns for dynamic resource names:

```yaml
# Pod names have random suffixes
pod_name: "myapp-.*"

# Route hostnames vary by cluster
expected_hostname_pattern: "myapp-.*\\.apps\\..*\\.example\\.com"
```

---

### 4. Conditional Validation

Make checks optional when appropriate:

```yaml
require_build_execution: false   # Only check BuildConfig exists
require_pipeline_run: true       # Verify pipeline actually ran
check_pvc_bound: true           # Ensure PVC is usable
```

---

### 5. Namespace Patterns

Support multi-user environments:

```yaml
# Good - supports multiple users
pod_namespace: "workshop-{{ lookup('env', 'LAB_USER') }}"

# Bad - hardcoded
pod_namespace: "workshop-user1"
```

---

### 6. Error Handling

Use `failed_when: false` instead of `ignore_errors: true` to avoid scary red output:

```yaml
- name: Check if resource exists
  kubernetes.core.k8s_info:
    kind: Pod
    name: "{{ pod_name }}"
    namespace: "{{ pod_namespace }}"
  register: r_pod
  failed_when: false  # Clean output, no red errors
```

---

### 7. Downstream Evidence

When direct evidence is unavailable, infer from later checkpoints:

```yaml
# If logs aren't accessible but Gitea issue was created,
# the agent must have connected and investigated
- name: Use downstream evidence
  ansible.builtin.set_fact:
    agent_connected: "{{
      (logs_show_connection) or
      (gitea_issue_created)  # Issue creation proves connection
    }}"
```

---

## Role Development Checklist

When creating a new grader role:

- [ ] Clear documentation in role header
- [ ] Required variables documented
- [ ] Optional variables with defaults
- [ ] Helpful default error messages
- [ ] Support for custom error messages
- [ ] Use `failed_when: false` for checks
- [ ] Logical success criteria
- [ ] Call `ftl_run_log_grade_to_log` at end
- [ ] Example usage in documentation
- [ ] Test with missing resources
- [ ] Test with partial completion
- [ ] Test with full completion

---

## Summary

**Total Grader Roles: 22**

| Category | Count | Roles |
|----------|-------|-------|
| Generic System | 7 | command_output, file_exists, file_contains, service_running, package_installed, user_exists, container_running |
| OpenShift/K8s | 11 | resource, pod_running, deployment, route_exists, service_exists, build_completed, secret_exists, configmap_exists, pvc_exists, pipeline_run |
| AAP/Tower | 3 | aap_licensed, aap_job_completed, aap_workflow_completed |
| HTTP/Network | 2 | http_endpoint, http_json_response |

**Note:** The count includes one missing role in the table above - `grader_check_ocp_resource` should be listed but was omitted for brevity as it's the foundational role that other OCP graders build upon.

All roles follow consistent patterns, provide helpful error messages, and integrate seamlessly with the FTL framework lifecycle.
