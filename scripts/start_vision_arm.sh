#!/usr/bin/env bash
set -e

export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}

echo "=== Starting Vision Arm Subsystem ==="
echo "Prerequisite: sudo airbot_server -i can1 -p 50001"
echo ""

VISION_DIR="/home/sunrise/robot"
if [ -d "$VISION_DIR" ]; then
    bash "$VISION_DIR/start_auto_grasp.sh"
else
    echo "Error: Vision arm directory not found at $VISION_DIR"
    echo "Expected vision_arm_x5 content to be placed at $VISION_DIR"
    exit 1
fi
