#!/usr/bin/env bash

set -e

export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}

echo "========================================"
echo " Vision Arm X5 Startup Guide"
echo "========================================"
echo ""
echo "This script provides startup commands for the Gemini2 vision and AIRBOT arm subsystem."
echo "Please run the following commands in separate terminals on the vision-arm RDK X5."
echo ""

echo "[Environment]"
echo "source /opt/ros/humble/setup.bash"
echo "export ROS_DOMAIN_ID=${ROS_DOMAIN_ID}"
echo ""

echo "[Terminal 0] Start AIRBOT CAN service"
echo "sudo airbot_server -i can1 -p 50001"
echo ""

echo "[Terminal 1] Move arm to home pose"
echo "python3 /home/sunrise/robot/hand_to_eye/move_to_lower_home.py"
echo ""

echo "[Terminal 2] Start Gemini2 camera"
echo "source /home/sunrise/robot/Orbbec_ws/install/setup.bash"
echo "ros2 launch orbbec_camera gemini2.launch.py \\"
echo "  enable_depth:=true \\"
echo "  enable_ir:=false \\"
echo "  enable_accel:=false \\"
echo "  enable_gyro:=false \\"
echo "  enable_point_cloud:=false \\"
echo "  enable_colored_point_cloud:=false \\"
echo "  enable_d2c_viewer:=false \\"
echo "  color_width:=640 \\"
echo "  color_height:=480 \\"
echo "  color_fps:=30"
echo ""

echo "[Terminal 3] Start target detector"
echo "source /home/sunrise/robot/Orbbec_ws/install/setup.bash"
echo "ros2 run detector duck_detector_node"
echo "# or: ros2 run detector apple_detector_node"
echo "# or: ros2 run detector box_detector_node"
echo ""

echo "[Terminal 4] Start grasp state machine"
echo "source /home/sunrise/robot/robot_ws/install/setup.bash"
echo "ros2 launch robot_bringup open_loop_grasp.launch.py"
echo ""

echo "[Terminal 5] Start camera-to-base transform"
echo "source /home/sunrise/robot/Orbbec_ws/install/setup.bash"
echo "source /home/sunrise/robot/robot_ws/install/setup.bash"
echo "python3 /home/sunrise/robot/hand_to_eye/camera_to_base_transform.py"
echo ""

echo "[Check]"
echo "ros2 topic echo /visual_target_base"
echo "ros2 topic echo /emotion/result"
echo ""

echo "========================================"
echo "Note:"
echo "1. Confirm the CAN device name: can0 or can1."
echo "2. Confirm the project path: /home/sunrise/robot."
echo "3. Recalibrate hand-eye transform if the camera pose changes."
echo "========================================"
