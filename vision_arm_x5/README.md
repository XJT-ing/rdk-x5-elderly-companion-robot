# Vision Arm X5 — RGB-D 视觉感知与 AIRBOT 机械臂抓取子系统

本目录为独居老人陪护机器人项目中的视觉机械臂子系统，运行在另一块 RDK X5 上，主要负责 Orbbec Gemini2 RGB-D 相机采集、居家物品检测、三维目标定位、手眼标定、AIRBOT Play 六轴机械臂抓取和面部情绪识别。

## 1. 子系统定位

`vision_arm_x5` 是整机系统中的“视觉感知与抓取执行中心”，主要功能包括：

- 启动 Gemini2 RGB-D 相机并发布彩色图、深度图；
- 检测常见居家物品，例如苹果、小鸭、药盒等；
- 根据像素位置和深度信息计算目标三维坐标；
- 通过手眼标定结果将相机坐标转换到机械臂基座坐标系；
- 控制 AIRBOT Play 机械臂和 G2 夹爪执行抓取；
- 识别人脸情绪状态，为主动陪护提供感知结果；
- 通过 ROS 2 DDS 与底盘语音子系统进行任务协同。

## 2. 目录结构

```text
vision_arm_x5/
├── README.md
├── .gitignore
├── Orbbec_ws/                  # Gemini2 相机与视觉检测 ROS 2 工作空间
│   └── src/
│       ├── detect_yolo/        # YOLO 通用物体检测
│       ├── detector/           # 苹果、小鸭、药盒等专用检测节点
│       ├── emotion/            # 情绪识别相关模块
│       ├── emotion_landmark_cpp/
│       └── emotion_local/
├── robot_ws/                   # AIRBOT 机械臂 ROS 2 工作空间
│   └── src/
│       ├── robot_arm_driver/   # 机械臂底层驱动
│       ├── robot_arm_interface/# 机械臂接口封装
│       ├── robot_bringup/      # 启动文件与配置
│       ├── robot_msgs/         # 自定义消息
│       └── robot_tasks/        # 抓取任务状态机
├── hand_to_eye/                # 手眼标定与坐标转换
├── docs/                       # 子系统说明文档
├── deploy/systemd/             # systemd 部署文件
├── start_airbot_can1.sh        # AIRBOT 服务启动脚本
└── start_auto_grasp.sh         # 自动抓取链路启动脚本
