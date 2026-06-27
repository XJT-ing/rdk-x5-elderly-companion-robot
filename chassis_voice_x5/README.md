# chassis_voice_x5

底盘与语音交互子系统，运行在底盘/语音侧 RDK X5 上。主要负责：

- 语音采集、唤醒词检测、ASR 识别；
- 大模型理解用户意图并生成结构化控制命令；
- TTS 语音播报；
- R550 麦克纳姆轮底盘运动控制；
- 激光雷达建图、定位、导航和避障；
- 通过 ROS 2 DDS 与视觉机械臂侧通信。

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
└── 底盘控制/               # R550 底盘控制、雷达、导航、SLAM 等代码
    ├── launch/
    ├── scripts/
    └── src/
```

## 语音交互入口

语音功能包说明见：

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

## 主要数据流

```text
麦克风
  -> voice_node
  -> /voice/command
  -> brain_node
  -> /command
  -> control_node / 视觉机械臂侧
```

其中：

- `/voice/command`：语音识别后的自然语言文本。
- `/command`：大模型解析后的结构化 JSON 指令。
- `/cmd_vel`：底盘运动控制话题。

## 与视觉机械臂侧接口

### 发布抓取命令

当用户说“抓取苹果”“拿一下香蕉”等指令时，语音侧向 `/command` 发布：

```json
[{"actuator":"机械臂","action":"抓取","params":{"target":"苹果"}}]
```

视觉机械臂侧当前支持：

```text
苹果、香蕉、瓶子、蛋糕、小黄鸭、绿色药盒、大樱桃
```

### 订阅视觉上下文

视觉侧会发布以下 `std_msgs/msg/String` 话题，语音侧可按需要订阅：

```text
/vision/scene_text         # 适合直接播报的桌面物体描述
/vision/scene_objects      # YOLO 识别物体 JSON
/vision/emotion_context    # 情绪识别 JSON
/vision/dialogue_context   # 推荐订阅的统一上下文事件
```

推荐语音/大模型侧优先订阅 `/vision/dialogue_context`，按 `event` 字段区分：

```text
event == "scene_objects" -> 回答“桌子上有什么”
event == "emotion"       -> 判断是否需要情绪干预
```

情绪干预判断字段：

```json
{
  "event": "emotion",
  "emotion": "low_mood",
  "intervention_required": true
}
```

## 常用检查

```bash
ros2 topic list
ros2 topic echo /voice/command
ros2 topic echo /command
ros2 topic echo /vision/dialogue_context
```

底盘控制检查：

```bash
ros2 topic echo /cmd_vel
```

## 注意事项

- 两块 RDK X5 需要处于同一局域网。
- 两侧 `ROS_DOMAIN_ID` 必须一致。
- 语音侧只负责发布命令和消费视觉上下文，不需要启动 YOLO、detector 或机械臂节点。
- 视觉机械臂侧的运行方式见 `vision_arm_x5/README.md`。
