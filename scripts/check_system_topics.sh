#!/usr/bin/env bash

echo "========================================"
echo " RDK X5 Elderly Companion Robot"
echo " ROS 2 Topic Check"
echo "========================================"
echo ""

if ! command -v ros2 >/dev/null 2>&1; then
  echo "[ERROR] ros2 command not found."
  echo "Please run: source /opt/ros/humble/setup.bash"
  exit 1
fi

echo "[1] Current ROS_DOMAIN_ID"
echo "ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-not_set}"
echo ""

echo "[2] Chassis / Voice related topics"
ros2 topic list 2>/dev/null | grep -E "(cmd_vel|odom|scan|voice|command|asr|tts)" || \
  echo "No chassis/voice topics found."

echo ""
echo "[3] Vision / Arm related topics"
ros2 topic list 2>/dev/null | grep -E "(camera|duck|apple|box|visual_target|robot_arm|emotion|yolo)" || \
  echo "No vision/arm topics found."

echo ""
echo "[4] All active topics"
ros2 topic list 2>/dev/null || echo "Failed to list ROS 2 topics."

echo ""
echo "========================================"
echo " Topic check finished."
echo "========================================"
