## solver_browser_action

Browser automation role for solving UI-based lab exercises.

### Purpose

This role automates browser interactions using Playwright to solve exercises that require UI manipulation in web applications like AAP Controller, Self-Service Portal, OpenShift Console, etc.

### Requirements

- Ansible >= 2.9
- Python >= 3.8
- Playwright: `pip install playwright && playwright install chromium`

### Role Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `url` | - | Yes | Target URL to navigate to |
| `action` | - | Yes | Browser action: `login`, `click`, `fill_form`, `wait_for_text`, `screenshot`, `navigate` |
| `username` | `""` | No | Username for login action |
| `password` | `""` | No | Password for login action |
| `selector` | `""` | No | CSS selector for element interaction |
| `text` | `""` | No | Text content for fill_form or wait_for_text |
| `screenshot_path` | `""` | No | Path to save screenshot |
| `timeout` | `30000` | No | Timeout in milliseconds |
| `headless` | `true` | No | Run browser in headless mode |

### Example Playbook

#### Example 1: Login to AAP Controller

```yaml
- name: Login to AAP as admin
  include_role:
    name: rhdp.ftl.solver_browser_action
  vars:
    url: "https://controller.example.com"
    action: "login"
    username: "admin"
    password: "redhat123"
```

#### Example 2: Navigate and click menu item

```yaml
- name: Click Access Management menu
  include_role:
    name: rhdp.ftl.solver_browser_action
  vars:
    url: "https://controller.example.com/#/teams"
    action: "click"
    selector: 'button:has-text("Create Team")'
```

#### Example 3: Fill form field

```yaml
- name: Enter team name
  include_role:
    name: rhdp.ftl.solver_browser_action
  vars:
    url: "https://controller.example.com/#/teams/add"
    action: "fill_form"
    selector: 'input[name="name"]'
    text: "cloud-team"
```

#### Example 4: Wait for success message

```yaml
- name: Wait for team created confirmation
  include_role:
    name: rhdp.ftl.solver_browser_action
  vars:
    url: "https://controller.example.com/#/teams"
    action: "wait_for_text"
    text: "cloud-team successfully created"
```

### Complete Example: Create Team in AAP

```yaml
---
- name: Solve AAP team creation via UI
  hosts: localhost
  gather_facts: false

  vars:
    aap_url: "https://controller.example.com"
    admin_user: "admin"
    admin_pass: "redhat123"

  tasks:
    - name: Login to AAP
      include_role:
        name: rhdp.ftl.solver_browser_action
      vars:
        url: "{{ aap_url }}"
        action: "login"
        username: "{{ admin_user }}"
        password: "{{ admin_pass }}"

    - name: Navigate to Teams page
      include_role:
        name: rhdp.ftl.solver_browser_action
      vars:
        url: "{{ aap_url }}/#/teams"
        action: "click"
        selector: 'a[href="#/teams"]'

    - name: Click Create Team button
      include_role:
        name: rhdp.ftl.solver_browser_action
      vars:
        url: "{{ aap_url }}/#/teams"
        action: "click"
        selector: 'button:has-text("Create Team")'

    - name: Fill team name
      include_role:
        name: rhdp.ftl.solver_browser_action
      vars:
        url: "{{ aap_url }}/#/teams/add"
        action: "fill_form"
        selector: 'input[name="name"]'
        text: "cloud-team"

    - name: Fill organization
      include_role:
        name: rhdp.ftl.solver_browser_action
      vars:
        url: "{{ aap_url }}/#/teams/add"
        action: "fill_form"
        selector: 'select[name="organization"]'
        text: "Default"

    - name: Click Save button
      include_role:
        name: rhdp.ftl.solver_browser_action
      vars:
        url: "{{ aap_url }}/#/teams/add"
        action: "click"
        selector: 'button[type="submit"]:has-text("Save")'

    - name: Verify team created
      include_role:
        name: rhdp.ftl.solver_browser_action
      vars:
        url: "{{ aap_url }}/#/teams"
        action: "wait_for_text"
        text: "cloud-team"
```

### Browser Automation Best Practices

1. **Use specific selectors**: Prefer data-testid or unique IDs over generic classes
2. **Wait for elements**: Use wait_for_text or timeouts to ensure page loads
3. **Take screenshots**: For debugging, capture screenshots at key steps
4. **Handle errors**: Browser automation can be flaky - use retries
5. **Headless mode**: Run in headless mode on bastion, use GUI mode locally for debugging

### License

Apache-2.0

### Author

Red Hat Demo Platform
