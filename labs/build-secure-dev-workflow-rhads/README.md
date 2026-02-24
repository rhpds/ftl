# Build Secure Dev Workflows (RHADS) — FTL Lab

Graders and solvers for the [Build Secure, Streamlined Developer Workflows with RHADS](https://github.com/rhpds/build-secured-dev-workflows-showroom) workshop.

**Modules:** 4 (Module 1 implemented) | **Checkpoints:** 23 total (5 in Module 1) | **Type:** OCP single-user

## Lab Overview

Single-user OCP lab where students act as platform engineers (Modules 1-3) then switch to developer persona (Module 4). All namespaces are fixed — no LAB_USER namespace derivation.

| Module | Topic | Checkpoints |
|--------|-------|-------------|
| 1 | Establish Software Composition Trust with SBOMs | 5 |
| 2 | Sign and Verify All Artifacts With RHTAS | 8 (WIP) |
| 3 | Developer Workflow Without Developer Friction | 5 (WIP) |
| 4 | Enforce Policy and Promote Safely | 5 (WIP) |

## Module 1 Checkpoints

| # | Description | Namespace | Student Action |
|---|-------------|-----------|----------------|
| 1.1 | KeycloakRealmImport `tpa` Done | tssc-keycloak | Apply keycloak-tpa-realm.yml |
| 1.2 | Secret `tpa-realm-cli-clients` exists (key: cli) | tssc-tpa | Apply tpa-cli-credentials.yml |
| 1.3 | TrustedProfileAnalyzer CR `trustedprofileanalyzer` exists | tssc-tpa | Apply tpa-instance.yml |
| 1.4 | RHTPA server pod Running | tssc-tpa | Automatic after 1.3 |
| 1.5 | SBOM uploaded (≥1 SBOM in inventory) | tssc-tpa | curl POST to RHTPA API |

## Environment Setup

### Required

```bash
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxxx.dynamic.redhatworkshops.io"
```

### Recommended (--podman mode with auto-discovery)

```bash
export OCP_API_URL="https://api.cluster-xxxx.dynamic.redhatworkshops.io:6443"
export OCP_ADMIN_PASSWORD="<admin-password>"
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxxx.dynamic.redhatworkshops.io"
```

`PASSWORD` is auto-discovered from the Showroom ConfigMap. Do **not** set it manually.

## Usage

### Grade Module 1 (local mount, no git push)

```bash
cd ~/work/code/experiment/ftl

# Grade on fresh environment — expect 1.1-1.5 all FAIL
grade_lab build-secure-dev-workflow-rhads student 1 --podman --local

# Solve Module 1 (automates all student exercises)
solve_lab build-secure-dev-workflow-rhads student 1 --podman --local

# Grade again — expect all PASS
grade_lab build-secure-dev-workflow-rhads student 1 --podman --local
```

### Grade after git push

```bash
git add labs/build-secure-dev-workflow-rhads/
git commit -m "Add FTL Module 1 for build-secure-dev-workflow-rhads"
git push

grade_lab build-secure-dev-workflow-rhads student 1 --podman
```

## Expected Results

### Fresh environment (before student completes Module 1)

```
Exercise 1.1: TPA Keycloak realm import completed    FAIL
Exercise 1.2: TPA CLI client secret created          FAIL
Exercise 1.3: RHTPA TrustedProfileAnalyzer CR        FAIL
Exercise 1.4: RHTPA server pod Running               FAIL
Exercise 1.5: SBOM uploaded to RHTPA                 FAIL
SUCCESS 0 Errors: 5
```

### After solver (or after student completes all steps)

```
Exercise 1.1: TPA Keycloak realm import completed    PASS
Exercise 1.2: TPA CLI client secret created          PASS
Exercise 1.3: RHTPA TrustedProfileAnalyzer CR        PASS
Exercise 1.4: RHTPA server pod Running               PASS
Exercise 1.5: SBOM uploaded to RHTPA                 PASS
SUCCESS 0 Errors: 0
```

## Key Notes

- **Keycloak admin user is `temp-admin`** (not `admin`) — confirmed from cluster ConfigMap
- **TPA CLI client secret = PASSWORD** (both are `common_password` in this lab)
- **RHTPA API endpoint**: `GET /api/v2/sbom?offset=0&limit=1` — returns `{"total": N, ...}`
- Solver includes the full KeycloakRealmImport spec inline (students use a pre-templated file)
- Exercise 1.5 SBOM check uses OIDC client credentials flow — verify if API endpoint is correct after Module 1 testing

## AgnosticV Reference

- Catalog: `agd_v2/build-secure-dev-workflow-rhads`
- Showroom: `https://github.com/rhpds/build-secured-dev-workflows-showroom`
- Collection: `https://github.com/rhpds/rhpds.build-secured-dev-workflows`
