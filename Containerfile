# FTL (Finish The Labs) Grader/Solver Image
# Built on top of AgnosticD multicloud EE which has:
#   - ansible-playbook
#   - kubernetes.core collection
#   - oc client
#   - All required Python dependencies (kubernetes, openshift, etc.)

FROM quay.io/agnosticd/ee-multicloud:chained-2026-02-16

USER root

# Copy FTL roles into the Ansible collections path
COPY roles/ /usr/share/ansible/roles/

# Copy FTL labs
COPY labs/ /runner/labs/

# Copy FTL plugins (agnosticd_user_info, agnosticd_user_data, etc.)
COPY plugins/ /usr/share/ansible/plugins/

# Copy ansible config
COPY ansible.cfg /home/runner/.ansible.cfg

# Fix permissions for OpenShift (runs as random UID with GID 0)
RUN chmod -R g+rwx /runner/labs /usr/share/ansible/roles && \
    chgrp -R root /runner/labs /usr/share/ansible/roles && \
    mkdir -p /runner/grading-reports && \
    chmod -R g+rwx /runner/grading-reports && \
    chgrp -R root /runner/grading-reports

USER 1000

WORKDIR /runner

# Default: list available labs
CMD ["ansible-playbook", "--version"]
