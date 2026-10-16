# OpenRoSDE Platform UR5e

The Universal Robots UR5e platform of [OpenRoSDE](https://github.com/openrosde/openrosde), read "Open Robotic SDE", the open-source Software Development Environment for collaborative robotics research maintained by [Coarobo GK](https://coarobo.com/).
It is an extension that OpenRoSDE finds by name once it is cloned into `extensions/openrosde-platform-ur5e/` of the core.

[![Test with OpenRoSDE](https://github.com/openrosde/openrosde-platform-ur5e/actions/workflows/test-with-openrosde.yml/badge.svg?branch=main)](https://github.com/openrosde/openrosde-platform-ur5e/actions/workflows/test-with-openrosde.yml)
[![ROS Noetic](https://img.shields.io/badge/ROS_Noetic-Framework-blue?logo=ros&logoColor=white)](http://wiki.ros.org/noetic)
[![Gazebo](https://img.shields.io/badge/Gazebo-Simulator-blue)](http://gazebosim.org/)
[![MoveIt](https://img.shields.io/badge/MoveIt-Motion_Planning-blue)](https://moveit.ros.org/)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-green)](LICENSE)

## 📑 Content

[[_TOC_]]

## 🤖 Robot Platform

| Platform | Robot                                                                    | Documentation                                                |
| -------- | ------------------------------------------------------------------------ | ------------------------------------------------------------ |
| `ur5e`   | [Universal Robots UR5e](https://www.universal-robots.com/products/ur5e/) | [docs/robot-platforms/ur5e.md](docs/robot-platforms/ur5e.md) |

The platform is the plain robot as sold, fixed to `world`, with MoveIt, MoveIt Servo, and the Universal Robots ROS Driver, and nothing mounted on its tool flange.
A setup adds its grippers, cameras, and input devices from device extensions, and mounts them in a robot description package of its own, as [Robot Description](docs/robot-platforms/ur5e.md#robot-description) describes.

## 📁 Directory Structure

| Path                              | Content                                                                                                                                        |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `env/ur5e.env`                    | Default setup of the platform, which `bash ./SWITCH-ROBOT-PLATFORM.bash ur5e` copies to `.env.custom` of the core.                             |
| `docker/ur5e-devel/Dockerfile`    | Platform image `ur5e-devel`, built on the image `openrosde-base` of the core.                                                                  |
| `docker/docker-compose-ur5e.yaml` | Docker Compose overlay of the platform.                                                                                                        |
| `ros/ur5e_catkin_ws/`             | Catkin workspace with `openrosde_ur5e_launch`, `openrosde_ur5e_teleop`, and `openrosde_ur5e_behaviors`.                                        |
| `tmux/ur5e.panes`                 | Panes of the `tmux` sessions of the platform.                                                                                                  |
| `terminator/ur5e.config`          | Terminator layouts of the platform, until `tmux` replaces them.                                                                                |
| `docs/robot-platforms/ur5e.md`    | Documentation of the platform.                                                                                                                 |
| `ci/`                             | Check of the plain UR5e in Gazebo, with its controllers and MoveIt Servo, which the CI of the core runs in the container of the default setup. |

The layout is the one of the core, which the [Extensions](https://github.com/openrosde/openrosde/blob/dev/docs/extensions.md) guide of OpenRoSDE describes.

## 🚀 Quick Start

1. Clone and set up the core of OpenRoSDE on the Ubuntu development machine, as its [Quick Start](https://github.com/openrosde/openrosde#-quick-start) describes:

    ```shell
    git clone https://github.com/openrosde/openrosde.git && cd openrosde/
    bash ./SETUP-DEVEL-MACHINE.bash
    ```

2. Clone this platform into `extensions/` of the core:

    ```shell
    git clone https://github.com/openrosde/openrosde-platform-ur5e.git extensions/openrosde-platform-ur5e
    ```

3. Switch to the platform, which also clones the Git submodules of every extension and applies their patches:

    ```shell
    bash ./SWITCH-ROBOT-PLATFORM.bash ur5e
    ```

4. Set the IP address of the teach pendant of your robot in `.env.custom`, which the template leaves empty:

    ```shell
    OPENROSDE_UR5E_TEACH_PENDANT_IP=<robot-ip>
    ```

5. Pull or build the Docker images, then run the container and build the Catkin workspaces:

    ```shell
    bash ./BUILD-DOCKER-IMAGE.bash
    bash ./RUN-DOCKER-CONTAINER.bash
    openrosde-initialize-new-container
    ```

6. Exit the container (`Ctrl+d`) and open the `tmux` session of the platform, `default-gazebo` for the simulation or `default-realworld` for the real robot:

    ```shell
    bash ./RUN-TMUX-SESSION.bash #[docker-project] default-gazebo
    ```

The core needs no change to find the platform, since `bash ./SWITCH-ROBOT-PLATFORM.bash` lists every platform of the cloned extensions.
Update the platform with `git -C extensions/openrosde-platform-ur5e pull`, then `bash ./scripts/update-git-submodules.bash`.

> [!IMPORTANT]
> `ur5e_bringup_default_realworld.launch` starts the driver in teach pendant mode, so the robot runs no program until an operator presses "Play" on the teach pendant.
> Pass `headless_mode:=true` only with a person standing by the robot, as [Headless Mode](docs/robot-platforms/ur5e.md#headless-mode) explains.

## 📖 Documentation

| Document                                                                     | Description                                                             |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [Robot Platforms / UR5e](docs/robot-platforms/ur5e.md)                       | Universal Robots UR5e configuration, simulation, and operation          |
| [`openrosde_ur5e_launch`](ros/ur5e_catkin_ws/src/openrosde_ur5e_launch/)     | Launch files and the robot description package contract of the platform |
| [`openrosde_ur5e_teleop`](ros/ur5e_catkin_ws/src/openrosde_ur5e_teleop/)     | MoveIt Servo teleoperation on `/servo_server/delta_twist_cmds`          |
| [Basic Usage](https://github.com/openrosde/openrosde/blob/dev/docs/basic-usage.md) | Full setup guide of the core of OpenRoSDE                               |
| [Extensions](https://github.com/openrosde/openrosde/blob/dev/docs/extensions.md)   | How OpenRoSDE finds the files of a cloned extension and tests it        |

## 🧪 Continuous Integration

The CI of the core of OpenRoSDE tests this platform at the commit that `gitlab-ci/extensions.repos` of the core pins: it builds or reuses the image `ghcr.io/openrosde/ur5e-devel`, builds the Catkin workspaces in it, and checks every launch entry point of the panes.
It publishes the image as `dev` or `main` from those branches of the core, and under the tag of a release of the core, such as `v3.0.0`.
In the container of the default setup `ur5e`, cut from every network, `ci/check-in-container.bash` starts the plain UR5e in Gazebo with `gzserver` alone and MoveIt Servo, checks its controllers, switches between two of them, and checks `/joint_states` and MoveIt Servo, which only the simulated arm feels.

`.github/workflows/test-with-openrosde.yml` of this repository calls the reusable workflow `extension.yml` of the core on `dev` for every push to `main` and every pull request, which checks out this commit in place of the version that the core pins, tests only the setups that run this platform, and publishes nothing.

## 🐛 Reporting Issues

Please report any issue of this platform using the GitHub issue tracker: [https://github.com/openrosde/openrosde-platform-ur5e/issues](https://github.com/openrosde/openrosde-platform-ur5e/issues).

## 📜 Third-Party Software

This repository holds one file of third-party code, the default kinematics of the Universal Robots UR5e, copied from `ur_description`.
The image `ur5e-devel` and the Catkin workspace bring the third-party software below, each under its own license, as [`NOTICE`](NOTICE) records.

| Component                                                                                            | Source                                                                                                                                                                      | License                                                                                                            |
| ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Default kinematics of `ur_description`, in `openrosde_ur5e_launch/config/ur5e/ur5e_calibration.yaml` | `ur_description` 1.5.0 of https://github.com/ros-industrial/universal_robot                                                                                                 | [BSD-3-Clause](https://spdx.org/licenses/BSD-3-Clause.html) (ROS-Industrial)                                       |
| Universal Robots ROS Driver: `ur_robot_driver` and `ur_calibration`                                  | Debian packages `ros-noetic-ur-robot-driver` and `ros-noetic-ur-calibration` of the image `ur5e-devel`, from https://github.com/UniversalRobots/Universal_Robots_ROS_Driver | [Apache-2.0](https://spdx.org/licenses/Apache-2.0.html), with parts under BSD-2-Clause and Zlib                    |
| ROS-Industrial Universal Robot: `ur_description`, `ur_gazebo`, and `ur5e_moveit_config`              | Debian package `ros-noetic-universal-robots` of the image `ur5e-devel`, from https://github.com/ros-industrial/universal_robot                                              | [BSD-3-Clause](https://spdx.org/licenses/BSD-3-Clause.html), and the terms of Universal Robots A/S for some meshes |
| ROS Noetic, Gazebo, MoveIt, FlexBE, and the other packages of the image `openrosde-base`             | The core of OpenRoSDE, https://github.com/openrosde/openrosde                                                                                                                       | Per upstream, such as BSD, Apache-2.0, or MIT                                                                      |

## 🕰️ History

The files of this platform come from the core of OpenRoSDE, [`coarobo/SDE`](https://gitlab.com/coarobo/SDE), at commit [`041d164`](https://gitlab.com/coarobo/SDE/-/commit/041d164201db41ac35db5efd7889e6424a84deca) of `dev`, where their earlier history lives.
They were made plain on import: the robot description, the SRDFs, the calibration, the RViz layout, the teleoperation, the image, and the layouts of this repository describe the robot as sold, with no device of a particular installation.

## ⚖️ License

```
Copyright 2019 Coarobo GK

Licensed under the Apache License, Version 2.0.
```

See [`LICENSE`](LICENSE) for the license, and [`NOTICE`](NOTICE) for the MIT notice of the earlier code and the notices of third-party software.
