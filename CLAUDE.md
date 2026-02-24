# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FTL (Finish The Labs) is an Ansible-based framework for automated grading and solving of hands-on technical labs. It integrates with Red Hat Demo Platform (RHDP) via AgnosticV/AgnosticD catalogs. The framework validates student work through API-based checks (never browser automation) and generates SHA256-signed grading reports.

## Key Commands

```bash
# Setup
bash bin/setup_ftl                              # Install deps (venv, ansible, collections)

# Grade labs
grade_lab <lab-name> [user] [module-number]     # Student-facing grading
grade_lab mcp-with-openshift user1 2            # Grade module 2 for user1

# Solve labs
solve_lab <lab-name> [user] [module-number]     # Auto-complete for testing

# Direct playbook execution
ansible-playbook main.yml -e purpose=grade_lab -e lab_id=mcp-with-openshift
ansible-playbook labs/mcp-with-openshift/grade_module_01.yml

# Test cycle: grade (expect FAIL) → solve → grade (expect PASS)
```

Required environment variables (must use `export` — variables without export are not passed into the podman container):

```bash
export OCP_API_URL="https://api.cluster-xxxx.dynamic.redhatworkshops.io:6443"
export OCP_ADMIN_PASSWORD="<admin-password>"
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxxx.dynamic.redhatworkshops.io"
# PASSWORD is auto-discovered from Showroom ConfigMap when OCP_API_URL is set
```

CI/CD: GitHub Actions builds and pushes the container image to `ghcr.io/rhpds/ftl` on push to `main`.

## Architecture

### Three-Phase Execution (main.yml)

1. **Initialize** (`ftl_run_init`) — creates working dir and report header (grade only)
2. **Execute** — imports `labs/<lab_id>/grade_lab.yml` or `solve_lab.yml`
3. **Finalize** (`ftl_run_grade_report_generation` + `ftl_run_finish`) — generates report with SHA256 signature (grade only)

### Directory Layout

- `main.yml` — framework entry point, orchestrates the 3-phase workflow
- `bin/` — bash wrapper scripts (`grade_lab`, `solve_lab`, `setup_ftl`) for bastion host usage
- `container/entrypoint.sh` — unified entrypoint for the container image (replaces `bin/` wrappers)
- `Containerfile` — container image definition (UBI9-minimal, oc CLI, ansible-core, collections)
- `.github/workflows/build-image.yml` — CI to build and push image to GHCR
- `labs/<lab-id>/` — per-lab implementations with `grade_module_XX.yml`, `solve_module_XX.yml`, and `lab.yml` metadata
- `roles/ftl_run_*` — 4 lifecycle roles (init, log, report generation, finish)
- `roles/grader_check_*` — 22 reusable validation roles (system, OCP/K8s, AAP, HTTP)
- `vars/global_vars.yml` — framework defaults (report paths, continue_on_failure, OCP config)
- `plugins/` — custom Ansible action plugins and modules (`agnosticd_user_info`, `portal_rbac_check`)

### Grader Role Pattern

Every grader role follows this structure:
1. Initialize `success: false`
2. Validate required variables with `assert`
3. Perform the check (k8s_info, stat, command, uri, etc.)
4. Set `success` fact based on result
5. Set `grader_output_message` to `"PASS: ..."` or `"FAIL: ..."`
6. Import `ftl_run_log_grade_to_log` to record result

Key variables consumed by grader roles:
- `task_description_message` — human-readable checkpoint name (e.g., "Exercise 1.1: Pod is running")
- `student_error_message` — hint shown on failure

### Checkpoint Naming

Format: `Exercise X.Y: Description` where X = module number, Y = checkpoint within module.

### Multi-User Support

Labs can be single-user or multi-user. Multi-user labs derive namespace/project names from `LAB_USER` (e.g., `namespace: "myapp-{{ LAB_USER }}"`). Reports are per-user: `/tmp/grading_dir/grading_report_<user>_module_<NN>.txt`.

### Wrapper Script Behavior

`grade_lab` and `solve_lab` (in `bin/`) and `container/entrypoint.sh` auto-discover `grade_module_*.yml`/`solve_module_*.yml` files in the lab directory. No lab-specific orchestration file is needed — the wrappers iterate over numbered module files automatically.

### Container Mode

FTL is packaged as a container image (`ghcr.io/rhpds/ftl`) built from `Containerfile`. The image uses UBI9-minimal with Python 3.11, `oc`/`kubectl` CLI, ansible-core, and all required collections pre-installed. It runs as non-root user `runner` (UID 1001).

The entrypoint (`container/entrypoint.sh`) supports three OCP auth methods in priority order:
1. Mounted kubeconfig (`-v ~/.kube/config:/home/runner/.kube/config:ro`)
2. Token (`-e OCP_TOKEN=... -e OPENSHIFT_API_URL=...`)
3. Username/password (`-e OPENSHIFT_USERNAME=... -e OPENSHIFT_PASSWORD=... -e OPENSHIFT_API_URL=...`)

```bash
# Container commands
podman run --rm ghcr.io/rhpds/ftl --help
podman run --rm ghcr.io/rhpds/ftl list
podman run --rm -e OPENSHIFT_USERNAME=user1 -e OPENSHIFT_PASSWORD=pass \
    -e OPENSHIFT_API_URL=https://api.cluster.example.com:6443 \
    ghcr.io/rhpds/ftl grade ocp4-getting-started user1

# Build locally
podman build -t rhpds/ftl -f Containerfile .
```

Key differences from bastion mode: `LAB_USER` defaults to `student` (not `$USER`), `GUID` defaults to `ftl-container` (not parsed from hostname). The `.containerignore` excludes `bin/`, `docs/`, `.git`, and other non-runtime files from the image.

## Dependencies

- Python 3 with venv
- Ansible 2.9+
- Collections: `kubernetes.core` (>=2.4.0), `community.general` (>=8.0.0)
- Python packages: `kubernetes`, `jmespath`

## Creating a New Lab

Copy `labs/lab-template/` to `labs/<new-lab-name>/`. Each lab needs:
- `lab.yml` — metadata (lab name, modules list)
- `grade_module_XX.yml` — grading playbooks using `grader_check_*` roles
- `solve_module_XX.yml` — solver playbooks (optional)

The complete grader role API is documented in `docs/GRADER_ROLES_REFERENCE.md`.

## Conventions

- All validation is API-based (no browser/UI automation)
- `continue_on_failure: true` — all checkpoints run even if earlier ones fail
- Playbooks run on `localhost` (bastion host) against remote APIs
- Variable naming: `snake_case`
- YAML indentation: 2 spaces
- Ansible FQCNs used throughout (e.g., `ansible.builtin.set_fact`, not `set_fact`)
