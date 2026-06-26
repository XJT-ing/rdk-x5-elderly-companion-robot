#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
sound_bodyfollower: 语音驱动的人体跟踪 launch 文件。
以 bodyfollow.launch.py 为基础，增加 sound_bodyfollower 节点。
sound_bodyfollower 订阅 /command 话题，收到 actuator="底盘"、
action="人体跟踪"、params 含 "开始" 的指令后，才拉起 bodyreader 跟随节点组。
"""
import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    return LaunchDescription([
        # 初始化小车底盘
        # (跟随节点组由 sound_bodyfollower 收到语音指令后通过
        #  ros2 launch bodyreader bodyfollow.launch.py 拉起)
        # ── 语音控制节点 ─────────────────────────────────────────────
        Node(
            package="bodyreader",
            executable="sound_bodyfollower_node.py",
            name="sound_bodyfollower",
            output="screen",
        ),
    ])
