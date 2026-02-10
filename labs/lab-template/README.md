# Lab Template - FTL Grader and Solver

This is a template for creating new labs with FTL graders and solvers.

**To use this template:**
1. Copy this entire directory to `labs/your-lab-name/`
2. Update `README.md` with your lab details
3. Customize `grade_module_01.yml` for your checkpoints
4. Customize `solve_module_01.yml` for your automation
5. Add additional modules as needed
6. Update `grade_lab.yml` orchestrator
7. Test thoroughly before deployment

---

## Lab Information

**Lab Name:** [Your Lab Name Here]
**Technology Stack:** [e.g., OpenShift, AAP, RHEL, etc.]
**Duration:** [e.g., 60 minutes, 90 minutes]
**Target Audience:** [e.g., Beginner, Intermediate, Advanced]

---

## Module Structure

### Module 1: [Module Name]

**Checkpoints:** [N checkpoints]

**Learning Objectives:**
- Objective 1
- Objective 2
- Objective 3

**Key Validations:**
- What gets checked
- What resources are validated
- What student actions are verified

---

## Environment Variables

**Required:**
```bash
export REQUIRED_VAR_1="value"
export REQUIRED_VAR_2="value"
```

**Optional:**
```bash
export LAB_USER="user1"  # For multi-user environments
export OPTIONAL_VAR="value"
```

---

## Usage

### Grading

**Full lab:**
```bash
grade_lab your-lab-name
```

**Specific module:**
```bash
grade_lab your-lab-name 1
```

**Multi-user grading:**
```bash
for user in user{1..10}; do
  export LAB_USER="${user}"
  grade_lab your-lab-name
done
```

### Solving

**Full lab automation:**
```bash
solve_lab your-lab-name
```

**Specific module:**
```bash
solve_lab your-lab-name 1
```

---

## File Inventory

### Grading Playbooks
- `grade_module_01.yml` - Module 1 grader (N checkpoints)
- `grade_lab.yml` - Full lab orchestrator

### Solver Playbooks
- `solve_module_01.yml` - Module 1 automation

### Documentation
- `README.md` - This file
- `lab.yml` - Lab metadata (optional)

---

## Checkpoint Mapping

### Module 1 Checkpoints

| Exercise | Description | Grader Role Used | Validation Method |
|----------|-------------|------------------|-------------------|
| 1.1 | [Exercise description] | grader_check_* | [What gets validated] |
| 1.2 | [Exercise description] | grader_check_* | [What gets validated] |
| 1.3 | [Exercise description] | grader_check_* | [What gets validated] |

---

## Technology Coverage

**Resources Validated:**
- Resource type 1 (e.g., Pods, Deployments)
- Resource type 2
- Resource type 3

**Grader Roles Used:**
- `grader_check_*` - Description
- `grader_check_*` - Description

---

## Testing Approach

### Fresh Environment Test

**Expected Behavior (Before Solver):**
```
Module 1: FAILED (no resources deployed)
Total: FAILED N Errors
```

**After Solver:**
```
Module 1: SUCCESS (all checkpoints pass)
Total: SUCCESS 0 Errors
```

### Manual Testing

Test individual components:

```bash
# Test command 1
command to verify manually

# Test command 2
command to verify manually
```

---

## AgnosticV Integration

**Post-software installation:**
```yaml
# catalog/dev.yaml
post_software:
  - name: Install FTL
    command: git clone https://github.com/rhpds/ftl.git ~/ftl

  - name: Setup FTL
    command: bash ~/ftl/bin/setup_ftl

  - name: Add grade_lab to PATH
    lineinfile:
      path: ~/.bashrc
      line: 'export PATH="$HOME/ftl/bin:$PATH"'
```

Students can then grade their work:
```bash
grade_lab your-lab-name
```

---

## Troubleshooting

### Common Issues

**1. "Resource not found"**
```bash
# Verify resource exists
command to check

# Common causes:
# - Cause 1
# - Cause 2
```

**2. "Connection failed"**
```bash
# Check connectivity
command to check

# Common causes:
# - Cause 1
# - Cause 2
```

---

## Contributing

When adding new checkpoints:

1. Add validation to appropriate module grader
2. Update solver if automatable
3. Update this README
4. Test on fresh environment
5. Verify error messages are helpful

---

## Statistics

**Checkpoints:** N total
**Grader Playbooks:** N
**Solver Playbooks:** N
**Lines of Code:** ~N (estimate)
**Roles Used:** N grader roles

---

## License

Part of the FTL (Finish The Labs) framework.
Repository: https://github.com/rhpds/ftl
