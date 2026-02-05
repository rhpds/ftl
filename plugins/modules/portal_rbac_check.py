#!/usr/bin/python
# -*- coding: utf-8 -*-

# Custom Ansible module to validate Portal RBAC policies
# Handles OAuth login flow and navigates to RBAC page

from ansible.module_utils.basic import AnsibleModule

DOCUMENTATION = '''
---
module: portal_rbac_check
short_description: Validate Self-Service Portal RBAC policies via browser automation
description:
    - Logs into Portal via OAuth (AAP authentication)
    - Navigates to Administration → RBAC page
    - Checks if specified RBAC policy exists
    - Optionally validates group count for the policy
options:
    portal_url:
        description: Self-Service Portal URL
        required: true
        type: str
    username:
        description: AAP admin username
        required: true
        type: str
    password:
        description: AAP admin password
        required: true
        type: str
    policy_name:
        description: RBAC policy name to check
        required: true
        type: str
    expected_groups:
        description: Expected number of groups assigned to policy
        required: false
        type: int
    headless:
        description: Run browser in headless mode
        required: false
        type: bool
        default: true
    screenshot_path:
        description: Path to save screenshot on completion
        required: false
        type: str
'''

EXAMPLES = '''
- name: Check if ssa-portal-users policy exists with 2 groups
  portal_rbac_check:
    portal_url: "https://portal.example.com"
    username: "admin"
    password: "secret"
    policy_name: "ssa-portal-users"
    expected_groups: 2
'''

def main():
    module = AnsibleModule(
        argument_spec=dict(
            portal_url=dict(type='str', required=True),
            username=dict(type='str', required=True),
            password=dict(type='str', required=True, no_log=True),
            policy_name=dict(type='str', required=True),
            expected_groups=dict(type='int', required=False),
            headless=dict(type='bool', required=False, default=True),
            screenshot_path=dict(type='str', required=False),
            timeout=dict(type='int', required=False, default=60000)
        )
    )

    try:
        from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
    except ImportError:
        module.fail_json(msg="Playwright is not installed. Install with: pip install playwright && playwright install chromium")

    portal_url = module.params['portal_url']
    username = module.params['username']
    password = module.params['password']
    policy_name = module.params['policy_name']
    expected_groups = module.params.get('expected_groups')
    headless = module.params['headless']
    screenshot_path = module.params.get('screenshot_path')
    timeout = module.params['timeout']

    result = {
        'changed': False,
        'policy_found': False,
        'groups_match': False,
        'message': ''
    }

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=headless)
            context = browser.new_context(ignore_https_errors=True)
            page = context.new_page()

            # Step 1: Navigate to Portal
            page.goto(portal_url, timeout=timeout)
            page.wait_for_load_state('networkidle')

            # Step 2: Click "Sign In" button for AAP authentication
            try:
                page.click("button:has-text('Sign In')", timeout=10000)
                page.wait_for_load_state('networkidle')
            except PlaywrightTimeout:
                # Maybe already logged in or different button text
                pass

            # Step 3: Fill AAP login form (if present)
            try:
                page.fill("#username", username, timeout=5000)
                page.fill("#password", password)
                page.click("button[type='submit']")
                page.wait_for_load_state('networkidle', timeout=timeout)
            except PlaywrightTimeout:
                # Maybe already authenticated
                pass

            # Step 4: Handle "Authorize" page if it appears
            try:
                authorize_button = page.locator("button:has-text('Authorize')")
                if authorize_button.is_visible(timeout=5000):
                    authorize_button.click()
                    page.wait_for_load_state('networkidle', timeout=timeout)
            except:
                # Authorize page didn't appear (already authorized)
                pass

            # Step 5: Navigate to Administration → RBAC
            page.goto(f"{portal_url}/settings/rbac", timeout=timeout)
            page.wait_for_load_state('networkidle')

            # Wait for RBAC page to load
            page.wait_for_selector("text=All roles", timeout=timeout)

            # Step 6: Check if policy exists
            policy_found = False
            groups_count = None

            try:
                # Look for policy name in the table
                policy_row = page.locator(f"text={policy_name}").first
                policy_found = policy_row.is_visible(timeout=5000)

                if policy_found and expected_groups is not None:
                    # Try to find groups count in the same row
                    # Pattern: "2 groups" or "1 group"
                    groups_text = page.locator(f"text={expected_groups} group").first
                    groups_match = groups_text.is_visible(timeout=5000)
                    result['groups_match'] = groups_match
                    result['message'] = f"Policy '{policy_name}' found with {expected_groups} groups"
                else:
                    result['message'] = f"Policy '{policy_name}' found"

            except PlaywrightTimeout:
                result['message'] = f"Policy '{policy_name}' not found on RBAC page"

            result['policy_found'] = policy_found

            # Step 7: Take screenshot if requested
            if screenshot_path:
                page.screenshot(path=screenshot_path)
                result['screenshot'] = screenshot_path

            browser.close()

            if not policy_found:
                module.fail_json(msg=result['message'], **result)
            elif expected_groups is not None and not result['groups_match']:
                module.fail_json(msg=f"Policy '{policy_name}' found but groups count doesn't match expected {expected_groups}", **result)
            else:
                module.exit_json(**result)

    except Exception as e:
        module.fail_json(msg=f"Portal RBAC check failed: {str(e)}")

if __name__ == '__main__':
    main()
