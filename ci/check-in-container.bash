#!/bin/bash

# This script runs the checks of the UR5e platform inside the container of a setup, as part of the CI of OpenRoSDE.
# 'gitlab-ci/run-extension-checks.bash' of the core runs it once the Catkin workspaces of the setup are built and sourced, in the container that 'gitlab-ci/test-catkin-workspaces.bash' disconnected from every network.
#
# Usage: bash ./ci/check-in-container.bash <robot-setup>
#
# <robot-setup>: The setup that the CI tests, which activates this platform, such as 'ur5e'.

################################################################################

# Resolve the folder of the checks.
OPENROSDE_UR5E_CI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check the plain UR5e in Gazebo in its default setup only, since a setup that mounts devices on it checks its own description.
if [ "$1" != "ur5e" ]; then
  echo "Skipping the check of the plain UR5e in Gazebo, since the setup '$1' is not the default setup 'ur5e'."
  exit 0
fi
bash "${OPENROSDE_UR5E_CI_DIR}/check-gazebo.bash"
