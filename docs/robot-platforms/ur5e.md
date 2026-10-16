# Universal Robots UR5e

Platform-specific documentation for the [Universal Robots UR5e](https://www.universal-robots.com/products/ur5e/) within OpenRoSDE.

## 🔗 External Resources

- Official website: [https://www.universal-robots.com/products/ur5e/](https://www.universal-robots.com/products/ur5e/)
- Official manual: [https://www.universal-robots.com/download/manuals-e-series/user/ur5e/510/user-manual-ur5e-e-series-sw-510-english-international-en/](https://www.universal-robots.com/download/manuals-e-series/user/ur5e/510/user-manual-ur5e-e-series-sw-510-english-international-en/)
- Universal Robots ROS Driver: [https://github.com/UniversalRobots/Universal_Robots_ROS_Driver](https://github.com/UniversalRobots/Universal_Robots_ROS_Driver)
- ROS Industrial Universal Robot: [https://github.com/ros-industrial/universal_robot](https://github.com/ros-industrial/universal_robot)
- MoveIt Servo: [https://github.com/moveit/moveit/tree/master/moveit_ros/moveit_servo](https://github.com/moveit/moveit/tree/master/moveit_ros/moveit_servo)

## 🔩 Hardware Overview

The platform is the plain Universal Robots UR5e collaborative robot as sold, fixed to the `world` frame, with nothing mounted on its tool flange.

- **Robot arm:** [Universal Robots UR5e](https://www.universal-robots.com/products/ur5e/) collaborative robot, with its control box and teach pendant.
- **Network:** the control box connects to the Ubuntu development machine over Ethernet, with a fixed IP address on each side.

Grippers, cameras, and input devices come from device extensions, such as [`openrosde-device-onrobot`](https://github.com/openrosde/openrosde-device-onrobot), [`openrosde-device-realsense`](https://github.com/openrosde/openrosde-device-realsense), and [`openrosde-device-spacenav`](https://github.com/openrosde/openrosde-device-spacenav).
A setup mounts them in its own robot description and starts their launch files from its own panes, as [Robot Description](#-robot-description) and the [Extensions](https://github.com/openrosde/openrosde/blob/dev/docs/extensions.md) guide of OpenRoSDE describe.

## ⚙️ Platform Configuration

Switch to the Universal Robots UR5e platform:

```shell
bash ./SWITCH-ROBOT-PLATFORM.bash ur5e
```

Set the IP address of the teach pendant of your robot in `.env.custom`, which the template leaves empty:

```shell
OPENROSDE_UR5E_TEACH_PENDANT_IP=<robot-ip>
```

> [!NOTE]
> The Universal Robots UR5e does not broadcast a host name on the network, so it cannot be operated using mDNS host names.
> Static IP addresses must be used instead (see [Network Configuration](#-network-configuration)).
> For this reason, `OPENROSDE_ROBOT_HOSTNAME` should be left empty.

## 🧩 Robot Description

The bringup, MoveIt, and RViz launch files load the robot description, the SRDF, the calibration, and the RViz layout from the ROS package that `OPENROSDE_UR5E_DESCRIPTION_PACKAGE` names, which defaults to `openrosde_ur5e_launch`.
The default description is the plain robot: 13 links and 12 joints, from `world` through `base_link` to `tool0` and `tool0_controller`.

A setup with a gripper, cameras, or another mount replaces the package with its own, which holds the same files under the same names:

| File                                 | Content                                                                    |
| ------------------------------------ | -------------------------------------------------------------------------- |
| `urdf/ur5e_gazebo.xacro`             | Robot description of the simulated robot                                   |
| `urdf/ur5e_realworld.xacro`          | Robot description of the real robot                                        |
| `config/ur5e/ur5e_gazebo.srdf`       | MoveIt semantic description of the simulated robot                         |
| `config/ur5e/ur5e_realworld.srdf`    | MoveIt semantic description of the real robot                              |
| `config/ur5e/ur5e_calibration.yaml`  | Kinematics calibration extracted from the real robot with `ur_calibration` |
| `config/rviz/ur5e_rviz_default.rviz` | RViz layout, with the displays of the devices of the setup                 |

Its xacro files call the macro `openrosde_ur5e` of `urdf/inc/ur5e_macro.xacro` of `openrosde_ur5e_launch`, with `environment` set to `gazebo` or `realworld`, then mount the devices of the setup on `tool0` or `world`, so the robot itself is described once for every setup.
The default `config/ur5e/ur5e_calibration.yaml` holds the nominal kinematics of `ur_description`, so a setup replaces it with the calibration of its own robot:

```shell
roslaunch ur_calibration calibration_correction.launch robot_ip:=<robot-ip> target_filename:="${HOME}/ur5e_calibration.yaml"
```

The launch arguments `description_file`, `semantic_description_file`, `kinematics_config`, and `rviz_config` still override each file for one launch.

## 🌐 Network Configuration

The Universal Robots UR5e and the Ubuntu development machine are connected to the same local network using fixed IP addresses, since the robot does not broadcast any host name.

| Device                     | Setting                                                           |
| -------------------------- | ----------------------------------------------------------------- |
| Universal Robots UR5e      | `<robot-ip>`, set on the teach pendant and in `.env.custom`       |
| Ubuntu development machine | `<host-ip>`, set as the Host IP of the URCap on the teach pendant |

## 🔌 Robot Bootup

- Turn on the robot by pressing the power button on the teach pendant.
- Initialize the robot by pressing the red LED icon in the bottom left corner.
  Then, press the "On" button, followed by the "Start" button, and exit.
  The robot will make some sound while releasing the motor brakes.
- Operate the robot by clicking on the move icon at the top of the teach pendant or by pressing the free drive button (the side button at the top of the teach pendant) if you want to move the robot by guiding it with your hand.

## 🛠️ Robot Setup

These configurations are only necessary for a new robot or after a factory reset.

- Turn on the robot by pressing the on/off button on the teach pendant.
- Initialize the robot by clicking in the bottom left corner of the teach pendant.
- Ensure that the Universal Robots PolyScope version is greater than 5.4 (the tested version is 5.11).
  To update the firmware, download the files from [Universal Robots](https://www.universal-robots.com/download).
  To check the robot firmware version, press the 3-line icon in the corner of the screen and then press "About".
- Install the URCap of the Universal Robots ROS Driver.
  Enter the robot settings by pressing the 3-line icon and selecting settings.
  Then go to "URCap", press the "+" button, and select the URCap file you want to install.
  For more details, refer to the [Universal Robots ROS Driver](https://github.com/UniversalRobots/Universal_Robots_ROS_Driver/blob/master/ur_robot_driver/doc/install_urcap_e_series.md) documentation.
- Set the robot IP address to `<robot-ip>` in the network settings.
- Set up the IP of the Ubuntu development machine that will control the robot.
  In the "Installation" tab of the teach pendant, go to "URCaps" then set the "Host IP" to `<host-ip>` and the "Custom port" to `50002`.
  Save the installation file.
- Create a new program called `external_control`.
  This program will only have the URCap installed previously.
  Select the "External Control URCap" and save the program.
  For more detailed information, read the official [Universal Robots](https://www.universal-robots.com/download/manuals-e-series/user/ur5e/510/user-manual-ur5e-e-series-sw-510-english-international-en/) manual or the [Universal Robots ROS Driver](https://github.com/UniversalRobots/Universal_Robots_ROS_Driver/blob/master/ur_robot_driver/doc/install_urcap_e_series.md) documentation.

## ⏹️ Robot Shutdown

- Stop any running code on the teach pendant by pressing the "Stop" button.
- If necessary, move the robot to a safe position using the teach pendant move option or the free drive button (the side button at the top of the teach pendant).
- To turn off the robot, press the power button on the teach pendant and then press "Power off", or press the 3-line icon at the top right corner of the teach pendant and select "Power off".

## 📡 ROS Communication

The Universal Robots UR5e driver supports two modes of operation: **teach pendant mode** and **headless mode**.

### 🏛️ Teach Pendant Mode

In this mode, the teach pendant must be set to **Local** mode and the `external_control` program must be started manually from the teach pendant.
This is the default mode of `ur5e_bringup_default_realworld.launch`, so that no program starts on the robot before an operator starts it.

- Load the program `external_control` on the teach pendant (just load the code, do not run it yet).
  By default, this code is already loaded when you turn on the robot.
- On the Ubuntu development machine, run the bringup launch file:

    ```shell
    roslaunch openrosde_ur5e_launch ur5e_bringup_default_realworld.launch
    ```

- Press the "Play" button on the teach pendant.
  If a message appears asking from where to run the code, select "Play from beginning".
  If everything is OK, the teach pendant program should change its status from "Loading" to "Running".
  Also, the ROS terminal should display "Robot ready to receive control commands".

### 🤖 Headless Mode

In this mode, the teach pendant must be set to **Remote** mode, allowing the driver to start the `external_control` program automatically without manual interaction on the teach pendant.

- Set the teach pendant to **Remote** mode by pressing the button in the top right corner of the Universal Robots PolyScope interface (where it shows "Local") and selecting "Remote".
- On the Ubuntu development machine, run the bringup launch file with headless mode enabled:

    ```shell
    roslaunch openrosde_ur5e_launch ur5e_bringup_default_realworld.launch headless_mode:=true
    ```

  The driver will automatically load and start the `external_control` program on the robot.
  The ROS terminal should display "Robot ready to receive control commands".

> [!WARNING]
> In headless mode, the driver starts the program on the robot as soon as it connects, without anyone pressing "Play" on the teach pendant.
> Enable it only with a person standing by the robot, or in the template of a setup whose operators expect it.

> [!NOTE]
> In headless mode, you can still use the teach pendant to monitor the robot, but you cannot start or stop programs from it.
> Switch back to **Local** mode if you need manual control from the teach pendant.

### 📊 MoveIt and Visualization

After bringing up the driver (in either mode), launch MoveIt and RViz:

```shell
roslaunch openrosde_ur5e_launch ur5e_moveit_default_realworld.launch
roslaunch openrosde_ur5e_launch ur5e_rviz_default.launch
```

You should be able to plan and execute motions from RViz.

### 🕹️ Teleoperation

`ur5e_teleop_default_realworld.launch` and `ur5e_teleop_default_gazebo.launch` start MoveIt Servo and switch the controllers for it:

```shell
roslaunch openrosde_ur5e_launch ur5e_teleop_default_realworld.launch
```

MoveIt Servo then moves the end effector frame, `flange` by default, along the `geometry_msgs/TwistStamped` commands that arrive on `/servo_server/delta_twist_cmds`.
The bridge of an input device, such as the one of [`openrosde-device-spacenav`](https://github.com/openrosde/openrosde-device-spacenav), or an application publishes these commands, and a setup starts the bridges of its own input devices beside the teleop launch file.
`controller_mode:=velocity` switches to the experimental velocity path, while the trajectory path stays the default.

### 🌳 TF Frames

When inspecting the TF tree (e.g. with `rqt_tf_tree`), you will notice two frames attached near `base_link` that are **not** broadcast by `robot_state_publisher`: `base` and `tool0_controller`.
This is expected, not a misconfiguration. Both are published by the upstream Universal Robots driver (broadcaster `/ur_hardware_interface`) and appear on every real UR robot:

- **`base`**: the robot controller's own base frame. It is rotated 180 degrees about Z relative to the ROS-standard `base_link` (the UR controller convention has X pointing backward, whereas REP-103 and `base_link` have X forward, Z up). The driver publishes the static `base_link` to `base` transform so ROS poses can be related to what the teach pendant and controller report.
- **`tool0_controller`**: the TCP/flange pose as measured and reported live by the UR controller, as opposed to `tool0`, which `robot_state_publisher` computes via forward kinematics from `/joint_states`. The two should be nearly identical. `tool0_controller` is useful for validating the driver's kinematics against the controller's own reading.

> [!TIP]
> For motion planning and downstream math, always use the URDF/FK frames `base_link` and `tool0`, not `base` or `tool0_controller`, to avoid the 180 degree rotation surprise.
> See the [Universal Robots ROS Driver](https://github.com/UniversalRobots/Universal_Robots_ROS_Driver) documentation for more details.

> [!IMPORTANT]
> Always have the emergency stop button in your hand while using the robot.
> In the case of any collision or emergency, press it immediately!

## 🚨 Emergency Button

If you have pressed the emergency button, you have to initialize the robot again.

- First, release the emergency button and press the "Go to initialization screen" button on the teach pendant, or press the yellow-red LED in the bottom left corner of the teach pendant.
- Second, if the robot is still colliding or too close to itself for safe initialization, press the free drive button and move the robot to a safe position by hand.
  The teach pendant should display "Backdrive" while pressing the button.
- Third, after making sure that the robot will not collide with anything during its initialization, press the "Start" button and then exit.

> [!NOTE]
> If the teach pendant is in **Remote** mode and you need to reinitialize after an emergency stop, you may need to switch back to **Local** mode first.

## 📋 Launch Files Reference

The following launch files are available for the Universal Robots UR5e platform (package: `openrosde_ur5e_launch`):

| Launch File                                 | Description                                                    |
| ------------------------------------------- | -------------------------------------------------------------- |
| `ur5e_bringup_default_realworld.launch`     | Universal Robots UR5e driver (teach pendant mode by default)   |
| `ur5e_bringup_default_gazebo.launch`        | Universal Robots UR5e Gazebo simulation                        |
| `ur5e_description_default_realworld.launch` | Robot description adapter for the Universal Robots UR5e driver |
| `ur5e_moveit_default_realworld.launch`      | MoveIt motion planning (real robot)                            |
| `ur5e_moveit_default_gazebo.launch`         | MoveIt motion planning (Gazebo)                                |
| `ur5e_rviz_default.launch`                  | RViz visualization (Gazebo and real robot)                     |
| `ur5e_teleop_default_realworld.launch`      | MoveIt Servo on `/servo_server/delta_twist_cmds` (real robot)  |
| `ur5e_teleop_default_gazebo.launch`         | MoveIt Servo on `/servo_server/delta_twist_cmds` (Gazebo)      |

## 🧪 FlexBE Behavior

The `openrosde_ur5e_flexbe_behaviors` package provides an example behavior that loops the arm between the `home` and `up` SRDF named states using `SrdfStateToMoveit` and `WaitState`.

To start the FlexBE behavior engine and app:

```shell
roslaunch openrosde_launch flexbe_app_default.launch
```

Load the `UR5e Example Behavior` behavior in the FlexBE App and press **Start**.

> [!CAUTION]
> The FlexBE example behavior is **experimental** and currently has known issues in the Gazebo simulation.
