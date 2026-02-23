# MCP with OpenShift — FTL Lab

Graders and solvers for the [MCP with OpenShift workshop](https://github.com/rhpds/lb1726-mcp-showroom).

**Modules:** 4 | **Checkpoints:** 35 | **Type:** OCP multi-user + Gitea + LibreChat + LiteMaaS

## Run

> **First time?** Add FTL to PATH: `echo 'export PATH="$HOME/ftl/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc`  
> Or prefix commands with `bash ~/ftl/bin/`

```bash
# Credentials — from Showroom → User tab / demo.redhat.com
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxx.dynamic.redhatworkshops.io"
export PASSWORD="<user-password>"
export GITEA_ADMIN_USER="mcpadmin"
export GITEA_ADMIN_PASSWORD="<gitea-admin-password>"

# Grade one module
grade_lab mcp-with-openshift user1 1

# Solve all → grade all
solve_lab mcp-with-openshift user1
grade_lab mcp-with-openshift user1

# Load test — all users in parallel
for user in user1 user2 user3; do
  LAB_USER=$user grade_lab mcp-with-openshift $user 1 &
done && wait
```

**Expected on fresh environment:** Module 1: 5/6 PASS (infrastructure pre-deployed). Modules 2-4: FAIL (student exercises not started).

**After solver:** SUCCESS 0 Errors (35/35 checkpoints)

## Modules

| Module | Description | Checkpoints |
|---|---|---|
| 1 | Lab Setup — OCP access, LibreChat, MCP servers, Gitea repo | 6 |
| 2 | Sovereign SRE Agent Demo — pipeline triggers, Gitea issue creation | 9 |
| 3 | MCP Server Administration — MCPToolConfig, ServiceMonitor, metrics | 11 |
| 4 | MCP Registry — PostgreSQL (CNPG), MCPRegistry CR | 9 |

## Notes

- **Namespace pattern:** `mcp-openshift-{user}`, `mcp-gitea-{user}`, `agent-{user}`, `librechat-{user}`
- **OCP checks:** Admin kubeconfig (SSO users cannot `oc login` directly)
- **Gitea checks:** Uses admin token — works even if student has not logged into Gitea yet
- **Gitea credentials:** Auto-read from Showroom `showroom-userdata` ConfigMap when running as cluster admin
- **Showroom repo:** https://github.com/rhpds/lb1726-mcp-showroom
