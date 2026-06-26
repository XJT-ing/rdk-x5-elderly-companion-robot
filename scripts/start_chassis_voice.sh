#!/usr/bin/env bash

set -e

export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}

echo "========================================"
echo " Chassis Voice X5 Startup Guide"
echo "========================================"
echo ""
echo "This script provides startup commands for the chassis and voice subsystem."
echo "Please run the following commands in separate terminals on the chassis RDK X5."
echo ""

echo "[Environment]"
echo "source /opt/ros/humble/setup.bash"
echo "source ~/chassis_ws/install/setup.bash"
echo "export ROS_DOMAIN_ID=${ROS_DOMAIN_ID}"
echo ""

echo "[Terminal 1] Start chassis base driver"
echo "ros2 launch turn_on_wheeltec_robot turn_on_wheeltec_robot.launch.py"
echo ""

echo "[Terminal 2] Start LiDAR / SLAM / Nav2"
echo "# Choose one according to the actual task:"
echo "ros2 launch wheeltec_robot_slam slam.launch.py"
echo "# or"
echo "ros2 launch wheeltec_robot_nav2 wheeltec_nav2.launch.py"
echo ""

echo "[Terminal 3] Start voice interaction"
echo "ros2 launch ros_voice voice.launch.py"
echo ""

echo "[Terminal 4] Check topics"
echo "ros2 topic list"
echo "ros2 topic echo /cmd_vel"
echo "ros2 topic echo /voice/command"
echo ""

echo "========================================"
echo "Note:"
echo "1. Make sure the chassis workspace has been built."
echo "2. Make sure the microphone, speaker, LiDAR and chassis are connected."
echo "3. Do not upload real API keys or WiFi passwords to GitHub."
echo "========================================"
