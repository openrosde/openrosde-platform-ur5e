# openrosde_ur5e_teleop

The `openrosde_ur5e_teleop` package provides the launch files and nodes for teleoperating a Universal Robots UR5e through MoveIt Servo.
MoveIt Servo listens for `geometry_msgs/TwistStamped` commands on `/servo_server/delta_twist_cmds`, which any input device or application of a setup publishes.

- Maintainer: Lotfi El Hafi ([lotfi@coarobo.com](mailto:lotfi@coarobo.com)).
- Author: Lotfi El Hafi ([lotfi@coarobo.com](mailto:lotfi@coarobo.com)).

## Overview

`ur5e_teleop.launch` is the main entry point.
It starts MoveIt Servo and performs the controller switch based on `controller_mode`.
It starts no input bridge, since the input devices belong to a setup.
A setup starts the bridge of each of its input devices beside this launch file, such as the one of [`openrosde-device-spacenav`](https://github.com/openrosde/openrosde-device-spacenav), and each bridge publishes on `/servo_server/delta_twist_cmds`.
Several bridges may publish at once only if each publishes while its input is in use, so whichever input is in use drives MoveIt Servo.

## Full Teleop Stack

```shell
roslaunch openrosde_ur5e_teleop ur5e_teleop.launch
```

This starts MoveIt Servo and performs the controller switch automatically based on `controller_mode`.
By default it starts in trajectory mode.
Velocity mode is still experimental.

Parameters:

- `controller_mode`: Selects the UR controller path. Use `velocity` or `trajectory`. Defaults to `trajectory`.
- `ee_frame_name`: End effector frame that MoveIt Servo commands. Defaults to `flange`.
- `robot_link_command_frame`: Frame in which MoveIt Servo reads the commands. Defaults to `base_link`.
- `switch_controllers`: If `true`, switches the controllers of `controller_mode` once the controller manager answers. Defaults to `true`.

The wrappers `ur5e_teleop_default_realworld.launch` and `ur5e_teleop_default_gazebo.launch` of `openrosde_ur5e_launch` set the controllers of the real robot and of Gazebo, and are the launch files that the `tmux` sessions start.

## MoveIt Servo

`ur5e_teleop.launch` starts MoveIt Servo automatically.
It can also be launched on its own in either output mode.

### Velocity

```shell
roslaunch openrosde_ur5e_teleop ur5e_moveit_servo_velocity.launch
```

This starts `moveit_servo/servo_server` and loads the Servo parameters from `config/ur5e_moveit_servo_velocity.yaml`.
This launch publishes joint velocity commands as `std_msgs/Float64MultiArray` to `/joint_group_vel_controller/command`.
Velocity mode is still experimental.

Parameters:

- `planning_frame`: Defaults to `base_link`.
- `ee_frame_name`: Defaults to `flange`.
- `robot_link_command_frame`: Defaults to `flange`.
- `command_out_topic`: Defaults to `/joint_group_vel_controller/command`.
- `command_out_type`: Defaults to `std_msgs/Float64MultiArray`.
- `publish_joint_positions`: Defaults to `false`.
- `publish_joint_velocities`: Defaults to `true`.

### Trajectory

```shell
roslaunch openrosde_ur5e_teleop ur5e_moveit_servo_trajectory.launch
```

This keeps the older `trajectory_msgs/JointTrajectory` output path and publishes to `/scaled_pos_joint_traj_controller/command`.

### Servo Configuration

The Servo node is launched from `moveit_servo/servo_server` using separate mode-specific configs:

- `config/ur5e_moveit_servo_velocity.yaml` for true velocity control.
- `config/ur5e_moveit_servo_trajectory.yaml` for trajectory output.

Important defaults:

- `move_group_name`: `manipulator`.
- `planning_frame`: `base_link`.
- `ee_frame_name`: `flange`.
- `robot_link_command_frame`: `flange`.
- `cartesian_command_in_topic`: `/servo_server/delta_twist_cmds`.
- `command_out_type`: `std_msgs/Float64MultiArray`.
- `command_out_topic`: `/joint_group_vel_controller/command`.

Trajectory mode is the recommended default.
The velocity configuration remains experimental.

## Runtime Prerequisites

Before launching the teleoperation stack, make sure the rest of the robot stack is already available in your ROS graph:

- A running Universal Robots UR5e driver publishing robot state and accepting the controller type used by the selected teleop mode.
- A valid MoveIt configuration and planning scene for the robot.
- A node that publishes `geometry_msgs/TwistStamped` commands on `/servo_server/delta_twist_cmds`, such as the bridge of an input device.

This package does not launch the robot driver, controllers, MoveIt configuration, or any input device.

## Recommended Launch Sequence

1. Bring up the robot driver and controllers outside this package.
2. Ensure the MoveIt model for the robot is available.
3. Launch `ur5e_teleop.launch` from this package.
4. Start the bridge of an input device, or connect an application, that publishes on `/servo_server/delta_twist_cmds`.

The default `controller_mode` is `trajectory`.
Use `controller_mode:=velocity` only when you explicitly want the experimental velocity path.

If you want to launch components separately, start `ur5e_moveit_servo_velocity.launch` for velocity mode, or `ur5e_moveit_servo_trajectory.launch` for the older trajectory path.

## Controller Switching

For true velocity control with the Universal Robots UR driver, MoveIt Servo must publish to `/joint_group_vel_controller/command` while the scaled position trajectory controller is stopped.
`ur5e_teleop.launch` performs that switch automatically based on `controller_mode`, through `ur5e_controller_manager_switch.py`, but that velocity path is still experimental.

Start the velocity controller and stop the scaled position trajectory controller:

```shell
rosservice call /controller_manager/switch_controller "start_controllers: ['joint_group_vel_controller']
stop_controllers: ['scaled_pos_joint_traj_controller']
strictness: 2
start_asap: false
timeout: 5.0"
```

Switch back to the original trajectory-based teleop path:

```shell
rosservice call /controller_manager/switch_controller "start_controllers: ['scaled_pos_joint_traj_controller']
stop_controllers: ['joint_group_vel_controller']
strictness: 2
start_asap: false
timeout: 5.0"
```

If the Universal Robots UR driver was launched with its default controller list, `joint_group_vel_controller` is normally loaded in the stopped state and can be activated with the command above.
