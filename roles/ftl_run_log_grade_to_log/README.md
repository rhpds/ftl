# ftl_run_log_grade_to_log

Log FTL grading results to the report file.

## Purpose

This role appends PASS/FAIL messages to the grading report file. It's called by every grader role after performing validation checks.

## Requirements

- Ansible >= 2.14
- `ftl_run_init` must be called first to create the report file

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `grader_working_dir` | `/tmp/grading_dir` | Directory containing the report file |
| `grader_student_report_file` | `grading_report.txt` | Report file name |
| `grader_output_message` | (required) | Message to log (PASS or FAIL) |

## Dependencies

None (but assumes `ftl_run_init` has been called).

## Example Playbook

```yaml
- name: Grade package installation
  block:
    - name: Check if package is installed
      ansible.builtin.package:
        name: httpd
        state: present
      check_mode: true
      register: r_check

    - name: Determine success
      ansible.builtin.set_fact:
        success: "{{ not r_check.changed }}"

    - name: Log result
      include_role:
        name: rhdp.ftl.ftl_run_log_grade_to_log
      vars:
        grader_output_message: >-
          {{ 'PASS' if success else 'FAIL' }}: Apache package is installed
          {{ '' if success else ': Package not found' }}
```

## Message Format

Messages should follow this format:

- **PASS**: `PASS: Task description`
- **FAIL**: `FAIL: Task description: Error message`

Example:
```
PASS: Apache service is running
FAIL: PostgreSQL database exists: Database not found
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
