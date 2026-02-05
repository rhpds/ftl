# Work In Progress Labs

This directory contains labs that are not yet production-ready.

## aap-selfserv-intro-showroom

**Status:** Browser automation for Portal RBAC is too fragile

**What Works:**
- ✅ All AAP RBAC automation via API (teams, users, role assignments)
- ✅ Grading via API validation
- ✅ 90% of Module 1 automation complete

**What Needs Work:**
- ❌ Portal RBAC browser automation (Playwright)
  - Timing issues with dropdown loading
  - Multiple similar selectors causing strict mode violations
  - Page reload sync issues between AAP and Portal

**Recommendation:**
- Use as reference for AAP API patterns
- Portal RBAC should be manual step or future enhancement
- Focus on API-first labs for core FTL collection

**Lessons Learned:**
- Browser automation is fragile for complex UI workflows
- API-based validation is much more reliable
- Portal API requires OAuth secrets not available programmatically
- See `tests/archive/README.md` for authentication attempts

**Future Work:**
- Consider Selenium for more robust browser automation
- Or make Portal RBAC a documented manual step
- Focus on labs that can be fully automated via API/CLI
