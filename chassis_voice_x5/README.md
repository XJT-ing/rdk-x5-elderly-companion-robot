# chassis_voice_x5

底盘、导航与语音交互子系统，运行在底盘侧 RDK X5 上。它是整机的“移动与交互中心”，负责让机器人听懂指令、移动到目标区域、感知室内环境，并与视觉机械臂侧协同完成生活辅助和安全守护任务。

## 子系统职责

- 语音采集、唤醒词检测、ASR 识别和 TTS 播报；
- 大模型理解用户意图，生成结构化 ROS 2 控制命令；
- R550 麦克纳姆轮底盘运动控制；
- 激光雷达、深度相机、里程计和 IMU 数据接入；
- SLAM 建图、定位、路径规划、避障和定点导航；
- 人体追踪、异常姿态/摔倒检测相关功能；
- 通过 ROS 2 DDS 与视觉机械臂侧共享任务指令和上下文。

## 目录结构

```text
chassis_voice_x5/
├── README.md
├── ros_voice/              # ROS 2 语音交互功能包
│   ├── launch/
│   ├── realtime_asr/
│   ├── ros_voice/
│   ├── test/
│   ├── resource/
│   ├── package.xml
│   ├── setup.py
│   └── README.md
└── 底盘控制/               # R550 底盘、雷达、导航、SLAM 等代码
    ├── launch/
    ├── scripts/
    └── src/
```

## 功能链路

### 语音与任务理解

```text
麦克风
  -> voice_node
  -> /voice/command
  -> brain_node
  -> /command
  -> 底盘控制 / 视觉机械臂侧
```

`/voice/command` 保存语音识别文本，`/command` 保存大模型生成的结构化任务 JSON。底盘侧可以直接执行移动类任务，也可以把抓取、查询、陪护等任务交给视觉机械臂侧继续处理。

### 底盘与导航

底盘侧负责接收 `/cmd_vel` 并驱动 R550 麦克纳姆轮底盘运动，同时发布里程计、IMU、TF 等状态数据。结合 N10P 激光雷达、Astra Pro 深度相机和导航栈，可完成建图、定位、避障和定点导航。

典型数据流：

```text
/cmd_vel
  -> 底盘控制器
  -> /odom, /imu/data_raw, /tf
  -> SLAM / Nav2 / 避障
```

### 安全与陪护

底盘侧传感器用于室内移动、人体跟随和异常状态检测；视觉机械臂侧的情绪识别结果会通过 `/vision/dialogue_context` 返回语音侧，用于主动关怀、安抚或求助式对话。

## 语音功能包入口

详细说明见：

```text
chassis_voice_x5/ros_voice/README.md
```

典型启动方式：

```bash
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 launch ros_voice voice.launch.py
```

如果使用仓库内已有启动脚本，请以 `ros_voice/README.md` 中的说明为准。

## 与视觉机械臂侧接口

### 发布抓取命令

当用户说“抓取苹果”“拿一下香蕉”等指令时，语音/大模型侧向 `/command` 发布：

```json
[{"actuator":"机械臂","action":"抓取","params":{"target":"苹果"}}]
```

视觉机械臂侧当前支持：

```text
苹果、香蕉、瓶子、蛋糕、小黄鸭、绿色药盒、大樱桃
```

### 订阅视觉与情绪上下文

视觉侧会发布：

```text
/vision/scene_text         # 桌面物体中文描述
/vision/scene_objects      # YOLO 识别物体 JSON
/vision/emotion_context    # 情绪识别 JSON
/vision/dialogue_context   # 推荐订阅的统一上下文事件
```

推荐语音/大模型侧优先订阅 `/vision/dialogue_context`：

```text
event == "scene_objects" -> 回答“桌子上有什么”
event == "emotion"       -> 判断是否需要情绪干预
```

当 `intervention_required` 为 `true` 时，语音侧可触发安抚、陪伴、询问是否需要帮助或进一步求助流程。

## 常用检查

```bash
ros2 topic list
ros2 topic echo /voice/command
ros2 topic echo /command
ros2 topic echo /cmd_vel
ros2 topic echo /odom --once
ros2 topic echo /scan --once
ros2 topic echo /vision/dialogue_context
```

## 注意事项

- 两块 RDK X5 需要处于同一局域网。
- 两侧 `ROS_DOMAIN_ID` 必须一致。
- 语音侧负责发布命令和消费上下文，不需要启动 YOLO、detector 或机械臂节点。
- 视觉机械臂侧的运行方式见 `vision_arm_x5/README.md`。
