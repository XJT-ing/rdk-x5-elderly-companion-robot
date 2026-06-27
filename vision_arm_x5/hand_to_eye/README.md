# hand_to_eye 实机链路说明

主链路只使用：

```text
camera_to_base_transform.py
```

它订阅：

- `/robot_arm/end_pose`
- `/duck_position`
- `/red_circle_position`
- `/box_position`
- `/detect_yolo/apple_position`
- `/detect_yolo/banana_position`
- `/detect_yolo/bottle_position`
- `/detect_yolo/cake_position`

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

## 语音命令自动抓取

如果语音板通过 ROS 2 DDS 发布 `/command`，可以在视觉机械臂板常驻运行：

```bash
source /opt/ros/humble/setup.bash
source /home/sunrise/robot/Orbbec_ws/install/setup.bash
source /home/sunrise/robot/robot_ws/install/setup.bash
python3 /home/sunrise/robot/hand_to_eye/arm_task_manager.py
```

`arm_task_manager.py` 订阅 `/command`，收到 `{"actuator":"机械臂","action":"抓取"}` 后会自动启动坐标转换和 `open_loop_grasp.launch.py`。默认配置会复用常驻运行的 YOLO，避免重复占用 BPU；传统 detector 目标会按需启动对应节点。目标映射：

```text
苹果 / 香蕉 / 瓶子 / 蛋糕 -> YOLO: /detect_yolo/<class>_position
小黄鸭 / 绿色药盒 / 大樱桃 -> detector: /duck_position, /box_position, /red_circle_position
```

抓取过程中，`arm_task_manager.py` 会向 `/arm_task/active_object` 发布当前目标英文名，`camera_to_base_transform.py` 在管理节点启动时会开启过滤，只把当前目标转发到 `/visual_target_base`。因此常驻 YOLO 可以同时识别多个物体，但抓取链路只响应语音指定的那个目标。

如果没有常驻运行 YOLO，也可以让抓取管理节点按需启动 YOLO：

```bash
python3 /home/sunrise/robot/hand_to_eye/arm_task_manager.py --ros-args -p launch_yolo_for_grasp:=true
```

状态输出：

```bash
ros2 topic echo /arm_task/status
```

## 视觉信息给语音侧

不修改语音侧代码时，视觉机械臂板只负责把识别信息发布出去：

```bash
source /opt/ros/humble/setup.bash
source /opt/tros/humble/setup.bash
source /home/sunrise/robot/Orbbec_ws/install/setup.bash
source /home/sunrise/robot/robot_ws/install/setup.bash
python3 /home/sunrise/robot/hand_to_eye/vision_voice_bridge.py
```

桥接节点订阅 `/yolo_detections` 和 `/emotion/result`，发布：

```text
/vision/scene_objects     # YOLO 识别物体 JSON，包含 graspable/dialogue_only 标记
/vision/scene_text        # 适合语音直接播报的中文场景描述
/vision/emotion_context   # 情绪 JSON，low_mood / negative_distress 会标记 intervention_required
/vision/dialogue_context  # 统一给语音/大模型侧消费的视觉上下文事件
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
