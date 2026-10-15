# General guidelines and recommendations for writing 'Dockerfile':
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

################################################################################

# Inherit from the OpenRoSDE base image which provides all common tools.
ARG OPENROSDE_BASE_IMAGE=registry.gitlab.com/coarobo/sde/openrosde-base:main
FROM ${OPENROSDE_BASE_IMAGE}

################################################################################

# Install the Universal Robots UR5e robot ROS dependencies.

# Gather the UR5e robot driver packages and dependencies from the ROS repositories.
# https://github.com/UniversalRobots/Universal_Robots_ROS_Driver
RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-noetic-ur-robot-driver \
  ros-noetic-ur-calibration \
  ros-noetic-rqt-joint-trajectory-controller \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Gather the UR5e simulation model packages from the ROS repositories.
# https://github.com/ros-industrial/universal_robot
RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-noetic-universal-robots \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

################################################################################

# Set the platform identifier as an environment variable.
ARG OPENROSDE_ROBOT_PLATFORM=ur5e
ENV OPENROSDE_ROBOT_PLATFORM=${OPENROSDE_ROBOT_PLATFORM}

# Pass variables for version traceability.
ARG OPENROSDE_DOCKERFILE_COMMIT_SHORT_SHA
ENV OPENROSDE_DOCKER_IMAGE_VERSION=${OPENROSDE_DOCKERFILE_COMMIT_SHORT_SHA}
