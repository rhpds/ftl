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

### Grade Lab

Grade all modules:
```bash
grade_lab mcp-with-openshift
```

Grade specific module:
```bash
grade_lab mcp-with-openshift 1    # Grade module 1 only
grade_lab mcp-with-openshift 2    # Grade module 2 only
```

### Solve Lab

Solve all modules (auto-complete lab):
```bash
solve_lab mcp-with-openshift
```

Solve specific module:
```bash
solve_lab mcp-with-openshift 1    # Solve module 1 only
solve_lab mcp-with-openshift 2    # Solve module 2 only
```

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
