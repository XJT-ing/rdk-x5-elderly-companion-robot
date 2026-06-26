# hand_to_eye 实机链路说明

主链路只使用：

```text
camera_to_base_transform.py
```

它订阅：

- `/robot_arm/end_pose`
- `/duck_position`
- `/apple_position`
- `/box_position`

它发布：

- `/visual_target_base`

`/visual_target_base` 类型是 `robot_msgs/msg/VisualTarget`，所以启动前必须 source 机械臂工作区：

```bash
source /home/sunrise/robot/robot_ws/install/setup.bash
```

## 启动

```bash
source /opt/ros/humble/setup.bash
source /home/sunrise/robot/Orbbec_ws/install/setup.bash
source /home/sunrise/robot/robot_ws/install/setup.bash
python3 /home/sunrise/robot/hand_to_eye/camera_to_base_transform.py
```

## 可调参数

```bash
python3 /home/sunrise/robot/hand_to_eye/camera_to_base_transform.py --ros-args \
  -p target_frame:=base_link \
  -p max_end_pose_age_sec:=0.5 \
  -p default_confidence:=0.85 \
  -p assume_target_stable:=true \
  -p republish_rate_hz:=1.0 \
  -p target_hold_sec:=0.0 \
  -p target_timeout_sec:=1.5
```

当前脚本默认手眼参数如下，文档应以 `camera_to_base_transform.py` 中的默认值为准：

```text
t_cam2gripper = [0.09135190476527959, -0.07201739513738753, 0.011442796927694777]
q_cam2gripper_xyzw = [-0.1219551044160354, 0.694256163711082, 0.125630634909801, 0.6981062062667869]
```

该含义是 `camera -> gripper`，即 `^gT_c`，不要取反。若实机重新标定，请优先通过 ROS 参数覆盖这两个值，并同步更新本文档。

## legacy 脚本

`auto_pick_from_base.py` 只保留为旧调试脚本，不推荐作为主抓取节点。主抓取请使用：

```bash
ros2 launch robot_bringup open_loop_grasp.launch.py
```

`end_position_publisher.py` 会直接连接 AIRBOT SDK，只能用于旧调试链路。主链路中不要和 `arm_executor_node` 同时运行。
