#!/usr/bin/env bash
set -e

export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}

source /opt/ros/humble/setup.bash
source ~/chassis_ws/install/setup.bash

echo "=== Starting Chassis Voice Subsystem ==="
echo "Terminal 1: Launch chassis control"
echo "  ros2 launch turn_on_wheeltec_robot turn_on_wheeltec_robot.launch.py"
echo ""
echo "Terminal 2: Launch voice navigation"
echo "  ros2 launch wheeltec_robot_nav2 wheeltec_nav2.launch.py"
echo ""
echo "Terminal 3: Start large model service"
echo "  ros2 run largemodel model_service_node"
echo "========================================"
