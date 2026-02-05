#!/usr/bin/python
# -*- coding: utf-8 -*-

# Browser automation module for FTL solvers
# Uses Playwright for UI automation

from ansible.module_utils.basic import AnsibleModule

DOCUMENTATION = '''
---
module: browser_automate
short_description: Automate browser actions for UI-based lab solving
description:
    - Uses Playwright to automate browser interactions
    - Supports login, navigation, clicking, form filling
    - Returns success/failure and optional screenshots
options:
    url:
        description: URL to navigate to
        required: true
        type: str
    action:
        description: Action to perform
        required: true
        type: str
        choices: ['login', 'click', 'fill_form', 'wait_for_text', 'screenshot']
    username:
        description: Username for login action
        required: false
        type: str
    password:
        description: Password for login action
        required: false
        type: str
    selector:
        description: CSS selector for element to interact with
        required: false
        type: str
    text:
        description: Text to fill or wait for
        required: false
        type: str
    screenshot_path:
        description: Path to save screenshot
        required: false
        type: str
    timeout:
        description: Timeout in milliseconds
        required: false
        type: int
        default: 30000
    headless:
        description: Run browser in headless mode
        required: false
        type: bool
        default: true
'''

EXAMPLES = '''
- name: Login to AAP Controller
  browser_automate:
    url: "https://controller.example.com"
    action: login
    username: admin
    password: redhat123

- name: Click on Access Management menu
  browser_automate:
    url: "https://controller.example.com"
    action: click
    selector: 'a[href="#/access"]'

- name: Fill team name
  browser_automate:
    url: "https://controller.example.com/#/teams/add"
    action: fill_form
    selector: 'input[name="name"]'
    text: "cloud-team"
'''

try:
    from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
    HAS_PLAYWRIGHT = True
except ImportError:
    HAS_PLAYWRIGHT = False


def run_browser_action(module):
    """Execute browser automation action"""

    if not HAS_PLAYWRIGHT:
        module.fail_json(msg="Playwright is not installed. Install with: pip install playwright && playwright install chromium")

    url = module.params['url']
    action = module.params['action']
    username = module.params.get('username')
    password = module.params.get('password')
    selector = module.params.get('selector')
    text = module.params.get('text')
    screenshot_path = module.params.get('screenshot_path')
    timeout = module.params['timeout']
    headless = module.params['headless']

    result = {
        'changed': True,
        'action': action,
        'url': url
    }

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=headless)
            context = browser.new_context(ignore_https_errors=True)
            page = context.new_page()
            page.set_default_timeout(timeout)

            # Navigate to URL
            page.goto(url)

            # Perform action
            if action == 'login':
                if not username or not password:
                    module.fail_json(msg="username and password required for login action")

                # Generic login form
                page.fill('input[type="text"], input[name="username"]', username)
                page.fill('input[type="password"], input[name="password"]', password)
                page.click('button[type="submit"], input[type="submit"]')
                page.wait_for_load_state('networkidle')
                result['message'] = f"Logged in as {username}"

            elif action == 'click':
                if not selector:
                    module.fail_json(msg="selector required for click action")
                page.click(selector)
                page.wait_for_load_state('networkidle')
                result['message'] = f"Clicked element: {selector}"

            elif action == 'fill_form':
                if not selector or not text:
                    module.fail_json(msg="selector and text required for fill_form action")
                page.fill(selector, text)
                result['message'] = f"Filled {selector} with text"

            elif action == 'wait_for_text':
                if not text:
                    module.fail_json(msg="text required for wait_for_text action")
                page.wait_for_selector(f'text={text}', timeout=timeout)
                result['message'] = f"Found text: {text}"

            elif action == 'screenshot':
                if not screenshot_path:
                    module.fail_json(msg="screenshot_path required for screenshot action")
                page.screenshot(path=screenshot_path)
                result['message'] = f"Screenshot saved to {screenshot_path}"
                result['screenshot'] = screenshot_path

            # Optional screenshot for debugging
            if screenshot_path and action != 'screenshot':
                page.screenshot(path=screenshot_path)
                result['screenshot'] = screenshot_path

            browser.close()

    except PlaywrightTimeout as e:
        module.fail_json(msg=f"Timeout waiting for element: {str(e)}")
    except Exception as e:
        module.fail_json(msg=f"Browser automation failed: {str(e)}")

    module.exit_json(**result)


def main():
    module = AnsibleModule(
        argument_spec=dict(
            url=dict(type='str', required=True),
            action=dict(type='str', required=True,
                       choices=['login', 'click', 'fill_form', 'wait_for_text', 'screenshot']),
            username=dict(type='str', required=False, no_log=True),
            password=dict(type='str', required=False, no_log=True),
            selector=dict(type='str', required=False),
            text=dict(type='str', required=False),
            screenshot_path=dict(type='str', required=False),
            timeout=dict(type='int', required=False, default=30000),
            headless=dict(type='bool', required=False, default=True)
        ),
        supports_check_mode=False
    )

    run_browser_action(module)


if __name__ == '__main__':
    main()
