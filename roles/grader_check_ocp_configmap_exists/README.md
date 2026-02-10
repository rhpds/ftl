# grader_check_ocp_configmap_exists

Verify OpenShift/Kubernetes ConfigMap exists and optionally validate keys for FTL lab grading.

## Purpose

This role checks if a ConfigMap exists and optionally validates:
- ConfigMap contains required keys
- ConfigMap exists in correct namespace

Useful for validating application configuration, environment settings, and config files.

## Requirements

- Ansible >= 2.9
- kubernetes.core collection >= 2.4.0

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `task_description_message` | - | Yes | Human-readable task description |
| `configmap_name` | - | Yes | Name of the ConfigMap to check |
| `configmap_namespace` | - | Yes | Namespace containing the ConfigMap |
| `required_keys` | `[]` | No | List of keys that must exist in ConfigMap data |
| `student_error_message` | (auto-generated) | No | Custom error message on failure |

## Example Playbook

```yaml
- name: Verify application config
  include_role:
    name: rhdp.ftl.grader_check_ocp_configmap_exists
  vars:
    task_description_message: "Application configuration created"
    configmap_name: "app-config"
    configmap_namespace: "production"
    required_keys:
      - database.host
      - api.endpoint
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
