# vision_arm_x5

视觉机械臂子系统，运行在视觉/机械臂侧 RDK X5 上。主要负责：

- Orbbec Gemini2 RGB-D 相机启动与图像发布；
- YOLO BPU 通用物体检测；
- 小黄鸭、绿色药盒、大樱桃等传统 detector 检测；
- 相机坐标到 AIRBOT 机械臂 `base_link` 的坐标转换；
- AIRBOT Play 抓取状态机与执行器控制；
- 情绪识别结果转发给语音侧；
- 订阅语音侧 `/command` 后自动执行识别和抓取。

## 目录结构

```text
vision_arm_x5/
├── README.md
├── Orbbec_ws/              # 相机、YOLO、detector、情绪识别工作空间
├── robot_ws/               # AIRBOT 机械臂驱动、消息、抓取任务工作空间
├── hand_to_eye/            # 手眼标定、坐标桥、语音抓取管理、视觉语音桥
├── docs/                   # 子系统调试说明
├── deploy/systemd/         # systemd 部署文件
├── start_airbot_can1.sh
└── start_auto_grasp.sh
```

## 编译

```bash
cd /home/sunrise/robot/Orbbec_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install

cd /home/sunrise/robot/robot_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install
```

## 推荐启动顺序

### 1. 启动 AIRBOT CAN server

AIRBOT 使用 `can1`：

```bash
sudo airbot_server -i can1 -p 50001
```

或使用脚本：

```bash
bash /home/sunrise/robot/start_airbot_can1.sh
```

### 2. 启动 Orbbec 相机

```bash
source /opt/ros/humble/setup.bash
source /home/sunrise/robot/Orbbec_ws/install/setup.bash
ros2 launch orbbec_camera gemini2.launch.py \
  enable_depth:=true \
  enable_ir:=false \
  enable_accel:=false \
  enable_gyro:=false \
  enable_point_cloud:=false \
  enable_colored_point_cloud:=false \
  enable_d2c_viewer:=false \
  color_width:=640 \
  color_height:=480 \
  color_fps:=30
```

### 3. 常驻 YOLO

```bash
source /opt/ros/humble/setup.bash
source /opt/tros/humble/setup.bash
source /home/sunrise/robot/Orbbec_ws/install/setup.bash
ros2 run detect_yolo detect_yolo_node
```

常驻 YOLO 同时服务两件事：

- 给语音侧回答“桌子上有什么”；
- 给苹果、香蕉、瓶子、蛋糕抓取提供 3D 坐标。

### 4. 启动视觉信息桥接

```bash
source /opt/ros/humble/setup.bash
source /opt/tros/humble/setup.bash
source /home/sunrise/robot/Orbbec_ws/install/setup.bash
source /home/sunrise/robot/robot_ws/install/setup.bash
python3 /home/sunrise/robot/hand_to_eye/vision_voice_bridge.py
```

发布给语音侧：

```text
/vision/scene_objects
/vision/scene_text
/vision/emotion_context
/vision/dialogue_context
```

### 5. 启动语音命令自动抓取管理

```bash
source /opt/ros/humble/setup.bash
source /home/sunrise/robot/Orbbec_ws/install/setup.bash
source /home/sunrise/robot/robot_ws/install/setup.bash
python3 /home/sunrise/robot/hand_to_eye/arm_task_manager.py
```

支持语音侧发布：

```json
[{"actuator":"机械臂","action":"抓取","params":{"target":"苹果"}}]
```

支持目标：

```text
苹果、香蕉、瓶子、蛋糕、小黄鸭、绿色药盒、大樱桃
```

## 主要 Topic

| Topic | Type | 说明 |
| --- | --- | --- |
| `/command` | `std_msgs/msg/String` | 语音侧发布的抓取命令 |
| `/arm_task/status` | `std_msgs/msg/String` | 自动抓取管理状态 |
| `/arm_task/active_object` | `std_msgs/msg/String` | 当前语音指定抓取目标 |
| `/detect_yolo/apple_position` | `geometry_msgs/msg/PointStamped` | 苹果相机坐标 |
| `/detect_yolo/banana_position` | `geometry_msgs/msg/PointStamped` | 香蕉相机坐标 |
| `/detect_yolo/bottle_position` | `geometry_msgs/msg/PointStamped` | 瓶子相机坐标 |
| `/detect_yolo/cake_position` | `geometry_msgs/msg/PointStamped` | 蛋糕相机坐标 |
| `/duck_position` | `geometry_msgs/msg/PointStamped` | 小黄鸭相机坐标 |
| `/box_position` | `geometry_msgs/msg/PointStamped` | 绿色药盒相机坐标 |
| `/red_circle_position` | `geometry_msgs/msg/PointStamped` | 大樱桃/红色圆相机坐标 |
| `/visual_target_base` | `robot_msgs/msg/VisualTarget` | 机械臂抓取目标 |
| `/robot_arm/executor_status` | `std_msgs/msg/String` | 机械臂执行器状态 |

## 子目录说明

- `Orbbec_ws/README.md`：相机、YOLO、detector 与情绪识别节点。
- `robot_ws/README.md`：AIRBOT 抓取状态机和执行器接口。
- `hand_to_eye/README.md`：坐标转换、语音抓取管理、视觉语音桥接。
- `docs/grasp_startup_commands.md`：多终端调试启动顺序。
