#!/bin/bash

# This script checks that the plain UR5e runs in Gazebo with the controllers and the MoveIt Servo that its launch files start, as part of the CI of OpenRoSDE.
# It starts 'ci/ur5e_gazebo_check.launch': the UR5e in Gazebo without a GUI ('gzserver' alone), as 'ur5e_bringup_default_gazebo.launch' starts it, and MoveIt Servo, as 'ur5e_teleop_default_gazebo.launch' starts it.
# The ROS client 'ci/check-gazebo.py' then checks the controllers, switches between two of them, and checks '/joint_states' and MoveIt Servo, which catches a controller plugin missing from the image that resolving the launch files never sees.
# It starts nothing in a container with a network interface other than the loopback that is up, so that only the simulated arm can move, as in the container of the CI, which is disconnected from every network before any check runs.
# 'gitlab-ci/check-no-motion.bash' of the core allows its launch file, since 'ci/allowed-simulation-launches.txt' names it.
#
# Usage: bash ./ci/check-gazebo.bash [timeout]
#
# [timeout]: Seconds that the simulation and the topics may take to come up.
#            Default value is '240'.

################################################################################

# Resolve the folder of the checks, and name the log of the launch file and the timeout.
OPENROSDE_UR5E_CI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENROSDE_UR5E_LAUNCH_LOG_FILE="$(mktemp /tmp/openrosde-ur5e-gazebo-XXXXXX.log)"
OPENROSDE_UR5E_CHECK_TIMEOUT="$1"
if [ -z "${OPENROSDE_UR5E_CHECK_TIMEOUT}" ]; then
  OPENROSDE_UR5E_CHECK_TIMEOUT=240
fi

# Refuse to start any node while a network interface other than the loopback is up, whose flags carry 'IFF_UP' (0x1).
# An entry of '/sys/class/net/' without flags, such as 'bonding_masters', is no interface.
for OPENROSDE_UR5E_NETWORK_INTERFACE_DIR in /sys/class/net/*; do
  OPENROSDE_UR5E_NETWORK_INTERFACE="$(basename "${OPENROSDE_UR5E_NETWORK_INTERFACE_DIR}")"
  if [ "${OPENROSDE_UR5E_NETWORK_INTERFACE}" = "lo" ] || [ ! -f "${OPENROSDE_UR5E_NETWORK_INTERFACE_DIR}/flags" ]; then
    continue
  fi
  if (( $(cat "${OPENROSDE_UR5E_NETWORK_INTERFACE_DIR}/flags") & 0x1 )); then
    echo "Error: The network interface '${OPENROSDE_UR5E_NETWORK_INTERFACE}' is up, so this check starts no node: run it in a container without network, as the CI does."
    exit 1
  fi
done

################################################################################

# Run the ROS master of the check on port 11411 of the loopback, apart from any master that an earlier check of the job left, and keep Gazebo from looking for models online, which the container cannot reach.
OPENROSDE_UR5E_MASTER_PORT=11411
export ROS_MASTER_URI=http://localhost:${OPENROSDE_UR5E_MASTER_PORT}
export ROS_HOSTNAME=localhost
unset ROS_IP
export GAZEBO_MODEL_DATABASE_URI=

# Stop every node of the launch file, Gazebo included, by stopping its process group, then print the end of its log when the check failed.
function openrosde-ur5e-stop-launch () {
  local OPENROSDE_UR5E_CHECK_EXIT_CODE=$?
  local OPENROSDE_UR5E_WAITED_SECONDS
  if [ -n "${OPENROSDE_UR5E_LAUNCH_PID}" ]; then
    kill -INT -- "-${OPENROSDE_UR5E_LAUNCH_PID}" > /dev/null 2>&1
    for OPENROSDE_UR5E_WAITED_SECONDS in $(seq 1 30); do
      kill -0 -- "-${OPENROSDE_UR5E_LAUNCH_PID}" > /dev/null 2>&1 || break
      sleep 1
    done
    kill -KILL -- "-${OPENROSDE_UR5E_LAUNCH_PID}" > /dev/null 2>&1
  fi
  if [ "${OPENROSDE_UR5E_CHECK_EXIT_CODE}" -ne 0 ]; then
    echo "End of the log of 'ci/ur5e_gazebo_check.launch':"
    tail -n 80 "${OPENROSDE_UR5E_LAUNCH_LOG_FILE}"
  fi
  rm -f "${OPENROSDE_UR5E_LAUNCH_LOG_FILE}"
  exit "${OPENROSDE_UR5E_CHECK_EXIT_CODE}"
}
trap openrosde-ur5e-stop-launch EXIT

################################################################################

# Start the simulation and MoveIt Servo in a process group of their own, then run the client against them.
echo "Starting the UR5e in Gazebo and MoveIt Servo, with no network..."
setsid roslaunch -p "${OPENROSDE_UR5E_MASTER_PORT}" "${OPENROSDE_UR5E_CI_DIR}/ur5e_gazebo_check.launch" < /dev/null > "${OPENROSDE_UR5E_LAUNCH_LOG_FILE}" 2>&1 &
OPENROSDE_UR5E_LAUNCH_PID=$!
timeout "$((OPENROSDE_UR5E_CHECK_TIMEOUT + 120))" python3 "${OPENROSDE_UR5E_CI_DIR}/check-gazebo.py" --timeout "${OPENROSDE_UR5E_CHECK_TIMEOUT}"
