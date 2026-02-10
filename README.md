# FTL - Finish The Labs

Automated grading and solving framework for hands-on labs using Ansible.

## Overview

FTL (Finish The Labs) provides automated validation (grading) and completion (solving) for hands-on technical labs. It's designed to work with AgnosticV/AgnosticD catalogs and supports multiple lab types: OpenShift, Ansible, RHEL, AI, Virtualization, etc.

**Key Features:**
- ✅ Automated lab validation with detailed checkpoints
- ✅ Auto-solving for testing and demos
- ✅ Multi-user support for shared environments
- ✅ 22 reusable grader roles for common validations
- ✅ SHA256-signed grading reports
- ✅ Student-friendly wrapper scripts

**Repository:** https://github.com/rhpds/ftl

---

## Quick Start

### Installation

```bash
git clone https://github.com/rhpds/ftl.git ~/ftl
cd ~/ftl
bash bin/setup_ftl
export PATH="$HOME/ftl/bin:$PATH"
```

### Grade a Lab

```bash
# Set environment variables (get from your lab provisioning system)
export OPENSHIFT_CLUSTER_INGRESS_DOMAIN="apps.cluster-xxxxx.dynamic.redhatworkshops.io"

# Multi-user lab (namespace derived from user argument)
grade_lab ocp4-getting-started user1
grade_lab ocp4-getting-started user1 2    # Specific module

# Single-user lab (no user argument needed)
grade_lab automating-ripu-with-ansible
grade_lab automating-ripu-with-ansible 1  # Specific module

# View report
cat /tmp/grading_dir/grading_report_user1.txt
```

### Auto-Solve a Lab

```bash
solve_lab ocp4-getting-started user1      # Multi-user
solve_lab automating-ripu-with-ansible    # Single-user
```

**Command Syntax:**
```bash
grade_lab <lab-name> [user] [module-number]
solve_lab <lab-name> [user] [module-number]
```

---

## Production Labs

| Lab | Modules | Checkpoints | Technology | Details |
|-----|---------|-------------|------------|---------|
| **mcp-with-openshift** | 4 | 35 | OpenShift, MCP, Tekton, Gitea | [README](labs/mcp-with-openshift/README.md) |
| **automating-ripu-with-ansible** | 3 | 57 | AAP 2.6, RHEL, Leapp | [README](labs/automating-ripu-with-ansible/README.md) |
| **ocp4-getting-started** | 3 | 50 | OpenShift, S2I, MongoDB, Tekton | [README](labs/ocp4-getting-started/README.md) |

**Framework Statistics:**
- **Total Labs:** 3 production-ready
- **Total Checkpoints:** 142 across all labs
- **Total Grader Roles:** 22 reusable validation roles
- **Documentation:** 6,000+ lines

📊 **For detailed lab comparison:** See [LAB_MATRIX.md](LAB_MATRIX.md)
📊 **For lab statistics:** See [QUICK_STATS.md](QUICK_STATS.md)
📊 **For complete lab inventory:** See [FTL_LAB_INVENTORY.md](FTL_LAB_INVENTORY.md)

---

## Framework Components

### Wrapper Scripts (`bin/`)

- **`grade_lab`** - Student-facing grading wrapper (auto-installs FTL, smart argument parsing)
- **`solve_lab`** - Auto-completion wrapper for testing and demos
- **`setup_ftl`** - Dependency installer (Python venv, Ansible, collections)

### Lifecycle Roles (`roles/ftl_run_*`)

- **`ftl_run_init`** - Initialize grading session, create report file
- **`ftl_run_log_grade_to_log`** - Log PASS/FAIL results to report
- **`ftl_run_grade_report_generation`** - Generate summary and SHA256 signature
- **`ftl_run_finish`** - Display final results to student

### Grader Roles (`roles/grader_check_*`)

**22 reusable grader roles** for validating:
- **Generic System** (7): Commands, files, services, packages, users, containers
- **OpenShift/Kubernetes** (11): Resources, pods, deployments, routes, services, builds, secrets, configmaps, PVCs, pipelines
- **AAP/Tower** (3): Licensing, job templates, workflow templates
- **HTTP/Network** (2): Endpoints, JSON responses

📖 **Complete grader roles reference:** [docs/GRADER_ROLES_REFERENCE.md](docs/GRADER_ROLES_REFERENCE.md)

---

## Creating New Labs

### 1. Use the Lab Template

```bash
# Copy template to create new lab
cp -r labs/lab-template labs/my-new-lab
cd labs/my-new-lab
```

### 2. Customize Graders

Edit `grade_module_01.yml` to add your checkpoints:

```yaml
- name: "Exercise 1.1: Verify resource exists"
  ansible.builtin.include_role:
    name: grader_check_ocp_pod_running
  vars:
    task_description_message: "Exercise 1.1: Application pod is running"
    pod_name: "myapp-.*"
    pod_namespace: "{{ project_name }}"
```

### 3. Customize Solvers

Edit `solve_module_01.yml` to automate lab completion:

```yaml
- name: Deploy application
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: myapp
```

### 4. Test

```bash
# Test grader on fresh environment (should FAIL)
grade_lab my-new-lab

# Run solver
solve_lab my-new-lab

# Test grader again (should PASS)
grade_lab my-new-lab
```

📖 **Lab template documentation:** [labs/lab-template/README.md](labs/lab-template/README.md)
📖 **Grader role reference:** [docs/GRADER_ROLES_REFERENCE.md](docs/GRADER_ROLES_REFERENCE.md)

---

## AgnosticV Integration

Deploy FTL in the `post_software` phase of your AgnosticV catalog:

```yaml
# catalog/dev.yaml
post_software:
  - name: Install FTL
    ansible.builtin.git:
      repo: https://github.com/rhpds/ftl.git
      dest: /home/{{ ansible_user }}/ftl

  - name: Setup FTL
    ansible.builtin.command: bash /home/{{ ansible_user }}/ftl/bin/setup_ftl

  - name: Add grade_lab to PATH
    ansible.builtin.lineinfile:
      path: /home/{{ ansible_user }}/.bashrc
      line: 'export PATH="$HOME/ftl/bin:$PATH"'
```

Students can then grade their work:
```bash
grade_lab your-lab-name
```

---

## Documentation

### Getting Started
- **[README.adoc](README.adoc)** - Comprehensive installation and usage guide (AsciiDoc format)
- **[TESTING.md](TESTING.md)** - Testing guide for lab validation

### Lab Documentation
- **[LAB_MATRIX.md](LAB_MATRIX.md)** - At-a-glance lab comparison matrix
- **[QUICK_STATS.md](QUICK_STATS.md)** - Framework statistics and quality metrics
- **[FTL_LAB_INVENTORY.md](FTL_LAB_INVENTORY.md)** - Comprehensive lab-by-lab analysis

### Reference Guides
- **[docs/GRADER_ROLES_REFERENCE.md](docs/GRADER_ROLES_REFERENCE.md)** - Complete API reference for all 22 grader roles (847 lines)
- **[labs/lab-template/](labs/lab-template/)** - Template for creating new labs

### Per-Lab READMEs
- **[labs/mcp-with-openshift/README.md](labs/mcp-with-openshift/README.md)** - MCP lab documentation
- **[labs/automating-ripu-with-ansible/README.md](labs/automating-ripu-with-ansible/README.md)** - RIPU lab documentation
- **[labs/ocp4-getting-started/README.md](labs/ocp4-getting-started/README.md)** - OCP Getting Started lab documentation

---

## Key Design Principles

1. **100% API-Based Validation** - No browser automation; all validation via APIs
2. **Multi-User Support** - Isolated namespaces/projects per student
3. **Reusable Roles** - DRY principle for grader/solver components
4. **Student-Friendly** - Simple wrapper scripts hide complexity
5. **Signed Reports** - SHA256 verification for grading integrity

---

## Support

- **Issues:** https://github.com/rhpds/ftl/issues
- **Source Code:** https://github.com/rhpds/ftl
- **RHDP Team:** Red Hat Demo Platform

---

## License

Apache 2.0

## Authors

Red Hat Demo Platform (RHDP) Team
