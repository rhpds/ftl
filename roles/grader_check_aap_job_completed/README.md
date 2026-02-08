# grader_check_aap_job_completed

Check if an AAP job template exists and has been executed successfully.

## Required Variables

- `aap_hostname`: AAP controller URL (e.g., "https://controller.example.com")
- `aap_username`: AAP username for API authentication
- `aap_password`: AAP password for API authentication
- `job_template_name`: Name of the job template to check
- `task_description_message`: Description of what is being validated
- `grader_student_report_file`: Path to grading report file

## Optional Variables

- `require_job_execution`: Whether to check for successful job execution (default: true)
  - If true: Checks that job template exists AND has at least one successful job
  - If false: Only checks that job template exists
- `check_last_n_jobs`: Number of recent jobs to check (default: 5)
- `aap_validate_certs`: Whether to validate SSL certificates (default: false)
- `student_error_message`: Custom error message for failures

## Example Usage

```yaml
# Check job template exists only
- name: Check CaC job template exists
  ansible.builtin.include_role:
    name: grader_check_aap_job_completed
  vars:
    aap_hostname: "{{ aap_controller_url }}"
    aap_username: "{{ aap_user }}"
    aap_password: "{{ aap_pass }}"
    job_template_name: "Z / CaC / Controller"
    task_description_message: "AAP CaC job template configured"
    require_job_execution: false

# Check job template exists and has successful execution
- name: Check analysis job completed
  ansible.builtin.include_role:
    name: grader_check_aap_job_completed
  vars:
    aap_hostname: "{{ aap_controller_url }}"
    aap_username: "{{ aap_user }}"
    aap_password: "{{ aap_pass }}"
    job_template_name: "AUTO / 01 Analysis"
    task_description_message: "Pre-upgrade analysis job completed successfully"
    require_job_execution: true
    student_error_message: "Analysis job has not been run or did not complete successfully"
```
