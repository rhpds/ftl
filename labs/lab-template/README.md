# [Lab Name] — FTL Lab

Graders and solvers for the [[Lab Name] workshop](https://github.com/rhpds/YOUR-SHOWROOM-REPO).

**Modules:** N | **Checkpoints:** N | **Type:** OCP / AAP / RHEL

## Run

```bash
# Credentials — from Showroom → User tab / demo.redhat.com
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxx.dynamic.redhatworkshops.io"
export PASSWORD="<user-password>"

# Grade one module
grade_lab your-lab-name user1 1

# Solve all → grade all
solve_lab your-lab-name user1
grade_lab your-lab-name user1

# Load test — all users in parallel
for user in user1 user2 user3; do
  LAB_USER=$user grade_lab your-lab-name $user &
done && wait
```

**Expected on fresh environment:** All modules FAIL.
**After solver:** SUCCESS 0 Errors.

## Modules

| Module | Description | Checkpoints |
|---|---|---|
| 1 | [Module 1 description] | N |
| 2 | [Module 2 description] | N |

## Notes

- **Namespace pattern:** `[namespace-pattern]-{user}`
- **Showroom repo:** https://github.com/rhpds/YOUR-SHOWROOM-REPO
- **AgnosticV catalog:** (if applicable)
