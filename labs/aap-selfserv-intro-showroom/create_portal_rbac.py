#!/usr/bin/env python3
"""Create Portal RBAC policies via browser automation."""

from playwright.sync_api import sync_playwright
import os
import sys

portal_url = os.environ['SELF_SERVICE_PORTAL_URL']
username = "admin"
password = os.environ['AAP_ADMIN_PASSWORD']

print("=== Creating Portal RBAC Policies ===\n")

try:
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(ignore_https_errors=True)
        page = context.new_page()

        # Step 1: Login
        print("Step 1: Logging in to Portal...")
        page.goto(portal_url, timeout=60000)
        page.wait_for_load_state('networkidle')

        try:
            page.click("button:has-text('Sign In')", timeout=10000)
            page.wait_for_load_state('networkidle', timeout=30000)
        except:
            pass

        page.wait_for_timeout(3000)
        username_input = page.locator("input[type='text'], input[name='username']").first
        if username_input.is_visible(timeout=5000):
            username_input.fill(username)
        password_input = page.locator("input[type='password']").first
        if password_input.is_visible(timeout=5000):
            password_input.fill(password)
        page.click("button:has-text('Log in')", timeout=5000)
        page.wait_for_load_state('networkidle', timeout=60000)
        print("  ✅ Logged in successfully\n")

        # Step 2: Navigate to RBAC page
        print("Step 2: Navigating to RBAC page...")
        page.wait_for_selector('text=Templates', timeout=10000)
        page.wait_for_timeout(2000)
        page.click('text=Administration', timeout=10000)
        page.wait_for_timeout(2000)
        page.click('text=RBAC', timeout=10000)
        page.wait_for_load_state('networkidle')
        page.wait_for_timeout(3000)
        print("  ✅ RBAC page loaded\n")

        # Step 3: Create ssa-portal-users role
        print("Step 3: Creating ssa-portal-users role...")

        # Check if role already exists
        page_text = page.inner_text('body')
        if 'ssa-portal-users' in page_text:
            print("  ⚠️  Role ssa-portal-users already exists, skipping\n")
        else:
            # Click Create button (top right, blue button)
            page.get_by_role('button', name='Create').click()
            page.wait_for_timeout(2000)

            # Step 1: Fill name and description
            page.wait_for_selector('input[type="text"]', timeout=10000)
            page.wait_for_timeout(1000)

            page.locator('input[type="text"]').first.fill('ssa-portal-users')
            page.wait_for_timeout(500)

            page.locator('textarea').first.fill('Role for Cloud and Network teams')
            page.wait_for_timeout(500)
            page.get_by_role('button', name='Next').click()
            page.wait_for_timeout(2000)

            # Step 2: Add groups
            page.wait_for_selector('text=Add users and groups', timeout=10000)
            page.wait_for_timeout(1000)
            page.locator('input[role="combobox"]').first.click()
            page.wait_for_timeout(3000)

            # Wait for dropdown options to load
            page.wait_for_selector('text=cloud-team', timeout=10000)
            page.wait_for_timeout(500)

            # Click team names directly to select them (clicking toggles checkbox)
            page.locator('text=cloud-team').first.click()
            page.wait_for_timeout(500)

            page.locator('text=network-team').first.click()
            page.wait_for_timeout(500)

            page.locator('body').click()
            page.wait_for_timeout(1000)

            page.get_by_role('button', name='Next').click()
            page.wait_for_timeout(2000)

            # Step 3: Add permissions
            page.locator('text=Select plugins').click()
            page.wait_for_timeout(1000)

            page.locator('text=Catalog').locator('..').locator('input[type="checkbox"]').first.check()
            page.wait_for_timeout(500)
            page.locator('text=Scaffolder').locator('..').locator('input[type="checkbox"]').first.check()
            page.wait_for_timeout(500)

            page.locator('body').click()
            page.wait_for_timeout(1000)

            page.locator('text=Catalog').locator('..').locator('svg').first.click()
            page.wait_for_timeout(1000)

            page.locator('text=catalog.entity.read').locator('..').locator('input[type="checkbox"]').first.check()
            page.wait_for_timeout(500)

            page.locator('text=Scaffolder').locator('..').locator('svg').first.click()
            page.wait_for_timeout(1000)

            scaffolder_perms = [
                'scaffolder.template.parameter.read',
                'scaffolder.template.step.read',
                'scaffolder.action.execute',
                'scaffolder.task.cancel',
                'scaffolder.task.create',
                'scaffolder.task.read'
            ]
            for perm in scaffolder_perms:
                try:
                    page.locator('text=' + perm).locator('..').locator('input[type="checkbox"]').first.check()
                    page.wait_for_timeout(300)
                except:
                    pass

            page.wait_for_timeout(1000)

            page.get_by_role('button', name='Next').click()
            page.wait_for_timeout(2000)

            page.get_by_role('button', name='Create').click()
            page.wait_for_timeout(3000)
            print("  ✅ Created ssa-portal-users role\n")

        # Step 4: Create saa-portal-rhel-team role
        print("Step 4: Creating saa-portal-rhel-team role...")

        # Reload page to ensure Portal has latest team data from AAP
        print("  Refreshing RBAC page to sync latest teams from AAP...")
        page.reload()
        page.wait_for_load_state('networkidle')
        page.wait_for_timeout(5000)  # Longer wait after reload for Portal to sync
        print("  ✅ Page refreshed\n")

        page_text = page.inner_text('body')
        if 'saa-portal-rhel-team' in page_text:
            print("  ⚠️  Role saa-portal-rhel-team already exists, skipping\n")
        else:
            page.get_by_role('button', name='Create').click()
            page.wait_for_timeout(2000)

            page.wait_for_selector('input[type="text"]', timeout=10000)
            page.wait_for_timeout(1000)

            page.locator('input[type="text"]').first.fill('saa-portal-rhel-team')
            page.wait_for_timeout(500)

            page.locator('textarea').first.fill('Role for RHEL team')
            page.wait_for_timeout(500)
            page.get_by_role('button', name='Next').click()
            page.wait_for_timeout(2000)

            # Click the input field to open dropdown
            # Wait for the page to be fully rendered after clicking Next
            print("  Opening users and groups dropdown...")
            page.wait_for_selector('text=Add users and groups', timeout=10000)
            page.wait_for_timeout(1000)

            # Click the actual input/combobox field
            # Look for an input within the "Select users and groups" labeled section
            page.locator('input[role="combobox"]').first.click()
            page.wait_for_timeout(3000)

            # Wait for dropdown to open and load teams
            print("  Looking for rhel-team in dropdown...")

            # First wait for a team we know exists to ensure dropdown is loaded
            page.wait_for_selector('text=cloud-team', timeout=10000)
            print("  ✅ Dropdown loaded")
            page.wait_for_timeout(500)

            # Try to find rhel-team - it might need scrolling
            try:
                # Check if rhel-team is visible
                rhel_element = page.locator('text=rhel-team').first
                if not rhel_element.is_visible():
                    print("  ⚠️  rhel-team not visible, scrolling dropdown...")
                    # Scroll the dropdown by clicking on network-team first (which we know is above rhel-team)
                    page.locator('text=network-team').first.scroll_into_view_if_needed()
                    page.wait_for_timeout(500)
                    # Now rhel-team should be visible
                    rhel_element.scroll_into_view_if_needed()
                    page.wait_for_timeout(500)

                print("  ✅ Found rhel-team")
            except Exception as e:
                print("  ⚠️  Error finding rhel-team: " + str(e))
                raise

            # Click directly on rhel-team text to select it (clicking label toggles checkbox)
            page.locator('text=rhel-team').first.click()
            page.wait_for_timeout(500)

            page.locator('body').click()
            page.wait_for_timeout(1000)

            page.get_by_role('button', name='Next').click()
            page.wait_for_timeout(2000)

            page.locator('text=Select plugins').click()
            page.wait_for_timeout(1000)

            page.locator('text=Catalog').locator('..').locator('input[type="checkbox"]').first.check()
            page.wait_for_timeout(500)
            page.locator('text=Scaffolder').locator('..').locator('input[type="checkbox"]').first.check()
            page.wait_for_timeout(500)

            page.locator('body').click()
            page.wait_for_timeout(1000)

            page.locator('text=Catalog').locator('..').locator('svg').first.click()
            page.wait_for_timeout(1000)

            page.locator('text=catalog.entity.read').locator('..').locator('input[type="checkbox"]').first.check()
            page.wait_for_timeout(1000)

            # Add conditional rule
            print("  Adding conditional rule: NOT HAS_METADATA tags=custom...")

            catalog_row = page.locator('text=catalog.entity.read').locator('..')
            condition_button = catalog_row.locator('button').last
            condition_button.click()
            page.wait_for_timeout(2000)

            page.get_by_role('button', name='Not').click()
            page.wait_for_timeout(1000)

            page.wait_for_selector('text=Rule', timeout=5000)
            rule_dropdown = page.locator('select').first
            rule_dropdown.select_option('HAS_METADATA')
            page.wait_for_timeout(500)

            page.wait_for_selector('text=key', timeout=5000)
            key_input = page.locator('input[type="text"]').nth(0)
            key_input.fill('tags')
            page.wait_for_timeout(500)

            page.wait_for_selector('text=value', timeout=5000)
            value_input = page.locator('input[type="text"]').nth(1)
            value_input.fill('custom')
            page.wait_for_timeout(500)

            page.get_by_role('button', name='Save').click()
            page.wait_for_timeout(2000)

            print("  ✅ Added conditional rule to catalog.entity.read\n")

            page.locator('text=Scaffolder').locator('..').locator('svg').first.click()
            page.wait_for_timeout(1000)

            scaffolder_perms = [
                'scaffolder.template.parameter.read',
                'scaffolder.template.step.read',
                'scaffolder.action.execute',
                'scaffolder.task.cancel',
                'scaffolder.task.create',
                'scaffolder.task.read'
            ]
            for perm in scaffolder_perms:
                try:
                    page.locator('text=' + perm).locator('..').locator('input[type="checkbox"]').first.check()
                    page.wait_for_timeout(300)
                except:
                    pass

            page.wait_for_timeout(1000)

            page.get_by_role('button', name='Next').click()
            page.wait_for_timeout(2000)

            page.get_by_role('button', name='Create').click()
            page.wait_for_timeout(3000)
            print("  ✅ Created saa-portal-rhel-team role with conditional rule\n")

        browser.close()

        print("=" * 60)
        print("✅ SUCCESS: Portal RBAC policies created!")
        print("=" * 60)
        sys.exit(0)

except Exception as e:
    print("\n❌ ERROR: " + str(e))
    import traceback
    traceback.print_exc()

    # Try to take screenshot for debugging
    try:
        screenshot_path = '/tmp/portal_rbac_error.png'
        page.screenshot(path=screenshot_path)
        print("\n📸 Screenshot saved to: " + screenshot_path)
    except:
        pass

    sys.exit(1)
