# grader_check_ocp_pipeline_run

Verify Tekton Pipeline exists and optionally validate PipelineRun execution for FTL lab grading.

## Purpose

This role checks if a Tekton Pipeline exists and optionally validates:
- At least one PipelineRun has succeeded
- Recent PipelineRun history (last N runs)
- PipelineRun status (Succeeded, Failed, Running, etc.)

Useful for validating CI/CD pipeline configuration and execution in OpenShift labs.

## Requirements

- Ansible >= 2.9
- kubernetes.core collection >= 2.4.0
- OpenShift Pipelines (Tekton) installed

## Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `task_description_message` | - | Yes | Human-readable task description |
| `pipeline_name` | - | Yes | Name of the Pipeline to check |
| `pipeline_namespace` | - | Yes | Namespace containing the Pipeline |
| `require_pipeline_run` | `false` | No | If true, verifies at least one PipelineRun succeeded |
| `check_last_n_runs` | `5` | No | Number of recent PipelineRuns to check |
| `student_error_message` | (auto-generated) | No | Custom error message on failure |

## Dependencies

- `ftl_run_log_grade_to_log` - Logs the grading result
- kubernetes.core.k8s_info module
- Tekton CRDs (tekton.dev/v1)

## Example Playbook

```yaml
- name: Verify pipeline executed successfully
  include_role:
    name: rhdp.ftl.grader_check_ocp_pipeline_run
  vars:
    task_description_message: "Nationalparks pipeline executed successfully"
    pipeline_name: "nationalparks-pipeline"
    pipeline_namespace: "workshop"
    require_pipeline_run: true
    check_last_n_runs: 10
    student_error_message: |
      Pipeline not executed or failed.

      Start pipeline:
        oc create -f pipelinerun.yaml
      Monitor: oc get pipelineruns
```

## How It Works

1. **Check Pipeline**: Verifies Tekton Pipeline resource exists
2. **Get PipelineRuns**: Retrieves runs with label `tekton.dev/pipeline={{ pipeline_name }}`
3. **Check Success**: Looks for condition `type=Succeeded` with `status=True`
4. **Generate Result**: Creates PASS/FAIL with latest run status

## PipelineRun Status

| Condition | Status | Meaning |
|-----------|--------|---------|
| Succeeded | True | Pipeline completed successfully |
| Succeeded | False | Pipeline failed |
| Succeeded | Unknown | Pipeline still running |

## License

Apache-2.0

## Author

Red Hat Demo Platform
