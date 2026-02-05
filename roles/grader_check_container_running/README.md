# grader_check_container_running

Verify container is running for FTL lab grading.

## Purpose

This role checks if a podman or docker container is running and optionally validates the container image.

## Requirements

- Ansible >= 2.9
- Podman or Docker installed on target system

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `container_name` | - | Yes | Name of the container to check |
| `task_description_message` | - | Yes | Human-readable task description |
| `container_runtime` | `podman` | No | Container runtime: `podman` or `docker` |
| `student_error_message` | `"Container is not running"` | No | Error message on failure |
| `check_image` | `""` | No | Verify container is running specific image |
| `expected_status` | `running` | No | Expected container status |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result

## Example Playbook

### Example 1: Check podman container is running

```yaml
- name: Verify web application container is running
  include_role:
    name: rhdp.ftl.grader_check_container_running
  vars:
    task_description_message: "Web application container is running"
    container_name: "webapp"
    student_error_message: "Webapp container not running. Start with: podman start webapp"
```

### Example 2: Check docker container with specific image

```yaml
- name: Verify database container running correct image
  include_role:
    name: rhdp.ftl.grader_check_container_running
  vars:
    task_description_message: "PostgreSQL container running with correct image"
    container_name: "postgres-db"
    container_runtime: "docker"
    check_image: "postgres:15"
    student_error_message: "PostgreSQL container not running or wrong image"
```

### Example 3: Check container has exited successfully

```yaml
- name: Verify batch job container completed
  include_role:
    name: rhdp.ftl.grader_check_container_running
  vars:
    task_description_message: "Batch job container exited successfully"
    container_name: "batch-job"
    expected_status: "exited"
    student_error_message: "Batch job did not complete"
```

### Example 4: Check Edge device container

```yaml
- name: Verify POS application running on edge device
  include_role:
    name: rhdp.ftl.grader_check_container_running
  vars:
    task_description_message: "POS application container running on edge"
    container_name: "new-pos-app"
    check_image: "quay.io/rhdp/pos-app:latest"
    student_error_message: "POS container not running. Deploy with: podman run -d --name new-pos-app quay.io/rhdp/pos-app:latest"
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
