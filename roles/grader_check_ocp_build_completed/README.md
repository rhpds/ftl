# grader_check_ocp_build_completed

Verify OpenShift BuildConfig exists and optionally validate Build completion for FTL lab grading.

## Purpose

This role checks if an OpenShift BuildConfig exists and optionally validates:
- At least one Build has completed successfully
- Recent Build history (last N builds)
- Build status (Complete, Failed, Running, etc.)

Useful for validating Source-to-Image (S2I) builds in OpenShift labs.

## Requirements

- Ansible >= 2.9
- kubernetes.core collection >= 2.4.0
- OpenShift/Kubernetes cluster access configured (kubeconfig)

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `task_description_message` | - | Yes | Human-readable task description |
| `build_config_name` | - | Yes | Name of the BuildConfig to check |
| `build_config_namespace` | - | Yes | Namespace containing the BuildConfig |
| `require_build_execution` | `false` | No | If true, verifies at least one Build succeeded |
| `check_last_n_builds` | `5` | No | Number of recent Builds to check |
| `student_error_message` | (auto-generated) | No | Custom error message on failure |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result
- kubernetes.core.k8s_info module

## Example Playbook

### Example 1: Check BuildConfig exists

```yaml
- name: Verify BuildConfig exists
  include_role:
    name: rhdp.ftl.grader_check_ocp_build_completed
  vars:
    task_description_message: "Nationalparks BuildConfig created"
    build_config_name: "nationalparks"
    build_config_namespace: "workshop"
```

### Example 2: Verify Build completed successfully

```yaml
- name: Verify S2I build completed
  include_role:
    name: rhdp.ftl.grader_check_ocp_build_completed
  vars:
    task_description_message: "Nationalparks S2I build completed successfully"
    build_config_name: "nationalparks"
    build_config_namespace: "workshop"
    require_build_execution: true
    check_last_n_builds: 10
    student_error_message: |
      S2I build for nationalparks not found or failed.

      Start build: oc start-build nationalparks
      Monitor build: oc logs -f bc/nationalparks
      Check builds: oc get builds
```

### Example 3: Multi-user environment

```yaml
- name: Verify student's build completed
  include_role:
    name: rhdp.ftl.grader_check_ocp_build_completed
  vars:
    task_description_message: "User {{ lookup('env', 'LAB_USER') }} build completed"
    build_config_name: "myapp"
    build_config_namespace: "workshop-{{ lookup('env', 'LAB_USER') }}"
    require_build_execution: true
```

## How It Works

1. **Check BuildConfig Existence**: Uses k8s_info to check if BuildConfig exists
2. **Get Build History** (if require_build_execution=true): Retrieves recent Builds with label `buildconfig={{ build_config_name }}`
3. **Sort by Timestamp**: Sorts Builds by creation timestamp (newest first)
4. **Check Success**: Looks for at least one Build with `status.phase == 'Complete'` in last N builds
5. **Generate Result**: Creates PASS/FAIL message with helpful context

## Build Status Values

| Status | Meaning |
|--------|---------|
| `Complete` | Build finished successfully |
| `Failed` | Build encountered an error |
| `Running` | Build currently in progress |
| `Pending` | Build waiting to start |
| `Cancelled` | Build was manually cancelled |

## License

Apache-2.0

## Author

Red Hat Demo Platform
