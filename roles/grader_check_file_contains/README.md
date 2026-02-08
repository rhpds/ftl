# grader_check_file_contains

Check if a file exists and optionally contains expected content (exact match or regex).

## Required Variables

- `file_path`: Absolute path to file to check
- `task_description_message`: Description of what is being validated
- `grader_student_report_file`: Path to grading report file

## Optional Variables

- `expected_content`: Exact string that should appear in file (uses `in` operator)
- `expected_content_regex`: Regex pattern that should match file content
- `student_error_message`: Custom error message for failures

**Note:** If neither `expected_content` nor `expected_content_regex` is provided, only file existence is checked.

## Example Usage

```yaml
# Check file exists only
- name: Check Leapp report exists
  ansible.builtin.include_role:
    name: grader_check_file_contains
  vars:
    file_path: "/var/log/leapp/leapp-report.txt"
    task_description_message: "Leapp pre-upgrade report generated"
    student_error_message: "Leapp report not found. Run the analysis job."

# Check file contains specific text
- name: Check pet app cron entry exists
  ansible.builtin.include_role:
    name: grader_check_file_contains
  vars:
    file_path: "/var/spool/cron/cloud-user"
    expected_content: "spring-petclinic"
    task_description_message: "Pet app configured to start on reboot"
    student_error_message: "Cron entry for pet app not found"

# Check file matches regex pattern
- name: Check RHEL version in release file
  ansible.builtin.include_role:
    name: grader_check_file_contains
  vars:
    file_path: "/etc/redhat-release"
    expected_content_regex: "Red Hat Enterprise Linux.*release 8"
    task_description_message: "RHEL 8 installed"
    student_error_message: "System not running RHEL 8"
```
