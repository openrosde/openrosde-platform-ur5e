#!/usr/bin/env python3

"""Check the plain UR5e in Gazebo, as 'ci/check-gazebo.bash' starts it, with no network.

It checks, with a timeout:
- that the controller manager of Gazebo runs 'joint_state_controller' and 'eff_joint_traj_controller', and holds 'joint_group_eff_controller' stopped, which the image must provide with their plugins,
- that it switches from the trajectory controller to 'joint_group_eff_controller' and back, as a teleop in another mode would, so that only the simulated arm is touched,
- that '/joint_states' carries the six joints of the arm,
- and that MoveIt Servo runs and reads '/servo_server/delta_twist_cmds'.

Usage: check-gazebo.py [--timeout <seconds>]
"""

import argparse
import sys
import time

import rospy
from controller_manager_msgs.srv import ListControllers, SwitchController, SwitchControllerRequest
from sensor_msgs.msg import JointState

ARM_JOINTS = {"shoulder_pan_joint", "shoulder_lift_joint", "elbow_joint", "wrist_1_joint", "wrist_2_joint", "wrist_3_joint"}


def controller_states(list_controllers):
    return {controller.name: controller.state for controller in list_controllers().controller}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--timeout", type=float, default=240.0)
    arguments = parser.parse_args()
    rospy.init_node("ur5e_gazebo_check", anonymous=True, disable_signals=True)
    failures = []

    # Wait for the controller manager, then for the controllers that the bringup spawns.
    try:
        rospy.wait_for_service("/controller_manager/list_controllers", timeout=arguments.timeout)
        rospy.wait_for_service("/controller_manager/switch_controller", timeout=arguments.timeout)
    except rospy.ROSException:
        print("The controller manager of Gazebo did not come up within %.0f seconds." % arguments.timeout)
        return 1
    list_controllers = rospy.ServiceProxy("/controller_manager/list_controllers", ListControllers)
    switch_controller = rospy.ServiceProxy("/controller_manager/switch_controller", SwitchController)
    expected = {"joint_state_controller": "running", "eff_joint_traj_controller": "running", "joint_group_eff_controller": "initialized"}
    deadline = time.time() + arguments.timeout
    states = {}
    while time.time() < deadline:
        states = controller_states(list_controllers)
        if all(states.get(name) == state for name, state in expected.items()):
            break
        time.sleep(1.0)
    for name, state in expected.items():
        if states.get(name) != state:
            failures.append("controller '%s' is '%s' rather than '%s'" % (name, states.get(name), state))
    print("Controllers: %s." % ", ".join("%s %s" % item for item in sorted(states.items())))

    # Switch to the group effort controller and back, which moves nothing but the simulated arm.
    if not failures:
        for start, stop in (("joint_group_eff_controller", "eff_joint_traj_controller"), ("eff_joint_traj_controller", "joint_group_eff_controller")):
            response = switch_controller(start_controllers=[start], stop_controllers=[stop], strictness=SwitchControllerRequest.STRICT, start_asap=False, timeout=5.0)
            if not response.ok or controller_states(list_controllers).get(start) != "running":
                failures.append("the switch from '%s' to '%s' failed" % (stop, start))
            else:
                print("Switched from '%s' to '%s'." % (stop, start))

    # Check the joint states of the arm.
    try:
        joint_state = rospy.wait_for_message("/joint_states", JointState, timeout=arguments.timeout)
        missing = sorted(ARM_JOINTS - set(joint_state.name))
        if missing:
            failures.append("'/joint_states' lacks %s" % missing)
        else:
            print("'/joint_states' carries the six joints of the arm.")
    except rospy.ROSException:
        failures.append("no message on '/joint_states'")

    # Check that MoveIt Servo runs and reads the shared command topic, which it subscribes to once its parameters and its robot model are loaded.
    deadline = time.time() + arguments.timeout
    readers = []
    while time.time() < deadline:
        _, _, system_state = rospy.get_master().getSystemState()
        subscribers = dict((topic, nodes) for topic, nodes in system_state[1])
        readers = subscribers.get("/servo_server/delta_twist_cmds", [])
        if "/servo_server" in readers:
            break
        time.sleep(1.0)
    if "/servo_server" not in readers:
        failures.append("'/servo_server' does not read '/servo_server/delta_twist_cmds' (readers: %s)" % readers)
    else:
        print("'/servo_server' reads '/servo_server/delta_twist_cmds'.")

    if failures:
        print("The plain UR5e fails in Gazebo:")
        for failure in failures:
            print("  - " + failure)
        return 1
    print("The plain UR5e runs in Gazebo with its controllers and MoveIt Servo.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
