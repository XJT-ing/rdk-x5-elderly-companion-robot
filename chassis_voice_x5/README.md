# Chassis Voice X5 — 底盘控制与语音交互子系统

基于 RDK X5 的 R550 麦克纳姆轮底盘运动控制与 AI 语音交互模块。

## 功能

- R550 麦克纳姆轮底盘全向移动
- 讯飞 AIUI 语音识别（ASR）
- TTS 语音合成播报
- 大模型智能决策（Ollama 本地部署 / 阿里云 DashScope API）
- 激光雷达 SLAM 与自主导航（Nav2）
- 行人跟随、自动回充

## 目录

```
chassis_voice_x5/
└── src/
    ├── turn_on_wheeltec_robot/    # 底盘主控节点
    ├── wheeltec_mic_aiui/          # 讯飞 AIUI 语音交互
    ├── tts_make_ros2/              # TTS 语音合成
    ├── ollama_ros_chat-ros2/       # Ollama 大模型对话
    ├── largemodel/                 # 大模型决策服务
    ├── wheeltec_mic/               # 麦克风采集
    ├── wheeltec_bodyreader/        # 人体/骨骼识别
    ├── navigation2-humble/         # Nav2 导航完整栈
    ├── simple_follower_ros2/       # 行人跟随
    ├── wheeltec_lidar_ros2/        # 激光雷达驱动
    ├── wheeltec_robot_nav2/        # Wheeltec 导航集成
    └── ...                         # 其他传感器驱动
```

## 编译

```bash
mkdir -p ~/chassis_ws/src
cp -r chassis_voice_x5/src/* ~/chassis_ws/src/
cd ~/chassis_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install
```

## 语音交互流程

```
麦克风 → 讯飞AIUI(ASR) → 大模型决策 → 执行命令 → TTS语音反馈
```

支持的大模型：
- Ollama 本地模型（DeepSeek-R1，离线可用）
- 阿里云 DashScope API（在线）

## 注意事项

- 使用前请将 API Key 替换为 YOUR_API_KEY
- WiFi 连接配置请修改为实际网络
