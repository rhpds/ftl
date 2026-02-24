# FTL (Finish The Labs) Grader/Solver Image
# Built on top of AgnosticD multicloud EE which has:
#   - ansible-playbook, ansible-core
#   - kubernetes.core collection
#   - oc client
#   - All required Python dependencies (kubernetes, openshift, etc.)
#
# Generic grader/solver roles are baked in at build time.
# Lab content (labs/) is cloned at runtime — no rebuild needed when graders change.
# --local flag mounts local repo's labs/ instead.
#
# Build:
#   podman build -t quay.io/rhpds/ftl:latest .
#   podman push quay.io/rhpds/ftl:latest
#
# Run:
#   ./bin/grade_lab <lab> <user> <module> --podman

FROM quay.io/agnosticd/ee-multicloud:chained-2026-02-23

USER root

# ── Generic FTL roles (baked in — stable, rarely change) ──────────────────────
COPY roles/ /usr/share/ansible/roles/

# ── FTL plugins and ansible config ────────────────────────────────────────────
COPY plugins/ /usr/share/ansible/plugins/
COPY ansible.cfg /home/runner/.ansible.cfg

# ── Entrypoint: clone labs/ at runtime then run ansible-playbook ──────────────
COPY deploy/ftl-entrypoint.sh /usr/local/bin/ftl-entrypoint
RUN chmod +x /usr/local/bin/ftl-entrypoint

# ── Permissions for OpenShift (random UID, GID 0) ─────────────────────────────
RUN mkdir -p /runner/grading-reports /ftl \
    && chmod -R g+rwx /runner/grading-reports /ftl /usr/share/ansible/roles \
    && chgrp -R root /runner/grading-reports /ftl /usr/share/ansible/roles

ENV FTL_REPO=https://github.com/rhpds/ftl.git
ENV FTL_REF=main

WORKDIR /runner

ENTRYPOINT ["/usr/local/bin/ftl-entrypoint"]
