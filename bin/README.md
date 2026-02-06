# FTL Wrapper Scripts

Student-facing wrapper scripts for easy lab grading and solving.

## Installation (on Bastion)

These scripts are designed to be deployed to student bastion hosts:

```bash
# Option 1: Add to PATH via profile
echo 'export PATH="$HOME/ftl/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Option 2: Copy to /usr/local/bin (requires sudo)
sudo cp ~/ftl/bin/* /usr/local/bin/
sudo chmod +x /usr/local/bin/grade_lab /usr/local/bin/solve_lab
```

## Usage

### For Dedicated Cluster Environment

When each student has their own cluster, use without user argument:

```bash
# Grade all modules
grade_lab mcp-with-openshift

# Grade specific module
grade_lab mcp-with-openshift 1

# Solve all modules
solve_lab mcp-with-openshift

# Solve specific module
solve_lab mcp-with-openshift 1
```

### For Multi-User Environment

When grading/solving for specific users in a shared cluster:

```bash
# Grade all modules for user2
grade_lab mcp-with-openshift user2

# Grade module 1 for user3
grade_lab mcp-with-openshift user3 1

# Solve all modules for user2
solve_lab mcp-with-openshift user2

# Solve module 2 for user4
solve_lab mcp-with-openshift user4 2
```

### Command Syntax

```bash
grade_lab <lab-name> [user] [module-number]
solve_lab <lab-name> [user] [module-number]
```

**Smart argument parsing:**
- If 2nd argument is a **number**, it's treated as module number (uses `$LAB_USER`)
- If 2nd argument is **not a number**, it's treated as username (module from 3rd arg)

## Environment Variables

The scripts automatically detect:
- `LAB_USER`: Defaults to `$USER`
- `GUID`: Defaults to extracted from hostname

Override if needed:
```bash
export LAB_USER=user1
export GUID=abc123
grade_lab mcp-lab
```

## How It Works

1. **Auto-installs/updates FTL**: Clones `https://github.com/rhpds/ftl.git` to `~/ftl` on first run
2. **Pulls latest changes**: Updates FTL repo before each run
3. **Runs Ansible playbooks**: Executes grade/solve playbooks
4. **Displays results**: Shows grading report with color-coded output

## For Lab Authors

To add a new lab:
1. Create directory: `labs/<lab-name>/`
2. Add grading playbooks: `grade_module_01.yml`, `grade_module_02.yml`, etc.
3. Add solving playbooks: `solve_module_01.yml`, `solve_module_02.yml`, etc.
4. Add main orchestrators: `grade_lab.yml`, `solve_lab.yml`

The wrappers will automatically detect your lab and modules.
