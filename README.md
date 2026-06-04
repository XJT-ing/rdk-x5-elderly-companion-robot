# 基于 RDK X5 的集成多模态感知与智能决策的独居老人陪护机器人

> 嵌入式芯片与系统设计竞赛应用赛道作品源码仓库

## 项目概述

本项目采用**双 RDK X5 分布式架构**实现独居老人陪护机器人系统：

- **底盘语音 X5**（chassis_voice_x5）：负责 R550 麦克纳姆轮底盘运动控制与 AI 语音交互
- **视觉机械臂 X5**（vision_arm_x5）：负责 Gemini2 RGB-D 视觉感知与 AIRBOT 六轴机械臂抓取

两块 RDK X5 通过 ROS2 DDS 多机通信实现任务协同，完成语音交互、移动控制、生活物品检测、三维定位、机械臂抓取递送和情绪识别等功能。

## 系统功能

| 序号 | 功能 | 负责子系统 |
|------|------|-----------|
| 1 | R550 麦克纳姆轮底盘全向移动控制 | chassis_voice_x5 |
| 2 | AI 语音识别（讯飞 AIUI）与 TTS 语音播报 | chassis_voice_x5 |
| 3 | 大模型智能决策（Ollama 本地 / 阿里云 API） | chassis_voice_x5 |
| 4 | 激光雷达导航与自主避障 | chassis_voice_x5 |
| 5 | Gemini2 RGB-D 图像与深度采集 | vision_arm_x5 |
| 6 | YOLO / 颜色检测器居家物品识别与三维定位 | vision_arm_x5 |
| 7 | AIRBOT 六轴机械臂自主抓取与递送 | vision_arm_x5 |
| 8 | 面部情绪识别（5 类情绪） | vision_arm_x5 |
| 9 | 双 RDK X5 ROS2 DDS 多机通信 | 系统级 |

## 仓库结构

```
rdk-x5-elderly-companion-robot/
├── README.md                        # 本文件 - 项目总说明
├── chassis_voice_x5/                # 底盘控制与语音交互子系统
│   ├── README.md
│   └── src/                         # ROS2 Humble 工作空间源码
│       ├── turn_on_wheeltec_robot/  # 底盘主控
│       ├── wheeltec_mic_aiui/       # 讯飞 AIUI 语音识别
│       ├── tts_make_ros2/           # TTS 语音合成
│       ├── ollama_ros_chat-ros2/    # 大模型对话
│       ├── largemodel/              # 大模型决策服务
│       ├── wheeltec_mic/            # 麦克风采集
│       ├── wheeltec_bodyreader/     # 人体识别
│       ├── navigation2-humble/      # Nav2 导航栈
│       ├── simple_follower_ros2/    # 行人跟随
│       ├── wheeltec_lidar_ros2/     # 激光雷达驱动
│       ├── wheeltec_robot_nav2/     # Wheeltec 导航集成
│       ├── wheeltec_robot_slam/     # SLAM
│       └── ...                      # 其他驱动与功能包
│
├── vision_arm_x5/                   # Gemini2 视觉感知与 AIRBOT 机械臂子系统
│   ├── README.md                    # 子系统详细说明
│   ├── Orbbec_ws/                   # Orbbec 相机 ROS2 工作空间
│   │   └── src/
│   │       ├── detect_yolo/         # YOLO 通用检测
│   │       ├── detector/            # 颜色专用检测器
│   │       ├── emotion_local/       # 情绪识别融合节点
│   │       └── emotion_landmark_cpp/# 人脸关键点检测
│   ├── robot_ws/                    # 机械臂 ROS2 工作空间
│   │   └── src/
│   │       ├── robot_arm_driver/    # 机械臂驱动
│   │       ├── robot_arm_interface/ # AIRBOT SDK 封装
│   │       ├── robot_bringup/       # Launch 与配置
│   │       ├── robot_msgs/          # 自定义消息
│   │       └── robot_tasks/         # 抓取任务状态机
│   ├── hand_to_eye/                 # 手眼标定与坐标转换
│   ├── docs/                        # 子系统文档
│   ├── start_auto_grasp.sh          # 全链路一键启动
│   └── start_airbot_can0.sh         # AIRBOT 服务启动
│
├── docs/                            # 项目文档
├── scripts/                         # 常用启动与检查脚本
└── assets/                          # 图片与图表素材
```

## 硬件架构

```
┌─────────────────────────────────────────────────┐
│                  系统硬件架构                      │
├─────────────────────────────────────────────────┤
│                                                   │
│  ┌─────────────────┐    ┌─────────────────┐      │
│  │   RDK X5 #1     │    │   RDK X5 #2     │      │
│  │  (chassis_voice)│    │  (vision_arm)   │      │
│  │                 │    │                 │      │
│  │  ├─ 语音板      │    │  ├─ Gemini2相机  │      │
│  │  ├─ 麦克风阵列  │    │  ├─ AIRBOT机械臂 │      │
│  │  ├─ 扬声器      │    │  └─ WiFi         │      │
│  │  ├─ LiDAR       │    │                 │      │
│  │  ├─ IMU         │    └────────┬────────┘      │
│  │  ├─ 电机驱动    │             │               │
│  │  └─ WiFi        │             │               │
│  └────────┬────────┘             │               │
│           │                      │               │
│           └───── ROS2 DDS ───────┘               │
│                  (WiFi 多机通信)                   │
└─────────────────────────────────────────────────┘
```

## 软件架构

```
┌─────────── chassis_voice_x5 ───────────┐
│                                         │
│  麦克风 → 讯飞AIUI → 大模型决策          │
│     ↓               ↓                   │
│  ASR文本         行动指令               │
│                      ↓                  │
│              底盘Nav2导航执行            │
│                      ↓                  │
│              TTS语音播报反馈             │
│                                         │
└──────────────┬──────────────────────────┘
               │
          ROS2 DDS
               │
┌──────────────┴────── vision_arm_x5 ────┐
│                                         │
│  Gemini2 → YOLO/颜色检测 → 3D定位       │
│                ↓                        │
│          坐标转换桥 (相机→base_link)     │
│                ↓                        │
│          抓取状态机 → 机械臂执行          │
│                ↓                        │
│          情绪识别 (主动交互)              │
│                                         │
└─────────────────────────────────────────┘
```

## 快速开始

### 环境要求

- 2 台 RDK X5 主控板
- Ubuntu 22.04 + ROS2 Humble
- 同一 WiFi 网络（ROS_DOMAIN_ID 一致）

### 编译

参考各子系统 README：

- [chassis_voice_x5 编译说明](chassis_voice_x5/README.md)
- [vision_arm_x5 编译说明](vision_arm_x5/README.md)

### 启动

```bash
# 底盘语音 X5 上运行
bash scripts/start_chassis_voice.sh

# 视觉机械臂 X5 上运行
bash scripts/start_vision_arm.sh

# 检查所有话题是否正常
bash scripts/check_system_topics.sh
```

## 注意事项

- 启动前确保两块 RDK X5 在同一局域网，且 ROS_DOMAIN_ID 设置一致
- 语音功能的 API Key 请替换为 YOUR_API_KEY 后使用
- 视觉抓取前需先启动 AIRBOT 服务并确认 CAN 通信正常
- 详细说明请参阅各子系统的 README
