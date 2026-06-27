# RDK X5 Elderly Companion Robot

基于双 RDK X5 的独居老人陪护机器人代码仓库。项目面向居家养老中的生活辅助、情感陪伴和安全守护需求，集成语音交互、底盘移动、SLAM 导航、人体与环境感知、常见物品识别、机械臂抓取递送、情绪识别和跨板 ROS 2 通信。


## 系统定位

机器人采用“底盘语音导航板 + 视觉机械臂执行板”的双 RDK X5 分布式架构：

- `chassis_voice_x5/`：负责 R550 麦克纳姆轮底盘、AI 语音交互、Astra Pro 深度相机、N10P 激光雷达、人体追踪、SLAM/导航、避障和摔倒检测相关代码。
- `vision_arm_x5/`：负责 Gemini2 RGB-D 相机、YOLO 生活物品识别、传统 detector、AIRBOT 六轴机械臂抓取、手眼标定、三维定位和情绪识别相关代码。

两块 RDK X5 在同一局域网和同一 `ROS_DOMAIN_ID` 下通过 ROS 2 DDS 通信，完成任务指令、视觉结果、导航状态、抓取状态和情绪上下文的共享。

## 主要能力

| 能力 | 当前实现内容 | 所属子系统 |
| --- | --- | --- |
| 语音交互 | 唤醒、ASR、LLM 语义理解、TTS 播报、结构化命令发布 | `chassis_voice_x5` |
| 底盘运动 | R550 麦克纳姆轮底盘前后、横移、旋转和速度控制 | `chassis_voice_x5` |
| SLAM 与导航 | 激光雷达/深度相机/里程计/IMU 融合建图、定位、导航和避障 | `chassis_voice_x5` |
| 人体与安全感知 | 人体追踪、异常姿态/摔倒检测相关功能 | `chassis_voice_x5` |
| 物品识别 | YOLO 识别 COCO 常见生活物品，输出二维框和三维坐标 | `vision_arm_x5` |
| 专用目标检测 | 小黄鸭、绿色药盒、大樱桃等目标的传统 detector 检测 | `vision_arm_x5` |
| 机械臂抓取 | Gemini2 深度定位 + 手眼标定 + AIRBOT 抓取状态机 | `vision_arm_x5` |
| 情绪识别 | happy、neutral、surprise、low_mood、negative_distress 五类情绪 | `vision_arm_x5` |
| 跨板协同 | `/command`、视觉上下文、情绪上下文、抓取状态等 ROS 2 topic 通信 | 系统级 |

## 典型任务

### 生活辅助

```text
老人语音提出需求
  -> 语音识别和大模型理解
  -> 底盘移动/导航到服务位置
  -> 视觉识别桌面物品并估计 3D 坐标
  -> AIRBOT 机械臂抓取、抬升、递送
  -> 语音播报任务状态
```

### 桌面物品问答

```text
YOLO 常驻识别桌面物品
  -> vision_voice_bridge.py 整理成中文描述和 JSON
  -> 语音侧订阅 /vision/dialogue_context
  -> 用户询问“桌子上有什么”时进行播报
```

### 情感陪伴与安全守护

```text
相机采集老人面部状态
  -> 情绪识别输出 /emotion/result
  -> 视觉侧转发 /vision/emotion_context
  -> low_mood / negative_distress 触发语音侧关怀或进一步干预
```

## 仓库结构

```text
rdk-x5-elderly-companion-robot/
├── README.md
├── chassis_voice_x5/
│   ├── README.md
│   ├── ros_voice/              # 语音交互、LLM、TTS 和底盘语音控制
│   └── 底盘控制/               # R550 底盘、雷达、导航、SLAM 等代码
└── vision_arm_x5/
    ├── README.md
    ├── Orbbec_ws/              # Gemini2、YOLO、detector、情绪识别
    ├── robot_ws/               # AIRBOT 驱动、消息、抓取任务状态机
    ├── hand_to_eye/            # 手眼标定、坐标桥、跨板上下文桥接
    ├── docs/                   # 视觉机械臂子系统调试说明
    ├── deploy/systemd/
    ├── start_airbot_can1.sh
    └── start_auto_grasp.sh
```

根目录 `docs/` 已删除；项目级技术说明请放在比赛文档材料中。

## 快速入口

### 底盘语音板

```text
chassis_voice_x5/README.md
chassis_voice_x5/ros_voice/README.md
```

### 视觉机械臂板

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

联调时建议按多终端方式分别启动底盘、相机、YOLO、导航、情绪识别、视觉语音桥和抓取管理节点。

## 关键 ROS 2 Topic

| Topic | Type | 说明 |
| --- | --- | --- |
| `/cmd_vel` | `geometry_msgs/msg/Twist` | 底盘速度控制 |
| `/odom` | `nav_msgs/msg/Odometry` | 底盘里程计 |
| `/scan` | `sensor_msgs/msg/LaserScan` | 激光雷达数据 |
| `/voice/command` | `std_msgs/msg/String` | 语音识别后的文本 |
| `/command` | `std_msgs/msg/String` | 大模型生成的结构化任务命令 |
| `/yolo_detections` | `ai_msgs/msg/PerceptionTargets` | YOLO 原始识别结果 |
| `/detect_yolo/apple_position` | `geometry_msgs/msg/PointStamped` | 苹果相机坐标系 3D 坐标 |
| `/detect_yolo/banana_position` | `geometry_msgs/msg/PointStamped` | 香蕉相机坐标系 3D 坐标 |
| `/detect_yolo/bottle_position` | `geometry_msgs/msg/PointStamped` | 瓶子相机坐标系 3D 坐标 |
| `/detect_yolo/cake_position` | `geometry_msgs/msg/PointStamped` | 蛋糕相机坐标系 3D 坐标 |
| `/duck_position` | `geometry_msgs/msg/PointStamped` | 小黄鸭相机坐标系 3D 坐标 |
| `/box_position` | `geometry_msgs/msg/PointStamped` | 绿色药盒相机坐标系 3D 坐标 |
| `/red_circle_position` | `geometry_msgs/msg/PointStamped` | 大樱桃/红色圆相机坐标系 3D 坐标 |
| `/visual_target_base` | `robot_msgs/msg/VisualTarget` | 机械臂基座坐标系下的抓取目标 |
| `/robot_arm/executor_status` | `std_msgs/msg/String` | AIRBOT 执行状态 |
| `/emotion/result` | `std_msgs/msg/String` | 情绪识别原始 JSON |
| `/vision/dialogue_context` | `std_msgs/msg/String` | 视觉与情绪上下文，供语音/大模型侧消费 |

## 环境说明

- Ubuntu 22.04
- ROS 2 Humble
- Python 3.10
- RDK X5 BPU / TROS 环境
- 双 RDK X5 同一局域网、同一 `ROS_DOMAIN_ID`

模型文件、第三方 SDK、设备号、CAN 口和实际安装路径可能随实验环境变化，部署前请结合实机配置检查。
