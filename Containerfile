# FTL (Finish The Labs) Grader/Solver Image
# Built on top of AgnosticD multicloud EE which has:
#   - ansible-playbook, kubernetes.core, oc client
#   - All required Python dependencies
#
# FTL repo is cloned at runtime (not baked in) so no rebuild needed on changes.
# Set FTL_REPO env var to override the default repo URL.

FROM quay.io/agnosticd/ee-multicloud:chained-2026-02-16

USER root

# Copy runtime entrypoint
COPY deploy/ftl-entrypoint.sh /usr/local/bin/ftl-entrypoint
RUN chmod +x /usr/local/bin/ftl-entrypoint

# Fix permissions for OpenShift (random UID, GID 0)
RUN mkdir -p /runner/ftl /runner/grading-reports && \
    chmod -R g+rwx /runner && \
    chgrp -R root /runner

USER 1000
WORKDIR /runner

ENTRYPOINT ["/usr/local/bin/ftl-entrypoint"]
