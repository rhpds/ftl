# grader_check_ocp_pvc_exists

Verify OpenShift/Kubernetes PersistentVolumeClaim exists and optionally validate bound status for FTL lab grading.

## Purpose

This role checks if a PVC exists and optionally validates:
- PVC is in Bound status (attached to a PV)
- PVC has minimum required storage size

Useful for validating storage configuration for applications, databases, and pipelines.

## Requirements

- Ansible >= 2.9
- kubernetes.core collection >= 2.4.0

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `task_description_message` | - | Yes | Human-readable task description |
| `pvc_name` | - | Yes | Name of the PVC to check |
| `pvc_namespace` | - | Yes | Namespace containing the PVC |
| `check_pvc_bound` | `false` | No | If true, verifies PVC is Bound |
| `min_storage_size` | - | No | Minimum storage size (e.g., "1Gi") |
| `student_error_message` | (auto-generated) | No | Custom error message on failure |

## Example Playbook

```yaml
- name: Verify pipeline workspace PVC
  include_role:
    name: rhdp.ftl.grader_check_ocp_pvc_exists
  vars:
    task_description_message: "Pipeline workspace PVC created and bound"
    pvc_name: "app-source-pvc"
    pvc_namespace: "workshop"
    check_pvc_bound: true
    min_storage_size: "1Gi"
```

## PVC Status Values

| Status | Meaning |
|--------|---------|
| `Bound` | PVC successfully attached to PV |
| `Pending` | PVC waiting for available PV |
| `Lost` | PV lost, data may be unavailable |

## License

Apache-2.0

## Author

Red Hat Demo Platform
