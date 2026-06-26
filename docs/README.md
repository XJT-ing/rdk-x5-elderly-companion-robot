# docs — 项目文档目录

本目录用于存放“基于 RDK X5 的集成多模态感知与智能决策的独居老人陪护机器人”项目的补充说明文档，方便比赛评审和后续开发者快速理解系统架构、硬件组成、软件部署、运行流程和典型任务。

## 1. 文档定位

根目录 `README.md` 用于快速介绍整个项目，两个子系统目录中的 README 用于说明具体代码和运行方式：

* `chassis_voice_x5/README.md`：底盘控制与语音交互子系统说明
* `vision_arm_x5/README.md`：RGB-D 视觉感知与 AIRBOT 机械臂抓取子系统说明

本目录 `docs/` 用于放置更详细的项目级文档，例如系统架构、硬件连接、部署步骤、任务流程、调试方法和常见问题等。

## 2. 建议文档结构

后续可根据比赛提交和项目展示需要，逐步补充以下文档：

```text
docs/
├── README.md                   # 本文件，说明 docs 目录用途
├── system_architecture.md       # 系统总体架构说明
├── hardware_connection.md       # 硬件连接与设备组成说明
├── deployment_guide.md          # 软件环境配置、编译与部署说明
├── task_flow.md                 # 语音取物、主动陪护等典型任务流程
├── ros2_topics.md               # 关键 ROS 2 话题、消息类型与通信关系
├── handeye_calibration.md       # Gemini2 与 AIRBOT 机械臂手眼标定说明
└── troubleshooting.md           # 常见问题与排查方法
```

## 3. 系统架构文档建议

`system_architecture.md` 可重点说明：

1. 为什么采用双 RDK X5 分布式架构；
2. 底盘语音 X5 与视觉机械臂 X5 的职责划分；
3. 两块 RDK X5 如何通过 ROS 2 DDS 进行多机通信；
4. 语音、底盘、视觉、机械臂、情绪识别之间的数据流；
5. 系统在独居老人陪护场景中的完整闭环。

建议配合 `assets/system_architecture.png` 展示系统框图。

## 4. 硬件连接文档建议

`hardware_connection.md` 可重点说明：

1. RDK X5 与 R550 麦克纳姆轮底盘的连接方式；
2. 麦克风阵列、扬声器、激光雷达、IMU、Astra Pro 的连接方式；
3. 另一块 RDK X5 与 Orbbec Gemini2、AIRBOT Play 机械臂、G2 夹爪的连接方式；
4. CAN 设备名称、USB 设备、网络配置等注意事项；
5. 上电顺序和安全注意事项。

## 5. 部署运行文档建议

`deployment_guide.md` 可重点说明：

1. Ubuntu 22.04 与 ROS 2 Humble 环境配置；
2. `ROS_DOMAIN_ID` 设置；
3. `chassis_voice_x5` 的编译与启动；
4. `vision_arm_x5` 的编译与启动；
5. 两块 RDK X5 的网络连通性检查；
6. 常用检查命令，例如 `ros2 topic list`、`ros2 topic echo` 等。

## 6. 典型任务流程文档建议

`task_flow.md` 可重点说明以下任务：

### 6.1 语音取物任务

```text
老人发出语音指令
        ↓
底盘语音 X5 进行语音识别
        ↓
大模型解析任务意图
        ↓
视觉机械臂 X5 检测目标物品
        ↓
Gemini2 深度图估计目标三维坐标
        ↓
手眼标定结果完成坐标转换
        ↓
AIRBOT 机械臂执行抓取
        ↓
系统语音反馈任务状态
```

### 6.2 主动陪护任务

```text
相机采集人脸图像
        ↓
情绪识别节点输出情绪类别
        ↓
系统判断老人状态
        ↓
语音模块进行主动关怀或提醒
        ↓
必要时触发进一步陪护任务
```

## 7. ROS 2 通信文档建议

`ros2_topics.md` 可记录系统中的关键话题，例如：

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
| `/visual_target_base` | `geometry_msgs/msg/PointStamped` | 统一输出的机械臂基座坐标系目标点  |
| `/emotion/result`     | `std_msgs/msg/String`            | 情绪识别 JSON 结果      |

## 8. 图片与展示素材

项目图片、系统框图、流程图、运行截图建议放在根目录的 `assets/` 文件夹中，例如：

```text
assets/
├── system_architecture.png
├── task_flow.png
├── robot_overview.jpg
├── chassis_voice_x5.jpg
├── vision_arm_x5.jpg
├── grasp_demo.jpg
├── slam_map.png
├── emotion_result.png
└── ros2_topics.png
```
