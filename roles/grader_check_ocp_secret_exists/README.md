# grader_check_ocp_secret_exists

Verify OpenShift/Kubernetes Secret exists and optionally validate keys for FTL lab grading.

## Purpose

This role checks if a Secret exists and optionally validates:
- Secret contains required keys
- Secret exists in correct namespace

Useful for validating database credentials, API tokens, and configuration secrets.

## Requirements

- Ansible >= 2.9
- kubernetes.core collection >= 2.4.0
- OpenShift/Kubernetes cluster access configured

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `task_description_message` | - | Yes | Human-readable task description |
| `secret_name` | - | Yes | Name of the Secret to check |
| `secret_namespace` | - | Yes | Namespace containing the Secret |
| `required_keys` | `[]` | No | List of keys that must exist in Secret data |
| `student_error_message` | (auto-generated) | No | Custom error message on failure |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result
- kubernetes.core.k8s_info module

## Example Playbook

### Example 1: Check Secret exists

```yaml
- name: Verify database credentials secret exists
  include_role:
    name: rhdp.ftl.grader_check_ocp_secret_exists
  vars:
    task_description_message: "Database credentials secret created"
    secret_name: "db-credentials"
    secret_namespace: "production"
```

### Example 2: Validate Secret keys

```yaml
- name: Verify MongoDB credentials with required keys
  include_role:
    name: rhdp.ftl.grader_check_ocp_secret_exists
  vars:
    task_description_message: "MongoDB credentials secret has all required keys"
    secret_name: "mongodb-credentials"
    secret_namespace: "workshop"
    required_keys:
      - admin-usr
      - admin-pwd
      - app-usr
      - app-pwd
    student_error_message: |
      Secret mongodb-credentials missing required keys.

      Create secret:
        oc create secret generic mongodb-credentials \
          --from-literal=admin-usr=admin \
          --from-literal=admin-pwd=password \
          --from-literal=app-usr=appuser \
          --from-literal=app-pwd=apppass
```

## How It Works

1. **Check Existence**: Uses k8s_info to check if Secret exists
2. **Get Keys**: Extracts all keys from Secret.data
3. **Validate Keys**: Checks if all required_keys are present
4. **Generate Result**: Creates PASS/FAIL message with missing keys listed

## License

Apache-2.0

## Author

Red Hat Demo Platform
