# Archived Authentication Tests

This directory contains authentication tests that were explored but ultimately not used.

## Summary

**Goal:** Find an API-based method to validate Portal RBAC policies instead of HTML parsing.

**Attempts:**
1. AAP OAuth client credentials grant
2. AAP OAuth password grant
3. AAP token from OpenShift secret
4. RHDH backend secret from OpenShift
5. Session cookies from Playwright login
6. Various header formats (Bearer, X-Auth-Token, etc.)

**Result:** None of these authentication methods worked. The RHDH Permission API requires OAuth authentication that cannot be programmatically obtained without the OAuth client secret flow.

**Solution:** Use Playwright HTML parsing to validate Portal RBAC (implemented in `grade_module_01.yml` checkpoints 1.10-1.11).

## Files

- `test_portal_rbac_api.yml` - Basic API endpoint tests
- `test_portal_api_auth.yml` - Multiple auth method tests
- `test_portal_hybrid_auth.yml` - Playwright + API cookies
- `test_portal_with_csrf.yml` - CSRF token attempts
- `test_portal_oauth_client.yml` - OAuth client credentials (kubernetes module)
- `test_portal_oauth_oc.yml` - OAuth client credentials (oc commands)
- `test_aap_oauth_token.yml` - AAP OAuth token tests
- `test_aap_token_direct.yml` - Direct AAP token usage
- `test_rhdh_backend_secret.yml` - RHDH backend secret from OCP
- `test_backend_secret.sh` - Helper script
- `test_oauth_client.sh` - Helper script
- `test_token_direct.sh` - Helper script

## Lessons Learned

1. RHDH/Backstage APIs often require OAuth that's difficult to automate
2. HTML parsing via Playwright is a legitimate validation approach for UI-based tools
3. The `ocp4_workload_dynamic_user_provisioning` role uses API without auth because that RHDH instance has different configuration
4. Portal uses AAP OAuth: `/api/auth/rhaap/handler/frame`

## Reference

Working Portal RBAC validation: `../test_portal_rbac_final.yml`
