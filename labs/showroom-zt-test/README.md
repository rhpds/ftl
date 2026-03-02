# showroom-zt-test

CI test lab for validating Zero Touch showroom on OCP sandbox clusters.

## What it tests

- zerotouch-automation service runs correctly inside the showroom pod
- setup / validation / solve scripts execute on student namespace via SSH
- FTL graders and solvers produce consistent results

## Environment

One sandbox per order (sandbox model). For multi-user CI testing, run 3 parallel orders.

## Runtime automation scripts

The showroom content repo (`showroom-zt-ci-test`) contains:

```
runtime-automation/
  module-01/
    setup-node01.sh        # Creates namespace + ConfigMap
    validation-node01.sh   # Checks Deployment is running
    solve-node01.sh        # Creates the Deployment
```

## FTL usage

```bash
cd ~/work/code/experiment/ftl

export OCP_API_URL="https://api.cluster-xxx.example.com:6443"
export OCP_ADMIN_PASSWORD="<admin-password>"

# Grade (before solve — expect FAILs on exercise 1.3)
bash bin/grade_lab showroom-zt-test user1 1 --podman

# Solve
bash bin/solve_lab showroom-zt-test user1 1 --podman

# Grade again — expect all PASS
bash bin/grade_lab showroom-zt-test user1 1 --podman

# Multi-user (3 parallel)
bash bin/grade_lab showroom-zt-test all 1 --podman
```

## Namespace pattern

`zt-test-{user}` — e.g. `zt-test-user1`, `zt-test-user2`, `zt-test-user3`
