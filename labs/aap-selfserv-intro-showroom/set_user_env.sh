#!/bin/bash
# Set FTL Environment Variables for Specific User
# Usage: source set_user_env.sh <user_number>
# Example: source set_user_env.sh 1

USER_NUM="${1:-1}"  # Default to user1 if not specified

# GUID and cluster domain from deployment
GUID="j7kml"
CLUSTER_DOMAIN="apps.cluster-${GUID}.dynamic.redhatworkshops.io"

# Common password (all users share same password)
COMMON_PASSWORD="MjUxMzcw"

# Construct URLs for selected user
export AAP_CONTROLLER_URL="https://user${USER_NUM}-aap-user${USER_NUM}-aap.${CLUSTER_DOMAIN}"
export AAP_ADMIN_USERNAME="admin"
export AAP_ADMIN_PASSWORD="${COMMON_PASSWORD}"
export SELF_SERVICE_PORTAL_URL="https://self-service-rhaap-portal-user${USER_NUM}-aap-ssap.${CLUSTER_DOMAIN}"

# Additional info (not required for FTL but useful)
export OPENSHIFT_USERNAME="user${USER_NUM}"
export OPENSHIFT_PASSWORD="${COMMON_PASSWORD}"
export OPENSHIFT_CONSOLE_URL="https://console-openshift-console.${CLUSTER_DOMAIN}"
export AAP_NAMESPACE="user${USER_NUM}-aap"
export SHOWROOM_URL="https://showroom-showroom-${GUID}-1-user${USER_NUM}.${CLUSTER_DOMAIN}/"

echo "========================================="
echo "FTL Environment Set for User ${USER_NUM}"
echo "========================================="
echo ""
echo "AAP Controller: ${AAP_CONTROLLER_URL}"
echo "AAP Admin: ${AAP_ADMIN_USERNAME} / ${AAP_ADMIN_PASSWORD}"
echo "Portal: ${SELF_SERVICE_PORTAL_URL}"
echo "OpenShift User: ${OPENSHIFT_USERNAME}"
echo "Showroom: ${SHOWROOM_URL}"
echo ""
echo "Ready to run FTL graders/solvers!"
echo ""
