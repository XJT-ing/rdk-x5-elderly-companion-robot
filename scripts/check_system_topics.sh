#!/usr/bin/env bash
echo "=== System Topic Check ==="
echo ""

echo "[Chassis Voice topics]"
ros2 topic list 2>/dev/null | grep -E "(cmd_vel|odom|scan|asr|tts)" || echo "  (none - chassis_voice may not be running)"

echo ""
echo "[Vision Arm topics]"
ros2 topic list 2>/dev/null | grep -E "(duck|apple|box|visual_target|robot_arm|emotion|yolo)" || echo "  (none - vision_arm may not be running)"

echo ""
echo "[All active topics]"
ros2 topic list 2>/dev/null

echo ""
echo "========================="
