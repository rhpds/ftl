# FTL (Finish The Labs) Grader/Solver Image
# Lightweight UBI9-based — only what FTL graders actually need.
# Much smaller and faster than the full multicloud EE image.
#
# Build:
#   podman build -t quay.io/rhpds/ftl-grader:latest .
#
# Run (from laptop):
#   ./bin/run-grade.sh ocp4-getting-started https://api.xxx:6443 admin-pass

FROM registry.access.redhat.com/ubi9/ubi:latest

ARG OC_VERSION=4.18
ARG FTL_REPO=https://github.com/rhpds/ftl.git
ARG FTL_REF=main

# ── System packages ───────────────────────────────────────────────────────────
RUN dnf install -y \
      python3 \
      python3-pip \
      git \
      curl \
      tar \
      jq \
    && dnf clean all

# ── oc client ─────────────────────────────────────────────────────────────────
RUN curl -sL \
    "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OC_VERSION}/openshift-client-linux.tar.gz" \
    | tar -xz -C /usr/local/bin oc kubectl \
    && oc version --client

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
    && ansible-galaxy collection list

# ── Clone FTL at build time ───────────────────────────────────────────────────
# Use --build-arg FTL_REF=<branch/tag> to pin a version
RUN git clone --depth 1 --branch ${FTL_REF} ${FTL_REPO} /ftl \
    && echo "FTL cloned: $(git -C /ftl log --oneline -1)"

# ── Permissions for OpenShift (random UID, GID 0) ─────────────────────────────
RUN mkdir -p /home/runner/.kube /tmp/grading \
    && chmod -R g+rwx /home/runner /tmp/grading /ftl \
    && chgrp -R root /home/runner /tmp/grading /ftl

ENV HOME=/home/runner
ENV ANSIBLE_ROLES_PATH=/ftl/roles
ENV ANSIBLE_COLLECTIONS_PATH=/home/runner/.ansible/collections:/usr/share/ansible/collections
ENV FTL_DIR=/ftl

WORKDIR /ftl

# Simple clean entrypoint — just ansible-playbook
ENTRYPOINT ["ansible-playbook"]
CMD ["--version"]
