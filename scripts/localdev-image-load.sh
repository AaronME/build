#!/usr/bin/env bash
set -aeuo pipefail

COMPONENT=$1

# Source utility functions
source "${SCRIPTS_DIR}/utils.sh"
# sourcing load-configs.sh:
#   - initializes configuration variables with default values
#   - loads top level configuration
#   - loads component level configuration
source "${SCRIPTS_DIR}/load-configs.sh" "${COMPONENT}"

# Skip deployment of this component if COMPONENT_SKIP_DEPLOY is set to true
if [ "${COMPONENT_SKIP_DEPLOY}" == "true" ]; then
  echo_info "COMPONENT_SKIP_DEPLOY set to true, skipping deployment of ${COMPONENT}"
  exit 0
fi

# Run deploy script, if exists.
# If there is a deploy.sh script, which indicates this is a "script-only" component, only it will be run for this
# component and no helm deployments will be made.
if [ -f "${DEPLOY_SCRIPT}" ]; then
  echo_info "Loading required images..."
  # shellcheck disable=SC2068
  for i in ${REQUIRED_IMAGES[@]+"${REQUIRED_IMAGES[@]}"}; do
    pullAndLoadImage "${i}"
  done
  echo_info "Loading required images...OK"

  echo_info "Running deploy script..."
  source "${DEPLOY_SCRIPT}"
  echo_info "Running deploy script...OK"
  exit 0
fi
