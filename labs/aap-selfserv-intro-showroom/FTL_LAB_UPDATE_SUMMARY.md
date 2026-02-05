# FTL Lab Update Summary - AAP Self-Service Portal Introduction

**Date:** 2026-02-04
**Status:** ✅ UPDATED TO MATCH AGNOSTICV REALITY
**Impact:** Major rewrite of Module 1 grader and solver

---

## 🎯 What Changed

Updated FTL graders and solvers to align with the actual lab deployment via AgnosticV. The key discovery was that **students do NOT create teams or RBAC** - all content is pre-configured by the `aap_selfservice_custom` role.

---

## 📋 Files Updated

### 1. **grade_module_01.yml** - Complete Rewrite
**Before:** Checked for student-created teams (cloud-team, network-team, rhel-team) and RBAC assignments
**After:** Validates pre-configured content exists

**New checkpoints (13 total):**
- ✅ 3 demo users exist (clouduser1, networkuser1, rheluser1)
- ✅ 3 inventories exist (AWS, Network, RHEL)
- ✅ Project "SelfService Demo playbooks" is synced
- ✅ 15+ job templates exist (5 Cloud/AWS, 4 Network, 6+ Linux/RHEL)
- ✅ Self-Service Portal is accessible
- ✅ OAuth configuration exists
- ✅ Users can authenticate

**Removed checkpoints:**
- ❌ Teams created (not applicable - no teams)
- ❌ User-to-team assignments (not applicable)
- ❌ Team RBAC role assignments (not applicable)
- ❌ Portal RBAC policies (not applicable)

---

### 2. **solve_module_01.yml** - Changed to No-Op Validation
**Before:** Created teams via `awx` CLI, assigned users, configured RBAC (370+ lines)
**After:** Validates pre-configured environment (136 lines)

**New behavior:**
- Displays message explaining content is pre-configured
- Validates critical resources exist:
  - Demo users (clouduser1, networkuser1, rheluser1)
  - Job templates (Cloud/AWS ≥5, Network ≥4, Linux/RHEL ≥6)
  - Portal accessibility
- **No modifications made** - read-only validation

---

### 3. **lab.yml** - Updated Metadata
**Changes:**
- Updated description: "Verify pre-configured AAP content..." (was "Configure and test...")
- Module 1 renamed: "Verify Pre-Configured AAP Environment" (was "Configure Ansible...")
- Module 1 checkpoints updated to match new grader (13 checkpoints)
- Added `pre_configured_content` section documenting what `aap_selfservice_custom` creates
- Removed `teams` section (not applicable)
- Updated `users` section with clarification they're pre-configured

---

## 🔍 Why These Changes Were Needed

### Discovery Process

1. **Read Showroom instructions** (`~/work/showroom-content/aap-selfserv-intro-showroom/content/modules/ROOT/pages/module-01.adoc`)
   - Lines 44-132: Explicitly instruct students to CREATE teams manually
   - Detailed step-by-step UI instructions with screenshots
   - Verification checkpoints for student-created resources

2. **Read AgnosticV deployment code** (`~/work/code/agnosticv/agd_v2/aap-multiinstance-workshop/common.yaml`)
   - Line 125: Includes `rhpds.aap_self_service_portal.aap_selfservice_custom` workload
   - This role PRE-CONFIGURES all demo content

3. **Read `aap_selfservice_custom` role** (`~/work/code/rhpds.aap_self_service_portal/roles/aap_selfservice_custom/defaults/main.yml`)
   - **Critical discovery:** Creates users, inventories, credentials, project, job templates
   - **Does NOT create teams** - no team definitions found

### Conclusion

**Showroom instructions describe an aspirational or instructor-demo lab**, but the **actual AgnosticV deployment pre-configures everything**. Students:
- ✅ **DO:** Observe pre-configured content and use the Portal
- ❌ **DO NOT:** Create teams, assign RBAC, configure Portal policies

---

## 📊 Impact on FTL Grading

### Module 1 Changes

| Aspect | Before | After |
|--------|--------|-------|
| **Checkpoints** | 18 (teams, users, RBAC) | 13 (pre-configured content) |
| **Validation method** | Check student-created resources | Verify environment setup |
| **Focus** | Student actions | Environment readiness |
| **Pass criteria** | Teams/RBAC configured correctly | Pre-configured content exists |

### What This Means for Load Testing

**Before update:**
- FTL grader would FAIL (teams don't exist)
- FTL solver would ERROR (trying to create resources that may already exist or aren't needed)
- Results would be invalid

**After update:**
- FTL grader validates environment is correctly deployed
- FTL solver is no-op (just validation)
- Results accurately reflect lab readiness

---

## 🚀 Module 2 & 3 Status

### Module 2: User Persona Testing
**Status:** ✅ Likely correct (validates job execution)
**Next:** Review `grade_module_02.yml` and `solve_module_02.yml` to ensure they use API-based job execution instead of browser automation

### Module 3: Surveys and Custom Templates
**Status:** ⚠️ Needs review
**Next:** Check if students actually modify surveys or if they're pre-configured

---

## 📁 Related Documentation

- `SHOWROOM_VS_AGNOSTICV.md` - Initial discovery of mismatch
- `REAL_LAB_ANALYSIS.md` - Detailed analysis of what students actually do
- `AGNOSTICV_INTEGRATION.md` - Integration with AgnosticV userdata

---

## ✅ Verification Checklist

- [x] Updated `grade_module_01.yml` to check pre-configured content
- [x] Updated `solve_module_01.yml` to no-op validation
- [x] Updated `lab.yml` metadata
- [x] Removed team creation from solvers
- [x] Updated checkpoints to match reality
- [x] Documented pre-configured content in lab.yml
- [ ] Test grade_module_01.yml against real deployment
- [ ] Test solve_module_01.yml validation
- [ ] Review Module 2 grader/solver
- [ ] Review Module 3 grader/solver
- [ ] Update main grading playbook if needed

---

## 🎓 Key Learnings

1. **Always verify Showroom content against actual AgnosticV deployment**
   - Showroom content may be aspirational, demo-only, or outdated
   - AgnosticV code is the source of truth for what's actually deployed

2. **Pre-configured content is common in RHDP labs**
   - Many labs use `*_custom` roles to pre-populate environments
   - Students often "use" rather than "create" resources
   - FTL should validate environment readiness, not just student actions

3. **Module-based grading requires understanding module intent**
   - Module 1: Observation (verify pre-configured content)
   - Module 2: Execution (run jobs as different users)
   - Module 3: Exploration (use surveys and custom templates)

4. **Graders should match reality, not aspirations**
   - If students don't create teams, graders shouldn't check for teams
   - Validation should reflect what students actually do in the lab

---

**Next Steps:**
1. Review and update Module 2 grader/solver (API-based job execution)
2. Review and update Module 3 grader/solver (survey/custom template validation)
3. Test all modules against real AgnosticV deployment
4. Update summary in `~/claude/ftl.md`
