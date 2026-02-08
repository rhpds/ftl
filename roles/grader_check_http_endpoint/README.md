# grader_check_http_endpoint

Check if an HTTP/HTTPS endpoint is accessible and returns expected status code.

## Required Variables

- `url`: Full URL to check (e.g., "http://localhost:8080")
- `task_description_message`: Description of what is being validated
- `grader_student_report_file`: Path to grading report file

## Optional Variables

- `expected_status_code`: HTTP status code to expect (default: 200)
- `http_method`: HTTP method to use (default: GET)
- `validate_certs`: Whether to validate SSL certificates (default: false)
- `timeout`: Request timeout in seconds (default: 10)
- `follow_redirects`: How to handle redirects (default: 'safe')
- `student_error_message`: Custom error message for failures

## Example Usage

```yaml
- name: Check pet app is accessible
  ansible.builtin.include_role:
    name: grader_check_http_endpoint
  vars:
    url: "http://{{ inventory_hostname }}:8080"
    task_description_message: "Pet application web interface is accessible"
    expected_status_code: 200
    student_error_message: "Pet application is not responding on port 8080"
```
