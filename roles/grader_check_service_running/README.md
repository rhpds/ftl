# grader_check_service_running

Verify systemd service is running for FTL lab grading.

## Purpose

This role checks if a systemd service is active (running) and optionally verifies if it's enabled to start on boot.

## Requirements

- Ansible >= 2.9
- systemd on target system

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `service_name` | - | Yes | Name of the systemd service to check |
| `task_description_message` | - | Yes | Human-readable task description |
| `check_enabled` | `false` | No | Also verify service is enabled |
| `student_error_message` | `"Service is not running"` | No | Error message on failure |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result

## Example Playbook

### Example 1: Check service is running

```yaml
- name: Verify Apache is running
  include_role:
    name: rhdp.ftl.grader_check_service_running
  vars:
    task_description_message: "Apache web server is running"
    service_name: "httpd"
    student_error_message: "Apache not running. Start with: systemctl start httpd"
```

### Example 2: Check service is running and enabled

```yaml
- name: Verify PostgreSQL is running and enabled
  include_role:
    name: rhdp.ftl.grader_check_service_running
  vars:
    task_description_message: "PostgreSQL database is running and enabled"
    service_name: "postgresql"
    check_enabled: true
    student_error_message: "PostgreSQL not properly configured. Run: systemctl enable --now postgresql"
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
