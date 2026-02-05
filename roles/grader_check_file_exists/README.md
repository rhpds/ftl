# grader_check_file_exists

Verify file or directory exists for FTL lab grading.

## Purpose

This role checks if a file or directory exists and optionally validates:
- File type (file, directory, link)
- Permissions (mode)
- Owner
- Group

## Requirements

- Ansible >= 2.9

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `file_path` | - | Yes | Path to file or directory to check |
| `task_description_message` | - | Yes | Human-readable task description |
| `file_type` | `"any"` | No | Expected type: file, directory, link, any |
| `check_mode_permissions` | `""` | No | Expected permissions (e.g., "0644") |
| `check_owner` | `""` | No | Expected file owner |
| `check_group` | `""` | No | Expected file group |
| `student_error_message` | `"File or directory not found"` | No | Error message on failure |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result

## Example Playbook

### Example 1: Check file exists

```yaml
- name: Verify configuration file exists
  include_role:
    name: rhdp.ftl.grader_check_file_exists
  vars:
    task_description_message: "Apache configuration file exists"
    file_path: "/etc/httpd/conf/httpd.conf"
    file_type: "file"
    student_error_message: "Configuration file not found"
```

### Example 2: Check directory exists

```yaml
- name: Verify application directory exists
  include_role:
    name: rhdp.ftl.grader_check_file_exists
  vars:
    task_description_message: "Application directory created"
    file_path: "/opt/myapp"
    file_type: "directory"
    student_error_message: "Application directory not found. Create with: mkdir -p /opt/myapp"
```

### Example 3: Check permissions and ownership

```yaml
- name: Verify SSH key has correct permissions
  include_role:
    name: rhdp.ftl.grader_check_file_exists
  vars:
    task_description_message: "SSH private key has secure permissions"
    file_path: "/home/student/.ssh/id_rsa"
    file_type: "file"
    check_mode_permissions: "0600"
    check_owner: "student"
    student_error_message: "SSH key permissions incorrect. Fix with: chmod 600 ~/.ssh/id_rsa"
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
