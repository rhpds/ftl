# FTL (Finish The Labs) Container Image
# Packages the Ansible-based grading/solving framework for portable execution
#
# Build:  podman build -t rhpds/ftl -f Containerfile .
# Run:    podman run --rm -it rhpds/ftl grade ocp4-getting-started user1

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

LABEL name="rhpds/ftl" \
      summary="FTL - Finish The Labs" \
      description="Automated grading and solving for hands-on technical labs" \
      maintainer="Red Hat Demo Platform"

# System packages
RUN microdnf install -y --nodocs \
        python3.11 \
        python3.11-pip \
        git \
        jq \
        openssh-clients \
        sshpass \
        tar \
        gzip \
    && microdnf clean all \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/pip3.11 /usr/bin/pip3

# OpenShift CLI (oc + kubectl) — detect architecture for multi-arch support
RUN ARCH=$(uname -m) \
    && if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
         OC_URL="https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/stable-4.14/openshift-client-linux.tar.gz"; \
       else \
         OC_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.14/openshift-client-linux.tar.gz"; \
       fi \
    && curl -sL "$OC_URL" | tar xzf - -C /usr/local/bin oc kubectl \
    && chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

# Python packages (no venv — the container IS the isolation)
RUN pip3 install --no-cache-dir \
        ansible-core \
        kubernetes \
        jmespath

# Ansible collections
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml -p /usr/share/ansible/collections \
    && rm /tmp/requirements.yml

# Non-root user (UID 1001 works with OpenShift arbitrary UID)
RUN microdnf install -y --nodocs shadow-utils \
    && useradd -u 1001 -g 0 -m runner \
    && microdnf remove -y shadow-utils \
    && microdnf clean all \
    && mkdir -p /home/runner/.kube /tmp/grading_dir \
    && chown -R 1001:0 /home/runner /tmp/grading_dir \
    && chmod -R g=u /home/runner /tmp/grading_dir

WORKDIR /opt/ftl

# Copy framework files (ansible.cfg uses relative paths: ./roles, ./plugins)
COPY ansible.cfg main.yml galaxy.yml ./
COPY vars/ vars/
COPY roles/ roles/
COPY plugins/ plugins/
COPY labs/ labs/

# Entrypoint script
COPY container/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Fix ownership for non-root execution
RUN chown -R 1001:0 /opt/ftl && chmod -R g=u /opt/ftl

ENV ANSIBLE_CONFIG=/opt/ftl/ansible.cfg \
    ANSIBLE_FORCE_COLOR=1 \
    PYTHONUNBUFFERED=1

USER 1001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
