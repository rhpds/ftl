# grader_check_aap_licensed

Check if AAP controller has a valid license installed.

## Required Variables

- `aap_hostname`: AAP controller URL (e.g., "https://controller.example.com")
- `aap_username`: AAP username for API authentication
- `aap_password`: AAP password for API authentication
- `task_description_message`: Description of what is being validated
- `grader_student_report_file`: Path to grading report file

## Optional Variables

- `aap_validate_certs`: Whether to validate SSL certificates (default: false)
- `student_error_message`: Custom error message for failures

## Example Usage

```yaml
- name: Check AAP is licensed
  ansible.builtin.include_role:
    name: grader_check_aap_licensed
  vars:
    aap_hostname: "https://controller-{{ subdomain_base }}"
    aap_username: "lab-user"
    aap_password: "{{ common_password }}"
    task_description_message: "AAP controller has valid license"
    student_error_message: "AAP license not installed. Run the CaC job to apply license manifest."
```

## What It Checks

This role validates that AAP has a valid license by checking the `/api/v2/config/` endpoint for either:
- `license_info.valid_key` is true, OR
- `subscription_name` is set

This covers both traditional license keys and newer subscription-based licensing.
