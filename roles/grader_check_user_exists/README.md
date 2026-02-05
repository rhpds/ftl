# grader_check_user_exists

Verify user account exists for FTL lab grading.

## Purpose

This role checks if a user account exists on the system and optionally validates group membership, shell, and home directory.

## Requirements

- Ansible >= 2.9
- Target system with standard user management

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `username` | - | Yes | Username to check |
| `task_description_message` | - | Yes | Human-readable task description |
| `student_error_message` | `"User account does not exist"` | No | Error message on failure |
| `check_groups` | `""` | No | Comma-separated list of groups to verify |
| `check_shell` | `""` | No | Expected shell (e.g., `/bin/bash`) |
| `check_home` | `""` | No | Expected home directory (e.g., `/home/user`) |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result

## Example Playbook

### Example 1: Check user exists

```yaml
- name: Verify devops user exists
  include_role:
    name: rhdp.ftl.grader_check_user_exists
  vars:
    task_description_message: "User 'devops' exists"
    username: "devops"
    student_error_message: "User 'devops' not found. Create with: useradd devops"
```

### Example 2: Check user with group membership

```yaml
- name: Verify devops user in wheel group
  include_role:
    name: rhdp.ftl.grader_check_user_exists
  vars:
    task_description_message: "User 'devops' is in wheel group"
    username: "devops"
    check_groups: "wheel"
    student_error_message: "User 'devops' not in wheel group. Add with: usermod -aG wheel devops"
```

### Example 3: Check user with shell and home directory

```yaml
- name: Verify student user configuration
  include_role:
    name: rhdp.ftl.grader_check_user_exists
  vars:
    task_description_message: "Student user properly configured"
    username: "student"
    check_shell: "/bin/bash"
    check_home: "/home/student"
    check_groups: "users,docker"
    student_error_message: "Student user configuration incorrect"
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
