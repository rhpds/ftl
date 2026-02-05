# ftl_run_finish

Display grading report to students and provide next steps guidance.

## Purpose

This role shows the final grading report to students and provides guidance on what to do next based on the results. It's the final phase of the FTL grading workflow (init → grade → finish → **display**).

## Requirements

- Ansible >= 2.14
- `ftl_run_grade_report_generation` must be called first

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `grader_working_dir` | `/tmp/grading_dir` | Directory containing the report file |
| `grader_student_report_file` | `grading_report.txt` | Report file name |
| `display_full_report` | `true` | Display complete report to console |
| `ftl_lab_passed` | (from previous role) | Lab pass/fail status |
| `ftl_error_count` | (from previous role) | Number of errors |
| `lab_id` | `unknown` | Lab identifier |

## Dependencies

None (but assumes `ftl_run_grade_report_generation` has been called).

## Example Playbook

```yaml
- name: Finalize and display grading
  hosts: localhost
  gather_facts: true

  tasks:
    - name: Display grading report
      include_role:
        name: rhdp.ftl.ftl_run_finish
```

## Output

### If Lab Passed:
```
============================================================
🎉 Congratulations! You have successfully completed this lab.
============================================================

Report location: /tmp/grading_dir/grading_report.txt
============================================================
```

### If Lab Failed:
```
============================================================
⚠️  Lab validation incomplete - 3 errors found
============================================================

Please review the errors above and make the necessary corrections.
Then run the grader again to verify your fixes.

To re-grade: grade_lab aap-ocp-lab

Report location: /tmp/grading_dir/grading_report.txt
============================================================
```

## Report Locations

The report is copied to two locations for student convenience:

1. **Working directory**: `{{ grader_working_dir }}/{{ grader_student_report_file }}`
2. **Standard location**: `/tmp/grading_report.txt` (always the latest)
3. **Archived**: `{{ grader_working_dir }}/grading_report_<timestamp>.txt` (historical)

## License

Apache-2.0

## Author

Red Hat Demo Platform
