# openrosde_ur5e_launch

The `openrosde_ur5e_launch` package provides the launch files and the robot description of the Universal Robots UR5e platform.

- Maintainer: Lotfi El Hafi ([lotfi@coarobo.com](mailto:lotfi@coarobo.com)).
- Author: Lotfi El Hafi ([lotfi@coarobo.com](mailto:lotfi@coarobo.com)).

## Gazebo Teleoperation

The Gazebo teleoperation wrappers in this package are:

- `ur5e_bringup_default_gazebo.launch`
- `ur5e_moveit_default_gazebo.launch`
- `ur5e_rviz_default.launch`
- `ur5e_teleop_default_gazebo.launch`

Recommended startup order:

```shell
roslaunch openrosde_ur5e_launch ur5e_bringup_default_gazebo.launch
roslaunch openrosde_ur5e_launch ur5e_moveit_default_gazebo.launch
roslaunch openrosde_ur5e_launch ur5e_rviz_default.launch
roslaunch openrosde_ur5e_launch ur5e_teleop_default_gazebo.launch
```

Notes:

- `ur5e_bringup_default_gazebo.launch` spawns the robot description of the package that `OPENROSDE_UR5E_DESCRIPTION_PACKAGE` names, the plain Universal Robots UR5e by default, in Gazebo.
- `ur5e_bringup_default_gazebo.launch` also loads the MoveIt SRDF and kinematics config so RViz works independently of `move_group`.
- `ur5e_teleop_default_gazebo.launch` wraps the `openrosde_ur5e_teleop` teleop stack, which starts MoveIt Servo on `/servo_server/delta_twist_cmds` with `flange` as the end effector frame.
- The Gazebo teleop wrapper only overrides the internal controller topics and controller-management settings needed for simulation.
- Gazebo teleoperation is still experimental.
- The Gazebo trajectory path targets `eff_joint_traj_controller`, which is the controller spawned by the installed `ur_gazebo` Universal Robots UR5e bringup.
- Velocity mode is still experimental.

To start the same Gazebo stack in a `tmux` session:

```shell
bash ./RUN-TMUX-SESSION.bash #[docker-project] default-gazebo
```

## Real Robot Teleoperation

Recommended startup order:

```shell
roslaunch openrosde_ur5e_launch ur5e_bringup_default_realworld.launch
roslaunch openrosde_ur5e_launch ur5e_moveit_default_realworld.launch
roslaunch openrosde_ur5e_launch ur5e_rviz_default.launch
roslaunch openrosde_ur5e_launch ur5e_teleop_default_realworld.launch
```

Notes:

- `ur5e_bringup_default_realworld.launch` starts the Universal Robots UR5e driver in teach pendant mode by default, so an operator starts the `external_control` program on the teach pendant.
  Pass `headless_mode:=true` for headless mode, where the driver starts that program itself (see the platform documentation for details).
- `ur5e_bringup_default_realworld.launch` connects to `OPENROSDE_UR5E_TEACH_PENDANT_IP`, which `.env.custom` or the template of a setup sets.
- `ur5e_bringup_default_realworld.launch` loads the SRDF and kinematics config so RViz (with the MoveIt plugin) works independently of `move_group`.
- `ur5e_teleop_default_realworld.launch` starts MoveIt Servo on `/servo_server/delta_twist_cmds` and switches the controllers of the driver for it, so an input device or an application of a setup can drive the robot.

To start the same real robot stack in a `tmux` session:

```shell
bash ./RUN-TMUX-SESSION.bash #[docker-project] default-realworld
```

## Launch Files

| Launch File                                 | Description                                                |
| ------------------------------------------- | ---------------------------------------------------------- |
| `ur5e_bringup_default_gazebo.launch`        | Universal Robots UR5e Gazebo simulation                    |
| `ur5e_bringup_default_realworld.launch`     | Universal Robots UR5e real robot bringup                   |
| `ur5e_moveit_default_gazebo.launch`         | MoveIt motion planning (Gazebo)                            |
| `ur5e_moveit_default_realworld.launch`      | MoveIt motion planning (real robot)                        |
| `ur5e_rviz_default.launch`                  | RViz visualization (Gazebo and real robot)                 |
| `ur5e_description_default_realworld.launch` | Robot description adapter for the UR5e driver (real robot) |
| `ur5e_teleop_default_gazebo.launch`         | MoveIt Servo teleoperation (Gazebo)                        |
| `ur5e_teleop_default_realworld.launch`      | MoveIt Servo teleoperation (real robot)                    |

## FlexBE Behavior

To start the FlexBE behavior engine and app:

```shell
roslaunch openrosde_launch flexbe_app_default.launch
```

Load the `UR5e Example Behavior` behavior in the FlexBE App and press **Start**.

## Robot Description

The bringup, MoveIt, and RViz launch files load the robot description, the SRDF, the calibration of the robot, and the RViz layout from the ROS package that `OPENROSDE_UR5E_DESCRIPTION_PACKAGE` names, which defaults to `openrosde_ur5e_launch`.
A setup with a gripper, cameras, or another robot replaces it with its own package, which holds the same files under the same names:

| File                                 | Content                                                                    |
| ------------------------------------ | -------------------------------------------------------------------------- |
| `urdf/ur5e_gazebo.xacro`             | Robot description of the simulated robot                                   |
| `urdf/ur5e_realworld.xacro`          | Robot description of the real robot                                        |
| `config/ur5e/ur5e_gazebo.srdf`       | MoveIt semantic description of the simulated robot                         |
| `config/ur5e/ur5e_realworld.srdf`    | MoveIt semantic description of the real robot                              |
| `config/ur5e/ur5e_calibration.yaml`  | Kinematics calibration extracted from the real robot with `ur_calibration` |
| `config/rviz/ur5e_rviz_default.rviz` | RViz layout, with the displays of the devices of the setup                 |

The launch arguments `description_file`, `semantic_description_file`, `kinematics_config`, and `rviz_config` still override each file for one launch.

The xacro files of this package describe the plain robot, 13 links and 12 joints from `world` to `tool0` and `tool0_controller`, through the macro `openrosde_ur5e` of `urdf/inc/ur5e_macro.xacro`.
A setup calls the same macro from its own xacro files, then mounts its devices on `tool0` or `world`:

```xml
<xacro:include filename="$(find openrosde_ur5e_launch)/urdf/inc/ur5e_macro.xacro"/>

<xacro:openrosde_ur5e
  environment="realworld"
  joint_limits_parameters_file="$(arg joint_limit_params)"
  kinematics_parameters_file="$(arg kinematics_params)"
  physical_parameters_file="$(arg physical_params)"
  visual_parameters_file="$(arg visual_params)"
  transmission_hw_interface="$(arg transmission_hw_interface)"
/>
```

`environment` is `gazebo` for the simulated robot, which uses `ur_robot_gazebo` of `ur_gazebo`, or `realworld` for the real robot, which uses `ur_robot` of `ur_description`.

The default `config/ur5e/ur5e_calibration.yaml` holds the nominal kinematics of `ur_description`, which a setup replaces with the calibration of its own robot.

## Generate a URDF File from a Xacro File

The robot description xacro files in `urdf/` can be expanded into a flat URDF for inspection or for tools that do not run xacro themselves:

```shell
rosrun xacro xacro $(rospack find openrosde_ur5e_launch)/urdf/ur5e_gazebo.xacro > /tmp/ur5e_gazebo.urdf
```

Replace `ur5e_gazebo.xacro` with `ur5e_realworld.xacro` to generate the real-robot variant.
