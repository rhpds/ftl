# grader_check_http_json_response

Verify HTTP endpoint returns successful response with valid JSON content for FTL lab grading.

## Purpose

This role validates HTTP/HTTPS endpoints and checks:
- HTTP status code is correct (default: 200)
- HTTPS protocol is used (optional)
- JSON response contains required fields
- JSON field values match expected values

Useful for validating REST APIs, microservices, and web application endpoints.

## Requirements

- Ansible >= 2.9
- ansible.builtin.uri module

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `task_description_message` | - | Yes | Human-readable task description |
| `endpoint_url` | - | Yes | Full URL to test (e.g., https://api.example.com/health) |
| `expected_status_code` | `200` | No | HTTP status code to expect |
| `validate_https` | `false` | No | If true, requires HTTPS protocol |
| `validate_certs` | `false` | No | Validate SSL certificates |
| `json_field_checks` | `[]` | No | List of fields that must exist in JSON |
| `json_value_checks` | `{}` | No | Dict of field:value pairs to validate |
| `timeout` | `10` | No | Request timeout in seconds |
| `student_error_message` | (auto-generated) | No | Custom error message on failure |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result

## Example Playbook

### Example 1: Check endpoint responds

```yaml
- name: Verify API is accessible
  include_role:
    name: rhdp.ftl.grader_check_http_json_response
  vars:
    task_description_message: "Application API accessible"
    endpoint_url: "https://myapp.apps.cluster.example.com/api/health"
```

### Example 2: Validate JSON structure

```yaml
- name: Verify API returns correct metadata
  include_role:
    name: rhdp.ftl.grader_check_http_json_response
  vars:
    task_description_message: "Nationalparks API returns correct metadata"
    endpoint_url: "https://nationalparks-workshop.apps.example.com/ws/info/"
    validate_https: true
    json_field_checks:
      - id
      - displayName
      - center
      - zoom
    json_value_checks:
      id: "nationalparks"
```

### Example 3: Multi-user environment

```yaml
- name: Verify student's API endpoint
  include_role:
    name: rhdp.ftl.grader_check_http_json_response
  vars:
    task_description_message: "User {{ lookup('env', 'LAB_USER') }} API functional"
    endpoint_url: "https://myapp-workshop-{{ lookup('env', 'LAB_USER') }}.apps.cluster.example.com/api/info"
    json_field_checks:
      - version
      - status
```

## How It Works

1. **Protocol Check**: Validates HTTPS if validate_https=true
2. **HTTP Request**: Uses ansible.builtin.uri to GET endpoint
3. **Status Check**: Verifies HTTP status code matches expected
4. **JSON Parse**: Automatically parses JSON response
5. **Field Check**: Validates required fields exist
6. **Value Check**: Validates field values match expected
7. **Generate Result**: Creates PASS/FAIL with helpful context

## JSON Validation

**Field Existence Check** (`json_field_checks`):
- Checks if fields exist in response
- Does not validate values
- Example: `["id", "name", "version"]`

**Field Value Check** (`json_value_checks`):
- Checks field values match expected
- Example: `{id: "app1", version: "1.0"}`

## License

Apache-2.0

## Author

Red Hat Demo Platform
