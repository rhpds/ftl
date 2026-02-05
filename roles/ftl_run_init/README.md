# ftl_run_init

Initialize FTL (Finish The Labs) grading session.

## Purpose

This role creates the working directory and report file header for lab grading. It's the first phase of the FTL three-phase grading workflow (init → grade → finish).

## Requirements

- Ansible >= 2.14
- Write access to `/tmp` or specified `grader_working_dir`

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `grader_working_dir` | `/tmp/grading_dir` | Directory for grading reports |
| `grader_student_report_file` | `grading_report.txt` | Report file name |
| `guid` | `$GUID` env var or `unknown` | Lab GUID |
| `student_name` | `$STUDENT_NAME` env var or `student` | Student name |
| `lab_id` | (required) | Lab identifier |
| `agnosticd_user_info_enabled` | `false` | Enable AgnosticD userinfo integration |

## Dependencies

None.

## Example Playbook

```yaml
- name: Grade lab
  hosts: localhost
  gather_facts: true

  tasks:
    - name: Initialize grading session
      include_role:
        name: rhdp.ftl.ftl_run_init
      vars:
        lab_id: "aap-ocp-lab"
```

## Integration with AgnosticV

When used in AgnosticV catalogs, this role runs on the bastion host during the grading invocation:

```yaml
# In catalog post_software
- name: Initialize FTL grading
  include_role:
    name: rhdp.ftl.ftl_run_init
  vars:
    lab_id: "{{ catalog_name }}"
    guid: "{{ guid }}"
  delegate_to: bastion
```

## License

Apache-2.0

## Author

Red Hat Demo Platform
