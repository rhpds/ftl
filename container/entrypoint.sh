#!/bin/bash
# FTL Container Entrypoint
# Unified entrypoint for grading and solving labs
#
# Usage:
#   grade <lab-name> [user] [module-number] [--debug]
#   solve <lab-name> [user] [module-number] [--debug]
#   list
#   --help

set -e

FTL_DIR="/opt/ftl"
FTL_REPO="${FTL_REPO:-https://github.com/rhpds/ftl.git}"
FTL_REF="${FTL_REF:-main}"

# Clone labs/ at runtime if not already present (handles --local mount too)
if [ ! -d "${FTL_DIR}/labs" ]; then
    echo "FTL: cloning labs from ${FTL_REPO}@${FTL_REF}..."
    git clone --depth 1 --branch "$FTL_REF" --no-checkout "$FTL_REPO" /tmp/ftl-clone --quiet
    git -C /tmp/ftl-clone sparse-checkout set labs
    git -C /tmp/ftl-clone checkout --quiet
    cp -r /tmp/ftl-clone/labs "${FTL_DIR}/labs"
    rm -rf /tmp/ftl-clone
    echo "FTL: labs ready"
fi

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
ANSIBLE_DEBUG=""

# Strip --debug flag from arguments
ARGS=()
for arg in "$@"; do
    if [ "${arg}" = "--debug" ] || [ "${arg}" = "-d" ]; then
        ANSIBLE_DEBUG="-vvv"
    else
        ARGS+=("${arg}")
    fi
done
set -- "${ARGS[@]}"

# --- Functions ---

show_help() {
    cat <<'EOF'
FTL (Finish The Labs) - Containerized Lab Grader & Solver

Usage:
  ftl grade <lab-name> [user] [module-number] [--debug]   Grade a lab
  ftl solve <lab-name> [user] [module-number] [--debug]   Solve a lab
  ftl list                                                List available labs
  ftl --help                                              Show this help

Arguments:
  <lab-name>       Name of the lab (e.g., ocp4-getting-started)
  [user]           Lab user override (default: $LAB_USER or "student")
  [module-number]  Specific module to grade/solve (default: all)

Options:
  --debug, -d      Run ansible-playbook with -vvv for verbose debug output

Smart argument parsing:
  If the second argument is a number, it's treated as a module number.
  If it's not a number, it's treated as a user override.
  --debug can be placed anywhere in the arguments.

Authentication (for OpenShift labs):
  Method 1 - Mounted kubeconfig (highest priority):
    -v ~/.kube/config:/home/runner/.kube/config:ro

  Method 2 - Token-based:
    -e OCP_TOKEN=sha256~xxx
    -e OPENSHIFT_API_URL=https://api.cluster.example.com:6443

  Method 3 - Username/password:
    -e OPENSHIFT_USERNAME=user1
    -e OPENSHIFT_PASSWORD=secret
    -e OPENSHIFT_API_URL=https://api.cluster.example.com:6443

Environment variables:
  LAB_USER                         Lab user (default: "student")
  GUID                             Lab GUID (default: "ftl-container")
  OPENSHIFT_CLUSTER_INGRESS_DOMAIN Cluster ingress domain (required for OCP labs)
  OPENSHIFT_API_URL                OpenShift API URL (for token/password auth)
  OCP_TOKEN                        OpenShift auth token
  OPENSHIFT_USERNAME               OpenShift username
  OPENSHIFT_PASSWORD               OpenShift password

Examples:
  # Grade all modules with mounted kubeconfig
  podman run --rm -it \
      -v ~/.kube/config:/home/runner/.kube/config:ro \
      -e OPENSHIFT_CLUSTER_INGRESS_DOMAIN=apps.cluster.example.com \
      rhpds/ftl grade ocp4-getting-started user1

  # Solve module 1 with token auth
  podman run --rm -it \
      -e OCP_TOKEN=sha256~xxx \
      -e OPENSHIFT_API_URL=https://api.cluster.example.com:6443 \
      -e OPENSHIFT_CLUSTER_INGRESS_DOMAIN=apps.cluster.example.com \
      rhpds/ftl solve ocp4-getting-started user1 1

  # Persist grading reports to host
  podman run --rm -it \
      -v ~/.kube/config:/home/runner/.kube/config:ro \
      -v ./reports:/tmp/grading_dir \
      rhpds/ftl grade ocp4-getting-started user1
EOF
    exit 0
}

list_labs() {
    echo -e "${GREEN}Available labs:${NC}"
    echo ""
    for lab_dir in "${FTL_DIR}"/labs/*/; do
        lab_name=$(basename "${lab_dir}")
        # Skip template and WIP
        if [[ "${lab_name}" == "lab-template" || "${lab_name}" == "WIP" ]]; then
            continue
        fi
        grade_count=$(ls -1 "${lab_dir}"grade_module_*.yml 2>/dev/null | wc -l)
        solve_count=$(ls -1 "${lab_dir}"solve_module_*.yml 2>/dev/null | wc -l)
        echo -e "  ${BLUE}${lab_name}${NC}  (${grade_count} grade modules, ${solve_count} solve modules)"
    done
    echo ""
    exit 0
}

authenticate_cluster() {
    # Method 1: Mounted kubeconfig — check if it exists and has content
    if [ -f "${HOME}/.kube/config" ] && [ -s "${HOME}/.kube/config" ]; then
        echo -e "${BLUE}Using mounted kubeconfig${NC}"
        return 0
    fi

    # Method 2: Token-based auth
    if [ -n "${OCP_TOKEN}" ] && [ -n "${OPENSHIFT_API_URL}" ]; then
        echo -e "${BLUE}Authenticating with token...${NC}"
        oc login --token="${OCP_TOKEN}" --server="${OPENSHIFT_API_URL}" \
            --insecure-skip-tls-verify=true > /dev/null 2>&1
        echo -e "${GREEN}Authenticated via token${NC}"
        return 0
    fi

    # Method 3: Username/password auth
    if [ -n "${OPENSHIFT_USERNAME}" ] && [ -n "${OPENSHIFT_PASSWORD}" ] && [ -n "${OPENSHIFT_API_URL}" ]; then
        echo -e "${BLUE}Authenticating with username/password...${NC}"
        oc login -u "${OPENSHIFT_USERNAME}" -p "${OPENSHIFT_PASSWORD}" \
            --server="${OPENSHIFT_API_URL}" \
            --insecure-skip-tls-verify=true > /dev/null 2>&1
        echo -e "${GREEN}Authenticated via username/password${NC}"
        return 0
    fi

    # No auth provided — proceed without error (some labs don't need OCP)
    return 0
}

display_grade_report() {
    local lab_name="$1"
    local lab_user="$2"
    local module_num="$3"

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Grading Report${NC}"
    echo -e "${GREEN}========================================${NC}"

    if [ -n "${module_num}" ]; then
        # Single module report
        local report_file="/tmp/grading_dir/grading_report_${lab_user}_module_$(printf "%02d" "${module_num}").txt"

        if [ -f "${report_file}" ]; then
            cat "${report_file}"

            local last_result
            last_result=$(grep -E "^(SUCCESS|FAILED)" "${report_file}" | tail -1)

            if echo "${last_result}" | grep -q "SUCCESS 0 Errors"; then
                echo ""
                echo -e "${GREEN}Lab grading PASSED!${NC}"
                return 0
            else
                echo ""
                echo -e "${YELLOW}Lab grading FAILED - see report above${NC}"
                return 1
            fi
        else
            echo -e "${RED}Error: Report file not found: ${report_file}${NC}"
            return 1
        fi
    else
        # All modules
        local module_files
        module_files=$(ls -1 "${FTL_DIR}/labs/${lab_name}"/grade_module_*.yml 2>/dev/null | sort)
        local overall_pass=true

        for module_file in ${module_files}; do
            local mod_num
            mod_num=$(echo "${module_file}" | sed 's/.*grade_module_//' | sed 's/.yml//')
            local mod_report="/tmp/grading_dir/grading_report_${lab_user}_module_${mod_num}.txt"

            if [ -f "${mod_report}" ]; then
                cat "${mod_report}"
                echo ""
                local last_result
                last_result=$(grep -E "^(SUCCESS|FAILED)" "${mod_report}" | tail -1)
                if ! echo "${last_result}" | grep -q "SUCCESS 0 Errors"; then
                    overall_pass=false
                fi
            else
                echo -e "${YELLOW}Warning: Report not found for module ${mod_num}: ${mod_report}${NC}"
                overall_pass=false
            fi
        done

        if [ "${overall_pass}" = true ]; then
            echo -e "${GREEN}All modules PASSED!${NC}"
            return 0
        else
            echo -e "${YELLOW}Some modules FAILED - see reports above${NC}"
            return 1
        fi
    fi
}

# --- Main ---

COMMAND="${1}"

case "${COMMAND}" in
    --help|-h|"")
        show_help
        ;;
    list)
        list_labs
        ;;
    grade|solve)
        shift
        ;;
    *)
        echo -e "${RED}Error: Unknown command '${COMMAND}'${NC}"
        echo "Run with --help for usage information"
        exit 1
        ;;
esac

# From here: grade or solve
PURPOSE="${COMMAND}_lab"
LAB_NAME="${1}"
ARG2="${2}"
ARG3="${3}"

if [ -z "${LAB_NAME}" ]; then
    echo -e "${RED}Error: Lab name required${NC}"
    echo "Usage: ftl ${COMMAND} <lab-name> [user] [module-number]"
    echo ""
    echo "Available labs:"
    for lab_dir in "${FTL_DIR}"/labs/*/; do
        lab=$(basename "${lab_dir}")
        [[ "${lab}" == "lab-template" || "${lab}" == "WIP" ]] && continue
        echo "  ${lab}"
    done
    exit 1
fi

# Smart argument parsing
# If ARG2 is a number, it's a module number (user from env)
# If ARG2 is not a number, it's a user (module from ARG3)
if [[ "${ARG2}" =~ ^[0-9]+$ ]]; then
    MODULE_NUM="${ARG2}"
    USER_OVERRIDE=""
else
    USER_OVERRIDE="${ARG2}"
    MODULE_NUM="${ARG3}"
fi

# Validate lab exists
if [ ! -d "${FTL_DIR}/labs/${LAB_NAME}" ]; then
    echo -e "${RED}Error: Lab '${LAB_NAME}' not found${NC}"
    echo "Available labs:"
    for lab_dir in "${FTL_DIR}"/labs/*/; do
        lab=$(basename "${lab_dir}")
        [[ "${lab}" == "lab-template" || "${lab}" == "WIP" ]] && continue
        echo "  ${lab}"
    done
    exit 1
fi

# Set LAB_USER (priority: command arg > LAB_USER env > "student")
if [ -n "${USER_OVERRIDE}" ]; then
    export LAB_USER="${USER_OVERRIDE}"
elif [ -z "${LAB_USER}" ]; then
    export LAB_USER="student"
fi

# Set GUID (container hostnames are random, default to ftl-container)
export GUID="${GUID:-ftl-container}"

# Authenticate to OpenShift cluster if credentials are available
authenticate_cluster

# Action labels for display
if [ "${COMMAND}" = "grade" ]; then
    ACTION_NOUN="Grader"
    ACTION_VERB="Grading"
else
    ACTION_NOUN="Solver"
    ACTION_VERB="Solving"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}FTL Lab ${ACTION_NOUN}${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Lab:      ${BLUE}${LAB_NAME}${NC}"
echo -e "User:     ${BLUE}${LAB_USER}${NC}"
echo -e "GUID:     ${BLUE}${GUID}${NC}"
if [ -n "${ANSIBLE_DEBUG}" ]; then
    echo -e "Debug:    ${YELLOW}enabled (-vvv)${NC}"
fi

# Build inventory args
INVENTORY_ARGS=""
if [ -f "${FTL_DIR}/labs/${LAB_NAME}/inventory" ]; then
    INVENTORY_ARGS="-i ${FTL_DIR}/labs/${LAB_NAME}/inventory"
fi

cd "${FTL_DIR}"

if [ -n "${MODULE_NUM}" ]; then
    # Run specific module
    MODULE_FILE="labs/${LAB_NAME}/${COMMAND}_module_$(printf "%02d" "${MODULE_NUM}").yml"

    if [ ! -f "${MODULE_FILE}" ]; then
        echo -e "${RED}Error: Module ${MODULE_NUM} not found${NC}"
        echo "Available modules:"
        ls -1 "labs/${LAB_NAME}/${COMMAND}_module_"*.yml 2>/dev/null \
            | sed "s/.*${COMMAND}_module_/  Module /" | sed 's/.yml//'
        exit 1
    fi

    echo -e "Module:   ${BLUE}${MODULE_NUM}${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # shellcheck disable=SC2086
    ansible-playbook ${ANSIBLE_DEBUG} ${INVENTORY_ARGS} "${MODULE_FILE}"
else
    # Run all modules in order
    MODULE_FILES=$(ls -1 "labs/${LAB_NAME}/${COMMAND}_module_"*.yml 2>/dev/null | sort)
    if [ -z "${MODULE_FILES}" ]; then
        echo -e "${RED}Error: No ${COMMAND} modules found for '${LAB_NAME}'${NC}"
        exit 1
    fi

    echo -e "${ACTION_VERB}: ${BLUE}All modules${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    for MODULE_FILE in ${MODULE_FILES}; do
        MOD_NUM=$(echo "${MODULE_FILE}" | sed "s/.*${COMMAND}_module_//" | sed 's/.yml//' | sed 's/^0*//')
        echo -e "${BLUE}--- ${ACTION_VERB} Module ${MOD_NUM} ---${NC}"
        # shellcheck disable=SC2086
        ansible-playbook ${ANSIBLE_DEBUG} ${INVENTORY_ARGS} "${MODULE_FILE}"
        echo ""
    done
fi

# Display report for grade commands
if [ "${COMMAND}" = "grade" ]; then
    display_grade_report "${LAB_NAME}" "${LAB_USER}" "${MODULE_NUM}"
    exit $?
fi

# Solve completed
echo ""
echo -e "${GREEN}Lab solving completed!${NC}"
echo ""
if [ -n "${MODULE_NUM}" ]; then
    echo -e "${YELLOW}Run '${COMMAND%solve}grade ${LAB_NAME} ${LAB_USER} ${MODULE_NUM}' to verify the solution${NC}"
else
    echo -e "${YELLOW}Run 'grade ${LAB_NAME} ${LAB_USER}' to verify the solution${NC}"
fi
exit 0
