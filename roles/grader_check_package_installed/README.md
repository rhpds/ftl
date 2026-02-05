# grader_check_package_installed

Verify package is installed for FTL lab grading.

## Purpose

This role checks if an RPM/DNF package is installed on the system using Ansible's package module in check mode.

## Requirements

- Ansible >= 2.9
- DNF or YUM package manager

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `package_name` | - | Yes | Name of the package to check |
| `task_description_message` | - | Yes | Human-readable task description |
| `student_error_message` | `"Package is not installed"` | No | Error message on failure |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result

## Example Playbook

```yaml
- name: Verify Apache package is installed
  include_role:
    name: rhdp.ftl.grader_check_package_installed
  vars:
    task_description_message: "Apache web server package installed"
    package_name: "httpd"
    student_error_message: "Apache not installed. Install with: dnf install -y httpd"
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
