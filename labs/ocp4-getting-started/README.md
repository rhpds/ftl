# OpenShift 4 Getting Started — FTL Lab

Graders and solvers for the [OCP4 Getting Started workshop](https://github.com/rhpds/ocp4-getting-started-showroom).

**Modules:** 3 | **Checkpoints:** 30 | **Type:** OCP multi-user, S2I builds, Tekton pipelines

## Run

```bash
# Credentials — from Showroom → User tab / demo.redhat.com
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxx.dynamic.redhatworkshops.io"
export PASSWORD="<user-password>"

# Grade one module
grade_lab ocp4-getting-started user1 1

# Solve all → grade all (takes ~10 min — S2I build in module 2)
solve_lab ocp4-getting-started user1
grade_lab ocp4-getting-started user1

# Load test — all users
for user in user1 user2 user3; do
  LAB_USER=$user grade_lab ocp4-getting-started $user &
done && wait
```

**Expected on fresh environment:** All modules FAIL (student has not deployed anything yet).

**After solver:** SUCCESS 0 Errors (30/30 checkpoints)

> ⚠️  Module 2 runs an S2I Java build from source (~5-10 min). This is expected and not an error.

## Modules

| Module | Description | Checkpoints |
|---|---|---|
| 1 | Parksmap deployment — project, deployment, service, route, HTTPS, labels, SA permissions | 10 |
| 2 | Nationalparks S2I build + MongoDB + data loading + probes + route label | 15 |
| 3 | Tekton pipeline — PVC, pipeline tasks, PipelineRun, Triggers EventListener | 5 |

## Notes

- **Project namespace:** `wksp-{user}` (NOT `workshop-{user}`) — always verify from Showroom `vars.adoc`
- **Module 2 build:** Uses `image-registry.openshift-image-registry.svc:5000/{project}/nationalparks:latest` from internal registry
- **Tekton Triggers:** TriggerTemplate + TriggerBinding + EventListener created from student's Gitea repo YAML
- **Showroom repo:** https://github.com/rhpds/ocp4-getting-started-showroom
