cmake_minimum_required(VERSION 2.8.3)
project(openrosde_ur5e_teleop)

find_package(catkin REQUIRED COMPONENTS
  controller_manager_msgs
  rospy
)

catkin_package()

include_directories(
  ${catkin_INCLUDE_DIRS}
)

catkin_install_python(
  PROGRAMS
    scripts/ur5e_controller_manager_switch.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
