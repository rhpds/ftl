# FTL (Finish The Labs) Grader/Solver Image
# Lightweight UBI9-based for linux/amd64.
#
# FTL content is cloned at runtime (latest always) — no rebuild needed for changes.
# --local run flag mounts local repo over /ftl instead.
#
# Build:
#   podman build --platform linux/amd64 -t quay.io/rhpds/ftl-grader:latest .
#   podman push quay.io/rhpds/ftl-grader:latest
#
# Run:
#   ./bin/run-grade.sh ocp4-getting-started https://api.xxx:6443 admin-pass

FROM --platform=linux/amd64 registry.access.redhat.com/ubi9/ubi:latest

ARG OC_VERSION=4.18

# ── System packages ───────────────────────────────────────────────────────────
RUN dnf install -y --allowerasing \
      python3 \
      python3-pip \
      git \
      curl \
      tar \
      jq \
    && dnf clean all

# ── oc client (x86_64) ────────────────────────────────────────────────────────
RUN curl -sL \
    "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OC_VERSION}/openshift-client-linux.tar.gz" \
    | tar -xz -C /usr/local/bin oc kubectl \
    && echo "oc installed: $(ls -lh /usr/local/bin/oc)"

# ── Python dependencies ───────────────────────────────────────────────────────
RUN pip3 install --no-cache-dir \
      ansible-core \
      kubernetes \
      openshift \
      requests \
      PyYAML \
      jmespath

# ── Ansible collections ───────────────────────────────────────────────────────
RUN ansible-galaxy collection install \
      kubernetes.core \
      community.general \
      --collections-path /usr/share/ansible/collections \
    && ansible-galaxy collection list --collections-path /usr/share/ansible/collections

# ── Entrypoint: clone FTL at runtime then run ansible-playbook ────────────────
COPY deploy/ftl-entrypoint.sh /usr/local/bin/ftl-entrypoint
RUN chmod +x /usr/local/bin/ftl-entrypoint

# ── Permissions for OpenShift (random UID, GID 0) ─────────────────────────────
RUN mkdir -p /home/runner/.kube /ftl /tmp/grading \
    && chmod -R g+rwx /home/runner /tmp/grading /ftl \
    && chgrp -R root /home/runner /tmp/grading /ftl

ENV HOME=/home/runner
ENV ANSIBLE_ROLES_PATH=/ftl/roles
ENV ANSIBLE_COLLECTIONS_PATH=/home/runner/.ansible/collections:/usr/share/ansible/collections
ENV FTL_REPO=https://github.com/rhpds/ftl.git
ENV FTL_REF=main

WORKDIR /ftl

ENTRYPOINT ["/usr/local/bin/ftl-entrypoint"]
