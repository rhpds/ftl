# FTL — Claude Code Context

## Generating New Graders

Use the `/health:ftl-generator` skill from the RHDP Skills Marketplace. It handles reading Showroom content, AgV catalog analysis, checkpoint mapping, and file generation.

## Running Graders (from FTL repo root)

```bash
# Always use export — variables without export are not passed into the container
export OCP_API_URL="https://api.cluster-xxxx.dynamic.redhatworkshops.io:6443"
export OCP_ADMIN_PASSWORD="<admin-password>"
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxxx.dynamic.redhatworkshops.io"

bash bin/grade_lab <lab> <user> <module> --podman          # from GitHub (production)
bash bin/grade_lab <lab> <user> <module> --podman --local  # mount local repo, no push needed
bash bin/solve_lab <lab> <user> <module> --podman --local
```

## Key Conventions

- **Never generate `grade_lab.yml`** — `bin/grade_lab` auto-discovers `grade_module_*.yml` files
- **Three-play pattern** — every `grade_module_*.yml` must define `grader_student_report_file` in all 3 plays (Init / Grade / Finalize)
- **Never use `oc` CLI in graders** — use `kubernetes.core.k8s_info` instead (oc crashes silently on arm64)
- **One module at a time** — generate Module 1, test, then proceed to Module 2
- **Admin only for ConfigMap** — read `showroom-userdata` as admin, all checks run as the student user
- **Copy from template** — always `cp -r labs/lab-template labs/<new-lab>`, never create from scratch
- **`grader_check_*` roles first** — use the 22 generic grader roles before writing custom tasks
