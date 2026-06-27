# RDK X5 Elderly Companion Robot

基于双 RDK X5 的居家老人陪护机器人代码仓库。仓库按硬件板卡拆分为两个子系统：

- `chassis_voice_x5/`：底盘、语音交互、导航与大模型决策相关代码。
- `vision_arm_x5/`：Orbbec RGB-D 视觉、YOLO/传统检测、AIRBOT 机械臂抓取与情绪识别相关代码。

本仓库主要保存可运行源码、启动脚本和必要接口说明。比赛技术文档、汇报材料、截图素材等建议单独放在文档提交材料中，不放在 GitHub 代码仓库根目录。

## 仓库结构

```text
rdk-x5-elderly-companion-robot/
├── README.md
├── chassis_voice_x5/
│   ├── README.md
│   ├── ros_voice/
│   └── 底盘控制/
└── vision_arm_x5/
    ├── README.md
    ├── Orbbec_ws/
    ├── robot_ws/
    ├── hand_to_eye/
    ├── docs/
    ├── deploy/systemd/
    ├── start_airbot_can1.sh
    └── start_auto_grasp.sh
```

说明：根目录 `docs/` 已删除；`vision_arm_x5/docs/` 只保留视觉机械臂子系统运行和接口调试所需的轻量说明。

## 当前主流程

### 语音触发抓取

语音板向 `/command` 发布 JSON 指令：

```json
[{"actuator":"机械臂","action":"抓取","params":{"target":"苹果"}}]
```

视觉机械臂板运行 `arm_task_manager.py` 后，会自动启动抓取链路，并根据目标选择 YOLO 或 detector：

```text
苹果 / 香蕉 / 瓶子 / 蛋糕 -> 常驻 YOLO
小黄鸭 / 绿色药盒 / 大樱桃 -> detector
```

YOLO 常驻时，`arm_task_manager.py` 会发布 `/arm_task/active_object`，坐标桥只转发当前语音指定目标，避免多物体坐标互相干扰。

### 视觉结果给语音侧

视觉侧通过 `vision_voice_bridge.py` 将 YOLO 和情绪识别结果转成语音侧容易消费的 `std_msgs/msg/String`：

```text
/vision/scene_objects      # 桌面物体 JSON
/vision/scene_text         # 适合直接播报的中文文本
/vision/emotion_context    # 情绪识别 JSON
/vision/dialogue_context   # 统一给语音/大模型侧消费的上下文事件
```

语音模块只需要订阅这些话题并做播报或大模型干预，不需要启动视觉进程。

## 快速启动入口

### 底盘语音板

请参考：

```text
chassis_voice_x5/README.md
chassis_voice_x5/ros_voice/README.md
```

### 视觉机械臂板

请参考：

```text
vision_arm_x5/README.md
vision_arm_x5/Orbbec_ws/README.md
vision_arm_x5/robot_ws/README.md
vision_arm_x5/hand_to_eye/README.md
```

常用启动入口：

```bash
bash /home/sunrise/robot/start_airbot_can1.sh
bash /home/sunrise/robot/start_auto_grasp.sh
```

联调时推荐按多终端方式分别启动相机、YOLO、视觉语音桥接和自动抓取管理节点，便于排查 topic。

## 关键 Topic

| Topic | Type | 说明 |
| --- | --- | --- |
| `/command` | `std_msgs/msg/String` | 语音/大模型侧发布的结构化任务命令 |
| `/yolo_detections` | `ai_msgs/msg/PerceptionTargets` | YOLO 原始识别结果 |
| `/detect_yolo/apple_position` | `geometry_msgs/msg/PointStamped` | YOLO 苹果 3D 坐标 |
| `/detect_yolo/banana_position` | `geometry_msgs/msg/PointStamped` | YOLO 香蕉 3D 坐标 |
| `/detect_yolo/bottle_position` | `geometry_msgs/msg/PointStamped` | YOLO 瓶子 3D 坐标 |
| `/detect_yolo/cake_position` | `geometry_msgs/msg/PointStamped` | YOLO 蛋糕 3D 坐标 |
| `/duck_position` | `geometry_msgs/msg/PointStamped` | 小黄鸭 3D 坐标 |
| `/box_position` | `geometry_msgs/msg/PointStamped` | 绿色药盒 3D 坐标 |
| `/red_circle_position` | `geometry_msgs/msg/PointStamped` | 大樱桃/红色圆 3D 坐标 |
| `/visual_target_base` | `robot_msgs/msg/VisualTarget` | 机械臂基座坐标系下的抓取目标 |
| `/robot_arm/executor_status` | `std_msgs/msg/String` | 机械臂执行状态 |
| `/vision/scene_text` | `std_msgs/msg/String` | 给语音侧播报桌面物体 |
| `/vision/dialogue_context` | `std_msgs/msg/String` | 给语音/大模型侧的统一上下文 |
| `/emotion/result` | `std_msgs/msg/String` | 情绪识别节点原始结果 |

## 环境说明

- Ubuntu 22.04
- ROS 2 Humble
- Python 3.10
- RDK X5 BPU / TROS 环境
- 两块 RDK X5 需要位于同一局域网，并保持一致的 `ROS_DOMAIN_ID`

模型文件、第三方 SDK、设备号、CAN 口和实际安装路径可能随实验环境变化，部署前请结合实机配置检查。
