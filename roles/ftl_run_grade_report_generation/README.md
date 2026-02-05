# ftl_run_grade_report_generation

Generate final grading report with SHA256 signature and AgnosticD integration.

## Purpose

This role analyzes grading results, calculates pass/fail status, signs the report with SHA256 hash, and optionally reports to AgnosticD userinfo for catalog deployments. It's the third phase of the FTL grading workflow (init → grade → **finish**).

## Requirements

- Ansible >= 2.14
- `ftl_run_init` must be called first
- At least one grader role must have logged results via `ftl_run_log_grade_to_log`

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `grader_working_dir` | `/tmp/grading_dir` | Directory containing the report file |
| `grader_student_report_file` | `grading_report.txt` | Report file name |
| `agnosticd_user_info_enabled` | `false` | Enable AgnosticD userinfo integration |
| `lab_id` | `unknown` | Lab identifier |
| `guid` | `$GUID` env var or `unknown` | Lab GUID |
| `student_name` | `$STUDENT_NAME` env var or `student` | Student name |

## Dependencies

None (but assumes grading has been performed).

## Exported Facts

This role sets the following facts for downstream use:

- `ftl_lab_passed`: Boolean indicating if lab passed
- `ftl_error_count`: Number of failed checks
- `ftl_report_checksum`: SHA256 hash of the report

## Example Playbook

```yaml
- name: Finalize grading
  hosts: localhost
  gather_facts: true

  tasks:
    - name: Generate grading report
      include_role:
        name: rhdp.ftl.ftl_run_grade_report_generation
      vars:
        lab_id: "aap-ocp-lab"
```

## AgnosticD Integration

When `agnosticd_user_info_enabled: true`, this role reports grading results to AgnosticD userinfo:

```yaml
- name: Grade lab in AgnosticV catalog
  include_role:
    name: rhdp.ftl.ftl_run_grade_report_generation
  vars:
    agnosticd_integration: true
    lab_id: "{{ catalog_name }}"
```

The grading results will be visible in the provisioning output:

```
PLAY RECAP ********************************************************************
✓ Lab Passed
Full report: /tmp/grading_dir/grading_report.txt

User Info Messages:
- Lab grading completed successfully
- Report checksum: a3d5f8e9c2b1...
```

## Report Format

The final report includes:

```
================================================================================
FTL Grading Report
================================================================================
[... grading results ...]

================================================================================
Summary
================================================================================

SUCCESS 0 Errors
(or FAILED 3 Errors)

SHA256: a3d5f8e9c2b1a4f7e6d8c9b2a1f5e8d7...
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
