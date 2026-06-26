````markdown
# 基于 RDK X5 的集成多模态感知与智能决策的独居老人陪护机器人

> 嵌入式芯片与系统设计竞赛应用赛道作品源码仓库  
> 项目方向：智能机器人 / 智慧养老 / 多模态感知 / 端侧智能决策

## 1. 项目概述

本项目面向独居老人居家陪护场景，设计并实现了一套基于双 RDK X5 的分布式多模态陪护机器人系统。系统由底盘语音子系统和视觉机械臂子系统组成，通过 ROS 2 DDS 多机通信实现跨设备协同，能够完成语音交互、底盘移动、环境感知、物品识别、三维定位、机械臂抓取递送、情绪识别和安全陪护等任务。

系统采用“双 RDK X5 + ROS 2 Humble”的分布式架构：

- `chassis_voice_x5`：底盘控制与语音交互子系统，负责 R550 麦克纳姆轮底盘运动控制、激光雷达导航、语音识别、语音播报和大模型决策。
- `vision_arm_x5`：视觉感知与机械臂抓取子系统，负责 Orbbec Gemini2 RGB-D 相机采集、居家物品检测、三维坐标估计、手眼标定、AIRBOT Play 六轴机械臂抓取和面部情绪识别。
- 两块 RDK X5 通过 ROS 2 DDS 在同一局域网内通信，实现语音指令、目标位置、抓取状态和反馈信息的协同。

## 2. 应用场景

本项目主要面向独居老人家庭环境，重点解决以下问题：

1. 老人通过自然语音向机器人发出指令，例如“帮我拿苹果”“请过来一下”。
2. 机器人根据语音识别结果和大模型决策结果，完成底盘移动、任务解析和语音反馈。
3. 视觉机械臂子系统识别桌面上的常见生活物品，并估计目标在机械臂基座坐标系下的位置。
4. AIRBOT Play 机械臂根据目标坐标执行抓取、抬升和递送动作。
5. 系统可进行面部情绪识别，为主动陪护和异常状态提醒提供感知基础。
6. 底盘侧结合激光雷达、SLAM 和 Nav2，可支持室内导航、避障和移动陪护。

## 3. 系统功能

| 序号 | 功能模块 | 主要内容 | 负责子系统 |
|---|---|---|---|
| 1 | 底盘运动控制 | R550 麦克纳姆轮底盘全向移动、速度控制、里程计反馈 | `chassis_voice_x5` |
| 2 | 语音交互 | 麦克风采音、ASR 语音识别、唤醒词检测、TTS 播报 | `chassis_voice_x5` |
| 3 | 大模型决策 | 基于自然语言理解生成机器人动作指令 | `chassis_voice_x5` |
| 4 | 雷达导航 | 激光雷达建图、定位、Nav2 自主导航与避障 | `chassis_voice_x5` |
| 5 | RGB-D 视觉感知 | Gemini2 彩色图、深度图采集与 ROS 2 发布 | `vision_arm_x5` |
| 6 | 物品检测 | 苹果、小鸭、药盒等居家物品检测与目标像素定位 | `vision_arm_x5` |
| 7 | 三维定位 | 深度融合、相机坐标计算、相机到机械臂基座坐标转换 | `vision_arm_x5` |
| 8 | 机械臂抓取 | AIRBOT Play 机械臂控制、夹爪控制、开放环抓取流程 | `vision_arm_x5` |
| 9 | 情绪识别 | 面部检测、关键点分析、五类情绪识别与 ROS 话题发布 | `vision_arm_x5` |
| 10 | 双板协同 | ROS 2 DDS 多机通信，完成底盘、语音、视觉、机械臂协同 | 系统级 |

## 4. 硬件组成

| 模块 | 硬件 |
|---|---|
| 底盘主控 | RDK X5 |
| 底盘平台 | 轮趣 R550 麦克纳姆轮底盘 |
| 语音交互 | 麦克风阵列、扬声器、讯飞 AIUI / 本地语音模块 |
| 环境感知 | 激光雷达、IMU、Astra Pro 深度相机 |
| 视觉主控 | RDK X5 |
| RGB-D 相机 | Orbbec Gemini2 |
| 机械臂 | AIRBOT Play 六轴机械臂 |
| 末端执行器 | G2 夹爪 |
| 通信方式 | 同一局域网下 ROS 2 DDS 多机通信 |

## 5. 软件架构

```text
┌───────────────────────────────┐
│        chassis_voice_x5        │
│  底盘控制 + 语音交互 + 导航决策  │
├───────────────────────────────┤
│ 麦克风 / ASR / 唤醒词检测       │
│ 大模型语义理解与任务规划        │
│ TTS 语音播报                   │
│ R550 底盘控制                  │
│ LiDAR SLAM / Nav2 导航          │
└───────────────┬───────────────┘
                │ ROS 2 DDS
                │
┌───────────────┴───────────────┐
│         vision_arm_x5          │
│  RGB-D 感知 + 机械臂抓取 + 情绪识别 │
├───────────────────────────────┤
│ Gemini2 图像与深度采集          │
│ YOLO / 颜色阈值物品检测          │
│ 相机坐标到机械臂基座坐标转换     │
│ AIRBOT Play 抓取状态机           │
│ 面部情绪识别                    │
└───────────────────────────────┘
````

## 6. 仓库结构

```text
rdk-x5-elderly-companion-robot/
├── README.md
├── .gitignore
├── chassis_voice_x5/
│   ├── README.md
│   ├── ros_voice/              # ROS 2 语音交互功能包
│   └── 底盘控制/               # R550 底盘控制、雷达、导航、SLAM 等代码
│       ├── launch/
│       ├── scripts/
│       └── src/
├── vision_arm_x5/
│   ├── README.md
│   ├── Orbbec_ws/              # Gemini2 相机与视觉检测 ROS 2 工作空间
│   │   └── src/
│   │       ├── detect_yolo/
│   │       ├── detector/
│   │       ├── emotion/
│   │       ├── emotion_landmark_cpp/
│   │       └── emotion_local/
│   ├── robot_ws/               # AIRBOT 机械臂 ROS 2 工作空间
│   │   └── src/
│   │       ├── robot_arm_driver/
│   │       ├── robot_arm_interface/
│   │       ├── robot_bringup/
│   │       ├── robot_msgs/
│   │       └── robot_tasks/
│   ├── hand_to_eye/            # 手眼标定、坐标转换和验证脚本
│   ├── docs/                   # 视觉机械臂子系统说明文档
│   ├── deploy/systemd/         # systemd 部署相关文件
│   ├── start_airbot_can0.sh
│   └── start_auto_grasp.sh
├── scripts/                    # 系统级启动提示与话题检查脚本
├── docs/                       # 项目级文档说明
└── assets/                     # 项目图片、系统框图、运行效果图等素材说明
```

## 7. 快速开始

### 7.1 环境要求

两块 RDK X5 推荐使用以下软件环境：

* Ubuntu 22.04
* ROS 2 Humble
* Python 3.10
* colcon
* 同一 WiFi / 局域网
* 相同的 `ROS_DOMAIN_ID`

通用 ROS 2 环境配置示例：

```bash
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=0
```

如果两块 RDK X5 之间需要通信，请确保它们处于同一局域网，并且 `ROS_DOMAIN_ID` 保持一致。

### 7.2 底盘语音子系统

详细说明见：

```text
chassis_voice_x5/README.md
```

主要包含：

* `ros_voice/`：语音识别、大模型理解、TTS 播报和底盘语音控制。
* `底盘控制/`：底盘控制、雷达、SLAM、Nav2、跟随等功能代码。

### 7.3 视觉机械臂子系统

详细说明见：

```text
vision_arm_x5/README.md
```

主要包含：

* `Orbbec_ws/`：Gemini2 相机、目标检测、情绪识别相关 ROS 2 节点。
* `robot_ws/`：AIRBOT 机械臂驱动、接口封装、抓取任务状态机。
* `hand_to_eye/`：手眼标定和坐标转换脚本。

## 8. 系统级启动参考

底盘语音 X5：

```bash
bash scripts/start_chassis_voice.sh
```

视觉机械臂 X5：

```bash
bash scripts/start_vision_arm.sh
```

检查系统话题：

```bash
bash scripts/check_system_topics.sh
```

说明：`scripts/` 中的脚本主要用于提示和检查。由于不同实验环境下工作空间路径、设备号、CAN 口、模型路径可能不同，正式运行前需要结合实际部署路径进行调整。

## 9. 关键 ROS 2 话题

| 话题                    | 类型                               | 说明                |
| --------------------- | -------------------------------- | ----------------- |
| `/cmd_vel`            | `geometry_msgs/msg/Twist`        | 底盘速度控制            |
| `/scan`               | `sensor_msgs/msg/LaserScan`      | 激光雷达数据            |
| `/odom`               | `nav_msgs/msg/Odometry`          | 底盘里程计             |
| `/voice/command`      | `std_msgs/msg/String`            | 语音识别后的文本指令        |
| `/command`            | `std_msgs/msg/String`            | 大模型生成的结构化控制命令     |
| `/apple_position`     | `geometry_msgs/msg/PointStamped` | 苹果目标在相机坐标系下的位置    |
| `/duck_position_base` | `geometry_msgs/msg/PointStamped` | 小鸭目标在机械臂基座坐标系下的位置 |
| `/box_position_base`  | `geometry_msgs/msg/PointStamped` | 药盒目标在机械臂基座坐标系下的位置 |
| `/visual_target_base` | `geometry_msgs/msg/PointStamped` | 视觉目标在基座坐标系下的统一输出  |
| `/emotion/result`     | `std_msgs/msg/String`            | 情绪识别 JSON 结果      |

```
```
