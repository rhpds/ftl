# grader_check_command_output

Execute command and validate output for FTL lab grading.

## Purpose

This is the most versatile grader role. It executes a shell command and validates the result using one of three methods:
- **Exact match**: stdout must exactly match `expected_output`
- **Regex match**: stdout must match `expected_output_regex` pattern
- **Return code**: command must exit with `expected_rc` (default: 0)

## Requirements

- Ansible >= 2.9
- Access to shell on target system

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `command` | - | Yes | Shell command to execute |
| `task_description_message` | - | Yes | Human-readable task description |
| `expected_rc` | `0` | No | Expected return code |
| `expected_output` | `""` | No | Expected exact stdout match |
| `expected_output_regex` | `""` | No | Expected regex pattern for stdout |
| `student_error_message` | `"Command validation failed"` | No | Error message shown on failure |
| `chdir` | - | No | Working directory for command |
| `command_environment` | `{}` | No | Environment variables for command |

## Validation Priority

The role evaluates success in this order:
1. If `expected_output` is set → exact match required
2. Else if `expected_output_regex` is set → regex match required
3. Else → return code must match `expected_rc`

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result

## Example Playbook

### Example 1: Check return code only

```yaml
- name: Verify httpd service is running
  include_role:
    name: rhdp.ftl.grader_check_command_output
  vars:
    task_description_message: "Apache service is running"
    command: "systemctl is-active httpd"
    expected_rc: 0
    student_error_message: "Apache service is not running. Start it with: systemctl start httpd"
```

### Example 2: Check exact output

```yaml
- name: Verify hostname configuration
  include_role:
    name: rhdp.ftl.grader_check_command_output
  vars:
    task_description_message: "Hostname is correctly set"
    command: "hostname"
    expected_output: "server1.example.com"
    student_error_message: "Hostname not set correctly. Use: hostnamectl set-hostname server1.example.com"
```

### Example 3: Check regex pattern

```yaml
- name: Verify container is running
  include_role:
    name: rhdp.ftl.grader_check_command_output
  vars:
    task_description_message: "POS application container is running"
    command: "podman ps --format '{{.Names}}'"
    expected_output_regex: ".*new-pos-app.*"
    student_error_message: "Container 'new-pos-app' not running. Start with: podman start new-pos-app"
```

### Example 4: With working directory and environment

```yaml
- name: Verify application builds successfully
  include_role:
    name: rhdp.ftl.grader_check_command_output
  vars:
    task_description_message: "Application builds without errors"
    command: "make build"
    chdir: "/home/student/myapp"
    environment:
      PATH: "/usr/local/bin:{{ ansible_env.PATH }}"
    expected_rc: 0
    student_error_message: "Build failed. Check build logs for errors."
```

## Integration with AgnosticV

When used in AgnosticV catalogs:

```yaml
# In lab grade_lab.yml
- name: Grade exercise 1
  include_role:
    name: rhdp.ftl.grader_check_command_output
  vars:
    task_description_message: "Database connection successful"
    command: "psql -h localhost -U student -c 'SELECT 1'"
    expected_output_regex: ".*1 row.*"
    student_error_message: "Cannot connect to database"
```

## Output

This role produces a grading result in the format:
- **PASS**: `PASS: Task description`
- **FAIL**: `FAIL: Task description: Error message (expected rc=0, got rc=1)`

## License

Apache-2.0

## Author

Red Hat Demo Platform
